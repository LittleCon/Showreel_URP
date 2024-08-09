#ifndef GPU_TERRAIN_FUNC_DEFINE
#define GPU_TERRAIN_FUNC_DEFINE

inline BaseData GenerateBaseData(float4 valueList[10]) {
    BaseData baseData;
    baseData.cameraWorldPos = float3(valueList[0].x, valueList[0].y, valueList[0].z);
    baseData.fov = valueList[0].w;
    baseData.patchSize = valueList[1].z;
    baseData.nodeDevidePatchNum = valueList[2].x;
    baseData.worldSize = valueList[1].y;
    baseData.gridNum = valueList[1].w;
    baseData.worldHeightScale = valueList[2].z;
    baseData.lodJudgeFector = valueList[2].y;
    baseData.maxLOD = valueList[1].x;
    baseData.hizMapSize.x = valueList[2].w;
    baseData.hizMapSize.y = valueList[3].x;
    return baseData;
}

NodePatchData CreateEmptyNodePatchData() {
    NodePatchData nodeData;
    nodeData.nodeXY = 0;
    nodeData.patchXY = 0;
    nodeData.LOD = 0;
    nodeData.boundsMax = 0;
    nodeData.boundsMin = 0;
    nodeData.LodTrans = 0;
    return nodeData;
}

inline float GetNodeSizeByLod(BaseData baseData, int LOD) {
    return baseData.patchSize * baseData.nodeDevidePatchNum * (1 << LOD);
}

inline int GetNodeNumInLod(BaseData baseData, int LOD)
{
    return  floor(baseData.worldSize / GetNodeSizeByLod(baseData, LOD) + 0.1f);
}

inline float2 GetNodeCenterPos(BaseData baseData, NodePatchData nodeData)
{
    float nodeSize = GetNodeSizeByLod(baseData, nodeData.LOD);
    uint nodeCount = GetNodeNumInLod(baseData, nodeData.LOD);
    float2 nodePos = nodeSize * (nodeData.nodeXY + 0.5 - nodeCount * 0.5);
    return nodePos;
}

inline float GetPatchSizeInLod(BaseData baseData, int LOD)
{
    return baseData.patchSize * (1 << LOD);
}

inline float2 GetPatchPosInNode(BaseData baseData, uint2 xyInPatch, uint LOD)
{
    float patchSize = GetPatchSizeInLod(baseData, LOD);
    float2 patchPos = patchSize * (xyInPatch + 0.5 - baseData.nodeDevidePatchNum * 0.5);
    return patchPos;
}


#endif