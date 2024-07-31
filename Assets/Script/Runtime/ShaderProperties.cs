using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class ShaderProperties 
{
   public struct GPUTerrain
    {
        public static int globalValueID = Shader.PropertyToID("_GlobalValues");
        public static int finalPatchListID = Shader.PropertyToID("_FinalPatchList");
        public static int appendTempListID = Shader.PropertyToID("_AppendTempList");
        public static int nodeIndexsID = Shader.PropertyToID("_NodeIndexs");
        public static int consumeListID = Shader.PropertyToID("_ConsumeList"); 
        public static int minMaxHeightMapID = Shader.PropertyToID("_MinMaxHeightMap");
        public static int currentLODID = Shader.PropertyToID("CURRENT_LOD");
        public static int nodeBrunchListID = Shader.PropertyToID("NodeBrunchList");
        public static int sectorLODMapID = Shader.PropertyToID("_SectorLODMap");
    }

    public struct HizMap 
    {
        public static int inputDepthMapID = Shader.PropertyToID("_InputDepthMap");
        public static int inputDepthMapSize = Shader.PropertyToID("_InputDepthMapSize");
        public static int hizMap0ID = Shader.PropertyToID("HIZ_MAP_Mip0");
        public static int hizMap1ID = Shader.PropertyToID("HIZ_MAP_Mip1");
        public static int hizMap2ID = Shader.PropertyToID("HIZ_MAP_Mip2");
        public static int hizMap3ID = Shader.PropertyToID("HIZ_MAP_Mip3");
    }
}
