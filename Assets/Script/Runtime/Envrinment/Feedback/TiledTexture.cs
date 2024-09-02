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
        /// TileTexture������ϻص�
        /// </summary>
        public event Action<Vector2Int> onTileUpdateComplete;
    }
}

