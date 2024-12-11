#ifndef QC_LITFORWARD_PASS_INCLUDED
#define QC_LITFORWARD_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
#include "../../ShaderLibrary/PreData.hlsl"
#include "../../ShaderLibrary/Lighting.hlsl"
#include "../../ShaderLibrary/Attributes.hlsl"
#include "../../ShaderLibrary/DBuffer.hlsl"

#ifdef _ANIMATION_ON
#include "../../ShaderLibrary/Animation/Dissolve.hlsl"

#endif


struct Varyings
{
    float2 uv                       : TEXCOORD0;
    float3 positionWS               : TEXCOORD1;
    float3 normalWS                 : TEXCOORD2;
    half4  tangentWS                 : TEXCOORD3;    // xyz: tangent, w: sign
    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 4);
    float4 positionCS               : SV_POSITION;
    half   fogFactor                 : TEXCOORD5;
    float3 positionOS                : TEXCOORD6;
    half   dis                       : TEXCOORD7;
    float4 screenPos                 : TEXCOORD8;
    UNITY_VERTEX_OUTPUT_STEREO
};

void InitializePreData(Varyings input, half3 normalTS, out PreData preData)
{
    preData = (PreData)0;
    preData.positionWS = input.positionWS;
    half3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
 

#if defined(_NORMALMAP) || defined(_DETAIL)
    float sgn = input.tangentWS.w;      // should be either +1 or -1
    float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
    half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);

    #if defined(_NORMALMAP)
    preData.tangentToWorld = tangentToWorld;
    #endif
    preData.normalWS = TransformTangentToWorld(normalTS, tangentToWorld);
#else
    preData.normalWS = input.normalWS;
#endif

    preData.normalWS = NormalizeNormalPerPixel(preData.normalWS);
    preData.viewDirectionWS = viewDirWS;

#if defined(MAIN_LIGHT_CALCULATE_SHADOWS)
    preData.shadowCoord = TransformWorldToShadowCoord(preData.positionWS);
#else
    preData.shadowCoord = float4(0, 0, 0, 0);
#endif
preData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
//DYNAMICLIGHTMAP_ON目前没有启用

preData.bakedGI = lerp(float4(0,0,0,0),SAMPLE_GI(input.staticLightmapUV, input.vertexSH, preData.normalWS),_LightMapStrength);

preData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
    
}

Varyings LitPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;
     UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    output.uv = input.texcoord;
    output.normalWS = normalInput.normalWS;
    real sign = input.tangentOS.w * GetOddNegativeScale();
    half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
    output.tangentWS = tangentWS;
    output.positionOS= input.positionOS;
    output.positionWS = vertexInput.positionWS;
    output.positionCS = vertexInput.positionCS;
    output.screenPos = ComputeScreenPos(output.positionCS);
    float3 center = mul(unity_ObjectToWorld , float4(0,0,0,1)).xyz;
    center.y += _CharPosAdjust;
    output.dis =length(_WorldSpaceCameraPos - center);
    output.fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
    OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);
    return output;
                
}
float4 LitPassFragment(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    SurfaceData surfaceData;
    #ifdef _ANIMATION_ON
        float2 uv = input.uv* _Tiliing.xy + _Tiliing.zw;
        DissolveData data = InitDissolveData(_EmberColor,_BurnColor,_AnimationTilling,_MinValue,_MaxValue,_InvertDir,_DissolveAmount,_ScrollSpeed,
            _BurnWidth,_BurnOffset,_EmberWidth,_NoiseStrength,_BurnHardNess,_EmberHardNess);
        half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
        float4 dissolveColor=BurnDissolve(data,albedoAlpha,input.uv,TransformWorldToObject(input.positionWS),input.positionWS,input.normalWS);

        
        InitializeLitSurfaceData(dissolveColor,input.uv,surfaceData);
    #else
        InitializeLitSurfaceData(input.uv,surfaceData);
    #endif
    PreData preData;
    InitializePreData(input,surfaceData.normalTS,preData);

    #ifdef _DBUFFER
        ApplyDecalToSurfaceData(input.positionCS, surfaceData, preData);
    #endif
    
    half4 color = QCFragmentPBR(preData, surfaceData);
    half fogCoord= InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactor);

    #if defined(_FRESNEL)
        half fresnel = FresnelEffect(preData.normalWS,preData.viewDirectionWS,_FresnelPow);
        half4 ramp = SAMPLE_TEXTURE2D(_FresnelRamp, sampler_FresnelRamp, half2(fresnel,0.5));
        half4 fresnelResult = lerp(fresnel.xxxx,ramp,_FresnelRampOn);
        color.rgb = MixFog(color.rgb, fogCoord) + fresnelResult  * _FresnelColor;
    #else
        color.rgb = MixFog(color.rgb, fogCoord);
    #endif

    #if defined(_FRESNEL)
        color.a = OutputAlpha(color.a *fresnel, IsSurfaceTypeTransparent(_Surface));
    #else
        color.a = OutputAlpha(color.a, IsSurfaceTypeTransparent(_Surface));
    #endif

    #if defined(_ENABLE_DITHER)
    float fade = 1- smoothstep(0,_FadeDistance,input.dis);
    float dis = step(input.dis - _DispearDistance,0);
    half dispear = lerp(_TilingValue,_TilingValue*10 ,dis);
    float2 screenUV = input.screenPos.xy/input.screenPos.w ; 
    half clipValue =(1- SAMPLE_TEXTURE2D(_TilingTex ,sampler_TilingTex ,screenUV* 100 * dispear ).r)-0.5;
    clip(clipValue * fade);
    #endif

    
    return color ;


 
}

#endif