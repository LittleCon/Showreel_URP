using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace FC
{
    public enum SectorSize 
    {
        _2=2,
        _4=4,
        _8=8,
        _16=16,
        _32=32

    }

    [CreateAssetMenu(menuName ="Environment/CreateSettings",fileName ="EnvironmentSettings")]
    public class EnvironmentSettings : ScriptableObject
    {
        public int worldSize= 10240;

        /// <summary>
        /// 每个Node划分为几个Patch
        /// </summary>
        public int nodeDevidePatch = 8;

        public SectorSize sectorSize =SectorSize._8;

        public int maxLodLevel = 5;

        public float lodJudgeFector = 100;

        public Texture2D heightMap;
        public float worldSizeScale;
        public RenderTexture hizMap;

    }

}