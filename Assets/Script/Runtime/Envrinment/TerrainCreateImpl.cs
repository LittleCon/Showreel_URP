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

        //�洢ÿ��LOD��Node��ʼ����
        private EnvironmentSettings environmentSettings;
        private ComputeShader GPUTerrainCS;
        private int[] nodeLodIndexs;

        private Camera mainCamera;
        private Plane[] frustumPalnes = new Plane[6];
        private Vector4[] globalValue = new Vector4[10];

        #region computeShader��������
        private int createPathLODKernelID;
        private int createBaseNodeKernelID;
        private int createNodeLodMapKernelID;
        private int frustumCullKernelID;
        private int nodeConvertToPatchKernelID;
        #endregion

        #region ComputeBuffer
        private CommandBuffer cmd;

        /// <summary>
        /// ÿ��Node�Ŀ�ʼ�±꿪ʼ����
        /// </summary>
        private ComputeBuffer nodeLodIndexBuffer;

        /// <summary>
        /// ����ComputeShader���ݴ�Node���ݼ��������ݵ�Buffer
        /// </summary>
        private ComputeBuffer appendTempBuffer1;
        /// <summary>
        /// ����ComputeShader���ݴ�Node���ݼ��������ݵ�Buffer
        /// </summary>
        private ComputeBuffer appendTempBuffer2;

        /// <summary>
        /// �洢��ǰ����Node�Ľڵ�Ļ���״̬
        /// </summary>
        private ComputeBuffer NodeBrunchList;

        /// <summary>
        /// ������Ҫ���ص�����Patch
        /// </summary>
        private ComputeBuffer finaPatchlList;

        /// <summary>
        /// �߳������Buffer
        /// </summary>
        private ComputeBuffer dispatchArgs;

        uint[] dispatchArgsData = new uint[3] { 1, 1, 1 };

        /// <summary>
        /// �洢NodeLod��Ϣ������
        /// </summary>
        private RenderTexture SectorLODMap;

