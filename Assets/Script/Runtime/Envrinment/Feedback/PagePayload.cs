using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace RVTTerrain
{
    /// <summary>
    /// ҳ����Ԫ�ض�Ӧ��������
    /// </summary>
    public class PagePayload
    {
        /// <summary>
        /// Ԫ��Ϊ�ǻ�Ծ״̬ʱ����Ӧ������Ϊ�Ƿ�����
        /// </summary>
        private static Vector2Int s_InvalidTileIndex = new Vector2Int(-1, -1);

        /// <summary>
        /// �����֡���
        /// </summary>
        public int ActiveFrame;

        /// <summary>
        /// ����Ĭ��Ԫ�ض��Ƿǻ�ԾԪ��
        /// </summary>
        public Vector2Int tileIndex = s_InvalidTileIndex;

        /// <summary>
        /// �Ƿ��ڿ���״̬
        /// </summary>
        public bool isReady => tileIndex != s_InvalidTileIndex;

        /// <summary>
        /// �����ݶ�Ӧ����Ⱦ����
        /// </summary>
        public RenderTextureRequest loadRequest;

        /// <summary>
        /// ����ҳ�����ݣ�������Ϊ�ǻ�Ծ״̬
        /// </summary>
        public void ResetTileIndex()
        {
            tileIndex = s_InvalidTileIndex;
        }
    }

}