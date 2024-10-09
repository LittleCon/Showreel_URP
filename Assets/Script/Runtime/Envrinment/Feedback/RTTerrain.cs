using FC.Terrain;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Rendering;

namespace RVTTerrain
{
    public class RTTerrain : MonoBehaviour
    {

        public EnvironmentSettings environmentSettings;
        public float Radius = 500;
        public ScaleFactor ChangeViewDis = ScaleFactor.Eighth;
        public PageTable pageTable;

        /// <summary>
        /// �Ƿ�����FeedBack
        /// </summary>
        public bool useFeed;


        private FeedbackRenderer feedbackRenderer;
        private FeedbackReader feedbackReader;
        private RenderTextureJob rtJob;

        private Mesh m_Quad;
        private MakeTextureArray textureArray;


        private Rect realTotalRect;
        public Rect RealTotalRect
        {
            get
            {
                return realTotalRect;
            }
            set
            {
                realTotalRect = value;

                Shader.SetGlobalVector(
                "_VTRealRect",
                new Vector4(realTotalRect.xMin, realTotalRect.yMin, realTotalRect.width, realTotalRect.height));
            }
        }

        /// <summary>
        /// rvt��С*2/��Сtable��С��ͨ�����Ϊ����table���ֵ�������
        /// </summary>
        public float CellSize
        {
            get
            {
                return 2 * Radius / pageTable.TableSize;
            }
        }

        private TiledTexture tiledTex;
        private float changeViewDis;

        /// <summary>
        /// TileTexture�е�albedo��normal
        /// </summary>
        private RenderBuffer[] m_VTTileBuffer;

        /// <summary>
        /// ����ûʲô�õ����ͼ����Ϊm_VTTileBuffer��������renderbufferû����ȣ�����������Ϊ�˴ղ����õ�
        /// </summary>
        private RenderBuffer m_DepthBuffer;

        /// <summary>
        /// ����������ͼ�Ĵ�С
        /// </summary>
        private Vector2Int tileTexSize;


        /// <summary>
        /// ���ڻ���������ͼ�Ĳ�����
        /// </summary>
        private Material m_DrawTextureMaterial;

        private Shader m_DrawTextureShader;

        private void Start()
        {
            pageTable = GetComponent<PageTable>();
            feedbackRenderer = GetComponent<FeedbackRenderer>();
            feedbackReader = GetComponent<FeedbackReader>();
            tiledTex = GetComponent<TiledTexture>();
            textureArray = GetComponentInParent<MakeTextureArray>();
            rtJob = new RenderTextureJob();

            pageTable.Init(rtJob);
            tiledTex.Init();
            tiledTex.DoDrawTexture += DrawTexture;

            InitializeQuadMesh();
            //pageTable.UseFeed = UseFeed;
            changeViewDis = ScaleModeExtensions.ToFloat(ChangeViewDis) * 2 * Radius;//256
            var fixedCenter = GetFixedCenter(GetFixedPos(transform.position));//ͨ�������λ���ҵ�����ӽ���256�ı���,��1024���δ�С��,fixedCenter����0,256,512,1024
            RealTotalRect = new Rect(fixedCenter.x - Radius, fixedCenter.y - Radius, 2 * Radius, 2 * Radius);//fixedCenter.y - Radius����[-1024,1024]��ΧΪ2048


            m_VTTileBuffer = new RenderBuffer[2];
            m_VTTileBuffer[0] = tiledTex.VTRTs[0].colorBuffer;
            m_VTTileBuffer[1] = tiledTex.VTRTs[1].colorBuffer;
            m_DepthBuffer = tiledTex.VTRTs[0].depthBuffer;
            tileTexSize = new Vector2Int(tiledTex.VTRTs[0].width, tiledTex.VTRTs[0].height);
        }


