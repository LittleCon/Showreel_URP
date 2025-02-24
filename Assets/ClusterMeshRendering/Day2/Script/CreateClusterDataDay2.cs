#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using Unity.Collections;
using Unity.Mathematics;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using static CommonData;

public unsafe class CreateClusterDataDay2 : MonoBehaviour
{
    public const string infosPath = "Assets/ClusterMeshRendering/Day2/Data/";
    public ClusterMatResources clusterMatResources;
    [Range(100, 500)]
    public int voxelCount = 100;
    public struct CombinedModel
    {
        public NativeList<Point> allPoints;
        public NativeList<int> allMatIndex;
        public Bounds bound;
    }
    [EasyButtons.Button]
    public void CreateClusterData()
    {
        bool save = false;
        string fileName = infosPath + EditorSceneManager.GetActiveScene().name + ".mpipe";
        if (!clusterMatResources)
        {
            clusterMatResources = AssetDatabase.LoadAssetAtPath<ClusterMatResources>(infosPath+"SceneManager.asset");
        }
        if (!clusterMatResources)
        {
            save = true;
            clusterMatResources = ScriptableObject.CreateInstance<ClusterMatResources>();
            clusterMatResources.name = "SceneManager";
        }
        
        SceneStreamLoader loader = new SceneStreamLoader();
        CombinedModel model = CreateMeshData(ref loader);
        loader.clusterCount = GenerateCluster(model.allPoints, model.allMatIndex, model.bound, voxelCount, ref loader);
        clusterMatResources.maximumMaterialCount = Mathf.Max(1, clusterMatResources.maximumMaterialCount);
        clusterMatResources.maximumMaterialCount = Mathf.Max(clusterMatResources.maximumMaterialCount, loader.allProperties.Length);
        
        if (save)
            AssetDatabase.CreateAsset(clusterMatResources, infosPath+"SceneManager.asset");
        else
            EditorUtility.SetDirty(clusterMatResources);
        loader.SaveAll(EditorSceneManager.GetActiveScene().name);
        loader.Dispose();
    }

    public static int GenerateCluster(NativeList<Point> pointsFromMesh, NativeList<int> mats, Bounds bd, int voxelCount, ref SceneStreamLoader loader)
    {
        NativeList<Cluster> boxes; NativeList<Point> points; NativeList<int> outMats;
        GetCluster(pointsFromMesh, mats, bd, out boxes, out points, out outMats, voxelCount);
        loader.cluster = boxes;
        loader.points = points;
        loader.triangleMats = outMats;
        //Dispose Native Array
        return boxes.Length;
    }

    public static void GetCluster(NativeList<Point> pointsFromMesh, NativeList<int> materialsFromMesh, Bounds bd, out NativeList<Cluster> boxes, out NativeList<Point> points, out NativeList<int> outMats, int voxelCount)
    {
        NativeList<UnsafeData.Triangle> trs = GenerateTriangle(pointsFromMesh, materialsFromMesh);
        UnsafeData.Voxel[,,] voxels = GetVoxelData(trs, voxelCount, bd);
        GetClusterFromVoxel(voxels, out boxes, out points, out outMats, pointsFromMesh.Length, voxelCount);
    }
    
