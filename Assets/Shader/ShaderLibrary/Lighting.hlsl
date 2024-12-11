#ifndef QC_LIGHTING_INCLUDED
#define QC_LIGHTING_INCLUDED

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/EntityLighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "RealtimeLights.hlsl"
#include "BRDFData.hlsl"
#include "GlobalIllumination.hlsl"

struct LightingData
{
    half3 giColor;
    half3 mainLightColor;
    half3 additionalLightsColor;
    half3 vertexLightingColor;
    half3 emissionColor;
};

#if defined(LIGHTMAP_ON)
    #define DECLARE_LIGHTMAP_OR_SH(lmName, shName, index) float2 lmName : TEXCOORD##index
    #define OUTPUT_LIGHTMAP_UV(lightmapUV, lightmapScaleOffset, OUT) OUT.xy = lightmapUV.xy * lightmapScaleOffset.xy + lightmapScaleOffset.zw;
    #define OUTPUT_SH(normalWS, OUT)
#else
    #define DECLARE_LIGHTMAP_OR_SH(lmName, shName, index) half3 shName : TEXCOORD##index
    #define OUTPUT_LIGHTMAP_UV(lightmapUV, lightmapScaleOffset, OUT)
    #define OUTPUT_SH(normalWS, OUT) OUT.xyz = SampleSHVertex(normalWS)
#endif

LightingData CreateLightingData(PreData preData, SurfaceData surfaceData)
{
    LightingData lightingData;

    lightingData.giColor = preData.bakedGI;
    lightingData.emissionColor = surfaceData.emission;
    lightingData.vertexLightingColor = 0;
    lightingData.mainLightColor = 0;
    lightingData.additionalLightsColor = 0;

    return lightingData;
}


half DirectBRDFSpecular(BRDFData brdfData, half3 normalWS, half3 lightDirectionWS, half3 viewDirectionWS)
{
    float3 lightDirectionWSFloat3 = float3(lightDirectionWS);
    float3 halfDir = SafeNormalize(lightDirectionWSFloat3 + float3(viewDirectionWS));

    float NoH = saturate(dot(float3(normalWS), halfDir));
    half LoH = half(saturate(dot(lightDirectionWSFloat3, halfDir)));

    // GGX Distribution multiplied by combined approximation of Visibility and Fresnel
    // BRDFspec = (D * V * F) / 4.0
    // D = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2
    // V * F = 1.0 / ( LoH^2 * (roughness + 0.5) )
    // See "Optimizing PBR for Mobile" from Siggraph 2015 moving mobile graphics course
    // https://community.arm.com/events/1155

    // Final BRDFspec = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2 * (LoH^2 * (roughness + 0.5) * 4.0)
    // We further optimize a few light invariant terms
    // brdfData.normalizationTerm = (roughness + 0.5) * 4.0 rewritten as roughness * 4.0 + 2.0 to a fit a MAD.
    float d = NoH * NoH * brdfData.roughness2MinusOne + 1.00001f;

    half LoH2 = LoH * LoH;
    half specularTerm = brdfData.roughness2 / ((d * d) * max(0.1h, LoH2) * brdfData.normalizationTerm);

    // On platforms where half actually means something, the denominator has a risk of overflow
    // clamp below was added specifically to "fix" that, but dx compiler (we convert bytecode to metal/gles)
    // sees that specularTerm have only non-negative terms, so it skips max(0,..) in clamp (leaving only min(100,...))
#if REAL_IS_HALF
    specularTerm = specularTerm - HALF_MIN;
    // Update: Conservative bump from 100.0 to 1000.0 to better match the full float specular look.
    // Roughly 65504.0 / 32*2 == 1023.5,
    // or HALF_MAX / ((mobile) MAX_VISIBLE_LIGHTS * 2),
    // to reserve half of the per light range for specular and half for diffuse + indirect + emissive.
    specularTerm = clamp(specularTerm, 0.0, 1000.0); // Prevent FP16 overflow on mobiles
#endif

    return specularTerm;
}

half3 LightingPhysicallyBased(BRDFData brdfData, Light mainLight,
    half3 normalWS, half3 viewDirectionWS)
{
    half3 lightColor = mainLight.color;
    half3 lightDirectionWS = mainLight.direction;
    half lightAttenuation = mainLight.distanceAttenuation*mainLight.shadowAttenuation;
    half NdotL = saturate(dot(normalWS, lightDirectionWS));
    half3 radiance = lightColor * (lightAttenuation * NdotL);

    half3 brdf = brdfData.diffuse;
    brdf += brdfData.specular * DirectBRDFSpecular(brdfData, normalWS, lightDirectionWS, viewDirectionWS);
    return brdf * radiance;
}

