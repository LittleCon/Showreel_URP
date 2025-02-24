using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;

public static class CommonData
{
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
    
  
    
    public struct Cluster
    {
        public Vector3 extent;
        public Vector3 position;
        public int index;
    }
}

public unsafe static class UnsafeData
{
    public unsafe struct Voxel
    {
        public Triangle* start;
        /// <summary>
        /// 记录该体素网格中有多少个三角形被添加
        /// </summary>
        public int count;
        public void Add(Triangle* ptr)
        {
            if (start != null)
            {
                start->last = ptr;
                ptr->next = start;
            }
            start = ptr;
            count++;
        }
        public Triangle* Pop()
        {
            if (start->next != null)
            {
                start->next->last = null;
            }
            Triangle* last = start;
            start = start->next;
            count--;
            return last;
        }
    }
    
    public unsafe struct Triangle
    {
        public CommonData.Point a;
        public CommonData.Point b;
        public CommonData.Point c;
        public int materialID;
        public Triangle* last;
        public Triangle* next;
    }
}
