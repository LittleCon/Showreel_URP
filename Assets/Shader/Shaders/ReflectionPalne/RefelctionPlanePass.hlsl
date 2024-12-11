#ifndef QC_RefelctionPlane_PASS_INCLUDED
#define QC_RefelctionPlane_PASS_INCLUDED

#include "../../ShaderLibrary/Lighting.hlsl"
struct Attributes
{
    float4 positionOS : POSITION;
    float4 normalOS   :NORMAL;
    float4 tangentOS   :TANGENT;
    float2 uv : TEXCOORD0;
};

struct Varyings
{
    float2 uv : TEXCOORD0;
    float3 positionWS :TEXCOORD1;
    float4 positionCS : SV_POSITION;
    float4 screenPos : TEXCOORD2;
};

           

Varyings vert (Attributes input)
{
    Varyings output;
    VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS);
    output.positionCS = positionInputs.positionCS;
    output.uv = TRANSFORM_TEX(input.uv, _NormalMap);
    output.positionWS = positionInputs.positionWS;
    output.screenPos = ComputeScreenPos(output.positionCS);
    return output;
}

float4 frag (Varyings input) : SV_Target
{
    //float4 col = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,input.uv)*_BaseColor;
    float4 SHADOW_COORDS = TransformWorldToShadowCoord(input.positionWS);
    
    half2 speed1 = input.uv+_Time.y*_Speed.xy *0.1;
    half2 speed2 = input.uv+_Time.y*_Speed.zw *0.1;
    float3 normalMapUV1 = normalize(SAMPLE_TEXTURE2D(_NormalMap,sampler_NormalMap,speed1));
    float3 normalMapUV2 = normalize(SAMPLE_TEXTURE2D(_NormalMap,sampler_NormalMap,speed2));
    float3 normalMap1 = normalMapUV1*_NormalStrength;
    float3 normalMap2 = normalMapUV2*_NormalStrength;
    float3 normalMap = (normalMap1+normalMap2)*0.5;
    //input.screenPos.x += pow(_Offset ,2);
    half2 screenUV = input.screenPos.xy / input.positionCS.w;
    half4 reflection_map_color = _ReflectionRT.Sample(sampler_ReflectionRT, screenUV+normalMap*_Offset);
    
    Light lightData = GetMainLight(SHADOW_COORDS);
    float3 viewDirWS = normalize(_WorldSpaceCameraPos.xyz-input.positionWS.xyz);
    
    //half3 lambert = col*HalfLambertDiffuse(lightData,normalMap);
    half3 blinphong = BlinnPhongSpecular(lightData,normalMap,viewDirWS,3);
    //half3 color =lambert+blinphong+reflection_map_color;
    half3 color = blinphong*_BaseColor+reflection_map_color;
    return half4(color,1);
    //return input.screenPos.x;
}
#endif