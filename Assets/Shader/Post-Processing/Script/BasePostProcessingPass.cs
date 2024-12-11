using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


namespace FC.PostProcessing
{
    /// <summary>
    /// 为每一个不同时机的后处理都创建一个ScriptRenderPass对象
    /// </summary>
    public class BasePostProcessingPass : ScriptableRenderPass
    {
        // 存储当前注入时机的所有后处理
        private List<BasePostProcessing> m_BasePostProcessings;
        // 当前active组件下标
        private List<int> m_ActiveCustomPostProcessingIndex;

        // 每个组件对应的ProfilingSampler
        private string m_ProfilerTag;
        private List<ProfilingSampler> m_ProfilingSamplers;

        // 声明RT
        private RTHandle m_SourceRT;
        private RTHandle m_DesRT;
        private RTHandle m_TempRT0;
        private RTHandle m_TempRT1;
        bool rt1Used=false;
        private string m_TempRT0Name => "_TemporaryRenderTexture0";
        private string m_TempRT1Name => "_TemporaryRenderTexture1";


        public BasePostProcessingPass(string profilerTag, List<BasePostProcessing> customPostProcessings)
        {
            m_ProfilerTag = profilerTag;
            m_BasePostProcessings = customPostProcessings;
            m_ActiveCustomPostProcessingIndex = new List<int>(customPostProcessings.Count);
            // 将自定义后处理器对象列表转换成一个性能采样器对象列表
            m_ProfilingSamplers = customPostProcessings.Select(c => new ProfilingSampler(c.ToString())).ToList();

            //创建RT资源
            m_TempRT0 = RTHandles.Alloc(m_TempRT0Name, name: m_TempRT0Name);
            m_TempRT1 = RTHandles.Alloc(m_TempRT1Name, name: m_TempRT1Name);
        }

        /// <summary>
        /// 每一帧渲染都执行每个后处理自己的Configure，用于动态变量的设置
        /// </summary>
        /// <param name="cmd"></param>
        /// <param name="cameraTextureDescriptor"></param>
        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            base.Configure(cmd, cameraTextureDescriptor);
            for (int i = 0; i < m_ActiveCustomPostProcessingIndex.Count; i++)
            {
                int index = m_ActiveCustomPostProcessingIndex[i];
                var customProcessing = m_BasePostProcessings[index];
                customProcessing.Configure(cmd, cameraTextureDescriptor);
              
            }
        }

  

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            Debug.LogError(m_ActiveCustomPostProcessingIndex.Count);
            if (m_ActiveCustomPostProcessingIndex.Count == 0)return;
            //执行前调用Clear清理CMD缓冲区
            var cmd = CommandBufferPool.Get(m_ProfilerTag);
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();

            //获取相机RT的参数
            var descriptor = renderingData.cameraData.cameraTargetDescriptor;
            descriptor.msaaSamples = 1;
            descriptor.depthBufferBits = 0;
            descriptor.enableRandomWrite = true;
            descriptor.graphicsFormat = UnityEngine.Experimental.Rendering.GraphicsFormat.R8G8B8A8_SRGB;
            rt1Used = false;

            //获取相机当前的渲染结果
            m_DesRT = renderingData.cameraData.renderer.cameraColorTargetHandle;
            m_SourceRT = renderingData.cameraData.renderer.cameraColorTargetHandle;

            //检测已经申请的RT资源是格式是否符合Descriptor，如不符并调整至相同
            RenderingUtils.ReAllocateIfNeeded(ref m_TempRT0, descriptor, name: m_TempRT0Name);
            //仅有一个后处理的情况，直接调用该后处理的Render方法
            if (m_ActiveCustomPostProcessingIndex.Count == 1)
            {
                int index = m_ActiveCustomPostProcessingIndex[0];
                //using (new ProfilingScope(cmd, m_ProfilingSamplers[index]))
                {
                    m_BasePostProcessings[index].Render(cmd, ref renderingData, m_SourceRT, m_TempRT0);
                }
            }
            else
            {
                // 如果有多个组件，则在两个RT上来回bilt
                RenderingUtils.ReAllocateIfNeeded(ref m_TempRT1, descriptor, name: m_TempRT1Name);
                rt1Used = true;
                Blit(cmd, m_SourceRT, m_TempRT0);
                for (int i = 0; i < m_ActiveCustomPostProcessingIndex.Count; i++)
                {
                    int index = m_ActiveCustomPostProcessingIndex[i];
                    var customProcessing = m_BasePostProcessings[index];
                    
                    //using (new ProfilingScope(cmd, m_ProfilingSamplers[index]))
                    {
                        customProcessing.Render(cmd, ref renderingData, m_TempRT0, m_TempRT1);
                    }

                    CoreUtils.Swap(ref m_TempRT0, ref m_TempRT1);
                }
            }

            //把经过后处理的RT贴给相机
            Blitter.BlitCameraTexture(cmd, m_TempRT0, m_DesRT);

            // 释放


            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(Shader.PropertyToID(m_TempRT0.name));
            if (rt1Used) cmd.ReleaseTemporaryRT(Shader.PropertyToID(m_TempRT1.name));
        }

        public bool SetupCustomPostProcessing()
        {
            m_ActiveCustomPostProcessingIndex.Clear();
            for (int i = 0; i < m_BasePostProcessings.Count; i++)
            {
                if (m_BasePostProcessings[i].IsActive())
                {
                    m_BasePostProcessings[i].Setup();
                    m_ActiveCustomPostProcessingIndex.Add(i);
                }
            }
            return m_ActiveCustomPostProcessingIndex.Count != 0;
        }
    }
}