using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace RVTTerrain
{
    /// <summary>
    /// ����PageTable��Ӧ������MipMap����Ⱦ����
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
    /// ������ͼ���µ���Ⱦ������
    /// </summary>
    public class RenderTextureJob
    {
        private List<RenderTextureRequest> m_PendingRequests;

        /// <summary>
        /// ��Ⱦ����ȡ���ص��¼�
        /// </summary>
        public event Action<RenderTextureRequest> cancelRenderJob;

        /// <summary>
        /// ��Ⱦ��ɻص��¼�
        /// </summary>
        public event Action<RenderTextureRequest> startRenderJob;

        /// <summary>
        /// �½���Ⱦ����
        /// </summary>
        /// <param name="x"></param>
        /// <param name="y"></param>
        /// <param name="mip"></param>
        /// <returns></returns>
        public RenderTextureRequest Request(int x,int y,int mip)
        {
            //����Ѿ�����������У���ô����null
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
        /// ������Ⱦ����ȡ����Ļص������������еȴ�����Ⱦ����
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

