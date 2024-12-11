#ifndef QC_PREDATA_INCLUDED
#define QC_PREDATA_INCLUDED

//光照计算所需数据
struct PreData{
    float4  positionCS;
    float3  positionWS;
    float3  normalWS;
    float4  shadowCoord;
    half3   viewDirectionWS;
    half3   bakedGI;
    half4   shadowMask;
    float2  normalizedScreenSpaceUV;
    half3x3 tangentToWorld;
};

#endif