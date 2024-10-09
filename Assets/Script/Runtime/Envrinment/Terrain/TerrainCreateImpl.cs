using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Unity.Mathematics;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UIElements;
using static Unity.Burst.Intrinsics.X86.Avx;

namespace FC.Terrain{
    public class TerrainCreateImpl 
    {

        //存储每级LOD的Node起始索引
        private EnvironmentSettings environmentSettings;
        private ComputeShader GPUTerrainCS;
        //草地渲染
        private GrassGenerate grassGenerater;
        private Camera mainCamera;
        private Plane[] frustumPalnes = new Plane[6];
        private Vector4[] globalValue = new Vector4[10];
        private Matrix4x4 projcetMatrix;
        private Matrix4x4 vpMatrix;
        public Mesh terrainMesh;
        private Material terrainMat;
        private Bounds worldBound;

        /// <summary>
        /// Hiz剔除后的结果
        /// </summary>
        private RenderTexture resultPatchMap;

        #region computeShader函数索引
        private int createPathLODKernelID;
        private int createBaseNodeKernelID;
        private int createNodeLodMapKernelID;
        private int frustumCullKernelID;
        private int nodeConvertToPatchKernelID;
        private int hizCullKernelID;
        private int GrassPatchFilterKernelID;
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

        /// <summary>
        /// 存储NodeLod信息的纹理
        /// </summary>
        private RenderTexture SectorLODMap;

        private ComputeBuffer instanceArgsBuffer;

        private uint[] instanceArgsData;

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
            terrainMat = environmentSettings.terrainMat;

            grassGenerater = new GrassGenerate(environmentSettings);

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
            return Mathf.FloorToInt(environmentSettings.worldSize / GetNodeSizeInLod(LOD) + 0.1f) ;
        }

