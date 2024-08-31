using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using UnityEngine;
using VirtualTexture;

public class RTTerrain : MonoBehaviour
{
    public float Radius = 500;
    public ScaleFactor ChangeViewDis = ScaleFactor.Eighth;
    public PageTable pageTable;


    private Rect realTotalRect;
    public Rect RealTotalRect
    {
        get
        {
            return realTotalRect;
        }
        set
        {
            realTotalRect = value;

            Shader.SetGlobalVector(
            "_VTRealRect",
            new Vector4(realTotalRect.xMin, realTotalRect.yMin, realTotalRect.width, realTotalRect.height));
        }
    }

    /// <summary>
    /// rvt大小*2/最小table大小，通俗理解为可以table划分的数量？
    /// </summary>
    public float CellSize
    {
        get
        {
            return 2 * Radius / pageTable.TableSize;
        }
    }

    private TiledTexture tiledTex;
    private float changeViewDis;

    private void Start()
    {
        pageTable = GetComponent<PageTable>();
        //pageTable.UseFeed = UseFeed;
        changeViewDis = ScaleModeExtensions.ToFloat(ChangeViewDis) * 2 * Radius;//256
        var fixedCenter = GetFixedCenter(GetFixedPos(transform.position));//通过相机的位置找到其最接近的256的倍数,在1024地形大小下,fixedCenter仅有0,256,512,1024
        RealTotalRect = new Rect(fixedCenter.x - Radius, fixedCenter.y - Radius, 2 * Radius, 2 * Radius);//fixedCenter.y - Radius属于[-1024,1024]范围为2048
    }



    /// <summary>
    /// 将输入的坐标转换为最接近的changViewDis的倍数
    /// </summary>
    /// <param name="pos"></param>
    /// <returns></returns>
    private Vector2Int GetFixedCenter(Vector2Int pos)
    {
        return new Vector2Int((int)Mathf.Floor(pos.x / changeViewDis + 0.5f) * (int)changeViewDis,
                              (int)Mathf.Floor(pos.y / changeViewDis + 0.5f) * (int)changeViewDis);
    }

    /// <summary>
    /// 把坐标映射到CellSize的整数倍，即找到当前坐标最靠近的Cell的倍数，例如Cell=8,意味着[508,515.99]都归属到512
    /// </summary>
    /// <param name="pos"></param>
    /// <returns></returns>
    private Vector2Int GetFixedPos(Vector3 pos)
    {
        return new Vector2Int((int)Mathf.Floor(pos.x / CellSize + 0.5f) * (int)CellSize,
                              (int)Mathf.Floor(pos.z / CellSize + 0.5f) * (int)CellSize);
    }
}
