#ifndef QC_ParallaDecal_INPUT_INCLUDED
#define QC_ParallaDecal_INPUT_INCLUDED
CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    half _Height;
    half _StepsBin;
    half _Steps;
    half _Cutout;
CBUFFER_END
            
TEXTURE2D(_BaseMap);SAMPLER(sampler_BaseMap);
TEXTURE2D(_HeightMap); SAMPLER(sampler_HeightMap);
TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);

#endif