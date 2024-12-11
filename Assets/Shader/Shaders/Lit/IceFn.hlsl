struct IceInputData
{
    // 当前相机的世界空间位置
    float3 cameraPosition;
    // 模型表面着色点的世界空间位置
    float3 positionWS;
    // 世界空间的视觉方向，模型着色点指向相机的方向
    float3 viewDirectionWS;
    // 切线空间的视觉方向，是viewDirectionWS的不同空间描述
    float3 viewDirectionTS;
    // 世界空间的顶点法线方向
    float3 vertexNormalWS;
    // 世界空间的像素法线方向（包含法线贴图信息）
    float3 pixelNormalWS;
    // 切线空间的法线方向
    float3 normalTS;
    // 系统的运行时间
    float time;
};

half3 BlendAngleCorrectedNormals(half3 baseNormal, half3 additionalNormal)
{
    baseNormal.b += 1.0;
    additionalNormal.rg *= -1.0;
    half d = dot(baseNormal, additionalNormal);
    half3 tempBase = baseNormal * d;
    half3 tempAdd = additionalNormal * baseNormal.b;
    return tempBase - tempAdd;
}

void EffectNormal(float3x3 t2w, float2 uv, out half3 normalTS, out half3 normalWS)
{
    normalTS = half3(0, 0, 1);
    normalWS = TransformTangentToWorld(normalTS, t2w);
}

void InitializeIceData(Varyings input, out IceInputData inputData)
{
    inputData = (IceInputData)0;

    // 切线空间到世界空间的转换矩阵，由于每个顶点的切线坐标不一样，因此无法通过Unity统一传递过来，需要每个顶点去计算
    float3x3 t2w = float3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);
    inputData.cameraPosition = GetCameraPositionWS();
    inputData.positionWS = input.positionWS;
    // 在顶点着色器已经计算出来并储存在相关通道上
    inputData.viewDirectionWS = normalize(float3(input.normalWS.w, input.tangentWS.w, input.bitangentWS.w));
    inputData.viewDirectionTS = TransformWorldToTangent(inputData.viewDirectionWS, t2w);
    inputData.vertexNormalWS = normalize(input.normalWS.xyz);
    inputData.normalTS = half3(0, 0, 1);
    inputData.pixelNormalWS = TransformTangentToWorld(inputData.normalTS, t2w);
    // _Time是Unity传递过来的时间参数，x:t/20 y:t z:t*2 w:t*3
    inputData.time = _Time.x;
}

half Pow5(half x)
{
    return x * x * x * x * x;
}

//////////////////// Reflection
half4 EffectReflection(IceInputData inputData)
{
    half4 color = SAMPLE_TEXTURECUBE_LOD(_ReflectionTexture,SamplerState_Linear_Repeat,reflect(-inputData.viewDirectionWS, inputData.pixelNormalWS),0);

    // Fresnel
    // ((n1 - n2)/(n1 + n2))^2，n1是空气的折射率1.0，n2是冰的折射率1.333
    half R0 = 0.02;
    // cosθ，可以转换成出射方向与法线方向的点乘
    half fresnel = dot(inputData.viewDirectionWS, inputData.pixelNormalWS);
    fresnel = 1 - max(0, fresnel);
    fresnel = Pow5(fresnel);
    fresnel = R0 + (1 - R0) * fresnel;
    // _ReflectionColor 是用来模拟光线吸收
    color.rgb *= fresnel * _ReflectionColor.rgb;
    color.a = fresnel;
    return color;
}

//////////////////// Refraction
half4 EffectRefraction(IceInputData inputData)
{
    // n1/n2
    float w = 0.75;
    float3 L = -inputData.viewDirectionWS;
    float3 N = inputData.pixelNormalWS;
    half3 refractR = SAMPLE_TEXTURECUBE_LOD(_ReflectionTexture,SamplerState_Linear_Repeat,refract(L, N, w),0);
    half3 color = refractR;
    // 模拟颜色吸收，乘以一个折射颜色
    color *= _RefractionColor.rgb;

    return half4(color, 1.0);
}

/////////////// Cracks
half SDF_Raymarching(Texture2D tex, float2 baseUV, float2 offsetUV, int numSteps, half stepSize, half edgeWidth)
{
    // 起始点
    float2 p = baseUV;
    // 归一化后获得方向
    float2 dir = normalize(offsetUV);
    // 起始点到终点的距离
    float value = 0.0;

    for (int i = 0; i < numSteps && i < 10; i++)
    {
        // 通过采样 SDF 图求得当前 p 点与最近裂缝距离
        // 循环内只能对纹理的单一 MipMap 等级采样
        float distance = 1 - SAMPLE_TEXTURE2D_LOD(tex,SamplerState_Linear_Repeat,p,0).r;
        // 加入 edgeWidth 微调宽度效果
        distance -= edgeWidth;

        // 当距离少于0，说明已经击中物体，退出循环
        if (distance < 0.0)
            break;

        // 不为0的时候，记录当前 t ，更新 p 点位置
        float t = distance * stepSize;
        p += dir * t;
        value += t;
    }

    return value;
}

half EffectCracks(Varyings input, IceInputData inputData)
{
    // baseUV 在切线方向上做一些法线的扰动
    float2 baseUV = input.uv1.zw + inputData.normalTS.xy * _CracksDistortion;
    // -Vxy V在物体表面的投影方向的反方向，乘以_CracksHeight做高度微调
    float2 offsetUV = -inputData.viewDirectionTS.xy * _CracksHeight;
    int numSteps = _CracksDepthIterations;
    half stepSize = _CracksDepthStepSize;
    half edgeWidth = _CracksWidth;
    half depthCracks = SDF_Raymarching(_CracksSDFTexture, baseUV, offsetUV, numSteps, stepSize, edgeWidth);
    // viewDirectionTS 在物体表面的投影长度 减去 SDF_Raymarching 的距离
    depthCracks = length(offsetUV) - depthCracks;
    depthCracks *= _CracksDepthScale;
    depthCracks = saturate(depthCracks);

    return depthCracks;
}

