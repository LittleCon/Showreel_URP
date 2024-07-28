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
    }
}
