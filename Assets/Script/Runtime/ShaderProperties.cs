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
        public static int currentLODID = Shader.PropertyToID("_CurrentLOD");
        public static int nodeBrunchListID = Shader.PropertyToID("_NodeBrunchList");
        public static int sectorLODMapID = Shader.PropertyToID("_SectorLODMap");
        public static int vpMatrixID = Shader.PropertyToID("_VPMatrix");
        public static int hizMapID = Shader.PropertyToID("_HizMap");
        public static int instanceArgsID = Shader.PropertyToID("_InstanceArgs");
        public static int resultPatchMapID = Shader.PropertyToID("_ResultPatchMap");
        public static int boundsHeightRedundanceID = Shader.PropertyToID("_BoundsHeightRedundance");
        public static int hizDepthBiasID = Shader.PropertyToID("_HizDepthBias");
        public static int hizCameraPositionWSID = Shader.PropertyToID("_HizCameraPositionWS");

        //²ÄÖÊ
        public static int albedoTexNumsID = Shader.PropertyToID("_AlbedoTexNums");
        public static int normalTexNumsID = Shader.PropertyToID("_NormalTexNums");
        public static int albedoTexArrayID = Shader.PropertyToID("_AlbedoTexArray");
        public static int normalTexArrayID = Shader.PropertyToID("_NormalTexArray"); 
        public static int alphaMapSizeID = Shader.PropertyToID("_AlphaMapSize"); 
        public static int blendScaleArrayShaderID = Shader.PropertyToID("_BlendScaleArrayShader");
        public static int blendSharpnessArrayShaderId = Shader.PropertyToID("_BlendSharpnessArrayShader");
        public static int blendTexArraryID = Shader.PropertyToID("_BlendTexArray");
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

    public struct Grass
    {
        public static int vertexPosBuffer = Shader.PropertyToID("_VertexPosBuffer");
        public static int vertexColorsBuffer = Shader.PropertyToID("_VertexColorsBuffer");
        public static int vertexUVsBuffer = Shader.PropertyToID("_VertexUVsBuffer");
        public static int vertexIndexBuffer = Shader.PropertyToID("_VertexIndexBuffer");
        public static int grassBladeBuffer = Shader.PropertyToID("_GrassBladeBuffer");
        public static int grassMaskSplatMapID = Shader.PropertyToID("_GrassMaskSplatMap");
        public static int jitterStrengthID = Shader.PropertyToID("_JitterStrength");
        public static int patchGrassNumsID = Shader.PropertyToID("_PatchGrassNums");
        public static int clumpTexID = Shader.PropertyToID("_ClumpTex");
        public static int clumpScaleID = Shader.PropertyToID("_ClumpScale");
        public static int clumpParametersID = Shader.PropertyToID("_ClumpParameters");

    }
}
