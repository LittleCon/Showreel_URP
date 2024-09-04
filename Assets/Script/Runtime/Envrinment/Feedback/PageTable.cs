using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEditor.PackageManager.Requests;
using UnityEngine;
using UnityEngine.Rendering;

namespace RVTTerrain
{
    public class PageTable : MonoBehaviour
    {
        private class DrawPageInfo
        {
            public Rect rect;
            public int mip;
            public Vector2 drawPos;
        }
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

        [SerializeField]
        private bool useFeed;

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

        private Material debugMat;
        private Shader debugShader;

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
            GetComponent<FeedbackReader>().OnFeadbackReadComplete += ProcessFeedback;

            ActivatePage(0, 0, MaxMipLevel);
        }


        /// <summary>
        /// ��Feedback�ض��ɹ�����ã����ڼ����Ӧҳ��
        /// </summary>
        /// <param name="texure"></param>
        private void ProcessFeedback(Texture2D texture)
        {
            if (!useFeed) return;

            foreach(var c in texture.GetRawTextureData<Color32>())
            {
                ActivatePage(c.r, c.g, c.b);

            }

            this.UpdateLookup();
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
                m_TiledTexture.SetActive(page.payLoad.tileIndex);
                page.payLoad.ActiveFrame = Time.frameCount;
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
        /// ����pagetable����
        /// </summary>
        public void Reset()
        {
            for(int i = 0; i <= MaxMipLevel; i++)
            {
                for(int j = 0; j < m_PageTable[i].nodeCellCount; j++)
                {
                    for(int k = 0; k < m_PageTable[i].nodeCellCount; k++)
                    {
                        InvalidatePage(m_PageTable[i].cell[j, k].payLoad.tileIndex);
                    }
                }
            }

            m_ActivePages.Clear();
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

        /// <summary>
        /// ��Ⱦ������ͼ
        /// </summary>
        /// <param name="renderTextureRequest"></param>
        public void OnRenderJob(RenderTextureRequest renderTextureRequest)
        {

            //�ҵ�ӵ�и���Ⱦ�����pagetable�е�Ԫ��
            var node = m_PageTable[renderTextureRequest.mipmapLevel].Get(renderTextureRequest.pageX, renderTextureRequest.pageY);

            //���Ԫ�ش��󷵻�
            if (node == null || node.payLoad.loadRequest != renderTextureRequest)
                return;

            node.payLoad.loadRequest = null;

            var id = m_TiledTexture.RequestTile();
            m_TiledTexture.UpdateTile(id, renderTextureRequest);

            node.payLoad.tileIndex = id;
            m_ActivePages[id] = node;
        }


        public void OnRenderJobCancel(RenderTextureRequest renderTextureRequest)
        {
            //�ҵ�ӵ�и���Ⱦ�����pagetable�е�Ԫ��
            var node = m_PageTable[renderTextureRequest.mipmapLevel].Get(renderTextureRequest.pageX, renderTextureRequest.pageY);
            //���Ԫ�ش��󷵻�
            if (node == null || node.payLoad.loadRequest != renderTextureRequest)
                return;
            node.payLoad.loadRequest = null;
        }

        /// <summary>
        /// ��ʹ��feedbackʱ����pagetable�ķ���,��������pagetable�뵱ǰ���ĵ���������������Mipmaplevel
        /// </summary>
        /// <param name="center"></param>
        public void UpdatePage(Vector2Int center)
        {
            if (useFeed)
                return;
            for(int i = 0; i < TableSize; i++)
            {
                for(int j = 0; j < TableSize; j++)
                {
                    var thisPos = new Vector2Int(i, j);
                    Vector2Int manhattanDistance = thisPos - center;

                    int absX = Mathf.Abs(manhattanDistance.x);
                    int absY = Mathf.Abs(manhattanDistance.y);

                    int absMax = Mathf.Max(absX, absY);
                    int tempMipLevel = (int)Mathf.Floor(Mathf.Sqrt(2 * absMax));

                    tempMipLevel = Mathf.Clamp(tempMipLevel, 0, MaxMipLevel);
                    ActivatePage(i, j, tempMipLevel);
                }
            }
            UpdateLookup();
        }

        private void UpdateLookup()
        {
            var currentFrame = (byte)Time.frameCount;
            var drawList = new List<DrawPageInfo>();

            foreach(var kv in m_ActivePages)
            {
                var page = kv.Value;
                //��ǰҳ���Ƿ��ڵ�ǰ֡��Ծ
                if (page.payLoad.ActiveFrame != Time.frameCount)
                    continue;
                //��ȡ��ǰMipmap��������ҳ��
                var table = m_PageTable[page.mipLevel];
                var offset = table.pageOffset;
                var perSize = table.perCellSize;

                var lb = new Vector2Int((page.Rect.xMin - offset.x * perSize), (page.Rect.yMin - offset.y * perSize));

                while (lb.x < 0)
                {
                    lb.x += TableSize;
                }

                while (lb.y < 0)
                {
                    lb.y += TableSize;
                }

                drawList.Add(new DrawPageInfo()
                {
                    rect = new Rect(lb.x, lb.y, page.Rect.width, page.Rect.height),
                    mip = page.mipLevel,
                    drawPos = new Vector2((float)page.payLoad.tileIndex.x / 255, (float)page.payLoad.tileIndex.y / 255)
                });

                drawList.Sort((a, b) =>
                {
                    return -(a.mip.CompareTo(b.mip));
                });

                if (drawList.Count == 0)
                {
                    return;
                }

                var mats = new Matrix4x4[drawList.Count];
                var pageInfos = new Vector4[drawList.Count];

                for(int i = 0; i < drawList.Count; i++)
                {
                    float size = drawList[i].rect.width / TableSize;
                    mats[i] = Matrix4x4.TRS(new Vector3(drawList[i].rect.x / TableSize, drawList[i].rect.y / TableSize), Quaternion.identity, new Vector3(size, size, size));

                    pageInfos[i] = new Vector4(drawList[i].drawPos.x, drawList[i].drawPos.y, drawList[i].mip/255);
                }

                Graphics.SetRenderTarget(m_LookTexture);
                var tempCB = new CommandBuffer();

                var block = new MaterialPropertyBlock();

                block.SetVectorArray("_PageInfo", pageInfos);
                block.SetMatrixArray("_ImageMVP", mats);

                tempCB.DrawMeshInstanced(m_Quad, 0, drawLookupMat, 0, mats, mats.Length, block);
                Graphics.ExecuteCommandBuffer(tempCB);
                UpdateDebugTexture();
            }
        }

        private void UpdateDebugTexture()
        {
#if UNITY_EDITOR
            if (m_LookTexture == null || debugShader == null)
                return;

            if (debugMat == null)
                debugMat = new Material(debugShader);

            debugRT.DiscardContents();
            Graphics.Blit(m_LookTexture, debugRT, debugMat);
#endif
        }
        public void ChangeViewRect(Vector2Int offset)
        {
            for(int i = 0; i < MaxMipLevel; i++)
            {
                m_PageTable[i].ChangeViewRect(offset, InvalidatePage);
            }

            ActivatePage(0, 0, MaxMipLevel);
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