#if UNITY_EDITOR
        /// <summary>
        /// �༭״̬�¿�ĳ��Bufferʵ�ʳ���
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
        /// �ƶ�Lod�����ϵ�Node�߳�
        /// </summary>
        /// <param name="LOD"></param>
        /// <returns></returns>
        public int GetNodeSizeInLod(int LOD)
        {
            return (int)environmentSettings.sectorSize * environmentSettings.nodeDevidePatch * (1 << LOD);
        }

        /// <summary>
        /// ��ȡĳ��LOD����Terrain��һ��ά����NODE��������
        /// </summary>
        /// <param name="LOD"></param>
        /// <returns></returns>
        public int GetNodeNumInLod(int LOD)
        {
            return Mathf.FloorToInt(environmentSettings.worldSize / GetNodeSizeInLod(LOD) + 0.1f) ;
        }

        private void InitKernelIndex() 
        {
            createBaseNodeKernelID = GPUTerrainCS.FindKernel("CreateBaseNode");

            createPathLODKernelID = GPUTerrainCS.FindKernel("CreatePathLodList");
            createNodeLodMapKernelID = GPUTerrainCS.FindKernel("CreateNodeLodMap");
            frustumCullKernelID = GPUTerrainCS.FindKernel("FrustumCull");
            nodeConvertToPatchKernelID = GPUTerrainCS.FindKernel("NodeConvertToPatch");
        }
        public int GetNodeIndexOffset(int LOD)
        {
            int result = 0;
            for (int i = 0; i < LOD; i++)
            {
                int nodenum = GetNodeNumInLod(i)* GetNodeNumInLod(i);
                result += nodenum * nodenum;
            }
            return result;
        }
        private void InitBuffer()
        {
            //��Ҫ�ȼ����Buffer���ܴ�ŵ�������ݣ���World����Ϊ6��LODʱ�����е�Node����
            int totalNodeNum = 0;
            for (int i = 5; i >= 0; i--)
            {
                totalNodeNum += GetNodeNumInLod(i)* GetNodeNumInLod(i);
            }
            //���������е�Patch����
            int allPatchNum = GetNodeNumInLod(0) * GetNodeNumInLod(0);

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

            RenderTextureDescriptor sectorLODMapDes = new RenderTextureDescriptor(GetNodeNumInLod(0), GetNodeNumInLod(0), RenderTextureFormat.RFloat, 0, 1);
            sectorLODMapDes.enableRandomWrite = true;
            SectorLODMap = RenderTexture.GetTemporary(sectorLODMapDes);
            SectorLODMap.filterMode = FilterMode.Point;
            SectorLODMap.Create();

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
        /// ����������5x5����
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
        /// �����Ĳ���Node���
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
            if (EnvironmentManagerSystem.Instance.debugAllNode)
            {

                cmd.CopyCounterValue(finaPatchlList, lengthLogBuffer, 0);
                int[] length = new int[1] {1};
                lengthLogBuffer.GetData(length);
                debugNodeData = new NodePatchData[length[0]];
                finaPatchlList.GetData(debugNodeData);
            }
#endif
        }

        /// <summary>
        /// ΪfinalList������Node����һ��Tex��¼��Lod��Ϣ
        /// </summary>
        public void CreateNodeLodMap() 
        {
            int nodeNumLod0 = GetNodeNumInLod(0);
            cmd.SetComputeBufferParam(GPUTerrainCS, createNodeLodMapKernelID, ShaderProperties.GPUTerrain.nodeBrunchListID, NodeBrunchList);
            cmd.SetComputeTextureParam(GPUTerrainCS, createNodeLodMapKernelID, ShaderProperties.GPUTerrain.sectorLODMapID, SectorLODMap);
            cmd.DispatchCompute(GPUTerrainCS, createNodeLodMapKernelID, nodeNumLod0 / 8, nodeNumLod0 / 8, 1);
        }


        /// <summary>
        /// ��Node�ڵ������׶�޳�
        /// </summary>
        public void NodeFrustumCull() 
        {
            cmd.CopyCounterValue(finaPatchlList, dispatchArgs, 0);

            cmd.SetBufferCounterValue(appendTempBuffer1, 0);
            cmd.SetComputeBufferParam(GPUTerrainCS, frustumCullKernelID, ShaderProperties.GPUTerrain.consumeListID, finaPatchlList);
            cmd.SetComputeBufferParam(GPUTerrainCS, frustumCullKernelID, ShaderProperties.GPUTerrain.appendTempListID, appendTempBuffer1);
            cmd.SetComputeTextureParam(GPUTerrainCS, createPathLODKernelID, ShaderProperties.GPUTerrain.minMaxHeightMapID, environmentSettings.heightMap);
            cmd.DispatchCompute(GPUTerrainCS, frustumCullKernelID, dispatchArgs, 0);
#if UNITY_EDITOR
            if (EnvironmentManagerSystem.Instance.debugAfterFrustumNode)
            {
                cmd.CopyCounterValue(appendTempBuffer1, lengthLogBuffer, 0);
                int[] length = new int[1] { 1 };
                lengthLogBuffer.GetData(length);
                debugNodeData = new NodePatchData[length[0]];
                appendTempBuffer1.GetData(debugNodeData);
            }
#endif
        }


        /// <summary>
        /// ��Node��չ��ΪPatch
        /// </summary>
        public void NodeConvertToPatch() 
        {
            cmd.SetBufferCounterValue(appendTempBuffer2, 0);
            cmd.CopyCounterValue(appendTempBuffer1, dispatchArgs, 0);
            cmd.SetComputeBufferParam(GPUTerrainCS, nodeConvertToPatchKernelID, ShaderProperties.GPUTerrain.consumeListID, appendTempBuffer1);
            cmd.SetComputeBufferParam(GPUTerrainCS, nodeConvertToPatchKernelID, ShaderProperties.GPUTerrain.appendTempListID, appendTempBuffer2);
            cmd.DispatchCompute(GPUTerrainCS, nodeConvertToPatchKernelID, dispatchArgs, 0);
#if UNITY_EDITOR
            if (EnvironmentManagerSystem.Instance.debugPatch)
            {
                
                cmd.CopyCounterValue(appendTempBuffer2, lengthLogBuffer, 0);
                int[] length = new int[1] { 1 };
                lengthLogBuffer.GetData(length);
                if (length[0] == 0)
                    debugNodeData = new NodePatchData[1];
                else
                    debugNodeData = new NodePatchData[length[0]];
                appendTempBuffer2.GetData(debugNodeData);
            }
#endif
        }

        public void HizMapCull() 
        {

        }


        public void OnDisable()
        {
            if (finaPatchlList != null) finaPatchlList.Dispose();
            if (appendTempBuffer1 != null) appendTempBuffer1.Dispose();
            if (appendTempBuffer2 != null) appendTempBuffer2.Dispose();
            if (NodeBrunchList != null) NodeBrunchList.Dispose();
            if (nodeLodIndexBuffer != null) nodeLodIndexBuffer.Dispose();
            if (dispatchArgs != null) dispatchArgs.Dispose();
            if (lengthLogBuffer != null) lengthLogBuffer.Dispose();
            if (cmd != null) cmd.Dispose();

            RenderTexture.ReleaseTemporary(SectorLODMap);

#if UNITY_EDITOR
            if (lengthLogBuffer != null) lengthLogBuffer.Dispose();
#endif
        }
    }
}
