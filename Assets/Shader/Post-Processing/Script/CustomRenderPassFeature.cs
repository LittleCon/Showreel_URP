using Unity.Mathematics;
using Unity.VisualScripting;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using static Unity.Burst.Intrinsics.X86.Avx;
using static Unity.VisualScripting.Member;

public class CustomRenderPassFeature : ScriptableRendererFeature
{
    class CustomRenderPass : ScriptableRenderPass
    {
        private ComputeShader computeShader;
        private static int horinzontalKernel;
        private static int verticalKernel;
        private uint3 groupSize;
        private RTHandle mTempRT0;
        private float blurRadius;
        private int mTempRT0NameID = Shader.PropertyToID("_TemporaryRenderTexture0");
        private int mTempRT1NameID = Shader.PropertyToID("_TemporaryRenderTexture1");
        private string mTempRT0Name => "_TemporaryRenderTexture0";
        private Vector2 halfRes;
        public void Setup(ComputeShader computeShader,float r)
        {
            this.computeShader = computeShader;
            horinzontalKernel = computeShader.FindKernel("GaussianBlurHorizontalMain");
            verticalKernel = computeShader.FindKernel("GaussianBlurVerticalMain");
            blurRadius = r;
            computeShader.GetKernelThreadGroupSizes(horinzontalKernel, out groupSize.x, out groupSize.y, out groupSize.z);
           // mTempRT0 = RTHandles.Alloc(mTempRT0Name, name: mTempRT0Name);
        }
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            var descriptor = renderingData.cameraData.cameraTargetDescriptor;
            descriptor.msaaSamples = 1;
            descriptor.depthBufferBits = 0;
            descriptor.enableRandomWrite = true;
            cmd.GetTemporaryRT(mTempRT0NameID, descriptor);
            cmd.GetTemporaryRT(mTempRT1NameID, descriptor);
            halfRes = new Vector2(renderingData.cameraData.renderer.cameraColorTargetHandle.rt.width, renderingData.cameraData.renderer.cameraColorTargetHandle.rt.height);
        }

        // Here you can implement the rendering logic.
        // Use <c>ScriptableRenderContext</c> to issue drawing commands or execute command buffers
        // https://docs.unity3d.com/ScriptReference/Rendering.ScriptableRenderContext.html
        // You don't have to call ScriptableRenderContext.submit, the render pipeline will call it at specific points in the pipeline.
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            var cmd = CommandBufferPool.Get("GPUGaussian");
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();

            var mSourceRT = renderingData.cameraData.renderer.cameraColorTargetHandle;

            //RenderingUtils.ReAllocateIfNeeded(ref mTempRT0, descriptor, name: mTempRT0Name);

            //DoGaussianBlurHorizontal(cmd, renderingData.cameraData.renderer.cameraColorTargetHandle, mTempRT0NameID, computeShader, blurRadius);
           // DoGaussianBlurVertical(cmd, mTempRT0NameID, mTempRT1NameID, computeShader, blurRadius);
            computeShader.GetKernelThreadGroupSizes(horinzontalKernel, out groupSize.x, out groupSize.y, out groupSize.z);
            cmd.SetComputeTextureParam(computeShader, horinzontalKernel, "_InputTexture", renderingData.cameraData.renderer.cameraColorTargetHandle);
            cmd.SetComputeTextureParam(computeShader, horinzontalKernel, "_OutputTexture", mTempRT0NameID);
            cmd.SetComputeFloatParam(computeShader, "_BlurRadius", blurRadius);
            cmd.SetComputeVectorParam(computeShader, "_TextureSize", new Vector4(halfRes.x, halfRes.y, 1f / halfRes.x, 1f / halfRes.y));
            cmd.DispatchCompute(computeShader, horinzontalKernel, Mathf.CeilToInt((float)halfRes.x / groupSize.x),
              Mathf.CeilToInt((float)halfRes.y / groupSize.y), 1);
            computeShader.GetKernelThreadGroupSizes(verticalKernel, out groupSize.x, out groupSize.y, out groupSize.z);
            cmd.SetComputeTextureParam(computeShader, verticalKernel, "_InputTexture", mTempRT0NameID);
            cmd.SetComputeTextureParam(computeShader, verticalKernel, "_OutputTexture", mTempRT1NameID);
            cmd.SetComputeFloatParam(computeShader, "_BlurRadius", blurRadius);
            cmd.SetComputeVectorParam(computeShader, "_TextureSize", new Vector4(halfRes.x, halfRes.y, 1f / halfRes.x, 1f / halfRes.y));
            cmd.DispatchCompute(computeShader, verticalKernel, Mathf.CeilToInt((float)halfRes.x / groupSize.x),
              Mathf.CeilToInt((float)halfRes.y / groupSize.y), 1);