        private void Update()
        {
            //�ҵ���С�ؿ鵥Ԫ��PageTable��һ��ҳ��Ӧ�ĵؿ��С��
            var fixedPos = GetFixedPos(transform.position);
            //����һ֡λ�ù�ϵ
            var xDiff = fixedPos.x - RealTotalRect.center.x;
            var yDiff = fixedPos.y - RealTotalRect.center.y;

            //�����ǰ֡��λ���Ѿ�������PageTable����ֵ����Ҫ�ж��Ƿ���Ҫ���¼���pagetable
            if (Mathf.Abs(xDiff) > changeViewDis || Mathf.Abs(yDiff) > changeViewDis)
            {
                //�����µ�Rect����
                var fixedCenter = GetFixedCenter(fixedPos);

                //�µ�����!=�����ģ�˵����Ҫ����PageTable��������ͼ
                if (fixedCenter != RealTotalRect.center)
                {
                    rtJob.ClearJob();

                    var oldCenter = new Vector2Int((int)RealTotalRect.center.x, (int)RealTotalRect.center.y);

                    RealTotalRect = new Rect(fixedCenter.x - Radius, fixedCenter.y - Radius, 2 * Radius,2 * Radius);

                    //(2 * (int)Radius / pageTable.TableSize)����һ��pageTable��Ӧ�ĵؿ��С
                    //��ǰrect���ĵ��֮ǰ���ĵ�ľ�����Ҫƫ�ƶ��ٸ�pageTable�е�Ԫ��
                    //��rect����ƫ��ʱ���������µ�ҳ��Ҫ���ڻ�Ծ״̬���ɵĲ��ڷ�Χ�ڵ�ҳ��Ҫ����Ϊ����Ծ״̬
                    pageTable.ChangeViewRect((fixedCenter - oldCenter) / (2 * (int)Radius / pageTable.TableSize));

                    if (useFeed)
                    {
                        feedbackRenderer.FeedbackCamera.Render();
                        feedbackReader.NewRequest(feedbackRenderer.FeedbackCamera.targetTexture,true);
                        feedbackReader.UpdateRequest();
                        rtJob.Update();
                        feedbackReader.UpdateRequest();
                    }
                    else
                    {
                        pageTable.UpdatePage(GetPageSector(fixedPos, RealTotalRect));
                        rtJob.Update();
                        pageTable.UpdatePage(GetPageSector(fixedPos, RealTotalRect));

                    }
                    return;
                }
            }

            if (useFeed)
            {
                feedbackReader.UpdateRequest();
                if (feedbackReader.CanRead)
                {
                    feedbackRenderer.FeedbackCamera.Render();
                    feedbackReader.NewRequest(feedbackRenderer.FeedbackCamera.targetTexture);
                }
            }
            else
            {
                pageTable.UpdatePage(GetPageSector(fixedPos, realTotalRect));
            }
            rtJob.Update();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="drawPos">mipmap0��һ��������ͼ�ĳߴ磨����padding��</param>
        /// <param name="request"></param>
        private void DrawTexture(RectInt drawPos,RenderTextureRequest request)
        {
            //pageTable�е����أ�pageTableһ�����ض�Ӧһ��tileTexture���������Ҳ����tileTexture�еĶ�ά���꣨���������ֵģ�
            int x = request.pageX;
            int y = request.pageY;

            //��ȡ��Mipmaplevel������ͼ��һ���ĳߴ�
            int perSize = (int)Mathf.Pow(2, request.mipmapLevel);

            //����ȡ����ȡ��ӽ�perSize��x��y
            //��Ϊxy����mipmap0ʱ���������pagetable���꣬
            x = x - x % perSize;
            y = y - y % perSize;

            var tableSize = pageTable.TableSize;//256
            //���㲻ͬmipmapʱ��Ӧ�������Ĵ�С
            var paddingEffect = tiledTex.PaddingSize*perSize* (realTotalRect.width / tableSize) / tiledTex.TileSize;

            //��ǰ���Ƶ�������ͼ��ʵ�ʵ����ϵ�λ�úʹ�С�����ʾ��Ǵ�feedback�л�ԭ��λ����Ϣ����Ȼ�Ǿ���mipmap�������
            var realRect = new Rect(realTotalRect.xMin + (float)x / tableSize * realTotalRect.width - paddingEffect,
                realTotalRect.yMin + (float)y / tableSize * realTotalRect.height - paddingEffect,
                realTotalRect.width / tableSize * perSize + 2f * paddingEffect,
                realTotalRect.width / tableSize * perSize + 2f * paddingEffect);

            //ʵ�ʵ��ε�rect
            var terRect = Rect.zero;

            terRect.xMin = -environmentSettings.worldSize * 0.5f;
            terRect.yMin = -environmentSettings.worldSize * 0.5f;
            terRect.width = environmentSettings.worldSize;
            terRect.height = environmentSettings.worldSize;

            //��ֹ�������򳬳����η�Χ
            var needDrawRect = realRect;
            needDrawRect.xMin = Mathf.Max(realRect.xMin, terRect.xMin);
            needDrawRect.yMin = Mathf.Max(realRect.yMin, terRect.yMin);
            needDrawRect.xMax = Mathf.Min(realRect.xMax, terRect.xMax);
            needDrawRect.yMax = Mathf.Min(realRect.yMax, terRect.yMax);

            //mipmap0��ʵ������Ĵ�С��ֵ
            var scaleFactor = drawPos.width / realRect.width;

            //��������������ͼ�е�����ʹ�С
            //(needDrawRect.xMin - realRect.xMin)����ȵ�������ж����ؿ��ʱ��
            var position = new Rect(drawPos.x + (needDrawRect.xMin - realRect.xMin) * scaleFactor,
                drawPos.y+(needDrawRect.yMin-realRect.yMin)*scaleFactor,
                needDrawRect.width * scaleFactor, needDrawRect.height * scaleFactor);

            //��������splatmap��
            var scaleOffset = new Vector4(needDrawRect.width / terRect.width, needDrawRect.height / terRect.height,
                (needDrawRect.xMin - terRect.xMin) / terRect.width, (needDrawRect.yMin - terRect.yMin) / terRect.height);

            //����ǰposition���й�һ����Ҳ�������������ͼ��������������ͼ�е�uv����
            float l = position.x * 2.0f / tileTexSize.x - 1;
            float r = (position.x + position.width) / tileTexSize.x - 1;
            float b = position.y * 2.0f / tileTexSize.y - 1;
            float t = (position.y + position.height) / tileTexSize.y - 1;
            var mat = new Matrix4x4();
            mat.m00 = r - l;
            mat.m03 = l;
            mat.m11 = t - b;
            mat.m13 = b;
            mat.m23 = -1;
            mat.m33 = 1;

            Graphics.SetRenderTarget(m_VTTileBuffer, m_DepthBuffer);
            m_DrawTextureMaterial.SetMatrix(ShaderProperties.RVT.vtTileTexMVPID, GL.GetGPUProjectionMatrix(mat, true));
            m_DrawTextureMaterial.SetVector(ShaderProperties.RVT.tileTexScaleOffset, scaleOffset);

            //������������ڵ������������(uv�����žͷ���shader�����ˣ�
            var tileOffset = new Vector4(terRect.width / scaleOffset.x, terRect.height / scaleOffset.y,
                scaleOffset.z * terRect.width, scaleOffset.w * terRect.height);
            m_DrawTextureMaterial.SetVector(ShaderProperties.RVT.tileOffset, tileOffset);
            var tempCB = new CommandBuffer();
            tempCB.DrawMesh(m_Quad, Matrix4x4.identity, m_DrawTextureMaterial, 0);
            Graphics.ExecuteCommandBuffer(tempCB);//DEBUG
        }
        public void Rest()
        {
            tiledTex.Reset();
            m_VTTileBuffer = new RenderBuffer[2];
            m_VTTileBuffer[0] = tiledTex.VTRTs[0].colorBuffer;
            m_VTTileBuffer[1] = tiledTex.VTRTs[1].colorBuffer;
            m_DepthBuffer = tiledTex.VTRTs[0].depthBuffer;
            tileTexSize = new Vector2Int(tiledTex.VTRTs[0].width, tiledTex.VTRTs[0].height);
            pageTable.Reset();
        }

        /// <summary>
        /// �������Pos����ת��Ϊ����rect��Χ�ڶ�Ӧ�ĵؿ�����
        /// </summary>
        /// <param name="pos"></param>
        /// <param name="realRect"></param>
        /// <returns></returns>
        private Vector2Int GetPageSector(Vector2 pos, Rect realRect)
        {
            var sector = new Vector2Int((int)pos.x, (int)pos.y) - new Vector2Int((int)realRect.min.x, (int)realRect.min.y);

            sector.x = (int)(sector.x / CellSize);
            sector.y = (int)(sector.y / CellSize);

            return sector;
        }

        /// <summary>
        /// �����������ת��Ϊ��ӽ���changViewDis�ı���
        /// </summary>
        /// <param name="pos"></param>
        /// <returns></returns>
        private Vector2Int GetFixedCenter(Vector2Int pos)
        {
            return new Vector2Int((int)Mathf.Floor(pos.x / changeViewDis + 0.5f) * (int)changeViewDis,
                                  (int)Mathf.Floor(pos.y / changeViewDis + 0.5f) * (int)changeViewDis);
        }

        /// <summary>
        /// ������ӳ�䵽CellSize�������������ҵ���ǰ���������Cell�ı���������Cell=8,��ζ��[508,515.99]��������512
        /// </summary>
        /// <param name="pos"></param>
        /// <returns></returns>
        private Vector2Int GetFixedPos(Vector3 pos)
        {
            return new Vector2Int((int)Mathf.Floor(pos.x / CellSize + 0.5f) * (int)CellSize,
                                  (int)Mathf.Floor(pos.z / CellSize + 0.5f) * (int)CellSize);
        }


        void InitializeQuadMesh()
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
