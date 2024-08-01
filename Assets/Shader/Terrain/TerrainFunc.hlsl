#ifndef TERRAIN_FUNC
#define TERRAIN_FUNC

inline float GetPatchSizeInLod(BaseData baseData, int LOD)
{
    return baseData.patchSize * (1 << LOD);
}

inline void FixLODConnectSeam(inout float4 vertex, uint2 PatchXYInNode, uint NodeLOD, uint4 LOADTrans, BaseData baseData)
{
    float patchSize = GetPatchSizeInLod(baseData, 0);
    float patchGridSize = patchSize / (baseData.gridNum - 1);
    int2 vexIndex = floor((vertex.xz + patchSize * 0.5 + 0.01) / patchGridSize);
    if (vexIndex.x == 0 && LOADTrans.x > 0)
    {
        uint step = 1 << LOADTrans.x;
        uint stepIndex = vexIndex.y % step;
        if (stepIndex != 0)
        {
            vertex.z -= patchGridSize * stepIndex;
        }
        return;
    }

    if (vexIndex.y == 0 && LOADTrans.y > 0)
    {
        uint step = 1 << LOADTrans.y;
        uint stepIndex = vexIndex.x % step;
        if (stepIndex != 0)
        {
            vertex.x -= patchGridSize * stepIndex;
        }
        return;
    }

    if (vexIndex.x == baseData.gridNum - 1 && LOADTrans.z > 0)
    {
        uint step = 1 << LOADTrans.z;
        uint stepIndex = vexIndex.y % step;
        if (stepIndex != 0)
        {
            vertex.z -= patchGridSize * stepIndex;
        }
        return;
    }

    if (vexIndex.y == baseData.gridNum - 1 && LOADTrans.w > 0)
    {
        uint step = 1 << LOADTrans.w;
        uint stepIndex = vexIndex.x % step;
        if (stepIndex != 0)
        {
            vertex.x -= patchGridSize * stepIndex;
        }
        return;
    }
}




inline float GetNodeSizeByLod(BaseData baseData, int LOD) {
    return baseData.patchSize * baseData.nodeDevidePatchNum * (1 << LOD);
}

inline int GetNodeNumInLod(BaseData baseData, int LOD)
{
    return  floor(baseData.worldSize / GetNodeSizeByLod(baseData, LOD) + 0.1f);
}

inline float2 GetNodeCenterPos(BaseData baseData,uint2 nodeXY,int LOD)
{
    float nodeSize = GetNodeSizeByLod(baseData, LOD);
    uint nodeCount = GetNodeNumInLod(baseData, LOD);
    float2 nodePos = nodeSize * (nodeXY + 0.5 - nodeCount * 0.5);
    return nodePos;
}

inline float2 GetPatchPosInNode(BaseData baseData, uint2 xyInPatch, uint LOD)
{
    float patchSize = GetPatchSizeInLod(baseData, LOD);
    float2 patchPos = patchSize * (xyInPatch + 0.5 - baseData.nodeDevidePatchNum * 0.5);
    return patchPos;
}

inline float3 CalTerrainVertexPos(BaseData baseData, float4 vertexPos, float4 pix0, float4 pix1) 
{
	uint2 nodeXY = pix0.xy;
	uint patchIndex = pix0.z;
	uint2 patchXY = uint2(patchIndex / 100, patchIndex % 100);

	uint LOD = pix0.w;
	uint4 LODTrans = pix1;
	float2 nodePos = GetNodeCenterPos(baseData, nodeXY, LOD);
	float2 patchPosInNode = GetPatchPosInNode(baseData, patchXY, LOD);
	float2 patchWorldPos = nodePos + patchPosInNode;
    FixLODConnectSeam(vertexPos, patchXY, LOD, LODTrans, baseData);
    float scale = 1 << LOD;
    float3 vexWorldPos = float3(patchWorldPos.x, 0, patchWorldPos.y) + vertexPos.xyz * float3(scale, 1, scale);
    return vexWorldPos;
}

#endif