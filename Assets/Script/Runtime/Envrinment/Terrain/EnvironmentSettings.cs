using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace FC.Terrain
{
    [System.Serializable]
    public struct ClumpParametersStruct
    {
        public float pullToCentre;
        public float pointInSameDirection;
        public float baseHeight;
        public float heightRandom;
        public float baseWidth;
        public float widthRandom;
        public float baseTilt;
        public float tiltRandom;
        public float baseBend;
        public float bendRandom;

        public static int GetSize()
        {
            return sizeof(float) * 10;
        }
    };
    [CreateAssetMenu(menuName ="Environment/CreateSettings",fileName ="EnvironmentSettings")]
    public class EnvironmentSettings : ScriptableObject
    {
       

        public int worldSize= 10240;

        /// <summary>
        /// 每个Node划分为几个Patch
        /// </summary>
        public int nodeDevidePatch = 8;

        public int sectorVertexs = 17;

        public int sectorSize =>worldSize/((1 << maxLodLevel) * nodeDevidePatch*baseLodNum);

        public int maxLodLevel = 5;

        public int baseLodNum = 5;

        public float lodJudgeFector = 100;

        public Texture2D heightMap;
        public float worldSizeScale;
        public RenderTexture hizMap;
        public  Vector2Int hizMapSize = new Vector2Int(2048, 1024);

        public Material terrainMat;

        [Header("草地")]
        public ComputeShader grassCS;
        public Mesh grassMesh;
        public Material grassMat;
        public Texture grassSplatMap;
        [Range(10,640)]
        public int perPatchGrassNums;
        [Tooltip("草坪的数量")]
        public int grassChunkCount=8;

        [Tooltip("草坪样式的数量")]
        public int grassStyleCount=4;

        public float clumpScale;
        public float jitterStrength;
        public List<ClumpParametersStruct> clumpParametersStructs;
    }

    
}