half3 CalculateLightingColor(LightingData lightingData, half3 albedo)
{
    half3 lightingColor = 0;

    if (IsOnlyAOLightingFeatureEnabled())
    {
        return lightingData.giColor; // Contains white + AO
    }

    if (IsLightingFeatureEnabled(DEBUGLIGHTINGFEATUREFLAGS_GLOBAL_ILLUMINATION))
    {
        lightingColor += lightingData.giColor;
    }

    if (IsLightingFeatureEnabled(DEBUGLIGHTINGFEATUREFLAGS_MAIN_LIGHT))
    {
        lightingColor += lightingData.mainLightColor;
    }

    if (IsLightingFeatureEnabled(DEBUGLIGHTINGFEATUREFLAGS_ADDITIONAL_LIGHTS))
    {
        lightingColor += lightingData.additionalLightsColor;
    }

    if (IsLightingFeatureEnabled(DEBUGLIGHTINGFEATUREFLAGS_VERTEX_LIGHTING))
    {
        lightingColor += lightingData.vertexLightingColor;
    }

    lightingColor *= albedo;

 
    lightingColor += lightingData.emissionColor;

    return lightingColor;
}

half4 CalculateFinalColor(LightingData lightingData, half alpha)
{
    half3 finalColor = CalculateLightingColor(lightingData, 1);

    return half4(finalColor, alpha);
}

half4 QCFragmentPBR(PreData preData,SurfaceData surfaceData){
    BRDFData brdfData;
    InitializeBRDFData(surfaceData, brdfData);
    half4 shadowMask = CalculateShadowMask(preData);

    uint meshRenderingLayers = GetMeshRenderingLayer();
    Light mainLight = GetMainLight(preData, shadowMask);

    LightingData lightingData = CreateLightingData(preData, surfaceData);

    //项目使用ShadowMask模式，该方法在内部已经被跳过，暂时保留
    MixRealtimeAndBakedGI(mainLight, preData.normalWS, preData.bakedGI);

    lightingData.giColor = GlobalIllumination(brdfData,preData.bakedGI, 1, 
            preData.positionWS,preData.normalWS, preData.viewDirectionWS,preData.normalizedScreenSpaceUV);
#ifdef _LIGHT_LAYERS
    if (IsMatchingLightLayer(mainLight.layerMask, meshRenderingLayers))
#endif
    {
        lightingData.mainLightColor = LightingPhysicallyBased(brdfData,mainLight,
            preData.normalWS, preData.viewDirectionWS);
    }

//附加光源，这个功能仅在编辑器中使用，不能打包
#if defined(_ADDITIONAL_LIGHTS)
    uint pixelLightCount = GetAdditionalLightsCount();

// #if USE_FORWARD_PLUS
//     for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
//     {
//         FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK

//         Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);

// #ifdef _LIGHT_LAYERS
//         if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
// #endif //_LIGHT_LAYERS
//         {
//             lightingData.additionalLightsColor += LightingPhysicallyBased(brdfData, brdfDataClearCoat, light,
//                                                                           inputData.normalWS, inputData.viewDirectionWS,
//                                                                           surfaceData.clearCoatMask, specularHighlightsOff);
//         }
//     }
// #endif//USE_FORWARD_PLUS

    LIGHT_LOOP_BEGIN(pixelLightCount)
    Light light = GetAdditionalLight(lightIndex, preData, shadowMask);

#ifdef _LIGHT_LAYERS
        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
#endif//_LIGHT_LAYERS
        {
            lightingData.additionalLightsColor += LightingPhysicallyBased(brdfData,light,
                preData.normalWS, preData.viewDirectionWS);
        }
    LIGHT_LOOP_END
#endif//_ADDITIONAL_LIGHTS

// #if defined(_ADDITIONAL_LIGHTS_VERTEX)
//     lightingData.vertexLightingColor += preData.vertexLighting * brdfData.diffuse;
// #endif

#if REAL_IS_HALF
    // Clamp any half.inf+ to HALF_MAX
    return min(CalculateFinalColor(lightingData, surfaceData.alpha), HALF_MAX);
#else
    return CalculateFinalColor(lightingData, surfaceData.alpha);
#endif
}


half3 HalfLambertDiffuse(Light lightData,half3 normalWS)
{
    return  (dot(normalWS,lightData.direction)*0.5+0.5)*lightData.color;
}

half3 BlinnPhongSpecular(Light lightData,half3 normalWS,half3 viewDir,half gloss)
{
    float3 halfDir = normalize(lightData.direction+viewDir);
    return lightData.color.rgb *  pow(saturate(dot(normalWS , halfDir)),1);
}

#endif