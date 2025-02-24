using System;
using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEditor;
using UnityEngine;

[ExecuteAlways]
public class Test : MonoBehaviour
{
    private void OnEnable()
    {
        Debug.LogError( System.Runtime.InteropServices.Marshal.SizeOf(typeof(int4x4)) );
        Debug.LogError(AssetDatabase.AssetPathToGUID("Assets/ClusterMeshRendering/Day2/SceneStreamLoader.cs").ToCharArray().Length);
    }
}
