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
        /// TileTexture更新完毕回调
        /// </summary>
        public event Action<Vector2Int> onTileUpdateComplete;
    }
}

