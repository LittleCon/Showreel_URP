struct WaterVertexInput // vert struct
{
	float4	vertex 					: POSITION;		// vertex positions
	float2	texcoord 				: TEXCOORD0;	// local UVs
	UNITY_VERTEX_INPUT_INSTANCE_ID
};


struct WaterVertexOutput // fragment struct
{
	float4	uv 						: TEXCOORD0;	// Geometric UVs stored in xy, and world(pre-waves) in zw
	float3	posWS					: TEXCOORD1;	// world position of the vertices
	half3 	normal 					: NORMAL;		// vert normals
	float3 	viewDir 				: TEXCOORD2;	// view direction
	float3	preWaveSP 				: TEXCOORD3;	// screen position of the verticies before wave distortion
	half2 	fogFactorNoise          : TEXCOORD4;	// x: fogFactor, y: noise
	float4	additionalData			: TEXCOORD5;	// x = distance to surface, y = distance to surface, z = normalized wave height, w = horizontal movement
	half4	shadowCoord				: TEXCOORD6;	// for ssshadows

	float4	clipPos					: SV_POSITION;
	UNITY_VERTEX_INPUT_INSTANCE_ID
	UNITY_VERTEX_OUTPUT_STEREO
};

struct WaveStruct
{
	float3 position;
	float3 normal;
};

struct Wave
{
	half amplitude;
	half direction;
	half wavelength;
	half2 origin;
	half omni;
};


TEXTURE2D(_WaterDepthMap); SAMPLER(sampler_WaterDepthMap_linear_clamp);
TEXTURE2D(_CameraOpaqueTexture); SAMPLER(sampler_CameraOpaqueTexture_linear_clamp);
TEXTURE2D(_AbsorptionScatteringRamp); SAMPLER(sampler_AbsorptionScatteringRamp);
TEXTURE2D(_ReflectionRT); SAMPLER(sampler_ReflectionRT_linear_clamp);
 TEXTURE2D(_DitherPattern); SAMPLER(sampler_DitherPattern);
 TEXTURE2D(_WaterFXMap);
#define SHADOW_ITERATIONS 4
half _MaxDepth;
half4 _VeraslWater_DepthCamParams;
half4 waveData[20];
float _MaxWaveHeight;


StructuredBuffer<Wave> _WaveDataBuffer;
uniform uint 	_WaveCount;


float2 random(float2 st){
    st = float2( dot(st,float2(127.1,311.7)), dot(st,float2(269.5,183.3)) );
    return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
}

float noise (float2 st) {
    float2 i = floor(st);
    float2 f = frac(st);

    float2 u = f*f*(3.0-2.0*f);

    return lerp( lerp( dot( random(i), f),
                     dot( random(i + float2(1.0,0.0) ), f - float2(1.0,0.0) ), u.x),
                lerp( dot( random(i + float2(0.0,1.0) ), f - float2(0.0,1.0) ),
                     dot( random(i + float2(1.0,1.0) ), f - float2(1.0,1.0) ), u.x), u.y);
}

WaveStruct GerstnerWave(float2 pos, float waveCountMulti, half amplitude, half direction, half wavelength, half omni, half2 omniPos)
{
	WaveStruct waveOut;
#if defined(_STATIC_WATER)
	float time = 0;
#else
	float time = _Time.y;
#endif

	////////////////////////////////wave value calculations//////////////////////////
	float3 wave = 0; // wave vector
	float w = 6.28318 / wavelength; // 2pi over wavelength(hardcoded)
	float wSpeed = sqrt(9.8 * w); // frequency of the wave based off wavelength
	float peak = 1.5; // peak value, 1 is the sharpest peaks
	float qi = peak / (amplitude * w * _WaveCount);

	direction = radians(direction); // convert the incoming degrees to radians, for directional waves
	float2 dirWaveInput = float2(sin(direction), cos(direction)) * (1 - omni);
	float2 omniWaveInput = (pos - omniPos) * omni;

	float2 windDir = normalize(dirWaveInput + omniWaveInput); // calculate wind direction
	float dir = dot(windDir, pos - (omniPos * omni)); // calculate a gradient along the wind direction

	////////////////////////////position output calculations/////////////////////////
	float calc = dir * w + -time * wSpeed; // the wave calculation
	float cosCalc = cos(calc); // cosine version(used for horizontal undulation)
	float sinCalc = sin(calc); // sin version(used for vertical undulation)

	// calculate the offsets for the current point
	wave.xz = qi * amplitude * windDir.xy * cosCalc;
	wave.y = ((sinCalc * amplitude)) * waveCountMulti;// the height is divided by the number of waves

	////////////////////////////normal output calculations/////////////////////////
	float wa = w * amplitude;
	// normal vector
	float3 n = float3(-(windDir.xy * wa * cosCalc),
					1-(qi * wa * sinCalc));

	////////////////////////////////assign to output///////////////////////////////
	waveOut.position = wave * saturate(amplitude * 10000);
	waveOut.normal = (n.xzy * waveCountMulti);

	return waveOut;
}



