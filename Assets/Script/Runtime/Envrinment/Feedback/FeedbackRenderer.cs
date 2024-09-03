using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace RVTTerrain
{
    public enum ScaleFactor
    {
        // ԭʼ�ߴ�
        One,

        // 1/2�ߴ�
        Half,

        // 1/4�ߴ�
        Quarter,

        // 1/8�ߴ�
        Eighth,
    }

    public static class ScaleModeExtensions
    {
        public static float ToFloat(this ScaleFactor mode)
        {
            switch (mode)
            {
                case ScaleFactor.Eighth:
                    return 0.125f;
                case ScaleFactor.Quarter:
                    return 0.25f;
                case ScaleFactor.Half:
                    return 0.5f;
            }
            return 1;
        }
    }
    public class FeedbackRenderer : MonoBehaviour
    {
        public Camera mainCamera;

        public Camera FeedbackCamera;
        [SerializeField]
        private ScaleFactor m_Scale = default;

        /// <summary>
        /// mipmap�㼶ƫ��
        /// </summary>
        [SerializeField]
        private int m_MipmapBias = default;

        private RenderTexture targetTexture;
        private void Start()
        {
            Init();
        }

        private void Init()
        {
            mainCamera = Camera.main;
            FeedbackCamera = GetComponent<Camera>();

            FeedbackCamera.enabled = false;

            //���Ų���
            var scale = m_Scale.ToFloat();

            var width = (int)(mainCamera.pixelWidth * scale);
            var height = (int)(mainCamera.pixelHeight * scale);

            //VTFeedback��Ⱦ��ͼ
            targetTexture = new RenderTexture(width, height, 0);
            targetTexture.name = "_VTFeedbackRT";
            targetTexture.useMipMap = false;
            targetTexture.wrapMode = TextureWrapMode.Clamp;
            targetTexture.filterMode = FilterMode.Point;

            FeedbackCamera.targetTexture = targetTexture;
            CopyCamera(mainCamera);


            //����Shader����
            // x: ҳ���С(��λ: ҳ)
            // y: ������ͼ��С(��λ: ����)
            // z: ���mipmap�ȼ�
            var tileTexture = GetComponent(typeof(TiledTexture)) as TiledTexture;

            var virtualTable = GetComponent(typeof(PageTable)) as PageTable;

            Shader.SetGlobalVector(ShaderProperties.RVT.vtFeedbackParamID, new Vector4(
                virtualTable.TableSize, virtualTable.TableSize * tileTexture.TileSize * scale,
                virtualTable.MaxMipLevel - 1, m_MipmapBias));
        }

        private void CopyCamera(Camera camera)
        {
            if (camera == null)
                return;

            FeedbackCamera.fieldOfView = camera.fieldOfView;
            FeedbackCamera.nearClipPlane = camera.nearClipPlane;
            FeedbackCamera.farClipPlane = camera.farClipPlane;
        }

    }
}

