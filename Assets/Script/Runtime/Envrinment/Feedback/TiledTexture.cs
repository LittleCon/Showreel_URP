using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace RVTTerrain
{
    public class TiledTexture : MonoBehaviour
    {
        /// <summary>
        /// ����Tile�ĳߴ�.
        /// </summary>
        [SerializeField]
        private int m_TileSize = 256;
        public int TileSize => m_TileSize;

        /// <summary>
        /// ����ߴ�.
        /// </summary>
        [SerializeField]
        private Vector2Int m_RegionSize = default;

        /// <summary>
		/// ����ߴ�.
		/// ����ߴ��ʾ��������������Tile������.
		/// </summary>
		public Vector2Int RegionSize { get { return m_RegionSize; } }

        /// <summary>
        /// Tile�����.
        /// </summary>
        private LruCache m_TilePool = new LruCache();

        /// <summary>
        /// TileTexture������ϻص�
        /// </summary>
        public event Action<Vector2Int> onTileUpdateComplete;


        public bool SetActive(Vector2Int tile)
        {
            bool success = m_TilePool.SetActive(PosToId(tile));

            return success;
        }

        private int PosToId(Vector2Int tile)
        {
            return (tile.y * RegionSize.x + tile.x);
        }
    }
}

