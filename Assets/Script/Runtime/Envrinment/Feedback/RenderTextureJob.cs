using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace RVTTerrain
{
    /// <summary>
    /// 负责PageTable对应索引及MipMap的渲染请求
    /// </summary>
    public class RenderTextureRequest
    {
        public int pageX;

        public int pageY;

        public int mipmapLevel;

        public RenderTextureRequest(int pageX,int pageY,int mipmapLevel)
        {
            this.pageX = pageX;
            this.pageY = pageY;
            this.mipmapLevel = mipmapLevel;
        }
    }
    /// <summary>
    /// 物理贴图更新的渲染请求类
    /// </summary>
    public class RenderTextureJob
    {
        private List<RenderTextureRequest> m_PendingRequests;

        /// <summary>
        /// 渲染请求取消回调事件
        /// </summary>
        public event Action<RenderTextureRequest> cancelRenderJob;

        /// <summary>
        /// 渲染完成回调事件
        /// </summary>
        public event Action<RenderTextureRequest> startRenderJob;

        /// <summary>
        /// 新建渲染请求
        /// </summary>
        /// <param name="x"></param>
        /// <param name="y"></param>
        /// <param name="mip"></param>
        /// <returns></returns>
        public RenderTextureRequest Request(int x,int y,int mip)
        {
            //如果已经在请求队列中，那么返回null
            foreach(var r in m_PendingRequests)
            {
                if (r.pageX == x && r.pageY == y && r.mipmapLevel == mip)
                {
                    return null;
                }
            }

            var request = new RenderTextureRequest(x, y, mip);
            m_PendingRequests.Add(request);

            return request;
        }

        /// <summary>
        /// 触发渲染请求取消后的回调，并清理所有等待的渲染请求
        /// </summary>
        public void ClearJob()
        {
            foreach (var r in m_PendingRequests)
            {
                cancelRenderJob?.Invoke(r);
            }

            m_PendingRequests.Clear();
        }
    }
}

