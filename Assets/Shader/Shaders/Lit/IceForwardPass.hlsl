#ifndef ICE_FORWARD_PASS
#define ICE_FORWARD_PASS
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
#include "../../ShaderLibrary/PreData.hlsl"
#include "../../ShaderLibrary/Lighting.hlsl"
struct Attributes
{
    float4 positionOS : POSITION;
    float2 uv : TEXCOORD0;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv0 : TEXCOORD0; // xy:uv
    float4 uv1 : TEXCOORD1; // xy:DustTextureUV     zw:CracksSDFTextureUV
    float3 positionWS : TEXCOORD3; // 世界空间的模型顶点位置
    float4 normalWS : TEXCOORD4; // 世界空间的法线方向
    float4 tangentWS : TEXCOORD5; // 世界空间的切线方向
    float4 bitangentWS : TEXCOORD6; // 垂直于法线与切线方向的第三个方向，这三个方向通常用来把法线贴图转换成世界空间
    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 7);
};

#include "IceFn.hlsl"

Varyings IcePassVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

    output.positionCS = vertexInput.positionCS;
    output.positionWS = vertexInput.positionWS;
    output.uv0 = input.uv;
    output.uv1.xy = TRANSFORM_TEX(input.uv, _DustTexture);
    output.uv1.zw = TRANSFORM_TEX(input.uv, _CracksSDFTexture);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    half3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);

    output.normalWS.xyz = normalInput.normalWS;
    output.tangentWS.xyz = normalInput.tangentWS;
    output.bitangentWS.xyz = normalInput.bitangentWS;
    output.normalWS.w = viewDirWS.x;
    output.tangentWS.w = viewDirWS.y;
    output.bitangentWS.w = viewDirWS.z;
    OUTPUT_SH(normalInput.normalWS.xyz, output.vertexSH);

    return output;
}

half4 IcePassFragment(Varyings input) : SV_Target
{
    //emission
    IceInputData inputData;
    InitializeIceData(input, inputData);
    half4 emissionColor = 1;
    CombinedEffects(input, inputData, emissionColor.rgb);
    emissionColor *= SAMPLE_TEXTURE2D(_MaskMap,SamplerState_Linear_Repeat,input.uv0).r;

    //pbr
    SurfaceData surfaceData;
    InitializeLitSurfaceData(input.uv0,surfaceData);
    PreData preData;
    InitializePreData(input,surfaceData.normalTS,preData);
    half4 pbrColor = QCFragmentPBR(preData, surfaceData);

    half4 color = pbrColor+emissionColor;
    return color ;
}
#endif