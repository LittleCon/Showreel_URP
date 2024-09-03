using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace RVTTerrain
{
    public class TiledTexture : MonoBehaviour
    {
        /// <summary>
        /// 单个Tile的尺寸.
        /// </summary>
        [SerializeField]
        private int m_TileSize = 256;
        public int TileSize => m_TileSize;

        /// <summary>
        /// 区域尺寸.
        /// </summary>
        [SerializeField]
        private Vector2Int m_RegionSize = default;

        /// <summary>
		/// 区域尺寸.
		/// 区域尺寸表示横竖两个方向上Tile的数量.
		/// </summary>
		public Vector2Int RegionSize { get { return m_RegionSize; } }

        /// <summary>
        /// Tile缓存池.
        /// </summary>
        private LruCache m_TilePool = new LruCache();

        /// <summary>
        /// TileTexture更新完毕回调
        /// </summary>
        public event Action<Vector2Int> onTileUpdateComplete;


        public bool SetActive(Vector2Int tile)
        {
            bool success = m_TilePool.SetActive(PosToId(tile));

            return success;
        }

        /// <summary>
        /// 将输入的tileIndex转换为其在物理贴图中的索引
        /// </summary>
        /// <param name="tile"></param>
        /// <returns></returns>
        private int PosToId(Vector2Int tile)
        {
            return (tile.y * RegionSize.x + tile.x);
        }

        /// <summary>
        /// 将索引转换为TileIndex
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        private Vector2Int IdToPos(int id)
        {
            return new Vector2Int(id % RegionSize.x, id / RegionSize.x);
        }



        public Vector2Int RequestTile()
        {
            return IdToPos(m_TilePool.First);
        }

        public void UpdateTile(Vector2Int tile,RenderTextureRequest request)
        {
            //非活跃节点
            if (!SetActive(tile)) return;

            //DodrawTexture?.Invoke(new RectInt(tile.x*Tiles))
        }
    }
}

