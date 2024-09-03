using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace RVTTerrain
{
    /// <summary>
    /// 页表中元素对应的数据类
    /// </summary>
    public class PagePayload
    {
        /// <summary>
        /// 元素为非活跃状态时，对应的索引为非法索引
        /// </summary>
        private static Vector2Int s_InvalidTileIndex = new Vector2Int(-1, -1);

        /// <summary>
        /// 激活的帧序号
        /// </summary>
        public int ActiveFrame;

        /// <summary>
        /// 代表默认元素都是非活跃元素
        /// </summary>
        public Vector2Int tileIndex = s_InvalidTileIndex;

        /// <summary>
        /// 是否处于可用状态
        /// </summary>
        public bool isReady => tileIndex != s_InvalidTileIndex;

        /// <summary>
        /// 该数据对应的渲染请求
        /// </summary>
        public RenderTextureRequest loadRequest;

        /// <summary>
        /// 重置页表数据，即让其为非活跃状态
        /// </summary>
        public void ResetTileIndex()
        {
            tileIndex = s_InvalidTileIndex;
        }
    }

}