    /// <summary>
    /// 通过三角形数组转换到体素数组中
    /// </summary>
    /// <param name="trianglesFromMesh"></param>
    /// <param name="voxelCount"></param>
    /// <param name="bound"></param>
    /// <returns></returns>
    private static UnsafeData.Voxel[,,] GetVoxelData(NativeList<UnsafeData.Triangle> trianglesFromMesh, int voxelCount, Bounds bound)
    {
        //构建体素网格
        UnsafeData.Voxel[,,] voxels = new UnsafeData.Voxel[voxelCount, voxelCount, voxelCount];
        for (int x = 0; x < voxelCount; ++x)
            for (int y = 0; y < voxelCount; ++y)
                for (int z = 0; z < voxelCount; ++z)
                {
                    voxels[x, y, z] = new UnsafeData.Voxel();
                }
        //bounds的起点，同时也是即该体素的起点
        float3 downPoint = bound.center - bound.extents;
        for (int i = 0; i < trianglesFromMesh.Length; ++i)
        {
            var tr =  trianglesFromMesh[i];
            //计算三角形的中心
            float3 position = (tr.a.vertex + tr.b.vertex + tr.c.vertex) / 3;
            //将三角形的中心坐标转换到bounds空间下，并归一化
            float3 localPos = math.saturate((position - downPoint) / bound.size);
            //再将bounds空间坐标转换到体素的索引
            int3 coord = (int3)(localPos * voxelCount);
            //防止坐标越界
            coord = math.min(coord, voxelCount - 1);
            //将三角形指针添加到体素坐标中
            voxels[coord.x, coord.y, coord.z].Add(tr.Ptr());
            trianglesFromMesh[i] = tr;

        }
        return voxels;
    }
     /// <summary>
     ///从体素数据中生成Cluster数据
     /// </summary>
     /// <param name="voxels"></param>
     /// <param name="Clusteres"></param>
     /// <param name="points"></param>
     /// <param name="matIndex"></param>
     /// <param name="vertexCount">模型的Mesh*1.2之后的大小</param>
     /// <param name="voxelSize"></param>
       private static void GetClusterFromVoxel(UnsafeData.Voxel[,,] voxels, out NativeList<Cluster> Clusteres, out NativeList<Point> points, out NativeList<int> matIndex, int vertexCount, int voxelSize)
        {
            int3 voxelCoord = 0;
            float3 lessPoint = float.MaxValue;
            float3 morePoint = float.MinValue;
            //最多生成多少个Cluster
            int clusterCount = Mathf.CeilToInt((float)vertexCount / ClusterRenderingConfigs.CLUSTERCLIPCOUNT);
            points = new NativeList<Point>(clusterCount * ClusterRenderingConfigs.CLUSTERCLIPCOUNT, Allocator.Temp);
            matIndex = new NativeList<int>(clusterCount * ClusterRenderingConfigs.CLUSTERTRIANGLECOUNT, Allocator.Temp);
            Clusteres = new NativeList<Cluster>(clusterCount, Allocator.Temp);
            //生成每一个Cluster数据
            for (int i = 0; i < clusterCount - 1; ++i)
            {
                //单个Cluster数据
                NativeList<Point> currentPoints = new NativeList<Point>(ClusterRenderingConfigs.CLUSTERCLIPCOUNT, Allocator.Temp);
                //cluster对应的Material索引
                NativeList<int> currentMatIndex = new NativeList<int>(ClusterRenderingConfigs.CLUSTERTRIANGLECOUNT, Allocator.Temp);
                //一个Cluster最多三角形的个数
                int lastedVertex = ClusterRenderingConfigs.CLUSTERCLIPCOUNT / 3;
                //获取体素数据
                ref UnsafeData.Voxel currentVoxel = ref voxels[voxelCoord.x, voxelCoord.y, voxelCoord.z];
                //确保一个体素中不会超过最大记录的三角形个数
                int loopStart = math.min(currentVoxel.count, math.max(lastedVertex - currentVoxel.count, 0));
                
                //从当前体素网格中弹出一个三角形，并记录到当前的Cluster数据中
                for (int j = 0; j < loopStart; j++)
                {
                    UnsafeData.Triangle* tri = currentVoxel.Pop();
                    currentPoints.Add(tri->a);
                    currentPoints.Add(tri->b);
                    currentPoints.Add(tri->c);
                    currentMatIndex.Add(tri->materialID);
                }
                lastedVertex -= loopStart;
                
                //如果当前体素记录的三角形全部弹出后，Cluster还没有满，那么开始遍历下一个体素网格
                for (int size = 1; lastedVertex > 0; size++)
                {
                    int3 leftDown = math.max(voxelCoord - size, 0);
                    int3 rightUp = math.min(voxelSize, voxelCoord + size);
                    for (int x = leftDown.x; x < rightUp.x; ++x)
                        for (int y = leftDown.y; y < rightUp.y; ++y)
                            for (int z = leftDown.z; z < rightUp.z; ++z)
                            {
                                ref UnsafeData.Voxel vxl = ref voxels[x, y, z];
                                int vxlCount = vxl.count;
                                for (int j = 0; j < vxlCount; ++j)
                                {
                                    voxelCoord = math.int3(x, y, z);
                                    UnsafeData.Triangle* tri = vxl.Pop();
                                    //   try
                                    // {
                                    currentPoints.Add(tri->a);
                                    currentPoints.Add(tri->b);
                                    currentPoints.Add(tri->c);
                                    currentMatIndex.Add(tri->materialID);
                                    /* }
                                     catch
                                     {
                                         Debug.Log(vxlCount);
                                         Debug.Log(tri->a);
                                         Debug.Log(tri->b);
                                         Debug.Log(tri->c);
                                         Debug.Log(currentPoints.Length);
                                         return;
                                     }*/
                                    lastedVertex--;
                                    if (lastedVertex <= 0) goto CONTINUE;
                                }
                            }
            
                }
                //如果当前Cluster已经记录满了，跳转到此处，此处将本次循环的Cluster数据保存
            CONTINUE:
                points.AddRange(currentPoints);
                matIndex.AddRange(currentMatIndex);
                lessPoint = float.MaxValue;
                morePoint = float.MinValue;
                foreach (var j in currentPoints)
                {
                    lessPoint = math.lerp(lessPoint, j.vertex, (int3)(lessPoint > j.vertex));
                    morePoint = math.lerp(morePoint, j.vertex, (int3)(morePoint < j.vertex));
                }
                Cluster cb = new Cluster
                {
                    extent = (morePoint - lessPoint) / 2,
                    position = (morePoint + lessPoint) / 2
                };
                Clusteres.Add(cb);
                currentPoints.Dispose();
                currentMatIndex.Dispose();
            }
            
            //最后一个Cluster记录体素网格中剩余的三角形。（猜测是预防一个体素中出现的三角形大于一个Cluster中最多存放值时处理的用的）
            NativeList<Point> leftedPoints = new NativeList<Point>(ClusterRenderingConfigs.CLUSTERCLIPCOUNT, Allocator.Temp);
            NativeList<int> leftedMatID = new NativeList<int>(ClusterRenderingConfigs.CLUSTERTRIANGLECOUNT, Allocator.Temp);
            for (int x = 0; x < voxelSize; ++x)
                for (int y = 0; y < voxelSize; ++y)
                    for (int z = 0; z < voxelSize; ++z)
                    {
                        ref UnsafeData.Voxel vxl = ref voxels[x, y, z];
                        int vxlCount = vxl.count;
                        for (int j = 0; j < vxlCount; ++j)
                        {
                            UnsafeData.Triangle* tri = vxl.Pop();
                            leftedPoints.Add(tri->a);
                            leftedPoints.Add(tri->b);
                            leftedPoints.Add(tri->c);
                            leftedMatID.Add(tri->materialID);
            
                        }
                    }
            if (leftedPoints.Length <= 0) return;
            lessPoint = float.MaxValue;
            morePoint = float.MinValue;
            foreach (var j in leftedPoints)
            {
                lessPoint = math.lerp(lessPoint, j.vertex, (int3)(lessPoint > j.vertex));
                morePoint = math.lerp(morePoint, j.vertex, (int3)(morePoint < j.vertex));
            }
            Cluster lastBox = new Cluster
            {
                extent = (morePoint - lessPoint) / 2,
                position = (morePoint + lessPoint) / 2
            };
            Clusteres.Add(lastBox);
            for (int i = leftedPoints.Length; i < ClusterRenderingConfigs.CLUSTERCLIPCOUNT; i++)
            {
                leftedPoints.Add(new Point());
            }
            for(int i = leftedMatID.Length; i < ClusterRenderingConfigs.CLUSTERTRIANGLECOUNT; ++i)
            {
                leftedMatID.Add(0);
            }
            points.AddRange(leftedPoints);
            matIndex.AddRange(leftedMatID);
        }
             
   

       
        
