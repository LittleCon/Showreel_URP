using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class HizRenderer2 : ScriptableRendererFeature
{
    class CustomRenderPass : ScriptableRenderPass
    {
        private Shader depthCopyShader;
        private Material depthCopyMat;

        int m_depthTextureSize = 0;

        RenderTexture m_depthTexture;
        public RenderTexture depthTexture => m_depthTexture;

        const RenderTextureFormat m_depthTextureFormat = RenderTextureFormat.RFloat;//深度取值范围0-1，单通道即可。

        void InitDepthTexture()
        {
            if (m_depthTexture != null) return;
            m_depthTexture = new RenderTexture(depthTextureSize, depthTextureSize, 0, m_depthTextureFormat);
            m_depthTexture.autoGenerateMips = false;//Mipmap手动生成
            m_depthTexture.useMipMap = true;
            m_depthTexture.filterMode = FilterMode.Point;
            m_depthTexture.Create();
        }
        public int depthTextureSize
        {
            get
            {
                if (m_depthTextureSize == 0)
                    m_depthTextureSize = Mathf.NextPowerOfTwo(Mathf.Max(Screen.width, Screen.height));
                return m_depthTextureSize;
            }
        }

        public CustomRenderPass(Shader depthCopyShader)
        {
            this.depthCopyShader = depthCopyShader;
        }
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            depthCopyMat = CoreUtils.CreateEngineMaterial(depthCopyShader);
        }

        // Here you can implement the rendering logic.
        // Use <c>ScriptableRenderContext</c> to issue drawing commands or execute command buffers
        // https://docs.unity3d.com/ScriptReference/Rendering.ScriptableRenderContext.html
        // You don't have to call ScriptableRenderContext.submit, the render pipeline will call it at specific points in the pipeline.
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            int w = m_depthTexture.width;
            int mipmapLevel = 0;

            RenderTexture currentRenderTexture = null;//当前mipmapLevel对应的mipmap
            RenderTexture preRenderTexture = null;//上一层的mipmap，即mipmapLevel-1对应的mipmap

            //如果当前的mipmap的宽高大于8，则计算下一层的mipmap
            while (w > 8)
            {
                currentRenderTexture = RenderTexture.GetTemporary(w, w, 0, m_depthTextureFormat);
                currentRenderTexture.filterMode = FilterMode.Point;
                if (preRenderTexture == null)
                {
                    //Mipmap[0]即copy原始的深度图
                    Graphics.Blit(renderingData.cameraData.renderer.cameraDepthTargetHandle, currentRenderTexture);
                }
                else
                {
                    //将Mipmap[i] Blit到Mipmap[i+1]上
                    Graphics.Blit(preRenderTexture, currentRenderTexture, depthCopyMat);
                    RenderTexture.ReleaseTemporary(preRenderTexture);
                }
                Graphics.CopyTexture(currentRenderTexture, 0, 0, m_depthTexture, 0, mipmapLevel);
                preRenderTexture = currentRenderTexture;

                w /= 2;
                mipmapLevel++;
            }
            RenderTexture.ReleaseTemporary(preRenderTexture);
    }

        // Cleanup any allocated resources that were created during the execution of this render pass.
        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            CoreUtils.Destroy(depthCopyMat);
        }
    }

    CustomRenderPass m_ScriptablePass;
    public Shader depthCopyShader;
    /// <inheritdoc/>
    public override void Create()
    {
        m_ScriptablePass = new CustomRenderPass(depthCopyShader);

        // Configures where the render pass should be injected.
        m_ScriptablePass.renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_ScriptablePass);
    }
}