        private void InitKernelIndex() 
        {
            createBaseNodeKernelID = GPUTerrainCS.FindKernel("CreateBaseNode");
            createPathLODKernelID = GPUTerrainCS.FindKernel("CreatePathLodList");
            createNodeLodMapKernelID = GPUTerrainCS.FindKernel("CreateNodeLodMap");
            frustumCullKernelID = GPUTerrainCS.FindKernel("FrustumCull");
            nodeConvertToPatchKernelID = GPUTerrainCS.FindKernel("NodeConvertToPatch");
            hizCullKernelID = GPUTerrainCS.FindKernel("HizCull");
            GrassPatchFilterKernelID = GPUTerrainCS.FindKernel("GrassPatchFilter");
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

        /// <summary>
        /// 创建地形网格
        /// </summary>
        /// <param name="size">网格大小</param>
        /// <param name="gridNum">网格顶点数(奇数)</param>
        /// <returns></returns>
        public Mesh CreateQuadMesh(Vector2 size, Vector2Int gridNum)
        {
            Mesh mesh = new Mesh();
            Vector2 grid_size = size / (gridNum - Vector2.one);

            Vector3[] vertices = new Vector3[gridNum.x * gridNum.y];
            Vector2[] uvs = new Vector2[gridNum.x * gridNum.y];
            for (int i = 0; i < gridNum.x; i++)
            {
                for (int j = 0; j < gridNum.y; j++)
                {
                    float posx = grid_size.x * (i - gridNum.x / 2);
                    float posz = grid_size.y * (j - gridNum.y / 2);
                    Vector3 pos = new Vector3(posx, 0, posz);
                    Vector2 uv = new Vector2(i * 1.0f / (gridNum.x - 1), j * 1.0f / (gridNum.y - 1));
                    vertices[j * gridNum.x + i] = pos;
                    uvs[j * gridNum.x + i] = uv;
                }
            }
            mesh.vertices = vertices;

            int[] indexs = new int[(gridNum.x - 1) * (gridNum.y - 1) * 6];

            for (int i = 0; i < gridNum.x - 1; i++)
            {
                for (int j = 0; j < gridNum.y - 1; j++)
                {
                    int tri_index = (j * (gridNum.x - 1) + i);

                    indexs[tri_index * 6] = j * gridNum.x + i;
                    indexs[tri_index * 6 + 1] = (j + 1) * gridNum.x + i;
                    indexs[tri_index * 6 + 2] = (j + 1) * gridNum.x + i + 1;

                    indexs[tri_index * 6 + 3] = (j + 1) * gridNum.x + i + 1;
                    indexs[tri_index * 6 + 4] = j * gridNum.x + i + 1;
                    indexs[tri_index * 6 + 5] = j * gridNum.x + i;
                }
            }
            mesh.triangles = indexs;
            //mesh.uv = uvs;
            mesh.RecalculateNormals();


            return mesh;
        }

        private void InitBuffer()
        {
            if (SystemInfo.usesReversedZBuffer)
            {
                Debug.Log("EnableKeyword _REVERSE_Z");
                GPUTerrainCS.EnableKeyword("_REVERSE_Z");
            }
            else
            {
                Debug.Log("DisableKeyword _REVERSE_Z");
                GPUTerrainCS.DisableKeyword("_REVERSE_Z");
            }

            if (SystemInfo.graphicsDeviceType == GraphicsDeviceType.OpenGLES3)
            {
                Debug.Log("EnableKeyword _OPENGL_ES_3");
                GPUTerrainCS.EnableKeyword("_OPENGL_ES_3");
            }
            else
            {
                Debug.Log("DisableKeyword _OPENGL_ES_3");
                GPUTerrainCS.DisableKeyword("_OPENGL_ES_3");
            }

            //需要先计算出Buffer可能存放的最大数据，即World划分为6级LOD时最多具有的Node数量
            int totalNodeNum = 0;
            for (int i = 5; i >= 0; i--)
            {
                totalNodeNum += GetNodeNumInLod(i)* GetNodeNumInLod(i);
            }
            //计算最多具有的Patch数量
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
            globalValue[1].w = environmentSettings.sectorVertexs;
            globalValue[2].x = environmentSettings.nodeDevidePatch;
            globalValue[2].z = environmentSettings.worldSizeScale;
            globalValue[2].w = environmentSettings.hizMapSize.x;
            globalValue[3].x = environmentSettings.hizMapSize.y;

            RenderTextureDescriptor sectorLODMapDes = new RenderTextureDescriptor(GetNodeNumInLod(0), GetNodeNumInLod(0), RenderTextureFormat.RFloat, 0, 1);
            sectorLODMapDes.enableRandomWrite = true;
            SectorLODMap = RenderTexture.GetTemporary(sectorLODMapDes);
            SectorLODMap.filterMode = FilterMode.Point;
            SectorLODMap.Create();

            instanceArgsBuffer = new ComputeBuffer(5, sizeof(uint), ComputeBufferType.IndirectArguments);
            terrainMesh = CreateQuadMesh(Vector2.one*(int)environmentSettings.sectorSize,environmentSettings.sectorVertexs*Vector2Int.one);
            instanceArgsData = new uint[] { 0, 0, 0, 0, 0 };
            instanceArgsData[0] = terrainMesh.GetIndexCount(0);
            instanceArgsBuffer.SetData(instanceArgsData);

            //rt尺寸代表了最多支持多少个物体？
            RenderTextureDescriptor renderPatchMapDesc = new RenderTextureDescriptor(512, 512, RenderTextureFormat.ARGBFloat, 0, 1);
            renderPatchMapDesc.enableRandomWrite = true;
            resultPatchMap = RenderTexture.GetTemporary(renderPatchMapDesc);
            resultPatchMap.filterMode = FilterMode.Point;
            resultPatchMap.Create();

            worldBound = new Bounds(Vector3.zero,new Vector3(environmentSettings.worldSize, environmentSettings.worldSizeScale, environmentSettings.worldSize));


#if UNITY_EDITOR
            lengthLogBuffer = new ComputeBuffer(1, sizeof(int), ComputeBufferType.IndirectArguments);
#endif



            grassGenerater.InitBuffer();
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
            cmd.SetComputeVectorArrayParam(environmentSettings.grassCS, ShaderProperties.GPUTerrain.globalValueID, globalValue);
            cmd.SetComputeFloatParam(GPUTerrainCS, ShaderProperties.GPUTerrain.boundsHeightRedundanceID, environmentSettings.boundsHeightRedundance);
            cmd.SetComputeFloatParam(GPUTerrainCS, ShaderProperties.GPUTerrain.hizDepthBiasID, environmentSettings.hizDepthBias);
            cmd.SetComputeVectorParam(GPUTerrainCS, ShaderProperties.GPUTerrain.hizCameraPositionWSID, mainCamera.transform.position);
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
        /// 创建基础的nxn地形
        /// </summary>
        public void CreateBaseNode() {
            cmd.SetBufferCounterValue(appendTempBuffer1, 0);
            cmd.SetComputeBufferParam(GPUTerrainCS, createBaseNodeKernelID, ShaderProperties.GPUTerrain.appendTempListID, appendTempBuffer1);

            int baseLodNum = environmentSettings.baseLodNum;
            dispatchArgsData[0] = (uint)baseLodNum;
            dispatchArgsData[1] = (uint)baseLodNum;
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

            int baseLodNum = environmentSettings.baseLodNum;
            dispatchArgsData = new uint[3] {
            (uint)(baseLodNum*baseLodNum),1,1
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
            }
#endif
        }
        /// <summary>
        /// 为finalList中所有Node创建一个Tex记录其Lod信息
        /// </summary>
        public void CreateNodeLodMap() 
        {
            int nodeNumLod0 = GetNodeNumInLod(0);
            cmd.SetComputeBufferParam(GPUTerrainCS, createNodeLodMapKernelID, ShaderProperties.GPUTerrain.nodeBrunchListID, NodeBrunchList);
            cmd.SetComputeTextureParam(GPUTerrainCS, createNodeLodMapKernelID, ShaderProperties.GPUTerrain.sectorLODMapID, SectorLODMap);
            cmd.DispatchCompute(GPUTerrainCS, createNodeLodMapKernelID, nodeNumLod0 / 8, nodeNumLod0 / 8, 1);
        }


        /// <summary>
        /// 对Node节点进行视锥剔除
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
               
            }
#endif
        }