    /// <summary>
    /// 通过CombindeModel中的顶点数组生成对应的三角形数组。
    /// </summary>
    /// <param name="points"></param>
    /// <param name="materialID"></param>
    /// <returns></returns>
    private static NativeList<UnsafeData.Triangle> GenerateTriangle(NativeList<Point> points, NativeList<int> materialID)
    {
        NativeList<UnsafeData.Triangle> retValue = new NativeList<UnsafeData.Triangle>(points.Length / 3, Allocator.Temp);
        for (int i = 0; i < points.Length; i += 3)
        {
            UnsafeData.Triangle tri = new UnsafeData.Triangle
            {
                a = points[i],
                b = points[i + 1],
                c = points[i + 2],
                materialID = materialID[i / 3],
                last = null,
                next = null
            };
            retValue.Add(tri);
        }
        return retValue;
    }
    
    /// <summary>
    /// 获取顶点数据，三角形数据，材质球数据，包围盒数据
    /// </summary>
    /// <param name="loader"></param>
    /// <returns></returns>
    /// <exception cref="Exception"></exception>
    public CombinedModel CreateMeshData(ref SceneStreamLoader loader)
    {
        var allRenderers = GetComponentsInChildren<MeshRenderer>();
        if (allRenderers == null || allRenderers.Length == 0)
        {
            throw new System.Exception("非模型节点");
        }
        
        List<MeshFilter> allFilters = new List<MeshFilter>(allRenderers.Length);
        int sumVertexLength = 0;
        //获取所有网格，并计算顶点总数
        for (int i = 0; i < allRenderers.Length; ++i)
        {
            MeshFilter filter = allRenderers[i].GetComponent<MeshFilter>();
            allFilters.Add(filter);
            sumVertexLength += (int)(filter.sharedMesh.vertexCount * 1.2f);

        }
        
        NativeList<Point> points = new NativeList<Point>(sumVertexLength, Allocator.Temp);
        NativeList<int> triangleMaterials = new NativeList<int>(sumVertexLength / 3, Allocator.Temp);
        
        //记录材质球数据
        var matToIndexDict = VirtualMaterial.GetMaterialsData(allRenderers, ref loader);
        //记录网格数据和对应的材质索引关系
        for (int i = 0; i < allFilters.Count; ++i)
        {
            Mesh mesh = allFilters[i].sharedMesh;
            GetPoints(points, triangleMaterials, mesh, allFilters[i].transform, allRenderers[i].sharedMaterials, matToIndexDict);
        }

        //计算模型在世界空间下的包围盒
        float3 less = points[0].vertex;
        float3 more = points[0].vertex;
        for (int i = 1; i < points.Length; ++i)
        {
            float3 current = points[i].vertex;
            if (less.x > current.x) less.x = current.x;
            if (more.x < current.x) more.x = current.x;
            if (less.y > current.y) less.y = current.y;
            if (more.y < current.y) more.y = current.y;
            if (less.z > current.z) less.z = current.z;
            if (more.z < current.z) more.z = current.z;
        }

        float3 center = (less + more) / 2;
        float3 extent = more - center;
        Bounds b = new Bounds(center, extent * 2);
        
        CombinedModel md;
        md.bound = b;
        md.allPoints = points;
        md.allMatIndex = triangleMaterials;
        return md;

    }
    
