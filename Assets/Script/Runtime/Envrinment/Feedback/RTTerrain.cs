using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using Unity.VisualScripting;
using UnityEngine;


namespace RVTTerrain
{
    public class RTTerrain : MonoBehaviour
    {
        public float Radius = 500;
        public ScaleFactor ChangeViewDis = ScaleFactor.Eighth;
        public PageTable pageTable;

        /// <summary>
        /// 是否启用FeedBack
        /// </summary>
        public bool useFeed;


        private FeedbackRenderer feedbackRenderer;
        private FeedbackReader feedbackReader;
        private RenderTextureJob rtJob;

        private Mesh m_Quad;


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
        /// rvt大小*2/最小table大小，通俗理解为可以table划分的数量？
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
        /// TileTexture中的albedo和normal
        /// </summary>
        private RenderBuffer[] m_VTTileBuffer;

        /// <summary>
        /// 好像没什么用的深度图，因为m_VTTileBuffer中设置了renderbuffer没有深度，看起来像是为了凑参数用的
        /// </summary>
        private RenderBuffer m_DepthBuffer;

        /// <summary>
        /// 缓存物理贴图的大小
        /// </summary>
        private Vector2Int tileTexSize;

        private void Start()
        {
            pageTable = GetComponent<PageTable>();
            feedbackRenderer = GetComponent<FeedbackRenderer>();
            feedbackReader = GetComponent<FeedbackReader>();
            tiledTex = GetComponent<TiledTexture>();
            rtJob = new RenderTextureJob();

            pageTable.Init(rtJob);
            tiledTex.Init();
            tiledTex.DoDrawTexture += DrawTexture;

            
            InitializeQuadMesh();
            //pageTable.UseFeed = UseFeed;
            changeViewDis = ScaleModeExtensions.ToFloat(ChangeViewDis) * 2 * Radius;//256
            var fixedCenter = GetFixedCenter(GetFixedPos(transform.position));//通过相机的位置找到其最接近的256的倍数,在1024地形大小下,fixedCenter仅有0,256,512,1024
            RealTotalRect = new Rect(fixedCenter.x - Radius, fixedCenter.y - Radius, 2 * Radius, 2 * Radius);//fixedCenter.y - Radius属于[-1024,1024]范围为2048


            m_VTTileBuffer = new RenderBuffer[2];
            m_VTTileBuffer[0] = tiledTex.VTRTs[0].colorBuffer;
            m_VTTileBuffer[1] = tiledTex.VTRTs[1].colorBuffer;
            m_DepthBuffer = tiledTex.VTRTs[0].depthBuffer;
            tileTexSize = new Vector2Int(tiledTex.VTRTs[0].width, tiledTex.VTRTs[0].height);
        }


        private void Update()
        {
            //找到最小地块单元（PageTable中一个页对应的地块大小）
            var fixedPos = GetFixedPos(transform.position);
            //和上一帧位置关系
            var xDiff = fixedPos.x - RealTotalRect.center.x;
            var yDiff = fixedPos.y - RealTotalRect.center.y;

            //如果当前帧的位置已经超出了PageTable界限值，需要判断是否需要重新计算pagetable
            if (Mathf.Abs(xDiff) > changeViewDis || Mathf.Abs(yDiff) > changeViewDis)
            {
                //计算新的Rect中心
                var fixedCenter = GetFixedCenter(fixedPos);

                //新的中心!=旧中心，说明需要更新PageTable及物理贴图
                if (fixedCenter != RealTotalRect.center)
                {
                    rtJob.ClearJob();

                    var oldCenter = new Vector2Int((int)RealTotalRect.center.x, (int)RealTotalRect.center.y);

                    RealTotalRect = new Rect(fixedCenter.x - Radius, fixedCenter.y - Radius, 2 * Radius,2 * Radius);

                    //(2 * (int)Radius / pageTable.TableSize)代表一个pageTable对应的地块大小
                    //当前rect中心点和之前中心点的距离差，需要偏移多少个pageTable中的元素
                    //即rect发生偏移时，代表有新的页表要处于活跃状态，旧的不在范围内的页表要设置为不活跃状态
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


        private void DrawTexture(RectInt drawPos,RenderTextureRequest request)
        {
            //pageTable中的像素，pageTable一个像素对应一个tileTexture，因此这里也代表tileTexture中的二维坐标（按个数划分的）
            int x = request.pageX;
            int y = request.pageY;

            //获取该Mipmaplevel物理贴图的一个的尺寸
            int perSize = (int)Mathf.Pow(2, request.mipmapLevel);

            //向下取整获取最接近perSize的x、y
            x = x - x % perSize;
            y = y - x % perSize;

            var tableSize = pageTable.TableSize;//256
            //计算填充效果，用于调整绘制区域的大小以避免纹理接缝。
            var paddingEffect = tiledTex.PaddingSize*perSize* (realTotalRect.width / tableSize) / tiledTex.TileSize;
        }


        /// <summary>
        /// 将传入的Pos坐标转换为其在rect范围内对应的地块索引
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
        /// 将输入的坐标转换为最接近的changViewDis的倍数
        /// </summary>
        /// <param name="pos"></param>
        /// <returns></returns>
        private Vector2Int GetFixedCenter(Vector2Int pos)
        {
            return new Vector2Int((int)Mathf.Floor(pos.x / changeViewDis + 0.5f) * (int)changeViewDis,
                                  (int)Mathf.Floor(pos.y / changeViewDis + 0.5f) * (int)changeViewDis);
        }

        /// <summary>
        /// 把坐标映射到CellSize的整数倍，即找到当前坐标最靠近的Cell的倍数，例如Cell=8,意味着[508,515.99]都归属到512
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