        /// <summary>
        /// 将Node扩展成为Patch
        /// </summary>
        public void NodeConvertToPatch() 
        {

            cmd.SetBufferCounterValue(appendTempBuffer2, 0);
            cmd.CopyCounterValue(appendTempBuffer1, dispatchArgs, 0);
            cmd.SetComputeBufferParam(GPUTerrainCS, nodeConvertToPatchKernelID, ShaderProperties.GPUTerrain.consumeListID, appendTempBuffer1);
            //if (EnvironmentManagerSystem.Instance.showCompeleteTerrain)
            //{
            //    cmd.CopyCounterValue(finaPatchlList, dispatchArgs, 0);
            //    cmd.SetComputeBufferParam(GPUTerrainCS, nodeConvertToPatchKernelID, ShaderProperties.GPUTerrain.consumeListID, finaPatchlList);
            //}
            //else
            //{

            //}
            cmd.SetComputeBufferParam(GPUTerrainCS, nodeConvertToPatchKernelID, ShaderProperties.GPUTerrain.appendTempListID, appendTempBuffer2);
            cmd.DispatchCompute(GPUTerrainCS, nodeConvertToPatchKernelID, dispatchArgs, 0);
#if UNITY_EDITOR
            if (EnvironmentManagerSystem.Instance.debugPatch)
            {
                
                cmd.CopyCounterValue(appendTempBuffer2, lengthLogBuffer, 0);
               
            }
#endif
        }

        public void HizMapCull() 
        {
            projcetMatrix = GL.GetGPUProjectionMatrix(mainCamera.projectionMatrix, false);
            vpMatrix = projcetMatrix * mainCamera.worldToCameraMatrix;
            cmd.SetComputeMatrixParam(GPUTerrainCS, ShaderProperties.GPUTerrain.vpMatrixID, vpMatrix);
            cmd.CopyCounterValue(appendTempBuffer2, dispatchArgs, 0);
            instanceArgsData[1] = 0;
            cmd.SetBufferData(instanceArgsBuffer, instanceArgsData);

            cmd.SetComputeBufferParam(GPUTerrainCS, hizCullKernelID, ShaderProperties.GPUTerrain.instanceArgsID, instanceArgsBuffer);
            cmd.SetComputeBufferParam(GPUTerrainCS, hizCullKernelID, ShaderProperties.GPUTerrain.consumeListID, appendTempBuffer2);
            cmd.SetComputeTextureParam(GPUTerrainCS, hizCullKernelID, ShaderProperties.GPUTerrain.minMaxHeightMapID, environmentSettings.heightMap);
            cmd.SetComputeTextureParam(GPUTerrainCS, hizCullKernelID, ShaderProperties.GPUTerrain.resultPatchMapID,resultPatchMap);
            cmd.SetComputeTextureParam(GPUTerrainCS, hizCullKernelID, ShaderProperties.GPUTerrain.sectorLODMapID, SectorLODMap);
            cmd.SetComputeTextureParam(GPUTerrainCS, hizCullKernelID, ShaderProperties.GPUTerrain.hizMapID, environmentSettings.hizMap);

            //草渲染
            cmd.SetBufferCounterValue(appendTempBuffer1, 0);
            cmd.SetComputeBufferParam(GPUTerrainCS, hizCullKernelID, ShaderProperties.GPUTerrain.appendTempListID, appendTempBuffer1);

            cmd.DispatchCompute(GPUTerrainCS, hizCullKernelID, dispatchArgs, 0);
            
        }

