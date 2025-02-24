using System;
using System.Collections;
using System.Collections.Generic;
using Unity.Collections;
using Unity.Collections.LowLevel.Unsafe;
using Unity.Mathematics;
using UnityEditor;
using UnityEngine;
using static Unity.Mathematics.math;

public static class VirtualMaterial
{
    /// <summary>
    /// 对应Shader中的属性，贴图属性通过代码生成全局ID，其余属性直接从材质中获取
    /// </summary>
    [System.Serializable]
    public struct MaterialProperties
    {
        public int baseMap;

        public float4 baseColor;

        public float brightness;

        public float4 tiliing;

        public float4 addColor;

        public int MASMap;

        public float metallic;

        public float smoothness;

        public float occlusionStrength;

        public int normalMap;

    }

    /// <summary>
    /// 将颜色转换为Float记录,线性转Gamma
    /// Unity默认调色板是Gamma的，当项目处于线性颜色空间时，传递进材质球的参数会被自动纠正，因此保存数据的时候需要转换为Gamma空间
    /// </summary>
    /// <param name="c"></param>
    /// <returns></returns>
    static float4 ColorToVector_LinearToGamma(Color c)
    {
        return pow(float4(c.r, c.g, c.b, c.a), 2.2f);
    }

#if UNITY_EDITOR
    /// <summary>
    /// 记录材质球上的属性，这一步应该是在编辑器状态下就预烘培好
    /// </summary>
    /// <param name="allRenderers"></param>
    /// <param name="loader"></param>
    /// <returns></returns>
    /// <exception cref="Exception"></exception>
    public unsafe static Dictionary<Material, int> GetMaterialsData(MeshRenderer[] allRenderers, ref SceneStreamLoader loader)
    {
        var dict = new Dictionary<Material, int>(allRenderers.Length);
        var baseMaps = new List<Texture>(allRenderers.Length);
        var normalMaps = new List<Texture>(allRenderers.Length);
        var masMaps = new List<Texture>(allRenderers.Length);
        loader.allProperties =
            new NativeList<MaterialProperties>(allRenderers.Length, Unity.Collections.Allocator.Persistent);

        var baseMapDic = new Dictionary<Texture, int>(allRenderers.Length);
        var normalMapDic = new Dictionary<Texture, int>(allRenderers.Length);
        var masMapDic = new Dictionary<Texture, int>(allRenderers.Length);
        int len = 0;

        int GetTextureIndex(List<Texture> lst, Dictionary<Texture, int> texDict, Texture tex)
        {
            int ind = -1;
            if (tex)
            {
                if (!texDict.TryGetValue(tex, out ind))
                {
                    ind = lst.Count;
                    lst.Add(tex);
                    texDict.Add(tex, ind);
                }
            }

            return ind;
        }

        //获取材质属性
        foreach (var r in allRenderers)
        {
            var ms = r.sharedMaterials;
            foreach (var m in ms)
            {
                if (!m)
                {
                    throw new System.Exception(r.name + " Has Null Mat");
                }

                if (!dict.ContainsKey(m))
                {
                    dict.Add(m, len);
                    Texture albedo = m.GetTexture("_BaseMap");
                    Texture normal = m.GetTexture("_NormalMap");
                    Texture mas = m.GetTexture("_MASMap");

                    int albedoIndex = GetTextureIndex(baseMaps, baseMapDic, albedo);
                    int normalIndex = GetTextureIndex(normalMaps, normalMapDic, normal);
                    int masIndex = GetTextureIndex(masMaps, masMapDic, mas);

                    loader.allProperties.Add(new MaterialProperties
                    {
                        baseColor = ColorToVector_LinearToGamma(m.GetColor("_BaseColor")),
                        brightness = m.GetFloat("_Brightness"),
                        tiliing = m.GetVector("_Tiliing"),
                        addColor = ColorToVector_LinearToGamma(m.GetColor("_AddColor")),
                        metallic = m.GetFloat("_Metallic"),
                        smoothness = m.GetFloat("_Smoothness"),
                        occlusionStrength = m.GetFloat("_OcclusionStrength"),
                        baseMap = albedoIndex,
                        normalMap = normalIndex,
                        MASMap = masIndex

                    });
                    len++;
                }
            }
        }
        //记录贴图ID
        void GetGUIDs(out NativeList<int4x4> strs, List<Texture> texs)
        {
            strs = new NativeList<int4x4>(texs.Count, Allocator.Persistent);
            for (int i = 0; i < texs.Count; ++i)
            {
                string guid = AssetDatabase.AssetPathToGUID(AssetDatabase.GetAssetPath(texs[i]));
                //MEditorLib.SetObjectAddressable(texs[i], guid);
                int4x4 value = 0;
                fixed (char* c = guid)
                {
                  UnsafeUtility.MemCpy(value.Ptr(), c, sizeof(int4x4));
                }
                strs.Add(value);
            }
        }
        GetGUIDs(out loader.albedoGUIDs, baseMaps);
        GetGUIDs(out loader.normalGUIDs, normalMaps);
        GetGUIDs(out loader.masGUIDs, masMaps);
        // EditorUtility.SetDirty(AddressableAssetSettingsDefaultObject.Settings);
        return dict;
    }

#endif
    

}