    public void GetPoints(NativeList<Point> points, NativeList<int> materialIndices, Mesh targetMesh, Transform meshTrans, Material[] sharedMaterials, Dictionary<Material, int> matToIndex)
    {
        Vector3[] vertices;
        Vector3[] normals;
        Vector2[] uvs;
        Vector4[] tangents;
        GetTransformedMeshData(targetMesh, meshTrans.localToWorldMatrix, out vertices, out tangents, out uvs, out normals);

        //subMeshCount即多维子材质所代表的子网格，一个MeshFilter有几个多维子材质就有几个子网格
        //通过循环子网格来创建该模型的Points数据结构，并记录子网格对应的材质球序号
        for (int i = 0; i < targetMesh.subMeshCount; ++i)
        {
            int[] triangles = targetMesh.GetTriangles(i);
            Material mat = sharedMaterials[i];
            GetPointsWithArrays(points, materialIndices, vertices, normals, uvs, tangents, triangles, matToIndex[mat]);
            //TODO
            //Material Count
        }
    }
    
    public static void GetPointsWithArrays(NativeList<Point> points, NativeList<int> materialPoints, Vector3[] vertices, Vector3[] normals, Vector2[] uvs, Vector4[] tangents, int[] triangles, int materialCount)
    {
        void PointSet(int i)
        {
            float4 tan = tangents[i];
            float3 nor = normals[i];
            points.Add(new Point
            {
                vertex = vertices[i],
                tangent = tan,
                normal = nor,
                uv0 = uvs[i],
            });
        }
        for (int index = 0; index < triangles.Length; index += 3)
        {
            PointSet(triangles[index]);
            PointSet(triangles[index + 1]);
            PointSet(triangles[index + 2]);
            materialPoints.Add(materialCount);
        }
    }
    
