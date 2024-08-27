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

        [Header("��������")]
        public int worldSize= 10240;

        /// <summary>
        /// ÿ��Node����Ϊ����Patch
        /// </summary>
        public int nodeDevidePatch = 8;

        public int sectorVertexs = 17;

        [Tooltip("��Χ����չ��Χ"),Range(0,100)]
        public int boundsHeightRedundance;
        [Tooltip("hizmap���ƫ��"), Range(0.1f, 1000)]
        public float hizDepthBias;
        public int sectorSize =>worldSize/((1 << maxLodLevel) * nodeDevidePatch*baseLodNum);

        public int maxLodLevel = 5;

        public int baseLodNum = 5;

        public float lodJudgeFector = 100;

        public Texture2D heightMap;
        public float worldSizeScale;
        public RenderTexture hizMap;
        public  Vector2Int hizMapSize = new Vector2Int(2048, 1024);

        public Material terrainMat;

        [Header("�ݵ�")]
        public ComputeShader grassCS;
        public Mesh grassMesh;
        public Material grassMat;
        public Texture grassSplatMap;
        [Range(10,640)]
        public int perPatchGrassNums;
   

        [Tooltip("��ƺ��ʽ������")]
        public int grassStyleCount=4;

        public int clumpTexWidth = 512;
        public int clumpTexHeight = 512;
        public Material clumpingVoronoiMat;
        public float clumpScale;
        public float jitterStrength;
        public List<ClumpParametersStruct> clumpParametersStructs;

        [Header("����")]
        public List<Texture2D> albedos;
        public List<Texture2D> normals;
        public List<Texture2D> splatMaps;

        
    }

    
}