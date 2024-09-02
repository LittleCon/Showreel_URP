using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

namespace RVTTerrain
{
    public class PageTable : MonoBehaviour
    {
        public int TableSize { get => m_TableSize; }
        public int MaxMipLevel { get { return (int)Mathf.Log(TableSize, 2); } }

        /// <summary>
        /// ҳ��ߴ�.default=256x256
        /// </summary>
        [SerializeField]
        private int m_TableSize = default;

        /// <summary>
        /// ���ֱ���ʹ�õ�Shader
        /// </summary>
        [SerializeField]
        private Shader m_DrawLookup = default;


        private RenderTextureJob m_RenderTextureJob;

        /// <summary>
        /// ҳ��RT
        /// </summary>
        private RenderTexture m_LookTexture;

        /// <summary>
        /// ҳ��
        /// </summary>
        private PageLevelTable[] m_PageTable;

        /// <summary>
        /// ����debug
        /// </summary>
        private RenderTexture debugRT;

        /// <summary>
        /// ���ڻ���
        /// </summary>
        private Mesh m_Quad;

        /// <summary>
        /// ���ڽ��ֱ��ʵĲ�����
        /// </summary>
        private Material drawLookupMat;

        private TiledTexture m_TiledTexture;

        /// <summary>
        /// ��ǰ��Ծ��ҳ��
        /// </summary>
        private Dictionary<Vector2Int, TableNodeCell> m_ActivePages = new Dictionary<Vector2Int, TableNodeCell>();
        public void Init(RenderTextureJob job, int tileCount)
        {
            m_RenderTextureJob = job;

            m_RenderTextureJob.startRenderJob += OnRenderJob;
            m_RenderTextureJob.startRenderJob += OnRenderJobCancel;

            m_LookTexture = new RenderTexture(TableSize, TableSize, 0);
            m_LookTexture.filterMode = FilterMode.Point;
            m_LookTexture.wrapMode = TextureWrapMode.Clamp;


            m_PageTable = new PageLevelTable[MaxMipLevel+1];
            for(int i = 0; i <= MaxMipLevel; i++)
            {
                m_PageTable[i] = new PageLevelTable(i, TableSize);
            }

            drawLookupMat = new Material(m_DrawLookup);
            drawLookupMat.enableInstancing = true;

            Shader.SetGlobalTexture(ShaderProperties.RVT.vtLookupTexID, m_LookTexture);
            Shader.SetGlobalVector(ShaderProperties.RVT.vtPageParamID, new Vector4(TableSize, 1.0f / TableSize, MaxMipLevel, 0));

            InitDebugTexture();
            InitializeQuadMesh();

            m_TiledTexture = GetComponent<TiledTexture>();
            m_TiledTexture.onTileUpdateComplete += InvalidatePage;

            ActivatePage(0, 0, MaxMipLevel);
        }

        /// <summary>
        /// ��ĳ��mipmapLevel����ҳ���Ӧxyλ�ô���Ԫ������Ϊ��Ծ״̬
        /// </summary>
        /// <param name="x"></param>
        /// <param name="y"></param>
        /// <param name="mipmapLevel"></param>
        private void ActivatePage(int x,int y,int mipmapLevel)
        {
            if (mipmapLevel > MaxMipLevel || mipmapLevel < 0 || x < 0 || y < 0 || x >= TableSize || y >= TableSize)
                return;

            var page = m_PageTable[mipmapLevel].Get(x, y);
            if (page == null) return;

            if (!page.payLoad.isReady)
            {
                LoadPage(x, y, page);

                while(mipmapLevel<MaxMipLevel&& !page.payLoad.isReady)
                {
                    mipmapLevel++;
                    page = m_PageTable[mipmapLevel].Get(x, y);
                }
            }

            //���Ԫ�ز�����
            if (page.payLoad.isReady)
            {
                //�����Ӧƽ����ͼ��
                //m_TiledTexture.SetActive(page.payLoad.tileIndex);
                //page.payLoad.ActiveFrame = Time.frameCount;
            }
        }

        /// <summary>
        /// ����ҳ��
        /// </summary>
        /// <param name="x"></param>
        /// <param name="y"></param>
        /// <param name="node"></param>
        private void LoadPage(int x,int y,TableNodeCell node)
        {
            //��Ϊ�մ����Ѿ��ڼ����У���Ҫ�ظ�����
            if (node.payLoad.loadRequest!= null)
                return;

            node.payLoad.loadRequest = m_RenderTextureJob.Request(x, y, node.mipLevel);
        }

        /// <summary>
        /// ��ҳ������Ϊ�ǻ�Ծ״̬
        /// </summary>
        private void InvalidatePage(Vector2Int id)
        {
            if (!m_ActivePages.TryGetValue(id, out var node))
                return;

            node.payLoad.ResetTileIndex();
            m_ActivePages.Remove(id);
        }

        public void OnRenderJob(RenderTextureRequest renderTextureRequest)
        {

        }


        public void OnRenderJobCancel(RenderTextureRequest renderTextureRequest)
        {

        }


        private void InitDebugTexture()
        {
#if UNITY_EDITOR
            debugRT = new RenderTexture(TableSize, TableSize, 0);
            debugRT.filterMode = FilterMode.Point;
            debugRT.wrapMode = TextureWrapMode.Clamp;
#endif
        }

        private  void InitializeQuadMesh()
        {
            List<Vector3> quadVertexList = new List<Vector3>();
            List<int> quadTriangleList = new List<int>();
            List<Vector2> quadUVList = new List<Vector2>();

            quadVertexList.Add(new Vector3(0, 1, 0.1f));
            quadUVList.Add(new Vector2(0, 1));
            quadVertexList.Add(new Vector3(0, 0, 0.1f));
            quadUVList.Add(new Vector2(0, 0));
            quadVertexList.Add(new Vector3(1, 0, 0.1f));
            quadUVList.Add(new Vector2(1, 0));
            quadVertexList.Add(new Vector3(1, 1, 0.1f));
            quadUVList.Add(new Vector2(1, 1));

            quadTriangleList.Add(0);
            quadTriangleList.Add(1);
            quadTriangleList.Add(2);

            quadTriangleList.Add(2);
            quadTriangleList.Add(3);
            quadTriangleList.Add(0);

            m_Quad = new Mesh();
            m_Quad.SetVertices(quadVertexList);
            m_Quad.SetUVs(0, quadUVList);
            m_Quad.SetTriangles(quadTriangleList, 0);
        }
    }
}
