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

        const RenderTextureFormat m_depthTextureFormat = RenderTextureFormat.RFloat;//���ȡֵ��Χ0-1����ͨ�����ɡ�

        void InitDepthTexture()
        {
            if (m_depthTexture != null) return;
            m_depthTexture = new RenderTexture(depthTextureSize, depthTextureSize, 0, m_depthTextureFormat);
            m_depthTexture.autoGenerateMips = false;//Mipmap�ֶ�����
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

            RenderTexture currentRenderTexture = null;//��ǰmipmapLevel��Ӧ��mipmap
            RenderTexture preRenderTexture = null;//��һ���mipmap����mipmapLevel-1��Ӧ��mipmap

            //�����ǰ��mipmap�Ŀ�ߴ���8���������һ���mipmap
            while (w > 8)
            {
                currentRenderTexture = RenderTexture.GetTemporary(w, w, 0, m_depthTextureFormat);
                currentRenderTexture.filterMode = FilterMode.Point;
                if (preRenderTexture == null)
                {
                    //Mipmap[0]��copyԭʼ�����ͼ
                    Graphics.Blit(renderingData.cameraData.renderer.cameraDepthTargetHandle, currentRenderTexture);
                }
                else
                {
                    //��Mipmap[i] Blit��Mipmap[i+1]��
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


