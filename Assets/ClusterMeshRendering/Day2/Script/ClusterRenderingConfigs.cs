using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "ClusterRenderingConfigs", menuName = "ClusterRenderingConfigs")]
public class ClusterRenderingConfigs : ScriptableObject
{
    /// <summary>
    /// 一个Cluster数组最多存放的Cluster数量
    /// </summary>
    public static int CLUSTERCLIPCOUNT = 384;
    public  static int CLUSTERTRIANGLECOUNT = CLUSTERCLIPCOUNT / 3;
}
