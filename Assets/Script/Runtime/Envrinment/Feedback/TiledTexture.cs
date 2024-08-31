using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TiledTexture : MonoBehaviour
{
    /// <summary>
    /// µ¥¸öTileµÄ³ß´ç.
    /// </summary>
    [SerializeField]
    private int m_TileSize = 256;


    public int TileSize => m_TileSize;
}
