using System.Collections;
using System.Collections.Generic;
using Unity.Collections;
using Unity.Mathematics;
using UnityEditor;
using UnityEngine;
using UnityEngine.Experimental.Rendering;


[CreateAssetMenu(fileName = "ClusterMatResources", menuName = "Create ClusterMatResources", order = 1)]
public sealed unsafe class ClusterMatResources : ScriptableObject
{
    public int maximumClusterCount = 100000;
    public int maximumMaterialCount = 1;
}
