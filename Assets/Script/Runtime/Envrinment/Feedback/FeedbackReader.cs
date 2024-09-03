using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace RVTTerrain
{
    /// <summary>
    /// 负责读取FeedbackRenderer的渲染结果
    /// </summary>
    public class FeedbackReader : MonoBehaviour
    {

        /// <summary>
        /// 回读GPU数据完成后的回调
        /// </summary>
        public event Action<Texture2D> OnFeadbackReadComplete;

        /// <summary>
        /// 回读目标缩放比例
        /// </summary>
        [SerializeField]
        private ScaleFactor m_ReadbackScale = default;


        /// <summary>
		/// 处理CPU向GPU发送的回读请求
		/// </summary>
		private AsyncGPUReadbackRequest m_ReadbackRequest;

        /// <summary>
		/// 缩小后的RT
		/// </summary>
		private RenderTexture m_DownScaleTexture;

        /// <summary>
        /// 缩小RT使用的材质球
        /// </summary>
        private Material m_DownScaleMaterial;

        /// <summary>
        /// 缩小RTShader
        /// </summary>
        [SerializeField]
        private Shader m_DownScaleShader;

        /// <summary>
        /// 缩小RT对应使用的Shader pass序号
        /// </summary>
        private int m_DownScalePass;


        /// <summary>
        /// CPU记录回读数据的指定贴图
        /// </summary>
        private Texture2D m_ReadbackTexture;

        /// <summary>
        /// debug贴图
        /// </summary>
        private RenderTexture DebugTexture;

        /// <summary>
        /// Debug贴图使用材质球
        /// </summary>
        private Material m_DebugMaterial;

        /// <summary>
        /// Debug贴图使用Shader
        /// </summary>
        [SerializeField]
        private Shader m_DebugShader;

        public bool CanRead
        {
            get
            {
                return m_ReadbackRequest.done || m_ReadbackRequest.hasError;
            }
        }

        private void Start()
        {
            m_DownScaleMaterial = new Material(m_DownScaleShader);
            if (m_ReadbackScale != ScaleFactor.One)
            {
                switch (m_ReadbackScale)
                {
                    case ScaleFactor.Half:
                        m_DownScalePass = 0;
                        break;
                    case ScaleFactor.Quarter:
                        m_DownScalePass = 1;
                        break;
                    case ScaleFactor.Eighth:
                        m_DownScalePass = 2;
                        break;
                }
            }
        }

        /// <summary>
        /// 向GPU发送会读请求
        /// </summary>
        /// <param name="texture">需要从GPU回读的图片</param>
        /// <param name="forceRequestAndWaitCompelete">是否需要同步等待请求完成</param>
        public void NewRequest(RenderTexture texture,bool forceRequestAndWaitCompelete=false)
        {
            //会读还没有结束（即正在进行中）并且回读没有发生错误且不需要同步等待回读完成，满足以上三个条件不再次发送新的回读请求
            if (!m_ReadbackRequest.done && !m_ReadbackRequest.hasError && !forceRequestAndWaitCompelete)
                return;

            //texture已经是缩放过的，这里又再次缩放了
            var width = (int)(texture.width * m_ReadbackScale.ToFloat());
            var height = (int)(texture.height * m_ReadbackScale.ToFloat());

            if (m_ReadbackScale != ScaleFactor.One)
            {
                if(m_DownScaleTexture == null|| m_DownScaleTexture.width != width || m_DownScaleTexture.height != height)
                {
                    m_DownScaleTexture = new RenderTexture(width, height, 0);
                }

                //丢弃上一帧内容，在重新绘制，比直接重新绘制快
                m_DownScaleTexture.DiscardContents();
                Graphics.Blit(texture, m_DownScaleTexture, m_DownScaleMaterial, m_DownScalePass);
                texture = m_DownScaleTexture;
            }


            if(m_ReadbackTexture == null||m_ReadbackTexture.width!=width||m_ReadbackTexture.height!=height) 
            {
                m_ReadbackTexture = new Texture2D(width, height, TextureFormat.RGBA32, false);
                m_ReadbackTexture.filterMode = FilterMode.Point;
                m_ReadbackTexture.wrapMode = TextureWrapMode.Clamp;
                InitDebugTexture(width, height);
            }

            //发起回读请求
            m_ReadbackRequest = AsyncGPUReadback.Request(texture);
            if (forceRequestAndWaitCompelete)
            {
                m_ReadbackRequest.WaitForCompletion();
            }
        }

        public void UpdateRequest()
        {
            if(m_ReadbackRequest.done&& !m_ReadbackRequest.hasError)
            {
                m_ReadbackTexture.GetRawTextureData<Color32>().CopyFrom(m_ReadbackRequest.GetData<Color32>());
                OnFeadbackReadComplete?.Invoke(m_ReadbackTexture);

                UpdateDebugTexture();
            }
        }


        private void UpdateDebugTexture()
        {
#if UNITY_EDITOR
            if (m_ReadbackTexture == null || m_DebugShader == null)
                return;

            if (m_DebugMaterial == null)
                m_DebugMaterial = new Material(m_DebugShader);

            m_ReadbackTexture.Apply(false);

            DebugTexture.DiscardContents();
            Graphics.Blit(m_ReadbackTexture, DebugTexture, m_DebugMaterial);
#endif
        }

        private void InitDebugTexture(int width, int height)
        {
#if UNITY_EDITOR
            DebugTexture = new RenderTexture(width, height, 0);
            DebugTexture.filterMode = FilterMode.Point;
            DebugTexture.wrapMode = TextureWrapMode.Clamp;
#endif
        }
    }
}

