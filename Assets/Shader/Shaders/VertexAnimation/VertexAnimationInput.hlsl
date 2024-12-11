#ifndef FC_VertexAnimation_INPUT_INCLUDED
#define FC_VertexAnimation_INPUT_INCLUDED
CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    
    //BaseProperty
    half   _ZWrite;
    half   _ZTest;
    half   _Surface;
    half   _AlphaClip;
    half   _Clip;
    half   _Blend;
    half   _BlendAdavant;
CBUFFER_END
            
TEXTURE2D(_BaseMap);SAMPLER(sampler_BaseMap);

#endif