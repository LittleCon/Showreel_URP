#ifndef QC_PARTICLE_TRAIL_PASS_INCLUDED
#define QC_PARTICLE_TRAIL_PASS_INCLUDED


struct Attributes 
{
	float4 positionOS : POSITION;
	half4 color : COLOR;
	float2 uv : TEXCOORD0;
    
	
};

struct Varyings
{
    float4 positionCS               : SV_POSITION;
    float4 uv                       : TEXCOORD0;
    half4 color                     : COLOR;
    float4 positionHCS              :TEXCOORD1;
    float2 baseUV                      :TEXCOORD2;

};



Varyings vert(Attributes input){
    Varyings output;
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    output.positionCS = vertexInput.positionCS;
    output.color = input.color;
    output.uv.xy = input.uv.xy*_MainTiling.xy;
    output.uv.zw = input.uv.xy*_MainTiling.zw;
    output.baseUV.xy= input.uv;
    return output;
}

float4 frag(Varyings input):SV_TARGET
{
    half time = _Time.y*_TimeScale1;
    half2 uv = input.uv.xy+time*float2(-1,0);
    half4 albedo1 = pow(SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,uv),_MainTexturePower.xxxx);
    half time2 = _Time.y*_TimeScale2;
    half2 uv2 = input.uv.zw+float2(-1,0)*time2;
    half4 albedo2 =  pow(SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,uv2),_MainTexturePower.xxxx);

    half4 albedo = albedo1+albedo2;
    half2 maskUV = input.baseUV*_TextureMaskAlpha_ST.xy + _TextureMaskAlpha_ST.zw;
    half mask = SAMPLE_TEXTURE2D( _TextureMaskAlpha, sampler_TextureMaskAlpha,maskUV ).r;
    float4 finalColor = albedo*input.color*_BaseColor*mask;
    finalColor = float4(_EmissiveMultiply*finalColor.rgb,saturate(finalColor.a*_OpacityMultiply));

    return finalColor;
}

#endif