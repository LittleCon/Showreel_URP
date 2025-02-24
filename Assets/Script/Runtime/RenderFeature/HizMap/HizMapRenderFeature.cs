using FC;
using FC.Terrain;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class HizMapRenderFeature : ScriptableRendererFeature
{
  
    class HizMapRenderPass : ScriptableRenderPass
    {
        private ComputeShader hizMapCS;
        private int buildHizMapKernelID;
        private EnvironmentSettings environmentSettings;

        private ComputeBuffer dispatchArgsBuffer;

        /// <summary>
        /// ��һ��HizMap�߳������
        /// </summary>
        private uint[] buildHizMapArgs0= new uint[3];
        /// <summary>
        /// �ڶ���HizMap�߳������
        /// </summary>
        private uint[] buildHizMapArgs1 = new uint[3];

        /// <summary>
        /// ������HizMap�߳������
        /// </summary>
        private uint[] buildHizMapArgs2 = new uint[3];

        /// <summary>
        /// xy��¼��Ļʵ�ʿ��ߺ�zw���֧��hizmap�Ŀ���
        /// </summary>
        private Vector4 inputDepthMapSize0 = new Vector4();

        /// <summary>
        /// �ڶ���HizMap��ȳߴ�
        /// </summary>
        private Vector4 inputDepthMapSize1 = new Vector4();

        /// <summary>
        /// ������HizMap��ȳߴ�
        /// </summary>
        private Vector4 inputDepthMapSize2 = new Vector4();

        /// <summary>
        /// hizMap����MipmapLevel
        /// </summary>
        private int mipmapCount = 11;
        /// <summary>
        /// �ڶ����������
        /// </summary>
        private RenderTexture inputDepthMap1;
        /// <summary>
        /// �������������
        /// </summary>
        private RenderTexture inputDepthMap2;

        public HizMapRenderPass(ComputeShader hizMapCS, EnvironmentSettings environmentSettings)
        {
            this.hizMapCS = hizMapCS;
            this.environmentSettings = environmentSettings;
            InitBuffer();
        }

        private void InitBuffer()
        {
            if (hizMapCS == null || environmentSettings == null) return;
            if (SystemInfo.usesReversedZBuffer)
            {
                hizMapCS.EnableKeyword("_REVERSE_Z");
            }
            else
            {
                hizMapCS.DisableKeyword("_REVERSE_Z");
            }
            buildHizMapKernelID = hizMapCS.FindKernel("BuildHizMap");

            dispatchArgsBuffer = new ComputeBuffer(3, 4, ComputeBufferType.IndirectArguments);


            inputDepthMapSize0.x = Screen.width;
            inputDepthMapSize0.y = Screen.height;
            inputDepthMapSize0.z = 4096;//4096
            inputDepthMapSize0.w = 2048;//2048
            inputDepthMapSize1.x = 256;//256
            inputDepthMapSize1.y = 128;//128
            inputDepthMapSize1.z = 256;
            inputDepthMapSize1.w = 128;
            inputDepthMapSize2.x = 32;//16
            inputDepthMapSize2.y = 16;//8
            inputDepthMapSize2.z = 32;
            inputDepthMapSize2.w = 16;

            buildHizMapArgs0[0] = (uint)4096 / 32;//128
            buildHizMapArgs0[1] = (uint)2048 / 16;//128
            buildHizMapArgs0[2] = 1;

            buildHizMapArgs1[0] = (uint)256 / 32;
            buildHizMapArgs1[1] = (uint)128 / 16;
            buildHizMapArgs1[2] = 1;

            buildHizMapArgs2[0] = (uint)1;//1
            buildHizMapArgs2[1] = (uint)1;//1
            buildHizMapArgs2[2] = 1;


            RenderTextureDescriptor inputDepthMapDesc1 = new RenderTextureDescriptor((int)inputDepthMapSize1.x, (int)inputDepthMapSize1.y, RenderTextureFormat.RFloat, 0, 1);
            inputDepthMap1 = RenderTexture.GetTemporary(inputDepthMapDesc1);
            inputDepthMap1.filterMode = FilterMode.Point;
            inputDepthMap1.Create();

            RenderTextureDescriptor inputDepthMapDesc2 = new RenderTextureDescriptor((int)inputDepthMapSize2.x, (int)inputDepthMapSize2.y, RenderTextureFormat.RFloat, 0, 1);
            inputDepthMap2 = RenderTexture.GetTemporary(inputDepthMapDesc2);
            inputDepthMap2.filterMode = FilterMode.Point;
            inputDepthMap2.Create();

            RenderTextureDescriptor HizMapDesc = new RenderTextureDescriptor(environmentSettings.hizMapSize.x, environmentSettings.hizMapSize.y, RenderTextureFormat.RFloat, 0, mipmapCount);
            HizMapDesc.useMipMap = true;
            HizMapDesc.autoGenerateMips = false;
            HizMapDesc.enableRandomWrite = true;

            environmentSettings.hizMap = RenderTexture.GetTemporary(HizMapDesc);
            environmentSettings.hizMap.filterMode = FilterMode.Point;
            environmentSettings.hizMap.Create();
        }
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
        }


        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (hizMapCS == null || environmentSettings == null)
                return;
            var cmd = CommandBufferPool.Get("BuildHizMap");
            //��ȡ������ͼ
            RTHandle depthRTHandle = renderingData.cameraData.renderer.cameraDepthTargetHandle;
            BuildHizMap(cmd, depthRTHandle);
            context.ExecuteCommandBuffer(cmd);
            cmd.Release();
        }
        public override void OnCameraCleanup(CommandBuffer cmd)
        {
        }
        private void BuildHizMap(CommandBuffer cmd, RTHandle depthHandle)
        {
            //0-3��Mipmap
            cmd.SetComputeVectorParam(hizMapCS, ShaderProperties.HizMap.inputDepthMapSize, inputDepthMapSize0);

            cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.inputDepthMapID, depthHandle);
            cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap0ID, environmentSettings.hizMap, 0);
            cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap1ID, environmentSettings.hizMap, 1);
            cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap2ID, environmentSettings.hizMap, 2);
            cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap3ID, environmentSettings.hizMap, 3);
            cmd.SetBufferData(dispatchArgsBuffer, buildHizMapArgs0);
            cmd.DispatchCompute(hizMapCS, buildHizMapKernelID, dispatchArgsBuffer, 0);

            //4-7��mimap
            cmd.SetComputeVectorParam(hizMapCS, ShaderProperties.HizMap.inputDepthMapSize, inputDepthMapSize1);
            cmd.CopyTexture(environmentSettings.hizMap, 0, 3, inputDepthMap1, 0, 0);
            cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.inputDepthMapID, inputDepthMap1);
            cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap0ID, environmentSettings.hizMap, 4);
            cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap1ID, environmentSettings.hizMap, 5);
            cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap2ID, environmentSettings.hizMap, 6);
            cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap3ID, environmentSettings.hizMap, 7);
            cmd.SetBufferData(dispatchArgsBuffer, buildHizMapArgs1);
            cmd.DispatchCompute(hizMapCS, buildHizMapKernelID, dispatchArgsBuffer, 0);

            //8-11��mimap
            cmd.SetComputeVectorParam(hizMapCS, ShaderProperties.HizMap.inputDepthMapSize, inputDepthMapSize2);
            cmd.CopyTexture(environmentSettings.hizMap, 0, 6, inputDepthMap2, 0, 0);
            cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.inputDepthMapID, inputDepthMap2);
            cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap0ID, environmentSettings.hizMap, 7);
            cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap1ID, environmentSettings.hizMap, 8);
            cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap2ID, environmentSettings.hizMap, 9);
            cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap3ID, environmentSettings.hizMap, 10);
            cmd.SetBufferData(dispatchArgsBuffer, buildHizMapArgs2);
            cmd.DispatchCompute(hizMapCS, buildHizMapKernelID, dispatchArgsBuffer, 0);
        }

        // Cleanup any allocated resources that were created during the execution of this render pass.

        public void Dispose()
        {
            if (hizMapCS == null)
            {
                return;
            }
            //RenderTexture.ReleaseTemporary(inputDepthMap0);
            RenderTexture.ReleaseTemporary(inputDepthMap1);
            RenderTexture.ReleaseTemporary(inputDepthMap2);
            dispatchArgsBuffer.Dispose();
        }
    }
   
    public ComputeShader hizMapCS;
    public EnvironmentSettings environmentSettings;
    HizMapRenderPass m_ScriptablePass;

    public override void Create()
    {
        m_ScriptablePass = new HizMapRenderPass(hizMapCS, environmentSettings);
        // Configures where the render pass should be injected.
        m_ScriptablePass.renderPassEvent = RenderPassEvent.BeforeRenderingTransparents;
    }
    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (renderingData.cameraData.isSceneViewCamera || renderingData.cameraData.isPreviewCamera)
        {
            return;
        }
        if (renderingData.cameraData.camera.name != "Main Camera")
        {
            return;
        }
        renderer.EnqueuePass(m_ScriptablePass);
    }
    protected override void Dispose(bool disposing)
    {
        m_ScriptablePass.Dispose();
    }
}




