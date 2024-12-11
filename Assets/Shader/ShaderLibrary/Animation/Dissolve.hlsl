#ifndef DISSOLVE_ANIMATION_INPUT
#define DISSOLVE_ANIMATION_INPUT
#include "../Common.hlsl"

struct DissolveData
{
    half4 emberColor;
    half4 burnColor;
    float  animationTilling;
    float  minValue;
    float  maxValue;
    float  invertDir;
    float  dissolveAmount;
    float  scrollSpeed;
    float  burnWidth;
    float  burnOffset;
    float  emberWidth;
    float  noiseStrength;
    float  burnHardNess;
    float  emberHardNess;
};

TEXTURE2D(_GuideNoise);         SAMPLER(sampler_GuideNoise);

DissolveData InitDissolveData(half4 emberColor,half4 burnColor,float  animationTilling,
    float  minValue,
    float  maxValue,
    float  invertDir,
    float  dissolveAmount,
    float  scrollSpeed,
    float  burnWidth,
    float  burnOffset,
    float  emberWidth,
    float  noiseStrength,
    float  burnHardNess,
    float  emberHardNess)
{
    DissolveData data=(DissolveData)0;
    data.emberColor=emberColor;
    data.burnColor=burnColor;
    data.animationTilling = animationTilling;
    data.minValue = minValue;
    data.maxValue = maxValue;
    data.invertDir = invertDir;
    data.dissolveAmount = dissolveAmount;
    data.scrollSpeed = scrollSpeed;
    data.burnWidth = burnWidth;
    data.burnOffset = burnOffset;
    data.emberWidth = emberWidth;
    data.noiseStrength = noiseStrength;
    data.burnHardNess = burnHardNess;
    data.emberHardNess = emberHardNess;
    return data;
    
}

inline float NoiseWarpMask(float noise,float noiseStrength,float mask)
{
    return mask-noise*noiseStrength;
}

inline float AdjustHardNess(float burnHardNess,float value)
{
    burnHardNess = burnHardNess*0.5;
    float oneMinusBurnHardNess = 1-burnHardNess;
    return smoothstep(burnHardNess,oneMinusBurnHardNess,value);
}

float ObejctAxisMask(DissolveData data,float3 positionOS)
{
    float2 upDir = float2(data.minValue,data.maxValue);
    float2 downDir = float2(data.maxValue,data.minValue);

    float2 dir = lerp(upDir,downDir,data.invertDir);
    float dirMask = lerp(dir.x,dir.y,data.dissolveAmount);
    
    float axisMask=positionOS.z;
    #if defined(_ANIMATION_AXIS_X)
    axisMask =  positionOS.x;
    #elif defined(_ANIMATION_AXIS_Y)
    axisMask =  positionOS.y;
    #elif defined(_ANIMATION_AXIS_Z)
    axisMask =  positionOS.z;
    #endif
    float mask = axisMask-dirMask;
    return lerp(mask,1-mask,data.invertDir);
    
}

float3 BurnDissolveParam(DissolveData data,float noise,float mask)
{
    float noiseMask=NoiseWarpMask(noise,data.noiseStrength,mask);
    float maskDivideBurnWidth = noiseMask/data.burnWidth;
    float dis = 1-saturate(distance(maskDivideBurnWidth,data.burnOffset));
    float burn =AdjustHardNess(data.burnHardNess,dis);
    float maskDivide = 1-saturate(noiseMask/data.emberWidth);
    float ember = AdjustHardNess(data.emberHardNess,maskDivide);
    return float3(burn,ember,noiseMask);
    
}


float GuideNoise(DissolveData data, float2 uv2, float3 positionOS, float3 positionWS,float3 normalWS)
{
    float time = _Time.y*data.scrollSpeed;
    float3 axis=float3(0,time,0);
    #if defined(_ANIMATION_AXIS_X)
    axis=float3(time,0,0);
    #elif defined(_ANIMATION_AXIS_Y)
    axis = float3(0,time,0);
    #elif defined(_ANIMATION_AXIS_Z)
    axis = float3(0,0,time);
    #endif
    positionWS=GetAbsolutePositionWS(positionWS);
    float3 position=positionWS;
    #if defined(USE_WORLDPOS)
    position=positionWS;
    #elif defined(USE_OBJECTPOS)
    position=positionOS;
    #endif

    position=position+axis;

    //正常采样
    float tex_NR = SAMPLE_TEXTURE2D(_GuideNoise,sampler_GuideNoise,uv2*data.animationTilling).r;
    //三平面映射采样
    float tex_TR =Triplanar(TEXTURE2D_ARGS(_GuideNoise,sampler_GuideNoise),position,normalWS,data.animationTilling*0.1f).r;


    return tex_TR;
    // #ifdef USE_TRIPLANAR
    // return tex_TR;
    // #else
    // return tex_NR;
    // #endif
}

float4 BurnDissolve(DissolveData data,float4 albedo,float2 uv2,float3 positionOS,float3 positionWS,float3 normalWS)
{
    float guideNoise = GuideNoise(data,uv2,positionOS,positionWS,normalWS);
    float pointMask = ObejctAxisMask(data,positionOS);
    float3 burnDissolveData=BurnDissolveParam(data,guideNoise,pointMask);
    float3 dissolveColor= lerp(albedo.rgb,data.emberColor,burnDissolveData.y);
    dissolveColor = lerp(dissolveColor,data.burnColor,burnDissolveData.x);
    return float4(dissolveColor,burnDissolveData.z*albedo.a);
}

// float StandardDissolveAlpha(float edgeWidth,float dissolveAmount,float noise)
// {
//     float dissolveAmount40 =dissolveAmount*40;
//     edgeWidth *=dissolveAmount40;
//
//     float oneMinusMul = 1.0f-edgeWidth;
//     float dissloveAmountSub = dissolveAmount-edgeWidth;
//
//     float remapValue = Remap(dissloveAmountSub,float2(0,oneMinusMul),float2(0,1));
//
//     float clampNoise = clamp(noise,0,0.99);
//
//     return step(remapValue,clampNoise);
// }
//
// float4 StandardDissolve(TEXTURE2D_PARAM(Tex, sampler_Tex),float tilling,float scrollSpeed,float edgeWidth,float dissolveAmount,float4 dissolveColor,
//         float2 uv2,float3 positionOS,float3 positionWS,float3 normalWS)
// {
//     float guideNoise = GuideNoise(TEXTURE2D_ARGS(Tex,sampler_Tex),tilling,scrollSpeed,uv2,positionOS,positionWS,normalWS);
//     float alpha = StandardDissolveAlpha(edgeWidth,dissolveAmount,guideNoise);
//     float clampNoise = clamp(guideNoise,0,1);
//     float stepValue = step(clampNoise,dissolveAmount);
//     dissolveColor = lerp(dissolveColor,float4(0,0,0,0),stepValue);
//     return float4(dissolveColor.rgb,alpha);
// }
//
//
// float4 StandardDissolve(DissolveAnimationData data)
// {
//     return StandardDissolve(TEXTURE2D_ARGS(_GuideNoise,sampler_GuideNoise),data.tilling,data.scrollSpeed,
//             data.edgeWidth,data.dissolveAmount,data.dissolveColor,data.uv2,data.positionOS,data.positionWS,data.normalWS);
// }


#endif