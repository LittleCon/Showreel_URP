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
        /// һ֡��ദ�����Ⱦ�������
        /// </summary>
        [SerializeField]
        private int m_Limit = 2;

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

        public void Update()
        {
            if (m_PendingRequests.Count <= 0)
                return;

            //���ȴ���Mipmap�ȼ��ߵ�����
            m_PendingRequests.Sort((x, y) => { return x.mipmapLevel.CompareTo(y.mipmapLevel); });

            int count = m_Limit;

            while(count>0&& m_PendingRequests.Count > 0)
            {
                count--;
                //����һ������ӵȴ������ƶ������ж���
                var req = m_PendingRequests[m_PendingRequests.Count - 1];
                m_PendingRequests.RemoveAt(m_PendingRequests.Count - 1);

                //��ʼ��Ⱦ
                startRenderJob?.Invoke(req);
            }
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

