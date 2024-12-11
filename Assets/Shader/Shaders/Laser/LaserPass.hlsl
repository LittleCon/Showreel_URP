#ifndef QC_LASER_PASS_INCLUDED
#define QC_LASER_PASS_INCLUDED

struct Attributes 
{
	float4 positionOS : POSITION;
	half4 color : COLOR;
	float4 texcoord : TEXCOORD0;
};

struct Varyings 
{
	float4 positionCS : SV_POSITION;
	float3 positionWS :TEXCOORD1;
	half4 color : COLOR;
	float4 texcoord : TEXCOORD0;
};	

Varyings LaserVert (Attributes input)
{
    Varyings o;
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    o.positionCS = vertexInput.positionCS;
    o.color = input.color;
    o.texcoord = input.texcoord;
	o.positionWS = vertexInput.positionWS;
    return o;
}

float4 LaserFrag (Varyings input) : SV_Target
{
	float2 uv = input.texcoord.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;
	float2 speedUV = ( 1.0 * _Time.y * float2(_SpeedMainTexUVNoiseZW.x , _SpeedMainTexUVNoiseZW.y) + uv);
	float2 distortionUV = (float2(_DistortionSpeedXYPowerZ.x , _DistortionSpeedXYPowerZ.y));
	float3 flowUV = float3(input.texcoord.xy * _Flow_ST.xy + _Flow_ST.zw,input.texcoord.z);
	flowUV.xy = ( 1.0 * _Time.y * distortionUV + (flowUV).xy);

	float2 uv_Mask = input.texcoord.xy * _Mask_ST.xy + _Mask_ST.zw;
    //SAMPLE_TEXTURE2D(albedoAlphaMap, sampler_albedoAlphaMap, uv)
	float4 mask = SAMPLE_TEXTURE2D(_Mask, sampler_Mask, uv_Mask);
	float4 baseMap = SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap,( speedUV - ( (( SAMPLE_TEXTURE2D( _Flow,sampler_Flow, flowUV ) * mask )).rg * _DistortionSpeedXYPowerZ.z ) ) );
	
	float2 noiseUV = input.texcoord.xy * _Noise_ST.xy + _Noise_ST.zw;
	noiseUV = ( 1.0 * _Time.y * float2(_SpeedMainTexUVNoiseZW.z , _SpeedMainTexUVNoiseZW.w) + noiseUV);
	float4 noise = SAMPLE_TEXTURE2D( _Noise, sampler_Noise,noiseUV );
	
	float3 albedo = (( baseMap * noise * _Color * input.color )).rgb;
	float4 temp_cast_0 = ((1.0 + (flowUV.z - 0.0) * (0.0 - 1.0) / (1.0 - 0.0))).xxxx;
	float4 clampResult38 = clamp( ( mask - temp_cast_0 ) , float4( 0,0,0,0 ) , float4( 1,1,1,1 ) );
	float4 clampResult40 = clamp( ( mask * clampResult38 ) , float4( 0,0,0,0 ) , float4( 1,1,1,1 ) );

	float dissolve = step(0,input.positionWS.y-_DissolveProcess);
	float4 finalColor = (float4(( lerp(albedo,( albedo * (clampResult40).rgb ),0) * _Emission ) , ( baseMap.a * noise.a * _Color.a * input.color.a * _Opacity*dissolve )));
	return finalColor;
}
#endif