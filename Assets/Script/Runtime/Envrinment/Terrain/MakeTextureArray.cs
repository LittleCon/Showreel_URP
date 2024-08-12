using System;
using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;

public class MakeTextureArray : MonoBehaviour
{
    public List<Texture2D> albedos;
    public List<Texture2D> normals;
    public Texture2D heightMap;
    public List<Texture2D> splatMaps;

    public Texture2D blendTex;
    private TerrainData terrainData;

    private Texture2DArray albedoArray;
    private Texture2DArray normalArray;

    public List<float> blendScaleList;
    public List<float> blendSharpnessList;

    struct LayerWeight
    {
        public int index;
        public float weight;
    }
    private void Awake()
    {
        if (albedos.Count == 0) return;
        albedoArray = new Texture2DArray(albedos[0].width, albedos[0].height, albedos.Count, albedos[0].format, true, false);
        normalArray = new Texture2DArray(normals[0].width, normals[0].height, normals.Count, normals[0].format, true, false);


        for(int i = 0; i < albedos.Count; i++)
        {
            for(int j = 0; j < albedos[i].mipmapCount; j++)
            {
                Graphics.CopyTexture(albedos[i], 0, j, albedoArray, i, j);
                Graphics.CopyTexture(normals[i], 0, j, normalArray, i, j);
            }
        }

        var width = heightMap.width;
        var height = heightMap.height;
        var splatCount = albedos.Count;

        blendTex = new Texture2D(width, height, TextureFormat.R16, false, true)
        {
            name = "_BlendTexArray",
            anisoLevel = 0,
            filterMode = FilterMode.Point,
            wrapMode = TextureWrapMode.Clamp
        };

        var tileIndex = new int2[width * height];
        var weights = new LayerWeight[splatCount];
        var weightVal = new int[width * height];

        for (int i = 0; i < width; i++)
        {
            for (int j = 0; j < height; j++)
            {
                for (int k = 0; k < splatCount; k++)
                {
                    int splatIndex = k / 4;
                    int colorIndex = k % 4;
                    weights[k].weight = splatMaps[splatIndex].GetPixel(i, j)[colorIndex];
                    weights[k].index = k;
                }
                Array.Sort(weights, (a, b) => { return -a.weight.CompareTo(b.weight); });

                var tw = 0f;
                var blendCount = 2;
                for(int k = 0; k < blendCount; k++)
                {
                    tw += weights[k].weight;
                }

                if (tw == 0)
                {
                    tw = 1;
                    weights[0].weight = 1;
                }
                else
                {
                    for(int k = 0; k < blendCount; k++)
                    {
                        weights[k].weight /= tw;
                    }
                }

                if (weights[1].weight == 0)
                {
                    weights[1].index = weights[0].index;
                }
                tileIndex[i * height + j] = new int2(weights[0].index, weights[1].index);
                float weightDiff = Mathf.Clamp(weights[0].weight - weights[1].weight, 0, 0.9999f);
                weightVal[i * height + j] = Mathf.FloorToInt(64f * weightDiff);
            }

        }
        var texByte = new ushort[width * height];
        for (int i = 0; i < tileIndex.Length; i++)
        {
            texByte[i] = (ushort)(weightVal[i] + (tileIndex[i].y << 6) + (tileIndex[i].x << 11));

        }

        byte[] texBytes = new byte[texByte.Length * 2];

        Buffer.BlockCopy(texByte, 0, texBytes, 0, texByte.Length * 2);
        blendTex.LoadRawTextureData(texBytes);
        blendTex.Apply(false, false);

        Shader.SetGlobalTexture(ShaderProperties.GPUTerrain.albedoTexArrayID, albedoArray);
        Shader.SetGlobalTexture(ShaderProperties.GPUTerrain.normalTexArrayID, normalArray);
        Shader.SetGlobalTexture(ShaderProperties.GPUTerrain.minMaxHeightMapID, heightMap); //此处应该使用alpha8的HeightMap,测试暂用AlbedoArray
        Shader.SetGlobalInt(ShaderProperties.GPUTerrain.albedoTexNumsID, albedos.Count);

        Shader.SetGlobalVector(ShaderProperties.GPUTerrain.alphaMapSizeID, new Vector4(width, 1.0f / width, 0, 0));

        Shader.SetGlobalFloat("_HeightBlendEnd", 400);
        Shader.SetGlobalFloatArray(ShaderProperties.GPUTerrain.blendScaleArrayShaderID, blendScaleList);
        Shader.SetGlobalFloatArray(ShaderProperties.GPUTerrain.blendSharpnessArrayShaderId, blendSharpnessList);
        Shader.SetGlobalTexture(ShaderProperties.GPUTerrain.blendTexArraryID, blendTex);
    }

    private void Update()
    {
        Shader.SetGlobalFloat("_HeightBlendEnd", 400);
        Shader.SetGlobalFloatArray(ShaderProperties.GPUTerrain.blendScaleArrayShaderID, blendScaleList);
        Shader.SetGlobalFloatArray(ShaderProperties.GPUTerrain.blendSharpnessArrayShaderId, blendSharpnessList);
        //if (EnableHeightBlend)
        //{
        //    Shader.EnableKeyword("_HeightBlend");
        //}
        //else
        //{
        //    Shader.DisableKeyword("_HeightBlend");
        //}
    }

    private void OnDestroy()
    {
        DestroyImmediate(albedoArray);
        DestroyImmediate(normalArray);
        DestroyImmediate(blendTex);
    }
}
