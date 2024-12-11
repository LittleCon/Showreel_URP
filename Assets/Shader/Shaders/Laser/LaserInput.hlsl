#ifndef QC_LASER_INPUT_INCLUDED
#define QC_LASER_INPUT_INCLUDED

CBUFFER_START(UnityPerMaterial)
half4 _BaseMap_ST;
half4 _SpeedMainTexUVNoiseZW;
half4 _DistortionSpeedXYPowerZ;
half4 _Mask_ST;
half4 _Noise_ST;
half4 _Flow_ST;
half4 _Color;
half _Emission;
half _Opacity;
half _DissolveProcess;
CBUFFER_END


TEXTURE2D(_BaseMap);            SAMPLER(sampler_BaseMap);
TEXTURE2D(_Mask);               SAMPLER(sampler_Mask);
TEXTURE2D(_Noise);               SAMPLER(sampler_Noise);
TEXTURE2D(_Flow);               SAMPLER(sampler_Flow);
#endif