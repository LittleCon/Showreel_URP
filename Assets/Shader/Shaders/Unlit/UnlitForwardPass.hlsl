#ifndef QC_UNLITFORWARD_PASS_INCLUDED
#define QC_UNLITFORWARD_PASS_INCLUDED

//#ifdef _ANIMATION_ON
#include "../../ShaderLibrary/Animation/Dissolve.hlsl"

//#endif
struct Attributes
{
    float4 positionOS : POSITION;
    float4 uv : TEXCOORD0;
    half4 color : COLOR0;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
};

struct Varyings
{
    float4 uv                       : TEXCOORD0;
    float4 positionCS               : SV_POSITION;
    float3 positionOS               : TEXCOORD1;
    //half   fogFactor                 : TEXCOORD5;
    half4 color : TEXCOORD2;
    float3 positionWS               : TEXCOORD3;
    float3 normalWS                 : TEXCOORD4;
};


Varyings LitPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    output.positionWS = vertexInput.positionWS;
    output.positionCS = vertexInput.positionCS;
    output.normalWS = normalInput.normalWS;
    output.uv.xy = input.uv.xy * _Tiliing.xy + _Tiliing.zw;;
    output.uv.zw = input.uv.xy;
    output.positionOS=input.positionOS;
    output.color = input.color;
    return output;
                
}

float4 LitPassFragment(Varyings input) : SV_Target
{
    half2 uvxy = input.uv.xy;
    half2 uvzw = input.uv.zw;
    half4 texColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uvxy);
    #ifdef _ANIMATION_ON
        DissolveData data = InitDissolveData(_EmberColor,_BurnColor,_AnimationTilling,_MinValue,_MaxValue,_InvertDir,_DissolveAmount,_ScrollSpeed,
            _BurnWidth,_BurnOffset,_EmberWidth,_NoiseStrength,_BurnHardNess,_EmberHardNess);
        half4 albedoAlpha = SampleAlbedoAlpha(uvxy, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
        float4 dissolveColor=BurnDissolve(data,albedoAlpha,input.uv,TransformWorldToObject(input.positionWS),input.positionWS,input.normalWS);
        half3 color = dissolveColor.rgb * _BaseColor.rgb ;
        half alpha = Alpha(dissolveColor.a, _BaseColor, _Clip);
    #else
        half3 color = texColor.rgb * _BaseColor.rgb;
        half alpha = Alpha(texColor.a, _BaseColor, _Clip);
    #endif

    half3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uvzw).rgb * _EmissionColor * _EmissionStrength;

    #if defined(_EMISSION_PROCESSCONTROL)
    half emissionProcessMask=step(input.positionOS.y-_EmissionHeight,0);
    half emissionProcessMaskInv = step(_EmissionHeight-input.positionOS.y,0);
    emissionProcessMask=lerp(emissionProcessMask,emissionProcessMaskInv,_EmissionProcessInv);
    emission*=emissionProcessMask;
    #endif
    #if defined(_ENABLE_VERTEX_COLOR)
    alpha *= input.color.a;
    color *= input.color.rgb;
    emission *= input.color.rgb;
    #endif

    color = AlphaModulate(color, alpha);
    half4 finalColor = QCFragmentUnlit(color,emission, alpha);
    finalColor.a = OutputAlpha(finalColor.a, IsSurfaceTypeTransparent(_Surface));
    return finalColor;
}
#endif