    /// <summary>
    /// 获取模型的法线切线UV数据，并将其转换到世界空间下。
    /// </summary>
    /// <param name="targetMesh"></param>
    /// <param name="transformMat"></param>
    /// <param name="vertices"></param>
    /// <param name="tangents"></param>
    /// <param name="uvs"></param>
    /// <param name="normals"></param>
    public static void GetTransformedMeshData(Mesh targetMesh, Matrix4x4 transformMat, out Vector3[] vertices, out Vector4[] tangents, out Vector2[] uvs, out Vector3[] normals)
    {
        vertices = targetMesh.vertices;
        normals = targetMesh.normals;
        uvs = targetMesh.uv;
        tangents = targetMesh.tangents;

        for (int i = 0; i < vertices.Length; ++i)
        {
            vertices[i] = transformMat.MultiplyPoint(vertices[i]);
            //TODO
            //Add others
        }
        
        //处理法线，如果模型的法线数据正确（顶点数=法线数）直接读取模型数据，并将其转换到世界空间下
        //如果法线数据不正确，用（0，0，1）填充
        if (normals.Length == vertices.Length)
        {
            for (int i = 0; i < vertices.Length; ++i)
            {
                normals[i] = transformMat.MultiplyVector(normals[i]);
            }
        }
        else
        {
            normals = new Vector3[vertices.Length];
            for (int i = 0; i < vertices.Length; ++i)
            {
                normals[i] = new Vector3(0, 0, 1);
            }
        }
        //如果模型没有uv，创建默认的空UV
        if (uvs.Length != vertices.Length)
        {
            uvs = new Vector2[vertices.Length];
        }
        //同法线处理
        if (tangents.Length == vertices.Length)
        {
            for (int i = 0; i < vertices.Length; ++i)
            {
                float4 tan = tangents[i];
                tan.xyz = transformMat.MultiplyVector(tan.xyz);
                tangents[i] = tan;
            }
        }
        else
        {
            tangents = new Vector4[vertices.Length];
            for (int i = 0; i < vertices.Length; ++i)
            {
                tangents[i] = new float4(transformMat.MultiplyVector(new Vector3(0, 0, 1)), 1);
            }
        }
    }
}


#endif