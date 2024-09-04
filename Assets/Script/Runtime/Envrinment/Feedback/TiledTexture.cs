using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace RVTTerrain
{
    public class TiledTexture : MonoBehaviour
    {

        /// <summary>
        /// 画Tile的事件.
        /// </summary>
        public event Action<RectInt, RenderTextureRequest> DoDrawTexture;
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

        /// <summary>
		/// 填充尺寸
		/// </summary>
		[SerializeField]
        private int m_PaddingSize = 4;
        /// <summary>
		/// 填充尺寸
		/// 每个Tile上下左右四个方向都要进行填充，用来支持硬件纹理过滤.
		/// 所以Tile有效尺寸为(TileSize - PaddingSize * 2)
		/// </summary>
		public int PaddingSize { get { return m_PaddingSize; } }

        public int TileSizeWithPadding { get { return TileSize + PaddingSize * 2; } }

        /// <summary>
        /// 实际物理贴图，一般长度为2，一份法线贴图一份albedo
        /// </summary>
        public RenderTexture[] VTRTs;
        public void Init()
        {
            m_TilePool.Init(RegionSize.x * RegionSize.y);
            VTRTs = new RenderTexture[2];

            VTRTs[0] = new RenderTexture(RegionSize.x * TileSizeWithPadding, RegionSize.y * TileSizeWithPadding, 0);
            VTRTs[0].useMipMap = false;
            VTRTs[0].wrapMode = TextureWrapMode.Clamp;
            Shader.SetGlobalTexture("_VTDiffuse", VTRTs[0]);


            VTRTs[1] = new RenderTexture(RegionSize.x * TileSizeWithPadding, RegionSize.y * TileSizeWithPadding, 0);
            VTRTs[1].useMipMap = false;
            VTRTs[1].wrapMode = TextureWrapMode.Clamp;
            Shader.SetGlobalTexture("_VTNormal", VTRTs[1]);


            // 设置Shader参数
            // x: padding偏移量
            // y: tile有效区域的尺寸
            // zw: 1/区域尺寸
            Shader.SetGlobalVector("_VTTileParam", new Vector4((float)PaddingSize, (float)TileSize, RegionSize.x * TileSizeWithPadding, RegionSize.y * TileSizeWithPadding));
        }

        public void Reset()
        {
            m_TilePool.Init(RegionSize.x * RegionSize.y);

            m_TilePool.Init(RegionSize.x * RegionSize.y);
            VTRTs = new RenderTexture[2];

            VTRTs[0] = new RenderTexture(RegionSize.x * TileSizeWithPadding, RegionSize.y * TileSizeWithPadding, 0);
            VTRTs[0].useMipMap = false;
            VTRTs[0].wrapMode = TextureWrapMode.Clamp;
            Shader.SetGlobalTexture("_VTDiffuse", VTRTs[0]);


            VTRTs[1] = new RenderTexture(RegionSize.x * TileSizeWithPadding, RegionSize.y * TileSizeWithPadding, 0);
            VTRTs[1].useMipMap = false;
            VTRTs[1].wrapMode = TextureWrapMode.Clamp;
            Shader.SetGlobalTexture("_VTNormal", VTRTs[1]);
        }

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

            DoDrawTexture?.Invoke(new RectInt(tile.x * TileSizeWithPadding, tile.y * TileSizeWithPadding, TileSizeWithPadding, TileSizeWithPadding),request);
            onTileUpdateComplete?.Invoke(tile);
        }
    }
}

