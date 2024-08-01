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


void CalNodeBounds(BaseData baseData, inout NodePatchData nodeData) {
    float2 height = _MinMaxHeightMap.mips[nodeData.LOD + 3][nodeData.nodeXY].xy;
    float2 minMaxHeight = (height - 0.5) * 2 * baseData.worldHeightScale;
    float nodeSize = GetNodeSizeByLod(baseData, nodeData.LOD);
    nodeData.boundsMax = float3(nodeSize * 0.5, minMaxHeight.y, nodeSize * 0.5);
    nodeData.boundsMin = float3(nodeSize * -0.5, minMaxHeight.x, nodeSize * -0.5);
}

int GetNodeIndex(BaseData baseData, uint LOD, float2 nodeXY) {
    return _NodeIndexs[LOD] + nodeXY.y + nodeXY.x * GetNodeNumInLod(baseData, LOD);
}

uint IsNeedQuad(BaseData baseData, NodePatchData nodeData)
{
    if (nodeData.LOD == 0)
        return 0;
    float3 cameraPos = baseData.cameraWorldPos;
    float fov = baseData.fov;
    float nodeSize = GetNodeSizeByLod(baseData, nodeData.LOD);
    float2 nodePos = GetNodeCenterPos(baseData, nodeData);

    float dis = distance(cameraPos, float3(nodePos.x, nodeData.boundsMax.y, nodePos.y));
    float result = baseData.lodJudgeFector * nodeSize / (dis * fov);
    return step(1, result);
}





inline void GetFrustumPlane(float4 valueList[10], inout float4 frustumPlane[6])
{
    frustumPlane[0] = valueList[4];
    frustumPlane[1] = valueList[5];
    frustumPlane[2] = valueList[6];
    frustumPlane[3] = valueList[7];
    frustumPlane[4] = valueList[8];
    frustumPlane[5] = valueList[9];
}

bool IsOutSidePlane(float4 plane, float3 position)
{
    return dot(plane.xyz, position) + plane.w < 0;
}


//true: avalible
//flase: culled
bool FrustumCullBound(float3 minPos, float3 maxPos, float4 planes[6])
{
    [unroll]
    for (int i = 0; i < 6; i++)
    {
        float3 p = minPos;
        float3 normal = planes[i].xyz;
        if (normal.x >= 0)
            p.x = maxPos.x;
        if (normal.y >= 0)
            p.y = maxPos.y;
        if (normal.z >= 0)
            p.z = maxPos.z;
        if (IsOutSidePlane(planes[i], p))
        {
            return false;
        }
    }
    return true;
}



bool CompareDepth(float HizMapDepth, float obj_uvd_depth)
{
#if _REVERSE_Z
    HizMapDepth = 1 - HizMapDepth;
#endif
    return HizMapDepth >= obj_uvd_depth;
}


inline float3 CalPointUVD(float4x4 _VPMatrix, float3 pos)
{
    float4 clipSpace = mul(_VPMatrix, float4(pos, 1.0));
    float3 ndc = clipSpace.xyz / clipSpace.w;

    float3 uvd;
    uvd.xy = (ndc.xy + 1) * 0.5;
    uvd.z = ndc.z;
#if _OPENGL_ES_3
    uvd.z = (ndc.z + 1) * 0.5;
#endif
#if _REVERSE_Z
    uvd.z = 1 - uvd.z;
#endif
    return uvd;
}

Bound
CalBoundUVD(BaseData
    baseData,
    float3 minPos, float3 maxPos)
{
    float3 pos0 = float3(minPos.x, minPos.y, minPos.z);
    float3 pos1 = float3(minPos.x, minPos.y, maxPos.z);
    float3 pos2 = float3(minPos.x, maxPos.y, minPos.z);
    float3 pos3 = float3(maxPos.x, minPos.y, minPos.z);
    float3 pos4 = float3(maxPos.x, maxPos.y, minPos.z);
    float3 pos5 = float3(maxPos.x, minPos.y, maxPos.z);
    float3 pos6 = float3(minPos.x, maxPos.y, maxPos.z);
    float3 pos7 = float3(maxPos.x, maxPos.y, maxPos.z);

    float3 uvd0 = CalPointUVD(_VPMatrix, pos0);
    float3 uvd1 = CalPointUVD(_VPMatrix, pos1);
    float3 uvd2 = CalPointUVD(_VPMatrix, pos2);
    float3 uvd3 = CalPointUVD(_VPMatrix, pos3);
    float3 uvd4 = CalPointUVD(_VPMatrix, pos4);
    float3 uvd5 = CalPointUVD(_VPMatrix, pos5);
    float3 uvd6 = CalPointUVD(_VPMatrix, pos6);
    float3 uvd7 = CalPointUVD(_VPMatrix, pos7);

    float3 minPosUVD = min(min(min(uvd0, uvd1), min(uvd2, uvd3)), min(min(uvd4, uvd5), min(uvd6, uvd7)));
    float3 maxPosUVD = max(max(max(uvd0, uvd1), max(uvd2, uvd3)), max(max(uvd4, uvd5), max(uvd6, uvd7)));
    Bound bound;
    bound.maxPos = clamp(maxPosUVD, 0, 1);
    bound.minPos = clamp(minPosUVD, 0, 1);
    return bound;
}

