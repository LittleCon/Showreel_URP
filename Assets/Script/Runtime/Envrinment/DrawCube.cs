using FC.Terrain;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using TMPro;
using Unity.Mathematics;
using Unity.VisualScripting;
using UnityEditor.Hardware;
using UnityEngine;
using UnityEngine.PlayerLoop;

public class DrawCube : MonoBehaviour
{
    public TerrainCreateImpl terrainCreateImpl;
    public GameObject terrainMarkGo;
    private List<GameObject> marks;
    private void Start()
    {
        marks = new();
    }
    private void Update()
    {
        if (!EnvironmentManagerSystem.Instance.debug&& terrainCreateImpl.debugNodeData!=null) return;
        terrainCreateImpl = EnvironmentManagerSystem.Instance.terrainCreateImpl;
        if(terrainCreateImpl.debugNodeData.Length!= marks.Count)
        {
            var sub = terrainCreateImpl.debugNodeData.Length - marks.Count;
            for (int i=0;i< sub;i++)
            {
                var mark = Instantiate(terrainMarkGo, this.transform);
                marks.Add(mark);
            }
            for (int i = 0; i < terrainCreateImpl.debugNodeData.Length; i++)
            {
                var data = terrainCreateImpl.debugNodeData[i];
                var mark = marks[i];

                var center = GetNodeCenterPos(data, (int)data.LOD);

                if (EnvironmentManagerSystem.Instance.debugAfterFrustumNode)
                {
                   
                    mark.transform.localScale = terrainCreateImpl.GetNodeSizeInLod((int)data.LOD) * Vector3.one * 0.1f;
                    mark.transform.Find("index").GetComponent<TextMeshPro>().text = $"({data.nodeXY.x},{data.nodeXY.y})";
                }
                else if (EnvironmentManagerSystem.Instance.debugPatch)
                {
                    center += GetPatchPosInNode(data, (int)data.LOD);
                    mark.transform.position = new Vector3(center.x, 0, center.y);
                    mark.transform.Find("index").GetComponent<TextMeshPro>().text = $"nodeXY:({data.nodeXY.x},{data.nodeXY.y})\n patchXY:({data.patchXY.x},{data.patchXY.y})";
                    mark.transform.localScale = terrainCreateImpl.GetNodeSizeInLod((int)data.LOD) * Vector3.one * 0.1f / 8;

                }

            }
        }

       


    }

    float GetPatchSizeInLod(int LOD)
    {
        return (int)EnvironmentManagerSystem.Instance.environmentSettings.sectorSize * (1 << LOD);
    }

    float2 GetPatchPosInNode(NodePatchData nodeData, int LOD)
    {
        float patchSize = GetPatchSizeInLod( LOD);
        float2 patchPos = patchSize * (nodeData.patchXY + new float2(0.5f, 0.5f) - 8f * 0.5f);
        return patchPos;
    }
    float2 GetNodeCenterPos(NodePatchData nodeData, int LOD)
    {
        float nodeSize = terrainCreateImpl.GetNodeSizeInLod(LOD);
        int nodeCount = (int)terrainCreateImpl.GetNodeNumInLod(LOD);
        float2 nodePos = nodeSize * (nodeData.nodeXY + new float2(0.5f, 0.5f) - nodeCount * 0.5f);
        return nodePos;
    }

    

    public void OnDrawGizmos()
    {
        if (terrainCreateImpl == null) return;
        if (terrainCreateImpl.debugNodeData != null)
        {
            foreach (var data in terrainCreateImpl.debugNodeData)
            {
                var center = GetNodeCenterPos(data, (int)data.LOD);
                var bounds = data.boundsMax - data.boundsMin;
                bounds.y = 100;
                Gizmos.DrawWireCube(new Vector3(center.x, 0, center.y), bounds);
            }
        }
    }
}
