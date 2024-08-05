using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace FC
{

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
    }

}