using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


namespace FC.PostProcessing
{
    /// <summary>
    /// 后处理注入节点
    /// </summary>
    [System.Serializable]
    public enum CustomPostProcessInjectionPoint
    {
        AfterOpaqueAndSky,
        BeforePostProcess,
        AfterPostProcess
    }
    public abstract class BasePostProcessing : VolumeComponent, IPostProcessComponent, IDisposable
    {
        
        protected Material mMaterial = null;
        private Material mCopyMaterial = null;

        public new bool active => IsActive();
        /// <summary>
        /// 注入时机
        /// </summary>
        public virtual CustomPostProcessInjectionPoint InjectionPoint => CustomPostProcessInjectionPoint.AfterPostProcess;
        /// <summary>
        /// 在注入点的顺序
        /// </summary>
        public virtual int OrderInInjectionPoint => 0;

        #region IPostProcessComponent接口实现
        public abstract bool IsActive();

        /// <summary>
        /// 判断一个后处理效果是否可以与当前的图像纹理进行平铺（tiling）操作
        /// </summary>
        /// <returns></returns>
        public virtual bool IsTileCompatible() => false;
        #endregion
        #region 渲染执行

        public abstract void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor);
        // 配置当前后处理
        public abstract void Setup();

        // 执行渲染
        public abstract void Render(CommandBuffer cmd, ref RenderingData renderingData, RTHandle source, RTHandle destination);
        #endregion
        #region IDisposable接口实现
        public virtual void Dispose(bool disposing)
        {
        }
        public void Dispose()
        {
            Dispose(true);
           
            DestroyImmediate(mCopyMaterial);
            GC.SuppressFinalize(this);
        }

        protected override void OnEnable()
        {
            base.OnEnable();
            if (mCopyMaterial == null)
            {
                mCopyMaterial =new Material(Resources.Load<Shader>("Shader/PostProcessing"));
            }
        }
        
        #region Draw Function

        private int mSourceTextureId = Shader.PropertyToID("_SourceTexture");

        public virtual void Draw(CommandBuffer cmd, in RTHandle source, in RTHandle destination, int pass = -1) {
            // 将GPU端_SourceTexture设置为source
            cmd.SetGlobalTexture(mSourceTextureId, source);
            // 将RT设置为destination 不关心初始状态(直接填充) 需要存储
            //cmd.SetRenderTarget(destination, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store);
            CoreUtils.SetRenderTarget(cmd, destination, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store);
            // 绘制程序化三角形
            if (pass == -1 || mMaterial == null)
                cmd.DrawProcedural(Matrix4x4.identity, mCopyMaterial, 0, MeshTopology.Triangles, 3);
            else
                cmd.DrawProcedural(Matrix4x4.identity, mMaterial, pass, MeshTopology.Triangles, 3);
        }

        #endregion

        #endregion
    }

}

