using FC.Terrain;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using Unity.Mathematics;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.XR;

public class MakeTextureArray : MonoBehaviour
{
    public List<Texture2D> albedos;
    public List<Texture2D> normals;
    public Texture2D heightMap;
    public List<Texture2D> splatMaps;

    public Texture2D blendTex;
    private TerrainData terrainData;

    public Texture2DArray albedoArray;
    public Texture2DArray normalArray;

    public List<float> blendScaleList;
    public List<float> blendSharpnessList;

    public EnvironmentSettings environmentSettings;

    [Tooltip("Splat是否是RGB通道")]
    public bool isRGBSplat;

    public int splatRGBnums;
    struct LayerWeight
    {
        public int index;
        public float weight;
    }
    private void Awake()
    {
        if (blendScaleList == null || blendScaleList.Count == 0)
        {
            blendScaleList = new List<float>();
            for (int i = 0; i < 8; i++)
            {
                blendScaleList.Add(1);
            }
        }
        if (blendSharpnessList == null || blendSharpnessList.Count == 0)
        {
            blendSharpnessList = new List<float>();
            for (int i = 0; i < 8; i++)
            {
                blendSharpnessList.Add(1);
            }
        }
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
        environmentSettings.terrainMat.SetTexture(ShaderProperties.GPUTerrain.albedoTexArrayID, albedoArray);
        environmentSettings.terrainMat.SetTexture(ShaderProperties.GPUTerrain.normalTexArrayID, normalArray);
        var width = heightMap.width;
        var height = heightMap.height;
        var splatCount = albedos.Count;

        if (blendTex == null)
        {
            blendTex = new Texture2D(width, height, TextureFormat.R16, false, true)
            {
                name = "_BlendTexArray",
                anisoLevel = 0,
                filterMode = FilterMode.Point,
                wrapMode = TextureWrapMode.Clamp
            };

            var tileIndex = new int2[width * height];
            var weights = new LayerWeight[isRGBSplat?splatCount* splatRGBnums: splatCount];
            var weightVal = new int[width * height];
            var count = 0;
            for (int i = 0; i < width; i++)
            {
                for (int j = 0; j < height; j++)
                {
                    if (isRGBSplat) 
                    {
                        for (int k = 0; k < splatMaps.Count; k++)
                        {
                            int splatIndex = k;
                            weights[k*splatRGBnums].weight = splatMaps[splatIndex].GetPixel(i, j)[0];
                            weights[k * splatRGBnums +1].weight = splatMaps[splatIndex].GetPixel(i, j)[1];
                            weights[k * splatRGBnums +2].weight = splatMaps[splatIndex].GetPixel(i, j)[2];
                            weights[k * splatRGBnums ].index = k * splatRGBnums;
                            weights[k * splatRGBnums + 1].index = k * splatRGBnums + 1;
                            weights[k * splatRGBnums + 2].index = k * splatRGBnums  + 2;
                        }
                    }
                    else
                    {
                        for (int k = 0; k < splatCount; k++)
                        {
                            int splatIndex = k;
                            weights[k].weight = splatMaps[splatIndex].GetPixel(i, j).r;
                            weights[k].index = k;
                        }
                    }
                    
                    Array.Sort(weights, (a, b) => { return -a.weight.CompareTo(b.weight); });

                    var tw = 0f;
                    var blendCount = 2;
                    for (int k = 0; k < blendCount; k++)
                    {
                        tw += weights[k].weight;
                        
                    }
                    //权重为0的地方代表没有使用材质，这个时候一般要赋予的是默认材质，我们此时另weights[0]的权重直接为1，其实默认了albedo[0]是默认材质贴图
                    if (tw == 0)
                    {
                        tw = 1;
                        weights[0].weight = 1;
                    }
                    else
                    {
                        //tw是存在大于1的情况的，即两个splatmap在该像素都有值，且相加>1，相加后在处于tw，能够将weight缩放到[0-1]
                        for (int k = 0; k < blendCount; k++)
                        {
                            weights[k].weight /= tw;
                        }
                    }


                    
                    tileIndex[i * height + j] = new int2(weights[0].index, weights[1].index);
                    float weightDiff = Mathf.Clamp(weights[0].weight - weights[1].weight, 0, 0.9999f);
                    weightVal[i * height + j] = Mathf.FloorToInt(64f * weightDiff);
                }

            }
            Debug.LogError(count);
            var texByte = new ushort[width * height];
            for (int i = 0; i < tileIndex.Length; i++)
            {
                texByte[i] = (ushort)(weightVal[i] + (tileIndex[i].y << 6) + (tileIndex[i].x << 11));

            }

            byte[] texBytes = new byte[texByte.Length * 2];

            Buffer.BlockCopy(texByte, 0, texBytes, 0, texByte.Length * 2);
            blendTex.LoadRawTextureData(texBytes);
            blendTex.Apply(false, false);
            byte[] pngData = blendTex.EncodeToPNG();

            File.WriteAllBytes(Path.Combine("Assets/Textures/Environment", "BlendTex.png"), pngData);
        }

     


        Shader.SetGlobalTexture(ShaderProperties.GPUTerrain.minMaxHeightMapID, heightMap); //此处应该使用alpha8的HeightMap,测试暂用AlbedoArray
        Shader.SetGlobalInt(ShaderProperties.GPUTerrain.albedoTexNumsID, albedos.Count);

        Shader.SetGlobalVector(ShaderProperties.GPUTerrain.alphaMapSizeID, new Vector4(width, 1.0f / width, 0, 0));

        Shader.SetGlobalFloat("_HeightBlendEnd", 400);
        Shader.SetGlobalFloatArray(ShaderProperties.GPUTerrain.blendScaleArrayShaderID, blendScaleList);
        Shader.SetGlobalFloatArray(ShaderProperties.GPUTerrain.blendSharpnessArrayShaderId, blendSharpnessList);
        environmentSettings.terrainMat.SetTexture(ShaderProperties.GPUTerrain.blendTexArraryID, blendTex);
    }

    private void Update()
    {
        environmentSettings.terrainMat.SetTexture(ShaderProperties.GPUTerrain.albedoTexArrayID, albedoArray);
        environmentSettings.terrainMat.SetTexture(ShaderProperties.GPUTerrain.normalTexArrayID, normalArray);
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
        environmentSettings.terrainMat.SetTexture(ShaderProperties.GPUTerrain.blendTexArraryID, blendTex);
    }

    private void OnDestroy()
    {
        DestroyImmediate(albedoArray);
        DestroyImmediate(normalArray);
       
    }
}
