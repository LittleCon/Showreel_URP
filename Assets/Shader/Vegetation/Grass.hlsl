#ifndef GRASS_MAIN
#define GRASS_MAIN

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 normalWS:TEXCOORD1;
    float3 color:TEXCOORD2;
};

struct GrassBlade {

    float3 position;
    float3 surfaceNorm;
    float3 color;
    float2 facing;
    float windStrength;
    float hash;
    float height;
    float width;
    float tile;
    float bend;
    float sideCurve;
    float rotAngle;
    float clumpColorDistanceFade;

};

StructuredBuffer<float3>_VertexPosBuffer;
StructuredBuffer<float4>_VertexColorsBuffer;
StructuredBuffer<float2>_VertexUVsBuffer;
StructuredBuffer<int>_VertexIndexBuffer;
StructuredBuffer<GrassBlade>_GrassBladeBuffer;

CBUFFER_START(TERRAIN)
float _P1Flexibility;
float _P2Flexibility;
float _WeightP1;
float _WindControl;
float _WaveAmplitude;
float _WaveSpeed;
float _WavePower;
float _SinOffsetRange;
float _PushTipOscillationForward;
float _TaperAmount;
CBUFFER_END
TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);

void GenerateBezierControlPos(GrassBlade grassBlade, float bezierT,inout float3 bezCtrlOffsetDir,inout float3 p1,inout float3 p2,inout float3 p3)
{
    float p3y = grassBlade.tile * grassBlade.height;
    float p3x = sqrt(grassBlade.height * grassBlade.height - p3y * p3y);
    p3 = float3(-p3x, p3y, 0);

    bezCtrlOffsetDir = normalize(cross(normalize(p3), float3(0, 0, 1)));
    p1 = p3 * _WeightP1;
    p2 = p3 * (1- _WeightP1);
    p1 += bezCtrlOffsetDir * grassBlade.bend * _P1Flexibility;
    p2 += bezCtrlOffsetDir * grassBlade.bend * _P2Flexibility;
     
}

void ApplyWind(GrassBlade grassBlade, float3 bezCtrlOffsetDir,inout float3 p2,inout float3 p3)
{
    //_WindControl 控制风浪的影响程度
    float waveAmplitude = lerp(0, _WaveAmplitude, _WindControl);
    float waveSpeed = lerp(0, _WaveSpeed, _WindControl);
    float mult = 1 - grassBlade.bend;
    float weightP2 = 1 - _WeightP1;
    float p2Offset = pow(weightP2, _WavePower) * (waveAmplitude * 0.01) * sin((_Time.y + grassBlade.hash * 2 * 3.1415) * waveSpeed + weightP2 * 2 * 3.1415 * _SinOffsetRange) * grassBlade.windStrength;
    float p3Offset =(waveAmplitude * 0.01) * sin((_Time.y + grassBlade.hash * 2 * 3.1415) * waveSpeed +2 * 3.1415 * _SinOffsetRange) * grassBlade.windStrength;
    //_PushTipOscillationForward控制摆动风前后方向
    p3Offset = (p3Offset -_PushTipOscillationForward * mult *  waveAmplitude * 0.01) *0.5;
    p2 += bezCtrlOffsetDir * p2Offset;
    p3 += bezCtrlOffsetDir * p3Offset;
}

Varyings vert(uint vertexID:SV_VertexID, uint instanceID : SV_InstanceID)
{
    Varyings output;
    
    //获取顶点数据
    int vertexIndex = _VertexIndexBuffer[vertexID];
    float3 positionOS = _VertexPosBuffer[vertexIndex];
    float4 vertexColor = _VertexColorsBuffer[vertexIndex];
    float2 uv = _VertexUVsBuffer[vertexIndex];

    float bezierT = vertexColor.r;
    float side = vertexColor.g*2-1;

    GrassBlade grassBlade = _GrassBladeBuffer[instanceID];

    //计算贝塞尔控制点位置
    float3 p0 = 0;
    float3 p1 = 0;
    float3 p2 = 0;
    float3 p3=0;
    float3 bezCtrlOffsetDir;

    GenerateBezierControlPos(grassBlade, bezierT, bezCtrlOffsetDir,p1,p2,p3);
    ApplyWind(grassBlade, bezCtrlOffsetDir, p2, p3);

    p0 = 0;
    //各个顶点的贝塞尔偏移
    float3 bezierOffset = cubicBezier(p0, p1, p2, p3, bezierT);



    
    float width = (grassBlade.width) * (1 - _TaperAmount * bezierT);
    newPos.z += side * width;
    output.positionCS = mul(UNITY_MATRIX_MVP, float4(positionOS+ bezierOffset, 1));
    output.color = bezCtrlOffsetDir;
    return output;
}

float4 frag(Varyings i) : SV_Target
{
    // sample the texture
    float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex,i.uv);
    return float4(i.color,1);
}

#endif