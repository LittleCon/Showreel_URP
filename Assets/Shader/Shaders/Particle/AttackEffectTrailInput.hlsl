#ifndef QC_PARTICLE_TRAIL_INPUT_INCLUDED
#define QC_PARTICLE_TRAIL_INPUT_INCLUDED


CBUFFER_START(UnityPerMaterial)
half4 _BaseColor;
half4 _MainTiling;
half4 _TextureMaskAlpha_ST;
half _MainTexturePower;
half _InvFade;
half _EmissiveMultiply;
half _OpacityMultiply;
half _TimeScale1;
half _TimeScale2;
CBUFFER_END


TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
TEXTURE2D(_TextureMaskAlpha);  SAMPLER(sampler_TextureMaskAlpha);

#endif