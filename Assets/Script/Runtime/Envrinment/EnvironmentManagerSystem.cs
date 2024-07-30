using System.Collections;
using System.Collections.Generic;
using Unity.Collections;
using Unity.Jobs;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Rendering;

namespace FC.Terrain
{

    /// <summary>
    /// 地块数据,NodePatch共用
    /// </summary>
    public struct NodePatchData
    {
        public float3 boundsMax;
        public float3 boundsMin;
        public uint2 nodeXY;
        public uint2 patchXY;
        public uint LOD;

        public static int GetSize()
        {
            return sizeof(float) * ( 3 + 3) + sizeof(uint) * (2 + 2 + 1);
        }
    }
    public class EnvironmentManagerSystem : BaseMangerSystem<EnvironmentManagerSystem>
    {
        public EnvironmentSettings environmentSettings;
        public ComputeShader GPUTerrainCS;
        public bool debugAllNode;
        public bool debugAfterFrustumNode;
        public TerrainCreateImpl terrainCreateImpl;

        protected override void Awake()
        {
            base.Awake();
        }

        private void Start()
        {
            terrainCreateImpl = new TerrainCreateImpl(Camera.main, environmentSettings, GPUTerrainCS);
        }

        private void Update()
        {
            terrainCreateImpl.ClearCmd();
            terrainCreateImpl.GetCameraPalne();
            terrainCreateImpl.CreateBaseNode();
            terrainCreateImpl.CreateLodNodeList();
            terrainCreateImpl.CreateNodeLodMap();
            terrainCreateImpl.NodeFrustumCull();
            terrainCreateImpl.NodeConvertToPatch();
            terrainCreateImpl.ExectCmd();

        }
#if UNITY_EDITOR
        public bool debug => debugAfterFrustumNode | debugAllNode;
#endif

        private void OnDisable()
        {
            terrainCreateImpl.OnDisable();   
        }
        /// <summary>
        /// 生成当前帧各LOD级别Node
        /// </summary>

    }


}