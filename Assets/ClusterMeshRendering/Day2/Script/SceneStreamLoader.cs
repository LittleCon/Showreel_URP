using System.Collections;
using System.Collections.Generic;
using System.IO;
using Unity.Collections;
using Unity.Collections.LowLevel.Unsafe;
using Unity.Mathematics;
using static CommonData;
/// <summary>
/// 管理每个场景的ClusterMesh加载
/// </summary>
public unsafe struct SceneStreamLoader 
{
    public FileStream fsm;
    public int clusterCount;
    //Unity中GUID统一为32个字符（一个字符2个字节），即64bit。
    //刚好使用int4x4能够被记录，这里是映射过来的，提高性能(相比较查询int4x4比查询string更快)
    public NativeList<int4x4> albedoGUIDs;
    public NativeList<int4x4> normalGUIDs;
    public NativeList<int4x4> masGUIDs;
    public NativeList<VirtualMaterial.MaterialProperties> allProperties;
    public NativeList<Cluster> cluster;
    public NativeList<Point> points;
    public NativeList<int> triangleMats;
    public static byte[] bytesArray = new byte[8192];
    
    /// <summary>
    /// 保存整个场景的材质数据，保存为二进制
    /// </summary>
    /// <param name="sceneName"></param>
    public void SaveAll(string sceneName)
    {
        SaveClusterCount(sceneName);
        SaveGUIDArray(albedoGUIDs);
        SaveGUIDArray(normalGUIDs);
        SaveGUIDArray(masGUIDs);
        SaveMaterialArray(allProperties);
        SaveClusterData(cluster, points, triangleMats);
    }
    
    /// <summary>
    /// 保存由网格生成的Cluster数据、顶点数据、三角形数据
    /// </summary>
    /// <param name="cluster"></param>
    /// <param name="points"></param>
    /// <param name="triangleMats"></param>
    void SaveClusterData(NativeList<Cluster> cluster, NativeList<Point> points, NativeList<int> triangleMats)
    {
        int length = cluster.Length * sizeof(Cluster) + points.Length * sizeof(Point) + triangleMats.Length * sizeof(int);
        byte[] bytes = GetByteArray(length);
        fixed (byte* b = bytes)
        {
            UnsafeUtility.MemCpy(b, cluster.unsafePtr, cluster.Length * sizeof(Cluster));
            UnsafeUtility.MemCpy(b + cluster.Length * sizeof(Cluster), points.unsafePtr, points.Length * sizeof(Point));
            UnsafeUtility.MemCpy(b + cluster.Length * sizeof(Cluster) + points.Length * sizeof(Point), triangleMats.unsafePtr, triangleMats.Length * sizeof(int));
        }
        fsm.Write(bytes, 0, length);
    }
    
    /// <summary>
    /// 保存材质中的除贴图的其他属性
    /// </summary>
    /// <param name="arr"></param>
    void SaveMaterialArray(NativeList<VirtualMaterial.MaterialProperties> arr)
    {
        byte[] cacheArray = GetByteArray(arr.Length * sizeof(VirtualMaterial.MaterialProperties) + sizeof(int));
        int* intPtr = (int*)cacheArray.Ptr();
        *intPtr = arr.Length;
        UnsafeUtility.MemCpy(intPtr + 1, arr.unsafePtr, sizeof(VirtualMaterial.MaterialProperties) * arr.Length);
        fsm.Write(cacheArray, 0, arr.Length * sizeof(VirtualMaterial.MaterialProperties) + sizeof(int));
    }
    
    /// <summary>
    /// 获取一个二进制数组，该数组默认长度为8192。
    /// </summary>
    /// <param name="length"></param>
    /// <returns></returns>
    public static byte[] GetByteArray(int length)
    {
        if (bytesArray == null || bytesArray.Length < length)
        {
            bytesArray = new byte[length];
        }
        return bytesArray;
    }
    
    /// <summary>
    /// 保存场景的ClusterCount数量，转换成字节数组保存
    /// </summary>
    /// <param name="sceneName"></param>
    void SaveClusterCount(string sceneName)
    {
        byte[] bytes =GetByteArray(4);
        *(int*)bytes.Ptr() = clusterCount;
        if (fsm == null)
        {
            fsm = File.Create($"Assets/ClusterMeshRendering/Day2/Data/{sceneName}.mpipe");
        }
        fsm.Write(bytes, 0, 4);
    }
    
    /// <summary>
    /// 将转换成int4x4的GUID转换为字节存储，在此处是将贴图的GUID保存
    /// </summary>
    /// <param name="arr"></param>
    void SaveGUIDArray(NativeList<int4x4> arr)
    {
        byte[] cacheArray = GetByteArray(arr.Length * sizeof(int4x4) + sizeof(int));
        int* intPtr = (int*)cacheArray.Ptr();
        //将数组的长度写入数组的第一个元素
        *intPtr = arr.Length;
        //将arr.unsafePtr地址中的数据复制到intPtr+1地址中，sizeof(int4x4) * arr.Length是复制的数据长度
        UnsafeUtility.MemCpy(intPtr + 1, arr.unsafePtr, sizeof(int4x4) * arr.Length);
        //写入数据
        fsm.Write(cacheArray, 0, arr.Length * sizeof(int4x4) + sizeof(int));
    }
    
    public void Dispose()
    {
        albedoGUIDs.Dispose();
        normalGUIDs.Dispose();
        masGUIDs.Dispose();
        allProperties.Dispose();
        cluster.Dispose();
        points.Dispose();
        triangleMats.Dispose();
        if (fsm != null) fsm.Dispose();
    }
}
