#ifndef VT_FEEDBACK
#define VT_FEEDBACK


Varyings vert(Attributes input)
{
    Varyings output;
    uint instanceID = input.instanceID;
    //将resultPatchMap中的数据读取出来
    uint y = instanceID * 2 / 512;
    uint x = instanceID * 2 - y * 512;
    float2 uv0 = (1.0 / 512) * (uint2(x, y) + 0.5);
    float2 uv1 = (1.0 / 512) * (uint2 (x + 1, y) + 0.5);

    float4 pix0 = SAMPLE_TEXTURE2D_LOD(_ResultPatchMap, sampler_ResultPatchMap, uv0, 0);
    float4 pix1 = SAMPLE_TEXTURE2D_LOD(_ResultPatchMap, sampler_ResultPatchMap, uv1, 0);

    BaseData baseData = GenerateBaseData(_GlobalValues);
    float3 vexWorldPos = CalTerrainVertexPos(baseData, input.positionOS, pix0, pix1);
    float2 terrainUV = vexWorldPos.xz / baseData.worldSize + 0.5;
    float terrainHeight = SAMPLE_TEXTURE2D_LOD(_HeightMap, sampler_HeightMap, terrainUV, 0);
    vexWorldPos.y = (terrainHeight - 0.5) * 2 * baseData.worldHeightScale;
    input.positionOS.xyz = vexWorldPos;


    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    output.positionCS = vertexInput.positionCS;
    output.uv = TRANSFORM_TEX(terrainUV, _BaseMap);
    output.normalUV = terrainUV;
    output.positionWS = vertexInput.positionWS;
    output.viewDirWS = GetWorldSpaceViewDir(output.positionWS);

    output.feedbackUV = (vertexInput.positionWS.xz - _VTRealRect.xy) / _VTRealRect.zw;
    return output;
}

float4 VTFragFeedback(Varyings input) : SV_Target
{

    float2 page = floor(input.feedbackUV * _VTFeedbackParam.x);
    float2 uv = input.feedbackUV* _VTFeedbackParam.y;
    float2 dx = ddx(uv);
    float2 dy = ddy(uv);

    int mip = clamp(int(0.5 * log2(max(dot(dx, dx), dot(dy, dy))) + 0.5 + _VTFeedbackParam.w), 0, _VTFeedbackParam.z);

    return float4(page/255.0,mip/255.0,1);
}

#endif