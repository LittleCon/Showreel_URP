using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace RVTTerrain
{
    /// <summary>
    /// �����ȡFeedbackRenderer����Ⱦ���
    /// </summary>
    public class FeedbackReader : MonoBehaviour
    {

        /// <summary>
        /// �ض�GPU������ɺ�Ļص�
        /// </summary>
        public event Action<Texture2D> OnFeadbackReadComplete;

        /// <summary>
        /// �ض�Ŀ�����ű���
        /// </summary>
        [SerializeField]
        private ScaleFactor m_ReadbackScale = default;


        /// <summary>
		/// ����CPU��GPU���͵Ļض�����
		/// </summary>
		private AsyncGPUReadbackRequest m_ReadbackRequest;

        /// <summary>
		/// ��С���RT
		/// </summary>
		private RenderTexture m_DownScaleTexture;

        /// <summary>
        /// ��СRTʹ�õĲ�����
        /// </summary>
        private Material m_DownScaleMaterial;

        /// <summary>
        /// ��СRTShader
        /// </summary>
        [SerializeField]
        private Shader m_DownScaleShader;

        /// <summary>
        /// ��СRT��Ӧʹ�õ�Shader pass���
        /// </summary>
        private int m_DownScalePass;


        /// <summary>
        /// CPU��¼�ض����ݵ�ָ����ͼ
        /// </summary>
        private Texture2D m_ReadbackTexture;

        /// <summary>
        /// debug��ͼ
        /// </summary>
        private RenderTexture DebugTexture;

        /// <summary>
        /// Debug��ͼʹ�ò�����
        /// </summary>
        private Material m_DebugMaterial;

        /// <summary>
        /// Debug��ͼʹ��Shader
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
        /// ��GPU���ͻ������
        /// </summary>
        /// <param name="texture">��Ҫ��GPU�ض���ͼƬ</param>
        /// <param name="forceRequestAndWaitCompelete">�Ƿ���Ҫͬ���ȴ��������</param>
        public void NewRequest(RenderTexture texture,bool forceRequestAndWaitCompelete=false)
        {
            //�����û�н����������ڽ����У����һض�û�з��������Ҳ���Ҫͬ���ȴ��ض���ɣ��������������������ٴη����µĻض�����
            if (!m_ReadbackRequest.done && !m_ReadbackRequest.hasError && !forceRequestAndWaitCompelete)
                return;

            //texture�Ѿ������Ź��ģ��������ٴ�������
            var width = (int)(texture.width * m_ReadbackScale.ToFloat());
            var height = (int)(texture.height * m_ReadbackScale.ToFloat());

            if (m_ReadbackScale != ScaleFactor.One)
            {
                if(m_DownScaleTexture == null|| m_DownScaleTexture.width != width || m_DownScaleTexture.height != height)
                {
                    m_DownScaleTexture = new RenderTexture(width, height, 0);
                }

                //������һ֡���ݣ������»��ƣ���ֱ�����»��ƿ�
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

            //����ض�����
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

