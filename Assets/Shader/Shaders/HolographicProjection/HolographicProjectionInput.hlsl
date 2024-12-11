#ifndef HOLOGRAPHIC_PROJECTION_INPUT_H
#define HOLOGRAPHIC_PROJECTION_INPUT_H
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
CBUFFER_START(UnityPerMaterial)
float4 _BaseColor;
float4 _Line1Color;
half _Alpha;
half _LineDensity;
half _NormalScale;
half _NormalEffect;
half _Line1Speed;
half _Line1Frequency;
half _Line1HardNess;
half _Line1InvertedThinckness;
half _Line1Alpha;
half _Line2Speed;
half _Line2Frequency;
half _Line2HardNess;
half _Line2InvertedThinckness;
half _Line2Alpha;
half _FresnelPower;
half _FresnelScale;
half _FresnelAlphaPower;
half _FresnelAlphaScale;
half _RandomOffset;
CBUFFER_END

TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
TEXTURE2D(_Line1Map); SAMPLER(sampler_Line1Map);
TEXTURE2D(_Line2Map); SAMPLER(sampler_Line2Map);
TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);
TEXTURE2D(_EmissionMask);SAMPLER(sampler_EmissionMask);

float GetAxisMask(float3 positionOS,float3 positionWS)
{
    float3 position = positionOS;
    // #if defined(_USE_WORLDPOSITION)
    // position = positionWS;
    // #endif

    float axis = position.z;
    #if defined(_AXIS_X)
    axis = position.x;
    #elif defined(_AXIS_Y)
    axis = position.y;
    #elif defined(_AXIS_Z)
    axis = position.z;
    #endif
    
    return position.y;
    
}
//lineParam1 = float4(lineSpeed,lineDensity,lineFrequency,lineHardness)
//lineParam2 = float4(lineAlha,lineInvertedThickness,input.uv)
float4 GetLineNoiseColor(TEXTURE2D_PARAM(_LineTex,sampler_LineTex),float4 lineParam1,float4 lineParam2)
{
    float2 line1UV = (lineParam1.y*lineParam1.z+lineParam1.x+_RandomOffset).xx;

    float line1 = clamp((SAMPLE_TEXTURE2D(_LineTex,sampler_LineTex,line1UV).r-lineParam2.y)*lineParam1.w,0,1);
    return float4(line1.xxx,line1*lineParam2.x);
}
#endif