///////////////// Dust
half3 EffectDust(Varyings input, IceInputData inputData)
{
    // 基本UV加入时间参数模拟流动效果
    float2 dustUV = input.uv1.xy + inputData.time * _DustTextureUVAnim.xy;
    // 视觉偏移增加 _DustDepthShift 参数作为 k 系数
    float2 viewUV = -inputData.viewDirectionTS.xy * _DustDepthShift;

    // Layer1， _DustLayerBetween 作为两个 Layer 之间的偏差参数控制
    float2 uv1 = dustUV + viewUV * _DustLayerBetween;
    float3 color1 = SAMPLE_TEXTURE2D(_DustTexture, SamplerState_Linear_Repeat,uv1).rgb;
    // Layer2
    float2 uv2 = dustUV + viewUV;
    float3 color2 = SAMPLE_TEXTURE2D(_DustTexture,SamplerState_Linear_Repeat, uv2).rgb;

    // FinalColor
    float3 finalColor = color1 * color1 + color2 * color2;
    finalColor *= _DustColor.rgb;

    return finalColor;
}

/////////////// Thickness
// 从球体相交衍生出来的方法
void IntersectionMesh(float3 rayOrigin, float3 rayDirection, float radius, IceInputData inputData, out float thickness)
{
    // Shading Point 沿法线反方向以半径 radius 长度偏移，得出球心
    float3 offsetPosWS = inputData.positionWS - inputData.vertexNormalWS * radius;
    float3 oc = rayOrigin - offsetPosWS;
    float b = dot(rayDirection, oc);
    float c = dot(oc, oc) - radius * radius;
    float h = b * b - c;
    h = sqrt(h);

    thickness = h * 2;
}

// 获取物体缩放值
float3 ObjectScale()
{
    float3 output = 0;
    float3 worldDir = TransformObjectToWorldDir(float3(1, 0, 0), false);
    output.x = length(worldDir);
    worldDir = TransformObjectToWorldDir(float3(0, 1, 0), false);
    output.y = length(worldDir);
    worldDir = TransformObjectToWorldDir(float3(0, 0, 1), false);
    output.z = length(worldDir);
    return output;
}

// 最终求物体厚度的函数
float ShapeVolume(IceInputData inputData)
{
    float3 rayOrigin = inputData.cameraPosition;
    float3 rayDirection = -inputData.viewDirectionWS;
    float radius = _ShapeSphereRadius * ObjectScale().x;
    float thickness = 0;
    IntersectionMesh(rayOrigin, rayDirection, radius, inputData, thickness);

    return thickness;
}

/////////////// Fog
float ExponentialDensity(float depth, float density)//, bool useExp2
{

    float value = depth * density;
    value = pow(2.718, value);
    value = 1 / value;

    // 深度小于0则跳过
    if (depth <= 0) value = 1;

    return value;
}

// Premultiply Mode
half4 AlphaBlending(half4 srcColor, half4 dstColor)
{
    half4 finalColor;
    half oneMinutesAlpha = 1 - srcColor.a;
    finalColor = srcColor + oneMinutesAlpha * dstColor;
    return finalColor;
}

//////////////////// Diffuse
half4 DiffuseEffect(Varyings input, IceInputData inputData)
{
    // Thickness
    float thickness = ShapeVolume(inputData);
    thickness = max(0, thickness);

    // Fog
    half fog = ExponentialDensity(thickness + _FogBase, _FogDensity);
    fog = 1 - saturate(fog);

    // Dust Color
    half4 dustColor = 1;
    dustColor.rgb = EffectDust(input, inputData) + _FogColor.rgb;
    dustColor.rgb *= fog;
    dustColor.a = fog;

    // Cracks Color
    float depthCracks = EffectCracks(input, inputData);
    half4 cracksColor = _CracksColor;
    cracksColor.a *= depthCracks;
    cracksColor.rgb *= cracksColor.a;

    // Blend Cracks and Dust
    half4 cracksDustColor = AlphaBlending(cracksColor, dustColor);

    // Diffuse
    half4 diffuse = cracksDustColor;

    return diffuse;
}

// 最终合成
void CombinedEffects(Varyings input, IceInputData inputData, out half3 color)
{
    // Diffuse
    half4 diffuse = DiffuseEffect(input, inputData);

    // Reflection
    half4 reflection = EffectReflection(inputData);

    // Refraction
    #if defined(_ENABLE_REFRACTION)
    half4 refraction = EffectRefraction(inputData) * (1 - reflection.a);
    #else
    half4 refraction = half4(0, 0, 0, 1);
    #endif

    // FinalColor
    color = AlphaBlending(diffuse, refraction).rgb;
    color += reflection.rgb;
}

void InitializePreData(Varyings input, half3 normalTS, out PreData preData)
{
    preData = (PreData)0;
    preData.positionWS = input.positionWS;
    half3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);

    float sgn = input.tangentWS.w;      // should be either +1 or -1
    float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
    half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
    preData.tangentToWorld = tangentToWorld;
    preData.normalWS = NormalizeNormalPerPixel(TransformTangentToWorld(normalTS, tangentToWorld));
    preData.viewDirectionWS = viewDirWS;

    #if defined(MAIN_LIGHT_CALCULATE_SHADOWS)
    preData.shadowCoord = TransformWorldToShadowCoord(preData.positionWS);
    #else
    preData.shadowCoord = float4(0, 0, 0, 0);
    #endif
    preData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);

    preData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, input.normalWS);
    preData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
    
}
