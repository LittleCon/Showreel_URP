using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using UnityEngine;


namespace RVTTerrain
{
    public class RTTerrain : MonoBehaviour
    {
        public float Radius = 500;
        public ScaleFactor ChangeViewDis = ScaleFactor.Eighth;
        public PageTable pageTable;

        private RenderTextureJob rtJob;


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

        private void Start()
        {
            pageTable = GetComponent<PageTable>();
            //pageTable.UseFeed = UseFeed;
            changeViewDis = ScaleModeExtensions.ToFloat(ChangeViewDis) * 2 * Radius;//256
            var fixedCenter = GetFixedCenter(GetFixedPos(transform.position));//ͨ�������λ���ҵ�����ӽ���256�ı���,��1024���δ�С��,fixedCenter����0,256,512,1024
            RealTotalRect = new Rect(fixedCenter.x - Radius, fixedCenter.y - Radius, 2 * Radius, 2 * Radius);//fixedCenter.y - Radius����[-1024,1024]��ΧΪ2048

            rtJob = new RenderTextureJob();
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

                    pageTable.change
                }
            }
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
    }

}
