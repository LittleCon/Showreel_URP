using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace FC.Editor.FCShader
{
    public static class SSSObjectProperties
    {
        public static string tiling = "_Tiling";

        public static string bumpMap = "_BumpMap";

        public static string normalIntensity = "_NormalIntensity";

        public static string enableDetailNormalMap = "_EnableDetailNormalMap";

        public static string detailNormalMap = "_DetailNormalMap";

        public static string detailNormalIntensity = "_DetailNormalIntensity";

        public static string detailNormalMapTile = "_DetailNormalMapTile";

        public static string specGlossMap = "_SpecGlossMap";

        public static string specColor = "_SpecColor";

        public static string specularHighlightIntensity = "_SpecularHighlightIntensity";

        public static string smoothness = "_Smoothness";

        public static string occlusionMap = "_OcclusionMap";

        public static string occlusionStrength = "_OcclusionStrength";

        public static string specularOcclusion = "_SpecularOcclusion";

        public static string environmentReflectionsIntensity = "_EnvironmentReflectionsIntensity";

        public static string albedoInfluence = "_AlbedoInfluence";

        public static string fresnelIntensity = "_FresnelIntensity";

        public static string sssBlur = "_SSSBlur";

        public static string emissionColor = "_EmissionColor";

    }

    public class SSSObjectShaderGUI : BaseShaderGUI
    {
        public MaterialProperty tilingPorp;

        public MaterialProperty bumpMapPorp;

        public MaterialProperty normalIntensityPorp;

        public MaterialProperty enableDetailNormalMapProp;

        public MaterialProperty detailNormalMapProp;

        public MaterialProperty detailNormalIntensityProp;

        public MaterialProperty detailNormalMapTileProp;

        public MaterialProperty specGlossMapProp;

        public MaterialProperty specColorProp;

        public MaterialProperty specularHighlightIntensityProp;

        public MaterialProperty smoothnessProp;

        public MaterialProperty occlusionMapProp;

        public MaterialProperty occlusionStrengthProp;

        public MaterialProperty specularOcclusionProp;

        public MaterialProperty environmentReflectionsIntensityProp;

        public MaterialProperty albedoInfluenceProp;

        public MaterialProperty fresnelIntensityProp;

        public MaterialProperty sssBlurProp;

        public MaterialProperty emissionColorProp;



        public override void FindProperties(MaterialProperty[] properties)
        {
            base.FindProperties(properties);
            tilingPorp = FindProperty(SSSObjectProperties.tiling, properties, false);
            bumpMapPorp = FindProperty(SSSObjectProperties.bumpMap, properties, false);
            normalIntensityPorp = FindProperty(SSSObjectProperties.normalIntensity, properties, false);
            enableDetailNormalMapProp = FindProperty(SSSObjectProperties.enableDetailNormalMap, properties, false);
            detailNormalMapProp = FindProperty(SSSObjectProperties.detailNormalMap, properties, false);
            detailNormalIntensityProp = FindProperty(SSSObjectProperties.detailNormalIntensity, properties, false);
            detailNormalMapTileProp = FindProperty(SSSObjectProperties.detailNormalMapTile, properties, false);
            specGlossMapProp = FindProperty(SSSObjectProperties.specGlossMap, properties, false);
            specColorProp = FindProperty(SSSObjectProperties.specColor, properties, false);
            specularHighlightIntensityProp =
                FindProperty(SSSObjectProperties.specularHighlightIntensity, properties, false);
            smoothnessProp = FindProperty(SSSObjectProperties.smoothness, properties, false);
            occlusionMapProp = FindProperty(SSSObjectProperties.occlusionMap, properties, false);
            occlusionStrengthProp = FindProperty(SSSObjectProperties.occlusionStrength, properties, false);
            specularOcclusionProp = FindProperty(SSSObjectProperties.specularOcclusion, properties, false);
            environmentReflectionsIntensityProp =
                FindProperty(SSSObjectProperties.environmentReflectionsIntensity, properties, false);
            albedoInfluenceProp = FindProperty(SSSObjectProperties.albedoInfluence, properties, false);
            fresnelIntensityProp = FindProperty(SSSObjectProperties.fresnelIntensity, properties, false);
            sssBlurProp = FindProperty(SSSObjectProperties.sssBlur, properties, false);
            emissionColorProp = FindProperty(SSSObjectProperties.emissionColor, properties, false);
        }

        public override void DrawSurfaceInputs(Material material)
        {
            base.DrawSurfaceInputs(material);
            materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent(LitGUI.Properies.normalMap),
                bumpMapPorp);
            EditorGUI.indentLevel += 1;
            materialEditor.RangeProperty(normalIntensityPorp, LitGUI.Properies.normalStrengthName);
            EditorGUI.indentLevel -= 1;
            materialEditor.VectorProperty(tilingPorp, "Tiling");

            if (material.HasProperty("_EnableDetailNormalMap"))
            {
                DrawFloatToggleProperty(new GUIContent("EnableDetailNormalMap"), enableDetailNormalMapProp);
                if (material.GetFloat("_EnableDetailNormalMap") == 1.0)
                {
                    DrawDetail(material);
                }
            }

            void DrawDetail(Material material)
            {
                materialEditor.TextureProperty(detailNormalMapProp, "DetailNormalMap");
                materialEditor.RangeProperty(detailNormalIntensityProp, "DetailNormalIntensity");
                materialEditor.FloatProperty(detailNormalMapTileProp, "DetailNormalMapTile");
            }

            materialEditor.TextureProperty(specGlossMapProp, "SpecGlossMap");
            materialEditor.ColorProperty(specColorProp, "SpecColor");
            materialEditor.RangeProperty(specularHighlightIntensityProp, "SpecularHighlightIntensity");

            materialEditor.RangeProperty(smoothnessProp, "Smoothness");
            materialEditor.TextureProperty(occlusionMapProp, "OcclusionMap");
            materialEditor.RangeProperty(occlusionStrengthProp, "OcclusionStrength");

            materialEditor.RangeProperty(specularOcclusionProp, "SpecularOcclusion");
            materialEditor.RangeProperty(environmentReflectionsIntensityProp, "EnvironmentReflectionsIntensity");
            materialEditor.RangeProperty(albedoInfluenceProp, "AlbedoInfluence");
            materialEditor.RangeProperty(fresnelIntensityProp, "FresnelIntensity");
            materialEditor.RangeProperty(sssBlurProp, "SSSBlur");
            materialEditor.ColorProperty(emissionColorProp, "EmissionColor");




        }
    }
}
