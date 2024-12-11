#ifndef QC_UNLIT_INPUT_INCLUDED
#define QC_UNLIT_INPUT_INCLUDED
#include "../../ShaderLibrary/SurfaceData.hlsl"
//#include "../../ShaderLibrary/SurfaceInput.hlsl"

CBUFFER_START(UnityPerMaterial)
half4 _EmberColor;
half4 _BurnColor;
half4 _BaseColor;
half4 _Tiliing;
half4 _EmissionColor;
half4 _BaseMap_ST;
half _Surface;
half _Clip;
half _EmissionStrength;
half _EmissionHeight;
half _EmissionProcessInv;

half _Animation;
float  _AnimationTilling;
float  _MinValue;
float  _MaxValue;
float  _InvertDir;
float  _DissolveAmount;
float  _ScrollSpeed;
float  _BurnWidth;
float  _BurnOffset;
float  _EmberWidth;
float  _NoiseStrength;
float  _BurnHardNess;
float  _EmberHardNess;
CBUFFER_END

//half _Surface;

TEXTURE2D(_BaseMap);            SAMPLER(sampler_BaseMap);
TEXTURE2D(_EmissionMap);        SAMPLER(sampler_EmissionMap);
#endif

half4 SampleAlbedoAlpha(float2 uv, TEXTURE2D_PARAM(albedoAlphaMap, sampler_albedoAlphaMap))
{
    return half4(SAMPLE_TEXTURE2D(albedoAlphaMap, sampler_albedoAlphaMap, uv));
}

half Alpha(half albedoAlpha, half4 color, half cutoff)
{
    half alpha = albedoAlpha * color.a;

    alpha = AlphaDiscard(alpha, cutoff);

    return alpha;
}

half4 QCFragmentUnlit( SurfaceData surfaceData)
{
    half4 finalColor = half4(surfaceData.albedo + surfaceData.emission, surfaceData.alpha);
    return finalColor;
}

half4 QCFragmentUnlit( half3 color,half3 emission , half alpha)
{
    SurfaceData surfaceData;

    surfaceData.albedo = color;
    surfaceData.alpha = alpha;
#ifndef _EMISSION
    surfaceData.emission = 0;
#else
    surfaceData.emission = emission;
#endif
    surfaceData.metallic = 0;
    surfaceData.occlusion = 1;
    surfaceData.smoothness = 1;
    surfaceData.roughness=1;
    surfaceData.normalTS = half3(0, 0, 1);

    return QCFragmentUnlit(surfaceData);
}
