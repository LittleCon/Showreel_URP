using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class SetData : MonoBehaviour
{
    private Material material;
    public float tile;
    public float bend;
    public float height;
    struct GrassData
    {
       public float tile;
       public float bend;
       public float height;
    }
    private ComputeBuffer grassBuffer;

    private GrassData []grassDatas;
    private GrassData grassData;

    private void Start()
    {
        material = GetComponent<MeshRenderer>().material;
        grassBuffer = new ComputeBuffer(1, sizeof(float) * 3, ComputeBufferType.IndirectArguments);
        grassData = new GrassData();
        grassDatas = new GrassData []{ grassData };
    }

    private void Update()
    {
        grassData.tile = tile;
        grassData.bend = bend;
        grassData.height = height;
        grassDatas[0] = grassData;
        grassBuffer.SetData(grassDatas);
        material.SetBuffer("grassDatas", grassBuffer);
    }
}
