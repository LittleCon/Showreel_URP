using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PageTable : MonoBehaviour
{
   

    /// <summary>
    /// Ò³±í³ß´ç.
    /// </summary>
    [SerializeField]
    private int m_TableSize = default;




    public int TableSize { get => m_TableSize; }
    public int MaxMipLevel { get { return (int)Mathf.Log(TableSize, 2); } }



}
