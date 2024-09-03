using System;
using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;

namespace RVTTerrain
{
   /// <summary>
   /// һ��PageLevel����һ������Mipmap��ҳ��
   /// </summary>
    public class PageLevelTable
    {
        /// <summary>
        /// ��ǰҳ��Ԫ�غϼ�
        /// </summary>
        public TableNodeCell[,] cell { get; set; }

        /// <summary>
        /// ��ǰҳ���Mip�ȼ�
        /// </summary>
        public int mipLevel { get; }

        /// <summary>
        /// rect�����ƶ�ʱ��ҳ����xy������Ҫƫ�Ƶ�Ԫ�ظ���
        /// </summary>
        public Vector2Int pageOffset;

        /// <summary>
        /// ��ǰҳ��Ԫ��������
        /// </summary>
        public int nodeCellCount;
        /// <summary>
        /// ��ǰҳ��Ԫ�صĴ�С
        /// </summary>
        public int perCellSize;
        public PageLevelTable(int i,int tableSize)
        {
            pageOffset = Vector2Int.zero;

            mipLevel = i;

            perCellSize = (int)Mathf.Pow(2, i);
        }

        public TableNodeCell Get(int x,int y)
        {
            x /= perCellSize;
            y /= perCellSize;

            x = (x + pageOffset.x) % nodeCellCount;
            y = (y + pageOffset.y) % nodeCellCount;

            return cell[x, y]; 
        }

        public void ChangeViewRect(Vector2Int offset,Action<Vector2Int> invalidatePage)
        {    
            //mipmap����Խ��ҳ������Խ�ͣ��������������֧��һ��ƫ�ƣ���ô��������ҳ��
            if(Mathf.Abs(offset.x)>=nodeCellCount|| Mathf.Abs(offset.y) >= nodeCellCount||offset.x%perCellSize!=0||offset.y%perCellSize!=0)
            {
                for(int i = 0; i < nodeCellCount; i++)
                {
                    for(int j = 0; j < nodeCellCount; j++)
                    {
                        var transXY = GetTransXY(i, j);
                        cell[transXY.x, transXY.y].payLoad.loadRequest = null;
                        invalidatePage(cell[transXY.x, transXY.y].payLoad.tileIndex);
                    }
                    
                }
                pageOffset = Vector2Int.zero;
                return;
            }

            //����ƫ�Ƶ�Ԫ�ظ���
            offset.x /= perCellSize;
            offset.y /= perCellSize;

            #region clipmap
            //С��ƫ�����Ҳ��ҳ��ȫ������Ϊ����Ծ״̬
            if (offset.x > 0)
            {
                for(int i = 0; i < offset.x; i++)
                {
                    for(int j = 0; j < nodeCellCount; j++)
                    {
                        var transXY = GetTransXY(i, j);
                        cell[transXY.x, transXY.y].payLoad.loadRequest = null;
                        invalidatePage(cell[transXY.x, transXY.y].payLoad.tileIndex);
                    }
                }
            }else if (offset.x < 0)
            {
                for(int i = 0; i <= -offset.x; i++)
                {
                    for(int j = 0; j < nodeCellCount; j++)
                    {
                        var transXY = GetTransXY(nodeCellCount - i, j);
                        cell[transXY.x, transXY.y].payLoad.loadRequest = null;
                        invalidatePage(cell[transXY.x, transXY.y].payLoad.tileIndex);
                    }
                }
            }

            if (offset.y > 0)
            {
                for (int i = 0; i <= offset.y; i++)
                {
                    for (int j = 0; j < nodeCellCount; j++)
                    {
                        var transXY = GetTransXY(j, i);
                        cell[transXY.x, transXY.y].payLoad.loadRequest = null;
                        invalidatePage(cell[transXY.x, transXY.y].payLoad.tileIndex);
                    }
                }
            }
            else if (offset.y < 0)
            {
                for (int i = 1; i <= -offset.y; i++)
                {
                    for (int j = 0; j < nodeCellCount; j++)
                    {
                        var transXY = GetTransXY(j, nodeCellCount - i);
                        cell[transXY.x, transXY.y].payLoad.loadRequest = null;
                        invalidatePage(cell[transXY.x, transXY.y].payLoad.tileIndex);
                    }
                }
            }
            #endregion

            pageOffset += offset;

            while (pageOffset.x < 0)
            {
                pageOffset.x += nodeCellCount;
            }

            while (pageOffset.y < 0)
            {
                pageOffset.y += nodeCellCount;
            }

            pageOffset.x %= nodeCellCount;
            pageOffset.y %= nodeCellCount;

        }

        private Vector2Int GetTransXY(int x, int y)
        {
            return new Vector2Int((x + pageOffset.x) % nodeCellCount,
                                  (y + pageOffset.y) % nodeCellCount);
        }
    }

    /// <summary>
    /// ĳ��mipmapLevel��pageTable�е�Ԫ��
    /// </summary>
    public class TableNodeCell
    {
        public PagePayload payLoad;

        public int mipLevel;

        public RectInt Rect { get; set; }
    }

}