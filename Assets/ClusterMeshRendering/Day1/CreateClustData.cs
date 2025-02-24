using System;
using System.Collections;
using System.Collections.Generic;
using Unity.Collections;
using UnityEngine;
using Unity.Mathematics;

[ExecuteAlways]
public class CreateClustData : MonoBehaviour
{
    
    // private void OnDrawGizmos()
    // {
    //     if (trs.isCreated&& trs.Length > 0)
    //     {
    //         foreach (var tr in trs)
    //         {
    //             if (tr.materialID == 0)
    //             {
    //                 Gizmos.color= Color.red;
    //             }else if (tr.materialID == 2)
    //             {
    //                 Gizmos.color= Color.blue;
    //             }else if (tr.materialID == 1)
    //             {
    //                 Gizmos.color= Color.green;
    //             }
    //             //var mesh = ConvertTrianglesToMesh(tr);
    //             Gizmos.DrawLine(tr.a.vertex, tr.b.vertex);
    //             Gizmos.DrawLine(tr.b.vertex, tr.c.vertex);
    //         }
    //     }
    // }
    
    
    /// <summary>
    /// 顶点数据
    /// vertex:顶点模型空间坐标
    /// normal：模型空间法线
    /// tangent：模型空间切线
    /// uv0
    /// </summary>
    public struct Point
    {
        public float3 vertex;
        public float3 normal;
        public float4 tangent;
        public float2 uv0;

        public override string ToString()
        {
            return $"vertex:{vertex} ";
        }
    }
    
    public struct CombinedModel
    {
        public NativeList<Point> allPoints;
        public NativeList<int> allMatIndex;
        public Bounds bound;
    }
    


    public NativeList<Point> points;
    public void ProcessCluster()
    {
        var renderers = GetComponentsInChildren<MeshRenderer>();
        List<MeshFilter> allFilters = new List<MeshFilter>(renderers.Length);
        int sumVertexLength = 0;
        //获取所有网格，并计算顶点总数
        for (int i = 0; i < renderers.Length; ++i)
        {
            MeshFilter filter = renderers[i].GetComponent<MeshFilter>();
            allFilters.Add(filter);
            sumVertexLength += (int)(filter.sharedMesh.vertexCount * 1.2f);

        }

    
        int materialIndex = 0;
 
        //保存每个顶点
        points= new NativeList<Point>(sumVertexLength, Allocator.Temp);
        //保存每个顶点对应的三角形
        NativeList<int> triangleMaterials = new NativeList<int>(sumVertexLength / 3, Allocator.Temp);
        //记录每个顶点在世界空间中的坐标，以及每个三角形对应的材质球索引
        //即填充points和triangleMaterials
       
        for (int i = 0; i < allFilters.Count; ++i)
        {
            Mesh mesh = allFilters[i].sharedMesh;
            Debug.LogError(allFilters.Count+"===="+renderers.Length);
            GetPoint(mesh, allFilters[i].transform, renderers[i].sharedMaterials,points,triangleMaterials);
        }
        
      
    }
    

   
    public void GetPoint(Mesh targetMesh,  Transform meshTrans,Material[] sharedMaterials,NativeList<Point> points,NativeList<int> triangleMaterials)
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
            GetPointsWithArrays(points, triangleMaterials, vertices, normals, uvs, tangents, triangles, 1);
          
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
