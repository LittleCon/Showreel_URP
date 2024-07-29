using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Unity.Mathematics;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Rendering;

namespace FC.Terrain{
    public class TerrainCreateImpl 
    {

        //存储每级LOD的Node起始索引
        private EnvironmentSettings environmentSettings;
        private ComputeShader GPUTerrainCS;
        private int[] nodeLodIndexs;

        private Camera mainCamera;
        private Plane[] frustumPalnes = new Plane[6];
        private Vector4[] globalValue = new Vector4[10];

        #region computeShader函数索引
        private int createPathLODKernelID;
        private int createBaseNodeKernelID;
        #endregion

        #region ComputeBuffer
        private CommandBuffer cmd;

        /// <summary>
        /// 每级Node的开始下标开始索引
        /// </summary>
        private ComputeBuffer nodeLodIndexBuffer;

        /// <summary>
        /// 用于ComputeShader中暂存Node数据及传递数据的Buffer
        /// </summary>
        private ComputeBuffer appendTempBuffer1;
        /// <summary>
        /// 用于ComputeShader中暂存Node数据及传递数据的Buffer
        /// </summary>
        private ComputeBuffer appendTempBuffer2;

        /// <summary>
        /// 存储当前所有Node的节点的划分状态
        /// </summary>
        private ComputeBuffer NodeBrunchList;

        /// <summary>
        /// 最终需要加载的所有Patch
        /// </summary>
        private ComputeBuffer finaPatchlList;

        /// <summary>
        /// 线程组参数Buffer
        /// </summary>
        private ComputeBuffer dispatchArgs;

        uint[] dispatchArgsData = new uint[3] { 1, 1, 1 };

#if UNITY_EDITOR
        /// <summary>
        /// 编辑状态下看某个Buffer实际长度
        /// </summary>
        private ComputeBuffer lengthLogBuffer;
#endif
        #endregion
        private List<int> _nodeIndexOffsetList = new List<int>();
        public List<int> nodeIndexOffsetList
        {
            get
            {
                if (_nodeIndexOffsetList.Count == 0)
                {
                    for (int i = 0; i <= environmentSettings.maxLodLevel; i++)
                    {
                        _nodeIndexOffsetList.Add(GetNodeIndexOffset(i));
                    }
                }
                return _nodeIndexOffsetList;
            }
        }
        public TerrainCreateImpl(Camera camera,EnvironmentSettings environmentSettings,ComputeShader computeShader)
        {
            cmd = new();
            cmd.name = "GPUTerrain";
            mainCamera = camera;
            this.environmentSettings = environmentSettings;
            GPUTerrainCS = computeShader;
            InitKernelIndex();
            InitBuffer();
        }

        /// <summary>
        /// 制定Lod级别上的Node边长
        /// </summary>
        /// <param name="LOD"></param>
        /// <returns></returns>
        public int GetNodeSizeInLod(int LOD)
        {
            return (int)environmentSettings.sectorSize * environmentSettings.nodeDevidePatch * (1 << LOD);
        }

        /// <summary>
        /// 获取某个LOD级别，Terrain在一个维度上NODE的数量。
        /// </summary>
        /// <param name="LOD"></param>
        /// <returns></returns>
        public int GetNodeNumInLod(int LOD)
        {
            return Mathf.FloorToInt(environmentSettings.worldSize / GetNodeSizeInLod(LOD) + 0.1f) * Mathf.FloorToInt(environmentSettings.worldSize / GetNodeSizeInLod(LOD) + 0.1f);
        }

        private void InitKernelIndex() 
        {
            createBaseNodeKernelID = GPUTerrainCS.FindKernel("CreateBaseNode");

            createPathLODKernelID = GPUTerrainCS.FindKernel("CreatePathLodList");

        }
        public int GetNodeIndexOffset(int LOD)
        {
            int result = 0;
            for (int i = 0; i < LOD; i++)
            {
                int nodenum = GetNodeNumInLod(i);
                result += nodenum * nodenum;
            }
            return result;
        }
        private void InitBuffer()
        {
            //需要先计算出Buffer可能存放的最大数据，即World划分为6级LOD时最多具有的Node数量
            int totalNodeNum = 0;
            for (int i = 5; i >= 0; i--)
            {
                totalNodeNum += GetNodeNumInLod(i);
            }
            //计算最多具有的Patch数量
            int allPatchNum = GetNodeNumInLod(0);

            finaPatchlList = new(allPatchNum, NodePatchData.GetSize(), ComputeBufferType.Append);
            appendTempBuffer1 = new(totalNodeNum, NodePatchData.GetSize(), ComputeBufferType.Append);
            appendTempBuffer2 = new(totalNodeNum, NodePatchData.GetSize(), ComputeBufferType.Append);
            NodeBrunchList = new ComputeBuffer(totalNodeNum, 4);

            dispatchArgs = new ComputeBuffer(3, sizeof(uint), ComputeBufferType.IndirectArguments);

         
            nodeLodIndexBuffer = new ComputeBuffer(environmentSettings.maxLodLevel + 1, sizeof(int));
            nodeLodIndexBuffer.SetData(nodeIndexOffsetList);

            globalValue[1].x = environmentSettings.maxLodLevel;
            globalValue[1].y = environmentSettings.worldSize;
            globalValue[1].z = (int)environmentSettings.sectorSize;
            //globalValue[1].w = environmentSettings.PATCH_GRID_NUM;
            globalValue[2].x = environmentSettings.nodeDevidePatch;
            globalValue[2].z = environmentSettings.worldSizeScale;
            //globalValue[2].w = TerrainDataManager.HIZMapSize.x;
            //globalValue[3].x = TerrainDataManager.HIZMapSize.y;


           


#if UNITY_EDITOR
            lengthLogBuffer = new ComputeBuffer(1, sizeof(int), ComputeBufferType.IndirectArguments);
#endif
        }

