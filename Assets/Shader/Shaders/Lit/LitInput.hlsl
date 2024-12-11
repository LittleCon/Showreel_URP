#ifndef QC_LIT_INPUT_INCLUDED
#define QC_LIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Assets/Shader/ShaderLibrary/Common.hlsl"

#include "../../ShaderLibrary/SurfaceData.hlsl"
#include "../../ShaderLibrary/SurfaceInput.hlsl"

CBUFFER_START(UnityPerMaterial)

half4 _EmberColor;
half4 _BurnColor;
half4 _BaseColor;
half4 _Tiliing;
half4 _AddColor;
//half4 _SpecularColor;
half4 _EmissionColor;
half4 _BaseMap_ST;
half4 _NormalTiliing;
half4 _FresnelColor;
half4 _TilingValue;
half _FresnelPow;
half _Surface;
half _FresnelSwitch;
half _Animation;
half _LightMapStrength;

half _Clip;
half _Brightness;
half _Metallic;
half _Smoothness;
half _OcclusionStrength;
half _NormalStrength;
half _EmissionStrength;
half _DetailAlbedoMapScale;
half _DetailNormalMapStrength;
half _CharPosAdjust;
half _FadeDistance;
half _DispearDistance;
half _EnableDither;

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
half _FresnelRampOn;

CBUFFER_END


TEXTURE2D(_BaseMap);            SAMPLER(sampler_BaseMap);
TEXTURE2D(_MASMap);             SAMPLER(sampler_MASMap);
TEXTURE2D(_NormalMap);          SAMPLER(sampler_NormalMap);
TEXTURE2D(_EmissionMap);        SAMPLER(sampler_EmissionMap);
TEXTURE2D(_DetailMap);          SAMPLER(sampler_DetailMap);
TEXTURE2D(_DetailNormalMap);    SAMPLER(sampler_DetailNormalMap);
TEXTURE2D(_TilingTex);          SAMPLER(sampler_TilingTex);
TEXTURE2D(_FresnelRamp);        SAMPLER(sampler_FresnelRamp);

half3 ScaleDetailAlbedo(half3 detailAlbedo, half scale)
{
    // detailAlbedo = detailAlbedo * 2.0h - 1.0h;
    // detailAlbedo *= _DetailAlbedoMapScale;
    // detailAlbedo = detailAlbedo * 0.5h + 0.5h;
    // return detailAlbedo * 2.0f;

    // A bit more optimized
    return half(2.0) * detailAlbedo * scale - scale + half(1.0);
}

half3 ApplyDetailNormal(float2 detailUv, half3 normalTS, half detailMask)
{
#if defined(_DETAIL)
    half3 detailNormalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_DetailNormalMap, sampler_DetailNormalMap, detailUv), _DetailNormalMapScale);

    // With UNITY_NO_DXT5nm unpacked vector is not normalized for BlendNormalRNM
    // For visual consistancy we going to do in all cases
    detailNormalTS = normalize(detailNormalTS);

    return lerp(normalTS, BlendNormalRNM(normalTS, detailNormalTS), detailMask); // todo: detailMask should lerp the angle of the quaternion rotation, not the normals
#else
    return normalTS;
#endif
}

half3 ApplyDetailAlbedo(float2 detailUv, half3 albedo,out half detailMask)
{
    detailMask=0;
#if defined(_DETAIL)
    half4 detail = SAMPLE_TEXTURE2D(_DetailMap, sampler_DetailMap, detailUv);
    half3 detailAlbedo = detail.rgb;
    detailMask = detailAlbedo.a;
    // In order to have same performance as builtin, we do scaling only if scale is not 1.0 (Scaled version has 6 additional instructions)
// #if defined(_DETAIL_SCALED)
//     detailAlbedo = ScaleDetailAlbedo(detailAlbedo, _DetailAlbedoMapScale);
// #else
//     detailAlbedo = half(2.0) * detailAlbedo;
// #endif
    detailAlbedo = ScaleDetailAlbedo(detailAlbedo, _DetailAlbedoMapScale);
    return albedo * LerpWhiteTo(detailAlbedo, detailMask);
#else
    return albedo;
#endif
}

inline void InitializeLitSurfaceData(float2 uv,out SurfaceData surfaceData)
{
    uv = uv* _Tiliing.xy + _Tiliing.zw;
    float2 normalUV = uv*_NormalTiliing.xy+_NormalTiliing.zw;
    half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    half3 MSAmap = SAMPLE_TEXTURE2D(_MASMap, sampler_MASMap, uv).rgb;
    _Smoothness = max(0.02f, _Smoothness);
    surfaceData.alpha = Alpha(albedoAlpha.a, _BaseColor, _Clip);
    surfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb * _Brightness + _AddColor.rgb;
    surfaceData.roughness = saturate(1 - _Smoothness * MSAmap.g);
    surfaceData.metallic = saturate(_Metallic * MSAmap.r);
    surfaceData.occlusion = saturate(lerp(1, MSAmap.b, _OcclusionStrength));
    surfaceData.smoothness = _Smoothness;
    surfaceData.normalTS = SampleNormal(normalUV, TEXTURE2D_ARGS(_NormalMap, sampler_NormalMap), _NormalStrength);
    surfaceData.emission = SampleEmission(uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap))*_EmissionStrength;

#if defined(_DETAIL)
    float2 detailUv = uv * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
    half detailMask;
    outSurfaceData.albedo = ApplyDetailAlbedo(detailUv, outSurfaceData.albedo, detailMask);
    outSurfaceData.normalTS = ApplyDetailNormal(detailUv, outSurfaceData.normalTS, detailMask);
#endif
}

inline void InitializeLitSurfaceData(float4 albedoAlpha,float2 uv,out SurfaceData surfaceData)
{
    //uv = uv* _Tiliing.xy + _Tiliing.zw;
    float2 normalUV = uv*_NormalTiliing.xy+_NormalTiliing.zw;
    //half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    half3 MSAmap = SAMPLE_TEXTURE2D(_MASMap, sampler_MASMap, uv).rgb;
    _Smoothness = max(0.02f, _Smoothness);
    surfaceData.alpha = Alpha(albedoAlpha.a, _BaseColor, _Clip);
    surfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb * _Brightness + _AddColor.rgb;
    surfaceData.roughness = saturate(1 - _Smoothness * MSAmap.g);
    surfaceData.metallic = saturate(_Metallic * MSAmap.r);
    surfaceData.occlusion = saturate(lerp(1, MSAmap.b, _OcclusionStrength));
    surfaceData.smoothness = _Smoothness;
    surfaceData.normalTS = SampleNormal(normalUV, TEXTURE2D_ARGS(_NormalMap, sampler_NormalMap), _NormalStrength);
    surfaceData.emission = SampleEmission(uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap))*_EmissionStrength;

    #if defined(_DETAIL)
    float2 detailUv = uv * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
    half detailMask;
    outSurfaceData.albedo = ApplyDetailAlbedo(detailUv, outSurfaceData.albedo, detailMask);
    outSurfaceData.normalTS = ApplyDetailNormal(detailUv, outSurfaceData.normalTS, detailMask);
    #endif
}

#endif