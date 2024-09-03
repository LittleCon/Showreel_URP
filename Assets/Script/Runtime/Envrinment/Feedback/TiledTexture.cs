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

        /// <summary>
        /// �������tileIndexת��Ϊ����������ͼ�е�����
        /// </summary>
        /// <param name="tile"></param>
        /// <returns></returns>
        private int PosToId(Vector2Int tile)
        {
            return (tile.y * RegionSize.x + tile.x);
        }

        /// <summary>
        /// ������ת��ΪTileIndex
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
            //�ǻ�Ծ�ڵ�
            if (!SetActive(tile)) return;

            //DodrawTexture?.Invoke(new RectInt(tile.x*Tiles))
        }
    }
}

