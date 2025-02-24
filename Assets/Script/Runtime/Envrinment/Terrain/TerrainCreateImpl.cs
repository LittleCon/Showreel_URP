using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Unity.Mathematics;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UIElements;
using static Unity.Burst.Intrinsics.X86.Avx;

namespace FC.Terrain
{
    public class TerrainCreateImpl
    {

        //?????LOD??Node???????
        private EnvironmentSettings environmentSettings;
        private ComputeShader GPUTerrainCS;
        //??????
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
        /// Hiz????????
        /// </summary>
        private RenderTexture resultPatchMap;

        #region computeShader????????
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
        /// ???Node?????±??????
        /// </summary>
        private ComputeBuffer nodeLodIndexBuffer;

        /// <summary>
        /// ????ComputeShader?????Node??????????????Buffer
        /// </summary>
        private ComputeBuffer appendTempBuffer1;
        /// <summary>
        /// ????ComputeShader?????Node??????????????Buffer
        /// </summary>
        private ComputeBuffer appendTempBuffer2;

        /// <summary>
        /// ?????????Node??????????
        /// </summary>
        private ComputeBuffer NodeBrunchList;

        /// <summary>
        /// ????????????????Patch
        /// </summary>
        private ComputeBuffer finaPatchlList;

        /// <summary>
        /// ????????Buffer
        /// </summary>
        private ComputeBuffer dispatchArgs;

        uint[] dispatchArgsData = new uint[3] { 1, 1, 1 };

        /// <summary>
        /// ??NodeLod?????????
        /// </summary>
        private RenderTexture SectorLODMap;

        private ComputeBuffer instanceArgsBuffer;

        private uint[] instanceArgsData;

#if UNITY_EDITOR
        /// <summary>
        /// ??????????Buffer??????
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
                        var value = GetNodeIndexOffset(i);
                        _nodeIndexOffsetList.Add(value);
                    }
                }
                return _nodeIndexOffsetList;
            }
        }
        public TerrainCreateImpl(Camera camera, EnvironmentSettings environmentSettings, ComputeShader computeShader)
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
        /// ???Lod???????Node???
        /// </summary>
        /// <param name="LOD"></param>
        /// <returns></returns>
        public int GetNodeSizeInLod(int LOD)
        {
            return (int)environmentSettings.sectorSize * environmentSettings.nodeDevidePatch * (1 << LOD);
        }

        /// <summary>
        /// ??????LOD????Terrain??????????NODE????????
        /// </summary>
        /// <param name="LOD"></param>
        /// <returns></returns>
        public int GetNodeNumInLod(int LOD)
        {
            return Mathf.FloorToInt(environmentSettings.worldSize / GetNodeSizeInLod(LOD) + 0.1f);
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
                int nodenum = GetNodeNumInLod(i) * GetNodeNumInLod(i);
                result += nodenum;
            }
            return result;
        }

        /// <summary>
        /// ????????????
        /// </summary>
        /// <param name="size">?????С</param>
        /// <param name="gridNum">???????(????)</param>
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

            //?????????Buffer?????????????????World?????6??LOD??????е?Node????
            int totalNodeNum = 0;
            for (int i = 5; i >= 0; i--)
            {
                totalNodeNum += GetNodeNumInLod(i) * GetNodeNumInLod(i);
            }
            //?????????е?Patch????
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
            terrainMesh = CreateQuadMesh(Vector2.one * (int)environmentSettings.sectorSize, environmentSettings.sectorVertexs * Vector2Int.one);
            instanceArgsData = new uint[] { 0, 0, 0, 0, 0 };
            instanceArgsData[0] = terrainMesh.GetIndexCount(0);
            instanceArgsBuffer.SetData(instanceArgsData);

            //rt??????????????????????
            RenderTextureDescriptor renderPatchMapDesc = new RenderTextureDescriptor(512, 512, RenderTextureFormat.ARGBFloat, 0, 1);
            renderPatchMapDesc.enableRandomWrite = true;
            resultPatchMap = RenderTexture.GetTemporary(renderPatchMapDesc);
            resultPatchMap.filterMode = FilterMode.Point;
            resultPatchMap.Create();

            worldBound = new Bounds(Vector3.zero, new Vector3(environmentSettings.worldSize, environmentSettings.worldSizeScale, environmentSettings.worldSize));


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
        /// ??????????5x5????
        /// </summary>
        public void CreateBaseNode()
        {
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
        int[] result2222 = new int[21840];

        public NodePatchData[] debugNodeData;

        /// <summary>
        /// ?????????Node???
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

            NodeBrunchList.GetData(result2222);
#if UNITY_EDITOR
            if (EnvironmentManagerSystem.Instance.debugAllNode)
            {

                cmd.CopyCounterValue(finaPatchlList, lengthLogBuffer, 0);
                
            }
#endif
        }


        /// <summary>
        /// ?finalList??????Node???????Tex?????Lod???
        /// </summary>
        public void CreateNodeLodMap()
        {
            int nodeNumLod0 = GetNodeNumInLod(0);
            cmd.SetComputeBufferParam(GPUTerrainCS, createNodeLodMapKernelID, ShaderProperties.GPUTerrain.nodeBrunchListID, NodeBrunchList);
            cmd.SetComputeTextureParam(GPUTerrainCS, createNodeLodMapKernelID, ShaderProperties.GPUTerrain.sectorLODMapID, SectorLODMap);
            cmd.DispatchCompute(GPUTerrainCS, createNodeLodMapKernelID, nodeNumLod0 / 8, nodeNumLod0 / 8, 1);
        }


        /// <summary>
        /// ??Node????????????
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
        /// ??Node??????Patch
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
            cmd.SetComputeTextureParam(GPUTerrainCS, hizCullKernelID, ShaderProperties.GPUTerrain.resultPatchMapID, resultPatchMap);
            cmd.SetComputeTextureParam(GPUTerrainCS, hizCullKernelID, ShaderProperties.GPUTerrain.sectorLODMapID, SectorLODMap);
            cmd.SetComputeTextureParam(GPUTerrainCS, hizCullKernelID, ShaderProperties.GPUTerrain.hizMapID, environmentSettings.hizMap);

            //?????
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
            if (EnvironmentManagerSystem.Instance.enableHizCull)
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


#if UNITY_EDITOR
            if (EnvironmentManagerSystem.Instance.debugAllNode)
            {

                int[] length = new int[1] { 1 };
                lengthLogBuffer.GetData(length);
                debugNodeData = new NodePatchData[length[0]];
                finaPatchlList.GetData(debugNodeData);
            }
            else if (EnvironmentManagerSystem.Instance.debugPatch)
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