float WaterTextureDepth(float3 posWS)
{
    return (1 - SAMPLE_TEXTURE2D_LOD(_WaterDepthMap, sampler_WaterDepthMap_linear_clamp, posWS.xz * 0.002 + 0.5, 1).r) * (_MaxDepth + _VeraslWater_DepthCamParams.x) - _VeraslWater_DepthCamParams.x;
}

inline void SampleWaves(float3 position, half opacity, out WaveStruct waveOut)
{
	float2 pos = position.xz;
	waveOut.position = 0;
	waveOut.normal = 0;
	float waveCountMulti = 1.0 / _WaveCount;
	float3 opacityMask = saturate(float3(3, 3, 1) * opacity);

	UNITY_LOOP
	for(uint i = 0; i < _WaveCount; i++)
	{
#if defined(USE_STRUCTURED_BUFFER)
		Wave w = _WaveDataBuffer[i];
#else
		Wave w;
		w.amplitude = waveData[i].x;
		w.direction = waveData[i].y;
		w.wavelength = waveData[i].z;
		w.omni = waveData[i].w;
		w.origin = waveData[i + 10].xy;
#endif
		WaveStruct wave = GerstnerWave(pos,
								waveCountMulti,
								w.amplitude,
								w.direction,
								w.wavelength,
								w.omni,
								w.origin); // calculate the wave

		waveOut.position += wave.position; // add the position
		waveOut.normal += wave.normal; // add the normal
	}
	waveOut.position *= opacityMask;
	waveOut.normal *= float3(opacity, 1, opacity);
}

half4 AdditionalData(float3 postionWS, WaveStruct wave)
{
    half4 data = half4(0.0, 0.0, 0.0, 0.0);
    float3 viewPos = TransformWorldToView(postionWS);
	data.x = length(viewPos / viewPos.z);// distance to surface
    data.y = length(GetCameraPositionWS().xyz - postionWS); // local position in camera space
	data.z = wave.position.y / _MaxWaveHeight * 0.5 + 0.5; // encode the normalized wave height into additional data
	data.w = wave.position.x + wave.position.z;
	return data;
}

WaterVertexOutput WaveVertexOperations(WaterVertexOutput input,float4 _CubeWS)
{
#if defined(_STATIC_WATER)
	float time = 0;
#else
	float time = _Time.y;
#endif

    input.normal = float3(0, 1, 0);
	input.fogFactorNoise.y = ((noise((input.posWS.xz * 0.5) + time) + noise((input.posWS.xz * 1) + time)) * 0.25 - 0.5) + 1;

	// Detail UVs
    input.uv.zw = input.posWS.xz * 0.1h + time * 0.05h + (input.fogFactorNoise.y * 0.1);
    input.uv.xy = input.posWS.xz * 0.4h - time.xx * 0.1h + (input.fogFactorNoise.y * 0.2);

	half4 screenUV = ComputeScreenPos(TransformWorldToHClip(input.posWS));
	screenUV.xyz /= screenUV.w;

    // shallows mask
    half waterDepth = WaterTextureDepth(input.posWS);
//custom-begin: Less shallows creep
	//input.posWS.y += pow(saturate((-waterDepth + 1.5) * 0.4), 2);
	input.posWS.y += pow(saturate((-waterDepth + 0.5) * 0.2), 2);
//custom-end:

	//Gerstner here
	WaveStruct wave;
	SampleWaves(input.posWS, saturate((waterDepth * 0.1 + 0.05)), wave);
	input.normal = wave.normal;
    input.posWS += wave.position;

#ifdef SHADER_API_PS4
	input.posWS.y -= 0.5;
#endif

    // Dynamic displacement
	half4 waterFX = SAMPLE_TEXTURE2D_LOD(_WaterFXMap, sampler_LinearClamp, screenUV.xy, 0);
	input.posWS.y += waterFX.w * 2 - 1;
	float dist=distance(input.posWS.xz, _CubeWS.xz) ;
	dist = smoothstep(0.5, 2, dist);
	float mask = 1-dist;
	input.posWS.xz -= mask * _CubeWS.xz;

	// After waves
	input.clipPos = TransformWorldToHClip(input.posWS);
	input.shadowCoord = ComputeScreenPos(input.clipPos);
    input.viewDir = SafeNormalize(_WorldSpaceCameraPos - input.posWS);

    // Fog
	input.fogFactorNoise.x = ComputeFogFactor(input.clipPos.z);
	input.preWaveSP = screenUV.xyz; // pre-displaced screenUVs

	// Additional data
	input.additionalData = AdditionalData(input.posWS, wave);

	// distance blend
	half distanceBlend = saturate(abs(length((_WorldSpaceCameraPos.xz - input.posWS.xz) * 0.005)) - 0.25);
	input.normal = lerp(input.normal, half3(0, 1, 0), distanceBlend);

	return input;
}

// float2 AdjustedDepth(half2 uvs, half4 additionalData)
// {
// 	float rawD = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_WaterDepthMap_linear_clamp, uvs);
// 	float d = LinearEyeDepth(rawD, _ZBufferParams);

