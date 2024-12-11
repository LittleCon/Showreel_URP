#ifndef HOLOGRAPHIC_PROJECTION_PASS_H
#define HOLOGRAPHIC_PROJECTION_PASS_H
#include "HolographicProjectionInput.hlsl"
#include "../../ShaderLibrary/Lighting.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS   : NORMAL;
    float2 texcoord   : TEXCOORD0;
    float4 tangent    : TANGENT;
    float4 color      : COLOR;
};


struct Varyings
{
    float4 positionCS : SV_POSITION;
    float3 positionWS : TEXCOORD0;
    float4 normalWS   : NORMAL;
    float3 tangentWS   : TANGENT;
    float3 binormalWS  : TEXCOORD1;
    float2 uv : TEXCOORD3;
};


Varyings vert(Attributes input)
{
    Varyings output;
    float3 positionWS=TransformObjectToWorld(input.positionOS);
    float lineAxisMask = GetAxisMask(input.positionOS,positionWS);
    float lineDensity = lineAxisMask * _LineDensity;

    float4 positionOS = input.positionOS;
    #if defined(_VOXELIZATIONFEATURE_ON)
    float3 vertexOffset = lerp(input.positionOS,round(input.positionOS.xyz*_Voxelization/_Voxelization),_VoxelizationAffect);
    positionOS+=vertexOffset;
    #endif
    
    
    VertexPositionInputs positionInputs = GetVertexPositionInputs(positionOS);
    VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS);
    output.positionCS = positionInputs.positionCS;
    output.positionWS = positionInputs.positionWS;
    output.normalWS.xyz = normalInputs.normalWS;
    output.tangentWS.xyz = normalInputs.tangentWS;
    output.normalWS.w = lineDensity;
    float sign = input.tangent.w*unity_WorldTransformParams.w;
    output.binormalWS = cross(output.normalWS.xyz,output.tangentWS)*sign;
    output.uv =input.texcoord;
    return output;
}

float4 frag(Varyings input):SV_TARGET{
    float3 viewDirWS = normalize( _WorldSpaceCameraPos.xyz-input.positionWS.xyz);

    float nDotv = dot(input.normalWS,viewDirWS);
    float fresnel = _FresnelScale*pow(max(1.0-nDotv,0.0001),_FresnelPower);

    float3 normalMap = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap,sampler_NormalMap,input.uv),_NormalScale);
    normalMap.z= lerp(1,normalMap.z,saturate(_NormalScale));

    float3 tanToWorld0 = float3(input.tangentWS.x,input.binormalWS.x,input.normalWS.x);
    float3 tanToWorld1 = float3(input.tangentWS.y,input.binormalWS.y,input.normalWS.y);
    float3 tanToWorld2 = float3(input.tangentWS.z,input.binormalWS.z,input.normalWS.z);

    float3 viewDirTS = normalize(tanToWorld0*viewDirWS.x+tanToWorld1*viewDirWS.y+tanToWorld2*viewDirWS.z);

    float nDotv2 = dot(normalMap,viewDirTS);

    float normalEffect = 1.0-lerp(1.0,(nDotv2+1.0)/2,_NormalEffect);
    float fAddn = normalEffect+fresnel;
    float fresnelAlpha = 0;//_FresnelAlphaScale*pow(max(1.0-nDotv,0.0001),_FresnelAlphaPower);
    float fAddnAlpha = clamp(fresnelAlpha+normalEffect,0.0,1.0);
    float4 fresnelColor = 0;//_BaseColor*fAddnAlpha*fAddn;
    
    float lineDensity = input.normalWS.w;    
    
    //lineParam1 = float4(lineSpeed,lineDensity,lineFrequency,lineHardness)
    //lineParam2 = float4(lineAlha,lineInvertedThickness,input.uv)
    
    float4 line1Param1 = float4(_Line1Speed*_Time.x,lineDensity,_Line1Frequency,_Line1HardNess);
    float4 line1Param2 = float4(_Line1Alpha,_Line1InvertedThinckness,input.uv);
    float4 line1Color = GetLineNoiseColor(TEXTURE2D_ARGS(_Line1Map,sampler_Line1Map),line1Param1,line1Param2);
    line1Color.rgb = line1Color.x*_Line1Color;
    float4 line2Param1 = float4(_Line2Speed*_Time.x,lineDensity,_Line2Frequency,_Line2HardNess);
    float4 line2Param2 = float4(_Line2Alpha,_Line2InvertedThinckness,input.uv);
    float4 line2Color = GetLineNoiseColor(TEXTURE2D_ARGS(_Line2Map,sampler_Line2Map),line2Param1,line2Param2);
    // float2 line1UV = (lineDensity*_LineFrequency+lineSpeed+_RandomOffset).xx;
    //
    // float line1 = clamp((SAMPLE_TEXTURE2D(_Line1Tex,sampler_Line1Tex,input.uv).r-_Line1InvertedThickness)*_Line1Hardness,0,1);
    // float4 line1Color = float4(line1*_BaseColor.rgb,line1*_Line1Alpha);

    float4 lineColor = float4(line1Color.rgb*line2Color.rgb,line1Color.a*line2Color.a+line1Color.a);

    float finalAlpha = clamp(_BaseColor.a+fresnelAlpha+lineColor.a,0,1)*_Alpha;
    float emissionMask = SAMPLE_TEXTURE2D(_EmissionMask,sampler_EmissionMask,input.uv).r;

    float4 finalColor = float4((_BaseColor*emissionMask*(1-line1Color.x)+fresnelColor+float4(lineColor.rgb,0)).rgb,finalAlpha);


    Light lightData = GetMainLight();
    half halfLambert = max(0,dot(lightData.direction,normalize(input.normalWS))+1)*0.5;
    float3 color = finalColor.rgb*lightData.color*halfLambert;
    
    return float4(color,finalAlpha);
    
}
#endif