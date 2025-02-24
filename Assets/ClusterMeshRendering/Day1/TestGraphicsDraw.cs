using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Unity.Collections;
using Unity.Mathematics;
using Unity.VisualScripting;
using UnityEditor;
using UnityEngine;

public class TestGraphicsDraw : MonoBehaviour
{
   
   public Material clusterMaterial;
   private CreateClustData creater
   {
      get
      {
         var c=GetComponent<CreateClustData>();
         if (c == null)
         {
            c = gameObject.AddComponent<CreateClustData>();
         }
         return c;
      }
   }

   private NativeArray<Point> points;
   public void OnEnable()
   {
     // clusterMaterial=new Material(clusterShader);
      InitBuffer();
   }

   private ComputeBuffer pointDataBuffer;
   private ComputeBuffer instanceBuffer;
   private void Update()
   {
      clusterMaterial.SetBuffer("_PointData",pointDataBuffer);
      Graphics.DrawProceduralIndirect(clusterMaterial,new Bounds(){center = Vector3.zero,size = new Vector3(100,100,100)}
         ,MeshTopology.Triangles, instanceBuffer);
   }

   private void InitBuffer()
   {
      instanceBuffer = new ComputeBuffer(1, sizeof(int) * 4, ComputeBufferType.IndirectArguments);
      instanceBuffer.SetData(new int[] {3, creater.points.Length/3, 0, 0 });  // 3 个顶点
      
      pointDataBuffer = new ComputeBuffer(creater.points.Length, GetPointDataSize());
      pointDataBuffer.SetData(creater.points.ToArray());
   }

   public int GetPointDataSize()
   {
      return sizeof(float) * (3 + 3 + 4 + 2);
   }
   
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


   private bool debug = false;


   void OnDisable()
   {
      // 清理资源
      pointDataBuffer.Release();
      instanceBuffer.Release();
      points.Dispose();
   }
}
