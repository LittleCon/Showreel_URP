#ifndef QC_ParallaDecal_PASS_INCLUDED
#define QC_ParallaDecal_PASS_INCLUDED
struct Attributes
{
    float4 positionOS : POSITION;
    float4 normalOS   :NORMAL;
    float4 tangentOS   :TANGENT;
    float2 uv : TEXCOORD0;
};

struct Varyings
{
    float2 uv : TEXCOORD0;
    float3 normalWS :TEXCOORD1;
    float3 tangentWS : TEXCOORD2;
    float3 binormalWS :TEXCOORD3;
    float3 viewDirTS : TEXCOORD4;
    float3 positionWS :TEXCOORD5;
    float4 positionCS : SV_POSITION;
};

           

Varyings vert (Attributes input)
{
    Varyings output;
    VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS);
    VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS);
    output.positionCS = positionInputs.positionCS;
    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
    output.normalWS = normalInputs.normalWS;
    float3 biTangent= cross(normalize(input.normalOS), normalize(input.tangentOS))*input.tangentOS.w;
    output.positionWS = positionInputs.positionWS;
    output.tangentWS = normalInputs.tangentWS;
    output.binormalWS = normalInputs.bitangentWS;

    float3x3 tranformWorldToTs = float3x3(input.tangentOS.xyz,biTangent,input.normalOS.xyz);
    output.viewDirTS = mul(tranformWorldToTs,GetObjectSpaceNormalizeViewDir(input.positionOS));
    
    return output;
}

float4 frag (Varyings input) : SV_Target
{

    float3 p =float3(input.uv,0);
    //从相机指向片元
    float3 reverseViewDirTS = normalize(-1*input.viewDirTS);
    //观察方向的Z分量代表了其在深度（即垂直于屏幕方向上的投影）
    //当Z接近0的时候 即当前片元的位置几乎平行于相机
    //当Z接近1的时候，即当前片元的位置几乎垂直与相机平面
    reverseViewDirTS.z=abs(reverseViewDirTS.z);

    //取反，再累乘（平滑处理）
    float depthBias = 1.0-reverseViewDirTS.z;
    depthBias=depthBias*depthBias*depthBias;
    depthBias=1.0-depthBias*depthBias;
    
    reverseViewDirTS.xy*=depthBias;
    reverseViewDirTS.xy *= _Height;
    reverseViewDirTS/=reverseViewDirTS.z*_Steps;

    int idx;
    for(idx=0;idx<_Steps;idx++)
    {
        float height = SAMPLE_TEXTURE2D(_HeightMap,sampler_HeightMap,p).r;
        if(p.z<height) p+=reverseViewDirTS;
    }

    for(idx=0;idx<_StepsBin;idx++)
    {
        reverseViewDirTS*=0.5;
        float height = SAMPLE_TEXTURE2D(_HeightMap,sampler_HeightMap,p).r;
        if(p.z<height)p+=reverseViewDirTS;
        else p-=reverseViewDirTS;
    }

    half3 normal = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap,sampler_NormalMap,p.xy));
    float3x3 worldToTangentMatrix = float3x3(input.tangentWS,input.binormalWS,input.normalWS);
    normal = -normalize(mul(normal,worldToTangentMatrix));

    float4 finalColor;

    finalColor.a=1;
    finalColor.rgb=SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,p);

    finalColor.a = SAMPLE_TEXTURE2D(_HeightMap,sampler_HeightMap,p).a>0.5?1:0;
    finalColor.a*=saturate(SAMPLE_TEXTURE2D(_HeightMap,sampler_HeightMap,p).r-1+_Cutout*2);
    
    return max(0.00001, finalColor);
}
#endif