        public void GetCameraPalne()
        {
            globalValue[0].x = mainCamera.transform.position.x;
            globalValue[0].y = mainCamera.transform.position.y;
            globalValue[0].z = mainCamera.transform.position.z;
            globalValue[0].w = mainCamera.fieldOfView;
            globalValue[2].y = environmentSettings.lodJudgeFector;
            GeometryUtility.CalculateFrustumPlanes(mainCamera, frustumPalnes);
            for (int i = 0; i < 6; i++)
            {
                globalValue[4 + i].Set(frustumPalnes[i].normal.x, frustumPalnes[i].normal.y, frustumPalnes[i].normal.z, frustumPalnes[i].distance);
            }
            cmd.SetComputeVectorArrayParam(GPUTerrainCS, ShaderProperties.GPUTerrain.globalValueID, globalValue);
        }
        public void ClearCmd()
        {
            cmd.Clear();
        }

        public void ExectCmd()
        {
            Graphics.ExecuteCommandBuffer(cmd);
            
        }


        /// <summary>
        /// 创建基础的5x5地形
        /// </summary>
        public void CreateBaseNode() {
            cmd.SetBufferCounterValue(appendTempBuffer1, 0);
            cmd.SetComputeBufferParam(GPUTerrainCS, createBaseNodeKernelID, ShaderProperties.GPUTerrain.appendTempListID, appendTempBuffer1);

            int maxLodLevel = environmentSettings.maxLodLevel;
            dispatchArgsData[0] = (uint)maxLodLevel;
            dispatchArgsData[1] = (uint)maxLodLevel;
            dispatchArgsData[2] = 1;

            cmd.SetBufferData(dispatchArgs, dispatchArgsData);
            cmd.DispatchCompute(GPUTerrainCS, createBaseNodeKernelID, dispatchArgs, 0);

            //var length = new int[1];
            //cmd.CopyCounterValue(appendTempBuffer1, lengthLogBuffer, 0);
            //lengthLogBuffer.GetData(length);
            //var debugNodeData = new NodePatchData[25];
            //appendTempBuffer1.GetData(debugNodeData);
        }

        public  NodePatchData[] debugNodeData;

        /// <summary>
        /// 生成四叉树Node结果
        /// </summary>
        public void CreateLodNodeList()
        {
            int maxLodLevels = environmentSettings.maxLodLevel;
            cmd.SetBufferCounterValue(appendTempBuffer2, 0);
            cmd.SetBufferCounterValue(finaPatchlList, 0);
            cmd.SetBufferCounterValue(NodeBrunchList, 0);
       
            cmd.SetComputeBufferParam(GPUTerrainCS, createPathLODKernelID, ShaderProperties.GPUTerrain.finalPatchListID, finaPatchlList);
            cmd.SetComputeBufferParam(GPUTerrainCS, createPathLODKernelID, ShaderProperties.GPUTerrain.nodeIndexsID, nodeLodIndexBuffer);
            cmd.SetComputeBufferParam(GPUTerrainCS, createPathLODKernelID, ShaderProperties.GPUTerrain.nodeBrunchListID, NodeBrunchList);
            cmd.SetComputeTextureParam(GPUTerrainCS, createPathLODKernelID, ShaderProperties.GPUTerrain.minMaxHeightMapID, environmentSettings.heightMap);

            dispatchArgsData = new uint[3] {
            (uint)(maxLodLevels*maxLodLevels),1,1
            };
            cmd.SetBufferData(dispatchArgs, dispatchArgsData);
            for (int i = maxLodLevels; i >= 0; i--)
            {
                cmd.SetComputeIntParam(GPUTerrainCS, ShaderProperties.GPUTerrain.currentLODID, i);
                cmd.SetComputeBufferParam(GPUTerrainCS, createPathLODKernelID, ShaderProperties.GPUTerrain.consumeListID, appendTempBuffer1);
                cmd.SetComputeBufferParam(GPUTerrainCS, createPathLODKernelID, ShaderProperties.GPUTerrain.appendTempListID, appendTempBuffer2);
                cmd.DispatchCompute(GPUTerrainCS, createPathLODKernelID, dispatchArgs, 0);

                cmd.CopyCounterValue(appendTempBuffer2, dispatchArgs, 0);

                ComputeBuffer temp = appendTempBuffer1;
                appendTempBuffer1 = appendTempBuffer2;
                appendTempBuffer2 = temp;
            }
#if UNITY_EDITOR
            if (EnvironmentManagerSystem.Instance.debug)
            {

                cmd.CopyCounterValue(finaPatchlList, lengthLogBuffer, 0);
                int[] length = new int[1] {1};
                lengthLogBuffer.GetData(length);
                debugNodeData = new NodePatchData[length[0]];
                finaPatchlList.GetData(debugNodeData);
            }
#endif
        }

        

        public void OnDisable()
        {
            if (finaPatchlList != null) finaPatchlList.Dispose();
            if (appendTempBuffer1 != null) appendTempBuffer1.Dispose();
            if (appendTempBuffer2 != null) appendTempBuffer2.Dispose();
            if (NodeBrunchList != null) NodeBrunchList.Dispose();
            if (nodeLodIndexBuffer != null) nodeLodIndexBuffer.Dispose();
            if (dispatchArgs != null) dispatchArgs.Dispose();
            if (cmd != null) cmd.Dispose();

#if UNITY_EDITOR
            if (lengthLogBuffer != null) lengthLogBuffer.Dispose();
#endif
        }
    }
}
