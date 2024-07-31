using FC;
using FC.Terrain;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class HizMapRenderFeature : ScriptableRendererFeature
{
    public ComputeShader hizMapCS;
    public EnvironmentSettings environmentSettings;
    HizMapRenderPass m_ScriptablePass;

    /// <inheritdoc/>
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
        renderer.EnqueuePass(m_ScriptablePass);
    }
    protected override void Dispose(bool disposing)
    {
        m_ScriptablePass.Dispose();
    }
}

class HizMapRenderPass : ScriptableRenderPass
{
    private ComputeShader hizMapCS;
    private int buildHizMapKernelID;
    private EnvironmentSettings environmentSettings;

    private ComputeBuffer dispatchArgsBuffer;

    /// <summary>
    /// 第一批HizMap线程组参数
    /// </summary>
    private uint[] buildHizMapArgs0;
    /// <summary>
    /// 第二批HizMap线程组参数
    /// </summary>
    private uint[] buildHizMapArgs1;

    /// <summary>
    /// 第三批HizMap线程组参数
    /// </summary>
    private uint[] buildHizMapArgs2;

    /// <summary>
    /// xy记录屏幕实际宽高和zw最大支持hizmap的宽高
    /// </summary>
    private Vector4 inputDepthMapSize0;

    /// <summary>
    /// 第二次HizMap深度尺寸
    /// </summary>
    private Vector4 inputDepthMapSize1;

    /// <summary>
    /// 第三次HizMap深度尺寸
    /// </summary>
    private Vector4 inputDepthMapSize2;

    /// <summary>
    /// 最终生成的HizMap mipmap=0时的尺寸
    /// </summary>
    private Vector2Int hizMapSize = new Vector2Int(2048, 1024);

    /// <summary>
    /// hizMap最大的MipmapLevel
    /// </summary>
    private int mipmapCount = 11;
    /// <summary>
    /// 第二次深度纹理
    /// </summary>
    private RenderTexture inputDepthMap1;
    /// <summary>
    /// 第三次深度纹理
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
        if (hizMapCS == null|| environmentSettings==null) return;
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


        inputDepthMapSize0 = new Vector4(Screen.width, Screen.height, 4096, 2048);
        inputDepthMapSize1 = new Vector4(256, 128, 256, 128);
        inputDepthMapSize2 = new Vector4(32, 16, 32, 16);


        buildHizMapArgs0 = new uint[]
        {
            (uint)4096 / 32,
            (uint)2048/16,
            1
        };

        buildHizMapArgs1 = new uint[]
        {
            (uint)256 / 32,
            (uint)128/16,
            1
        };

        buildHizMapArgs2 = new uint[]
        {
            (uint)1,
            (uint)1,
            1
        };


        RenderTextureDescriptor inputDepthMapDesc1 = new RenderTextureDescriptor((int)inputDepthMapSize1.x, (int)inputDepthMapSize1.y, RenderTextureFormat.RFloat, 0, 1);
        inputDepthMap1 = RenderTexture.GetTemporary(inputDepthMapDesc1);
        inputDepthMap1.filterMode = FilterMode.Point;
        inputDepthMap1.Create();

        RenderTextureDescriptor inputDepthMapDesc2 = new RenderTextureDescriptor((int)inputDepthMapSize2.x, (int)inputDepthMapSize2.y, RenderTextureFormat.RFloat, 0, 1);
        inputDepthMap2 = RenderTexture.GetTemporary(inputDepthMapDesc2);
        inputDepthMap2.filterMode = FilterMode.Point;
        inputDepthMap2.Create();