        public void GrassPatchFilter()
        {
            cmd.SetComputeBufferParam(GPUTerrainCS, GrassPatchFilterKernelID, ShaderProperties.GPUTerrain.consumeListID, appendTempBuffer1);
            cmd.SetBufferCounterValue(appendTempBuffer2, 0);
            cmd.SetComputeBufferParam(GPUTerrainCS, GrassPatchFilterKernelID, ShaderProperties.GPUTerrain.appendTempListID, appendTempBuffer2);
            cmd.SetComputeTextureParam(GPUTerrainCS, GrassPatchFilterKernelID, ShaderProperties.Grass.grassMaskSplatMapID, environmentSettings.grassSplatMap);
            cmd.CopyCounterValue(instanceArgsBuffer, dispatchArgs, 0);
            cmd.DispatchCompute(GPUTerrainCS, GrassPatchFilterKernelID, dispatchArgs, 0);
        }

        public void GenerateGrass()
        {
           // grassGenerater.DrawGrass(cmd, appendTempBuffer2);
        }

        public void SetKeyWorld()
        {
            if (EnvironmentManagerSystem.Instance.enableFrustumCull)
                GPUTerrainCS.EnableKeyword("ENABLE_FRUS_CULL");
            else
                GPUTerrainCS.DisableKeyword("ENABLE_FRUS_CULL");
            if(EnvironmentManagerSystem.Instance.enableHizCull)
                GPUTerrainCS.EnableKeyword("ENABLE_HIZ_CULL");
            else
                GPUTerrainCS.DisableKeyword("ENABLE_HIZ_CULL");
        }
        public void UpdateTerrainShaderData() 
        {
            terrainMat.SetVectorArray(ShaderProperties.GPUTerrain.globalValueID, globalValue);
            terrainMat.SetTexture(ShaderProperties.GPUTerrain.resultPatchMapID, resultPatchMap);
        }

        public void DrawTerrainInstance() 
        {
           
            Graphics.DrawMeshInstancedIndirect(terrainMesh, 0, terrainMat, worldBound, instanceArgsBuffer);
           
        }

        public void DebugBuffer() 
        {
            cmd.CopyCounterValue(appendTempBuffer2, lengthLogBuffer,0);
            int[] length3 = new int[1] { 1 };
            lengthLogBuffer.GetData(length3);

#if UNITY_EDITOR
            if (EnvironmentManagerSystem.Instance.debugAllNode)
            {

                int[] length = new int[1] { 1 };
                lengthLogBuffer.GetData(length);
                debugNodeData = new NodePatchData[length[0]];
                finaPatchlList.GetData(debugNodeData);
            }else if (EnvironmentManagerSystem.Instance.debugPatch)
            {
                int[] length = new int[1] { 1 };
                lengthLogBuffer.GetData(length);
                if (length[0] == 0)
                    debugNodeData = new NodePatchData[1];
                else
                    debugNodeData = new NodePatchData[length[0]];
                appendTempBuffer2.GetData(debugNodeData);
            }
            uint[] length2 = new uint[5];
            instanceArgsBuffer.GetData(length2);
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
            if (instanceArgsBuffer != null) instanceArgsBuffer.Dispose();
            if (cmd != null) cmd.Dispose();
            RenderTexture.ReleaseTemporary(environmentSettings.hizMap);
            RenderTexture.ReleaseTemporary(resultPatchMap);
            RenderTexture.ReleaseTemporary(SectorLODMap);

            //Grass
            grassGenerater.Dispose();
#if UNITY_EDITOR
            if (lengthLogBuffer != null) lengthLogBuffer.Dispose();
#endif
        }
    }
}
