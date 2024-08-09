#ifndef TERRAIN_DATASTRUCT_DEFINE
#define TERRAIN_DATASTRUCT_DEFINE

struct NodePatchData {
    float3 boundsMax;
    float3 boundsMin;
    uint2 nodeXY;
    uint2 patchXY;
    uint LOD;
    int4 LodTrans;
};

struct BaseData {
    float3 cameraWorldPos;
    float fov;
    float patchSize;
    int nodeDevidePatchNum;
    float worldSize;
    float worldHeightScale;
    float lodJudgeFector;
    float2 hizMapSize;
    int gridNum;
    int maxLOD;
};

struct Bound
{
    float3 minPos;
    float3 maxPos;
};


struct GrassBlade
{
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

struct ClumpParametersStruct {

     float pullToCentre;
     float pointInSameDirection;
     float baseHeight;
     float heightRandom;
     float baseWidth;
     float widthRandom;
     float baseTilt;
     float tiltRandom;
     float baseBend;
     float bendRandom;
};

#endif