#ifndef ICE_INPUT
#define ICE_INPUT
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
//#include "Assets/Shader/Shaders/ShaderLibrary/Common.hlsl"
#include "../../ShaderLibrary/SurfaceData.hlsl"
#include "../../ShaderLibrary/SurfaceInput.hlsl"

CBUFFER_START(UnityPerMaterial)
    half4 _BaseColor;
    half4 _BaseMap_ST;
    half4 _NormalTiliing;
    float4 _DustTexture_ST;
    float4 _CracksSDFTexture_ST;
    half4 _FogColor;
    half4 _DustColor;
    half4 _DustTextureUVAnim;
    half4 _CracksColor;
    half4 _RefractionColor;
    half4 _ReflectionColor;
    half _Metallic;
    half _Smoothness;
    half _OcclusionStrength;
    half _NormalStrength;
    half _FogBase;
    half _FogDensity;
    half _ShapeSphereRadius;
    half _DustDepthShift;
    half _DustLayerBetween;
    half _CracksDepthIterations;
    half _CracksDepthScale;
    half _CracksDepthStepSize;
    half _CracksDistortion;
    half _CracksHeight;
    half _CracksWidth;
    half _FresnelPower;
    half _FresnelBias;
CBUFFER_END

TEXTURE2D(_BaseMap);
TEXTURE2D(_MASMap);             
TEXTURE2D(_NormalMap);
TEXTURE2D (_DustTexture);
TEXTURE2D  (_CracksSDFTexture);
TEXTURECUBE(_ReflectionTexture);
TEXTURE2D (_MaskMap);
SAMPLER(SamplerState_Linear_Repeat);

#endif

inline void InitializeLitSurfaceData(float2 uv,out SurfaceData surfaceData)
{
    uv = uv;
    float2 normalUV = uv*_NormalTiliing.xy+_NormalTiliing.zw;
    half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, SamplerState_Linear_Repeat));
    half3 MSAmap = SAMPLE_TEXTURE2D(_MASMap, SamplerState_Linear_Repeat, uv).rgb;
    _Smoothness = max(0.02f, _Smoothness);
    surfaceData.alpha = albedoAlpha.a;
    surfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb ;
    surfaceData.roughness = saturate(1 - _Smoothness * MSAmap.g);
    surfaceData.metallic = saturate(_Metallic * MSAmap.r);
    surfaceData.occlusion = saturate(lerp(1, MSAmap.b, _OcclusionStrength));
    surfaceData.smoothness = _Smoothness;
    surfaceData.normalTS = SampleNormal(normalUV, TEXTURE2D_ARGS(_NormalMap, SamplerState_Linear_Repeat), _NormalStrength);
    surfaceData.emission = 0;
}