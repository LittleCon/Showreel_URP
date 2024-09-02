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