//true: avalible
//flase: culled
bool HizCullPoint(int mip, uint2 mapsize_mip, float3 pos)
{
    float2 mip_uv_step = float2(1.0 / mapsize_mip.x, 1.0 / mapsize_mip.y);
    float obj_depth = pos.z;
    //vulkan may be wrong
    uint2 ptXYInMap = uint2(floor(pos.x / mip_uv_step.x), floor(pos.y / mip_uv_step.y));
    ptXYInMap = clamp(ptXYInMap, 0, mapsize_mip - 1);
    float scene_depth = _HizMap.mips[mip][ptXYInMap];
    return CompareDepth(scene_depth, obj_depth);
}


int GetSectorLod(BaseData baseData, int2 sectorXY, int LOD)
{
    int sectornum = GetNodeNumInLod(baseData, 0);
    if (sectorXY.x < 0 || sectorXY.y < 0 || sectorXY.x >= sectornum || sectorXY.y >= sectornum)
    {
        return LOD;
    }
    int result = round(_SectorLODMap[sectorXY] * baseData.maxLOD);
    return result;
}

//get patchData around(left,down,right,up) lod 
void GetLodTrans(inout NodePatchData patchData, BaseData baseData)
{
    patchData.LodTrans = 0;
    int lod = patchData.LOD;
    int2 sectorXY = patchData.nodeXY * (1 << lod);

    if (patchData.patchXY.x == 0)
    {
        patchData.LodTrans.x = clamp(GetSectorLod(baseData, sectorXY + int2(-1, 0), lod) - lod, 0, baseData.maxLOD);
    }
    if (patchData.patchXY.y == 0)
    {
        patchData.LodTrans.y = clamp(GetSectorLod(baseData, sectorXY + int2(0, -1), lod) - lod, 0, baseData.maxLOD);
    }
    if (patchData.patchXY.x == baseData.nodeDevidePatchNum - 1)
    {
        patchData.LodTrans.z = clamp(GetSectorLod(baseData, sectorXY + int2(1 << lod, 0), lod) - lod, 0, baseData.maxLOD);
    }
    if (patchData.patchXY.y == baseData.nodeDevidePatchNum - 1)
    {
        patchData.LodTrans.w = clamp(GetSectorLod(baseData, sectorXY + int2(0, 1 << lod), lod) - lod, 0, baseData.maxLOD);
    }
}

bool HizCullBound(BaseData baseData, float3 minPos, float3 maxPos)
{
    float3 pos0 = minPos;
    float3 pos7 = maxPos;
    Bound boundUVD = CalBoundUVD(baseData, minPos, maxPos);//[0,1]
    float2 objsize = float2(boundUVD.maxPos.x - boundUVD.minPos.x, boundUVD.maxPos.y - boundUVD.minPos.y);//[0,1]
    float objDepth = boundUVD.minPos.z;//[0,1]
    uint2 hizMapSize = baseData.hizMapSize;

    int sample_mip = max(objsize.x * hizMapSize.x, objsize.y * hizMapSize.y);
    sample_mip = clamp(ceil(log2(sample_mip)), 0, log2(min(hizMapSize.x, hizMapSize.y))); //this is importent, mean hizmip max mip level

    float3 boundpos0 = float3(boundUVD.minPos.x, boundUVD.minPos.y, objDepth);
    float3 boundpos1 = float3(boundUVD.minPos.x, boundUVD.maxPos.y, objDepth);
    float3 boundpos2 = float3(boundUVD.maxPos.x, boundUVD.minPos.y, objDepth);
    float3 boundpos3 = float3(boundUVD.maxPos.x, boundUVD.maxPos.y, objDepth);
    uint2 mapsize_mip = uint2(hizMapSize.x >> sample_mip, hizMapSize.y >> sample_mip);//hiz map resolution of mip
    bool avalible = HizCullPoint(sample_mip, mapsize_mip, boundpos0)
        || HizCullPoint(sample_mip, mapsize_mip, boundpos1)
        || HizCullPoint(sample_mip, mapsize_mip, boundpos2)
        || HizCullPoint(sample_mip, mapsize_mip, boundpos3);
    return avalible;
}


#endif