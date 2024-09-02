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
        /// 页表尺寸.default=256x256
        /// </summary>
        [SerializeField]
        private int m_TableSize = default;

        /// <summary>
        /// 降分辨率使用的Shader
        /// </summary>
        [SerializeField]
        private Shader m_DrawLookup = default;


        private RenderTextureJob m_RenderTextureJob;

        /// <summary>
        /// 页表RT
        /// </summary>
        private RenderTexture m_LookTexture;

        /// <summary>
        /// 页表
        /// </summary>
        private PageLevelTable[] m_PageTable;

        /// <summary>
        /// 用于debug
        /// </summary>
        private RenderTexture debugRT;

        /// <summary>
        /// 用于绘制
        /// </summary>
        private Mesh m_Quad;

        /// <summary>
        /// 用于降分辨率的材质球
        /// </summary>
        private Material drawLookupMat;

        private TiledTexture m_TiledTexture;

        /// <summary>
        /// 当前活跃的页表
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
        /// 将某个mipmapLevel级别页表对应xy位置处的元素设置为活跃状态
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

            //如果元素不可用
            if (page.payLoad.isReady)
            {
                //激活对应平铺贴图快
                //m_TiledTexture.SetActive(page.payLoad.tileIndex);
                //page.payLoad.ActiveFrame = Time.frameCount;
            }
        }

        /// <summary>
        /// 加载页表
        /// </summary>
        /// <param name="x"></param>
        /// <param name="y"></param>
        /// <param name="node"></param>
        private void LoadPage(int x,int y,TableNodeCell node)
        {
            //不为空代表已经在加载中，不要重复请求
            if (node.payLoad.loadRequest!= null)
                return;

            node.payLoad.loadRequest = m_RenderTextureJob.Request(x, y, node.mipLevel);
        }

        /// <summary>
        /// 将页表设置为非活跃状态
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
