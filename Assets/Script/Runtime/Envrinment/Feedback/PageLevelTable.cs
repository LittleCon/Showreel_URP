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

            offset.x /= perCellSize;
            offset.y /= perCellSize;

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

        
    }

}