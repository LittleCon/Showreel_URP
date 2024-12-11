#ifndef QC_RefelctionPlane_INPUT_INCLUDED
#define QC_RefelctionPlane_INPUT_INCLUDED
CBUFFER_START(UnityPerMaterial)
    float4 _NormalMap_ST;
    float4 _BaseColor;
    half4 _Speed;
    half4 _Offset;
    half _NormalStrength;

CBUFFER_END
            
//TEXTURE2D(_BaseMap);SAMPLER(sampler_BaseMap);
TEXTURE2D(_NormalMap);SAMPLER(sampler_NormalMap);
TEXTURE2D(_ReflectionRT);SAMPLER(sampler_ReflectionRT);

#endif