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
    }

    /// <summary>
    /// ĳ��mipmapLevel��pageTable�е�Ԫ��
    /// </summary>
    public class TableNodeCell
    {
        public PagePayload payLoad;

        public int mipLevel;
    }

}