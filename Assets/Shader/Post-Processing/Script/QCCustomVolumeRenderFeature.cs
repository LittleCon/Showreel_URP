using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace FC.PostProcessing
{
    public class QCCustomVolumeRenderFeature : ScriptableRendererFeature
    {
        BasePostProcessingPass m_AfterOpaqueAndSkyPass;
        BasePostProcessingPass m_BeforePostProcessingPass;
        BasePostProcessingPass m_AfterPostProcessingPass;
        List<BasePostProcessing> m_PostProcessings;


        public override void Create()
        {
            var stack = VolumeManager.instance.stack;
            //抓取所有自定义后处理
            m_PostProcessings = VolumeManager.instance.baseComponentTypeArray
                .Where(t => t.IsSubclassOf(typeof(BasePostProcessing)))
                .Select(t => stack.GetComponent(t) as BasePostProcessing).ToList();

            //获取AfterOpaqueAndSky节点注入的后处理列表
            var afterOpaqueAndSkyCPPs = m_PostProcessings
            .Where(c => c.InjectionPoint == CustomPostProcessInjectionPoint.AfterOpaqueAndSky) // 筛选出所有CustomPostProcessing类中注入点为透明物体和天空后的实例
            .OrderBy(c => c.OrderInInjectionPoint) // 按照顺序排序
            .ToList(); // 转换为List

            //AfterOpaqueAndSky节点对应的Pass
            m_AfterOpaqueAndSkyPass = new BasePostProcessingPass("Custom PostProcess after Skybox", afterOpaqueAndSkyCPPs);
            m_AfterOpaqueAndSkyPass.renderPassEvent = RenderPassEvent.AfterRenderingSkybox;

            var beforePostProcessingCPPs = m_PostProcessings
            .Where(c => c.InjectionPoint == CustomPostProcessInjectionPoint.BeforePostProcess)
            .OrderBy(c => c.OrderInInjectionPoint)
            .ToList();
            m_BeforePostProcessingPass = new BasePostProcessingPass("Custom PostProcess before PostProcess", beforePostProcessingCPPs);
            m_BeforePostProcessingPass.renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;

            var afterPostProcessCPPs = m_PostProcessings
            .Where(c => c.InjectionPoint == CustomPostProcessInjectionPoint.AfterPostProcess)
            .OrderBy(c => c.OrderInInjectionPoint)
            .ToList();
            m_AfterPostProcessingPass = new BasePostProcessingPass("Custom PostProcess after PostProcessing", afterPostProcessCPPs);
            m_AfterPostProcessingPass.renderPassEvent = RenderPassEvent.AfterRenderingPostProcessing;


            /*//Debug
            var postProcessingList = "AfterRenderingSkybox: ";
            foreach (var cpp in afterOpaqueAndSkyCPPs)
            {
                postProcessingList += cpp;
            }
            postProcessingList += "\n BeforePostProcess:";
            foreach (var cpp in beforePostProcessingCPPs)
            {
                postProcessingList += cpp;
            }
            postProcessingList += "\n AfterRenderingPostProcessing:";
            foreach (var cpp in afterPostProcessCPPs)
            {
                postProcessingList += cpp;
            }
            //Debug.LogError(postProcessingList);*/
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            if (renderingData.cameraData.postProcessEnabled)
            {
                // 为每个render pass设置RT
                // 并且将pass列表加到renderer中
                if (m_AfterOpaqueAndSkyPass.SetupCustomPostProcessing())
                {
                    renderer.EnqueuePass(m_AfterOpaqueAndSkyPass);
                }

                if (m_BeforePostProcessingPass.SetupCustomPostProcessing())
                {
                    renderer.EnqueuePass(m_BeforePostProcessingPass);
                }

                if (m_AfterPostProcessingPass.SetupCustomPostProcessing())
                {
                    renderer.EnqueuePass(m_AfterPostProcessingPass);
                }
            }
        }

        protected override void Dispose(bool disposing)
        {
            base.Dispose(disposing);
            if (disposing && m_PostProcessings != null)
            {
                foreach (var item in m_PostProcessings)
                {
                    item.Dispose();
                }
            }
        }

    }
}


