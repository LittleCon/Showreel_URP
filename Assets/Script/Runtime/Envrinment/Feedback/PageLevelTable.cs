using System;
using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;

namespace RVTTerrain
{
   /// <summary>
   /// 一个PageLevel代表一个级别Mipmap的页表
   /// </summary>
    public class PageLevelTable
    {
        /// <summary>
        /// 当前页的元素合集
        /// </summary>
        public TableNodeCell[,] cell { get; set; }

        /// <summary>
        /// 当前页表的Mip等级
        /// </summary>
        public int mipLevel { get; }

        /// <summary>
        /// rect发生移动时，页表在xy轴上需要偏移的元素个数
        /// </summary>
        public Vector2Int pageOffset;

        /// <summary>
        /// 当前页的元素总数量
        /// </summary>
        public int nodeCellCount;
        /// <summary>
        /// 当前页表元素的大小
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
            //mipmap级别越高页表数量越低，如果数量不足以支撑一个偏移，那么重新生成页表
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

            //计算偏移的元素个数
            offset.x /= perCellSize;
            offset.y /= perCellSize;

            #region clipmap
            //小于偏移量右侧的页表全部设置为不活跃状态
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
    /// 某级mipmapLevel的pageTable中的元素
    /// </summary>
    public class TableNodeCell
    {
        public PagePayload payLoad;

        public int mipLevel;

        public RectInt Rect { get; set; }
    }

}