        RenderTextureDescriptor HizMapDesc = new RenderTextureDescriptor(hizMapSize.x, hizMapSize.y, RenderTextureFormat.RFloat, 0, mipmapCount);
        HizMapDesc.useMipMap = true;
        HizMapDesc.autoGenerateMips = false;
        HizMapDesc.enableRandomWrite = true;
        //hizMap = RenderTexture.GetTemporary(HizMapDesc);
        //hizMap.filterMode = FilterMode.Point;
        //hizMap.name = "HizMap";
        //hizMap.Create();
        environmentSettings.hizMap = RenderTexture.GetTemporary(HizMapDesc);
        environmentSettings.hizMap.filterMode = FilterMode.Point;
        environmentSettings.hizMap.Create();
    }
    public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
    {
    }

   
    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        if (hizMapCS == null ||environmentSettings == null)
            return;
        var cmd = CommandBufferPool.Get("BuildHizMap");
        //获取相机深度图
        RTHandle depthRTHandle = renderingData.cameraData.renderer.cameraDepthTargetHandle;
        BuildHizMap(cmd, depthRTHandle);
        context.ExecuteCommandBuffer(cmd);
        cmd.Release();
    }

    private void BuildHizMap(CommandBuffer cmd,RTHandle depthHandle) 
    {
        //0-3级Mipmap
        cmd.SetComputeVectorParam(hizMapCS, ShaderProperties.HizMap.inputDepthMapSize, inputDepthMapSize0);

        cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.inputDepthMapID, depthHandle);
        cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap0ID,environmentSettings.hizMap, 0);
        cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap1ID,environmentSettings.hizMap, 1);
        cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap2ID,environmentSettings.hizMap, 2);
        cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap3ID,environmentSettings.hizMap, 3);
        cmd.SetBufferData(dispatchArgsBuffer, buildHizMapArgs0);
        cmd.DispatchCompute(hizMapCS, buildHizMapKernelID, dispatchArgsBuffer, 0);

        //4-7级mimap
        cmd.SetComputeVectorParam(hizMapCS, ShaderProperties.HizMap.inputDepthMapSize, inputDepthMapSize1);
        cmd.CopyTexture(environmentSettings.hizMap,0,3, inputDepthMap1,0,0);
        cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.inputDepthMapID, inputDepthMap1);
        cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap0ID, environmentSettings.hizMap, 4);
        cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap1ID,environmentSettings.hizMap, 5);
        cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap2ID,environmentSettings.hizMap, 6);
        cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap3ID,environmentSettings.hizMap, 7);
        cmd.SetBufferData(dispatchArgsBuffer, buildHizMapArgs1);
        cmd.DispatchCompute(hizMapCS, buildHizMapKernelID, dispatchArgsBuffer, 0);

        //8-11级mimap
        cmd.SetComputeVectorParam(hizMapCS, ShaderProperties.HizMap.inputDepthMapSize, inputDepthMapSize2);
        cmd.CopyTexture(environmentSettings.hizMap, 0, 6, inputDepthMap2, 0, 0);
        cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.inputDepthMapID, inputDepthMap2);
        cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap0ID,environmentSettings.hizMap, 7);
        cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap1ID,environmentSettings.hizMap, 8);
        cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap2ID,environmentSettings.hizMap, 9);
        cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap3ID,environmentSettings.hizMap, 10);
        cmd.SetBufferData(dispatchArgsBuffer, buildHizMapArgs2);
        cmd.DispatchCompute(hizMapCS, buildHizMapKernelID, dispatchArgsBuffer, 0);
    }


    //private void GenerateMipMap(CommandBuffer cmd,Vector4 mapSize,RenderTexture depthRT, uint[] buildHizMapArgs, int miplevelStart) {

    //    cmd.SetComputeVectorParam(hizMapCS, ShaderProperties.HizMap.inputDepthMapSize, mapSize);
    //    cmd.CopyTexture(EnvironmentManagerSystem.Instance.hizMap, 0, 3, depthRT, 0, 0);
    //    cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.inputDepthMapID, depthRT);
    //    cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap0ID,hizMap, miplevelStart++);
    //    cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap0ID,hizMap, miplevelStart++);
    //    cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap0ID,hizMap, miplevelStart++);
    //    cmd.SetComputeTextureParam(hizMapCS, buildHizMapKernelID, ShaderProperties.HizMap.hizMap0ID,hizMap, miplevelStart++);
    //    cmd.SetBufferData(dispatchArgsBuffer, buildHizMapArgs);
    //    cmd.DispatchCompute(hizMapCS, buildHizMapKernelID, dispatchArgsBuffer, 0);
    //}

    // Cleanup any allocated resources that were created during the execution of this render pass.
    public override void OnCameraCleanup(CommandBuffer cmd)
    {
    }
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


