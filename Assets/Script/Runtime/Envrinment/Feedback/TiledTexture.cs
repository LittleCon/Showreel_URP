using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace RVTTerrain
{
    public class TiledTexture : MonoBehaviour
    {

        /// <summary>
        /// ��Tile���¼�.
        /// </summary>
        public event Action<RectInt, RenderTextureRequest> DoDrawTexture;
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

        /// <summary>
		/// ���ߴ�
		/// </summary>
		[SerializeField]
        private int m_PaddingSize = 4;
        /// <summary>
		/// ���ߴ�
		/// ÿ��Tile���������ĸ�����Ҫ������䣬����֧��Ӳ���������.
		/// ����Tile��Ч�ߴ�Ϊ(TileSize - PaddingSize * 2)
		/// </summary>
		public int PaddingSize { get { return m_PaddingSize; } }

        public int TileSizeWithPadding { get { return TileSize + PaddingSize * 2; } }

        /// <summary>
        /// ʵ��������ͼ��һ�㳤��Ϊ2��һ�ݷ�����ͼһ��albedo
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


            // ����Shader����
            // x: paddingƫ����
            // y: tile��Ч����ĳߴ�
            // zw: 1/����ߴ�
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

            DoDrawTexture?.Invoke(new RectInt(tile.x * TileSizeWithPadding, tile.y * TileSizeWithPadding, TileSizeWithPadding, TileSizeWithPadding),request);
            onTileUpdateComplete?.Invoke(tile);
        }
    }
}