            cmd.Blit(mTempRT1NameID, mSourceRT);
            cmd.ReleaseTemporaryRT(mTempRT0NameID); 
            cmd.ReleaseTemporaryRT(mTempRT1NameID);
            context.ExecuteCommandBuffer(cmd);

            CommandBufferPool.Release(cmd);
            //mTempRT0.Release();
            
        }
        private void DoGaussianBlurHorizontal(CommandBuffer cmd, RenderTargetIdentifier srcid, RenderTargetIdentifier dstid, ComputeShader computeShader, float blurRadius)
        {
            int gaussianBlurKernel = computeShader.FindKernel("GaussianBlurHorizontalMain");

            computeShader.GetKernelThreadGroupSizes(gaussianBlurKernel, out uint x, out uint y, out uint z);
            cmd.SetComputeTextureParam(computeShader, gaussianBlurKernel, "_InputTexture", srcid);
            cmd.SetComputeTextureParam(computeShader, gaussianBlurKernel, "_OutputTexture", dstid);
            cmd.SetComputeFloatParam(computeShader, "_BlurRadius", blurRadius);
            cmd.SetComputeVectorParam(computeShader, "_TextureSize", new Vector4(halfRes.x, halfRes.y, 1f / halfRes.x, 1f / halfRes.y));
            cmd.DispatchCompute(computeShader, gaussianBlurKernel,
                Mathf.CeilToInt((float)halfRes.x / x),
                Mathf.CeilToInt((float)halfRes.y / y),
                1);
        }

        private void DoGaussianBlurVertical(CommandBuffer cmd, RenderTargetIdentifier srcid, RenderTargetIdentifier dstid, ComputeShader computeShader, float blurRadius)
        {
            int gaussianBlurKernel = computeShader.FindKernel("GaussianBlurVerticalMain");

            computeShader.GetKernelThreadGroupSizes(gaussianBlurKernel, out uint x, out uint y, out uint z);
            cmd.SetComputeTextureParam(computeShader, gaussianBlurKernel, "_InputTexture", srcid);
            cmd.SetComputeTextureParam(computeShader, gaussianBlurKernel, "_OutputTexture", dstid);
            cmd.SetComputeFloatParam(computeShader, "_BlurRadius", blurRadius);
            cmd.SetComputeVectorParam(computeShader, "_TextureSize", new Vector4(halfRes.x, halfRes.y, 1f / halfRes.x, 1f / halfRes.y));
            cmd.DispatchCompute(computeShader, gaussianBlurKernel,
                Mathf.CeilToInt((float)halfRes.x / x),
                Mathf.CeilToInt((float)halfRes.y / y),
                1);
        }

        // Cleanup any allocated resources that were created during the execution of this render pass.
        public override void OnCameraCleanup(CommandBuffer cmd)
        {
        }
        
    }

    CustomRenderPass m_ScriptablePass;
    public ComputeShader computeShader;
    public float blurRadius=1;
    /// <inheritdoc/>
    public override void Create()
    {
        m_ScriptablePass = new CustomRenderPass();

        // Configures where the render pass should be injected.
        m_ScriptablePass.renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        m_ScriptablePass.Setup(computeShader, blurRadius);
        renderer.EnqueuePass(m_ScriptablePass);
    }
}