// 	// TODO: Changing the usage of UNITY_REVERSED_Z this way to fix testing, but I'm not sure the original code is correct anyway.
// 	// In OpenGL, rawD should already have be remmapped before converting depth to linear eye depth.
// #if UNITY_REVERSED_Z
// 	float offset = 0;
// #else
// 	float offset = 1;
// #endif
// 	//x是水面到水
//  	return float2(d * additionalData.x - additionalData.y, (rawD * -_ProjectionParams.x) + offset);
// }


// float3 WaterDepth(float3 posWS, half4 additionalData, half2 screenUVs)// x = seafloor depth, y = water depth
// {
// 	float3 outDepth = 0;
// 	outDepth.xz = AdjustedDepth(screenUVs, additionalData);
// 	float wd = WaterTextureDepth(posWS);
// 	outDepth.y = wd + posWS.y;
// 	return outDepth;
// }

half2 DistortionUVs(half depth, float3 normalWS)
{
    half3 viewNormal = mul((float3x3)GetWorldToHClipMatrix(), -normalWS).xyz;

    return viewNormal.xz * saturate((depth) * 0.005);
}

half CalculateFresnelTerm(half3 normalWS, half3 viewDirectionWS)
{
    return saturate(pow(1.0 - dot(normalWS, viewDirectionWS), 5));//fresnel TODO - find a better place
}

half SoftShadows(float3 screenUV, float3 positionWS, half3 viewDir, half depth)
{
#if _MAIN_LIGHT_SHADOWS
    half2 jitterUV = screenUV.xy * _ScreenParams.xy *1;
	half shadowAttenuation = 0;

	float loopDiv = 1.0 / SHADOW_ITERATIONS;
	half depthFrac = depth * loopDiv;
	half3 lightOffset = -viewDir * depthFrac;
	for (uint i = 0u; i < SHADOW_ITERATIONS; ++i)
    {
#ifndef _STATIC_WATER
        jitterUV += frac(half2(_Time.x, -_Time.z));
#endif
        float3 jitterTexture = SAMPLE_TEXTURE2D(_DitherPattern, sampler_DitherPattern, jitterUV + i * _ScreenParams.xy).xyz * 2 - 1;
	    half3 j = jitterTexture.xzy * depthFrac * i * 0.1;
	    float3 lightJitter = (positionWS + j) + (lightOffset * (i + jitterTexture.y));
	    shadowAttenuation += SAMPLE_TEXTURE2D_SHADOW(_MainLightShadowmapTexture, sampler_MainLightShadowmapTexture, TransformWorldToShadowCoord(lightJitter));
	}
//custom-begin:
	float4 shadowCoord = TransformWorldToShadowCoord(positionWS);
    bool beyondFar = BEYOND_SHADOW_FAR(shadowCoord); 
    half shadowFade = GetShadowFade(positionWS);
#if defined(_MAIN_LIGHT_SHADOWS_CASCADE)
    shadowFade = shadowCoord.w == 4 ? 1.0h : shadowFade;
#endif
    return beyondFar ? 1.0 : lerp(shadowAttenuation * loopDiv, 1, shadowFade);
//custom-end:
#else
    return 1;
#endif
}

half3 SampleReflections(half3 normalWS, half3 viewDirectionWS, half2 screenUV, half roughness)
{
    half3 reflection = 0;
    half2 refOffset = 0;

#if _REFLECTION_CUBEMAP
    half3 reflectVector = reflect(-viewDirectionWS, normalWS);
    reflection = SAMPLE_TEXTURECUBE(_CubemapTexture, sampler_CubemapTexture, reflectVector).rgb;
#elif _REFLECTION_PROBES
    half3 reflectVector = reflect(-viewDirectionWS, normalWS);
    reflection = GlossyEnvironmentReflection(reflectVector, 0, 1);
#elif _REFLECTION_PLANARREFLECTION

    // get the perspective projection
    float2 p11_22 = float2(unity_CameraInvProjection._11, unity_CameraInvProjection._22) * 10;
    // conver the uvs into view space by "undoing" projection
    float3 viewDir = -(float3((screenUV * 2 - 1) / p11_22, -1));

    half3 viewNormal = mul(normalWS, (float3x3)GetWorldToViewMatrix()).xyz;
    half3 reflectVector = reflect(-viewDir, viewNormal);

    half2 reflectionUV = screenUV + normalWS.zx * half2(0.02, 0.15);
    reflection += SAMPLE_TEXTURE2D_LOD(_ReflectionRT, sampler_ReflectionRT_linear_clamp, reflectionUV, 6 * roughness).rgb;//planar reflection
#endif
    //do backup
    //return reflectVector.yyy;
    return reflection;
}

half3 Absorption(half depth)
{
	return SAMPLE_TEXTURE2D(_AbsorptionScatteringRamp, sampler_AbsorptionScatteringRamp, half2(depth, 0.0h)).rgb;
}

half3 Refraction(half2 distortion, half depth, real depthMulti)
{
	half3 output = SAMPLE_TEXTURE2D_LOD(_CameraOpaqueTexture, sampler_CameraOpaqueTexture_linear_clamp, distortion, depth * 0.25).rgb;
	output *= Absorption((depth) * depthMulti);
	return output;
}