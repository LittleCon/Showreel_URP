#ifndef QC_COMMON_INCLUDE
#define QC_COMMON_INCLUDE

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

float4 Triplanar(TEXTURE2D_PARAM(Tex, sampler_Tex),float3 position,float3 normal,float tile)
{
    float3 uv = position*tile;
    float3 blend = pow(abs(normal), 0);
    blend/=dot(blend,1.0);
    float4 x = SAMPLE_TEXTURE2D(Tex,sampler_Tex,uv.zy);
    float4 y = SAMPLE_TEXTURE2D(Tex,sampler_Tex,uv.xz);
    float4 z = SAMPLE_TEXTURE2D(Tex,sampler_Tex,uv.xy);
    float4 result= x*blend.x+y*blend.y+z*blend.z;
    return result;
}

float Remap(float inValue,float2 inMinMax,float2 outMinMax)
{
    return outMinMax.x + (inValue - inMinMax.x) * (outMinMax.y - outMinMax.x) / (inMinMax.y - inMinMax.x);
}




#endif