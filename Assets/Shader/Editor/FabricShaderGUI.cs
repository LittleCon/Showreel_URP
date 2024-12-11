using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.Rendering;
using UnityEngine;
using UnityEngine.Rendering;

namespace FC.Editor.FCShader
{
    public static class FabricProperties
    {

        public static string fabricType = "_FabricType";

        public static string alphaRemapMin = "_AlphaRemapMin";
        
        public static string alphaRemapMax = "_AlphaRemapMax";
        
        public static string maskMap = "_MaskMap";
        
        public static string smoothness = "_Smoothness";
        
        public static string smoothnessRemapMin = "_SmoothnessRemapMin";
        
        public static string smoothnessRemapMax = "_SmoothnessRemapMax";
        
        public static string anisotropy = "_Anisotropy";
        
        public static string aoRemapMin = "_AORemapMin";
        
        public static string aoRemapMax = "_AORemapMax";
        
        public static string specularColor = "_SpecularColor";
        
        public static string specularColorMap = "_SpecularColorMap";
        
        public static string normalMap = "_NormalMap";
        
        public static string normalStrength = "_NormalScale";
    }

    public class FabricShaderGUI : BaseShaderGUI
    {
        public enum FabricType
        {
            CottonWool,
            Silk
        }
        
        public MaterialProperty fabricTypeProp;

        public MaterialProperty alphaRemapMinProp;

        public MaterialProperty alphaRemapMaxProp;
        
        public MaterialProperty maskMapProp;
        
        public MaterialProperty smoothnessProp;
        
        public MaterialProperty smoothnessRemapMinProp;
        
        public MaterialProperty smoothnessRemapMaxProp;

        public MaterialProperty anisotropyProp;
        
        public MaterialProperty aoRemapMinPorp;
        
        public MaterialProperty aoRemapMaxPorp;
        
        public MaterialProperty specularColorProp;
        
        public MaterialProperty specularColorMapProp;
        
        public MaterialProperty normalMapProp;

        public MaterialProperty normalStrengthProp;


        public override void FindProperties(MaterialProperty[] properties)
        {
            base.FindProperties(properties);
            alphaRemapMinProp = FindProperty(FabricProperties.alphaRemapMin, properties);
            alphaRemapMaxProp = FindProperty(FabricProperties.alphaRemapMax, properties);
            fabricTypeProp = FindProperty(FabricProperties.fabricType, properties,false);
            maskMapProp = FindProperty(FabricProperties.maskMap, properties,false);
            smoothnessProp = FindProperty(FabricProperties.smoothness, properties,false);
            smoothnessRemapMinProp = FindProperty(FabricProperties.smoothnessRemapMin, properties,false);
            smoothnessRemapMaxProp = FindProperty(FabricProperties.smoothnessRemapMax, properties,false);
            anisotropyProp = FindProperty(FabricProperties.anisotropy, properties,false);
            aoRemapMinPorp = FindProperty(FabricProperties.aoRemapMin, properties,false);
            aoRemapMaxPorp = FindProperty(FabricProperties.aoRemapMax, properties,false);
            specularColorProp= FindProperty(FabricProperties.specularColor, properties,false);
            specularColorMapProp= FindProperty(FabricProperties.specularColorMap, properties,false);
            normalMapProp = FindProperty(FabricProperties.normalMap, properties,false);
            normalStrengthProp= FindProperty(FabricProperties.normalStrength, properties,false);
        }

        public override void DrawBaseProperties(Material material)
        {
          
        }
        
        

        public override void DrawSurfaceInputs(Material material)
        {
            base.DrawSurfaceInputs(material);
            base.DrawBaseProperties(material);
            materialEditor.PopupShaderProperty(fabricTypeProp,new GUIContent("衣服类型"),  Enum.GetNames(typeof(FabricType)));
            if (IsCottonWoll(material))
            {
                materialEditor.RangeProperty(anisotropyProp, "各向异性");
            }

            materialEditor.RangeProperty(alphaRemapMinProp, "alphaMin");
            materialEditor.RangeProperty(alphaRemapMaxProp,"alphaMax");
            
            materialEditor.TextureProperty(maskMapProp, "MaskMap");
            materialEditor.RangeProperty(smoothnessProp, "光滑度");

            materialEditor.RangeProperty(smoothnessRemapMinProp, "光滑度最小值");
            materialEditor.RangeProperty(smoothnessRemapMaxProp, "光滑度最大值");
            
            materialEditor.RangeProperty(aoRemapMinPorp, "AO贴图最小值");
            materialEditor.RangeProperty(aoRemapMaxPorp, "AO贴图最大值");
            
            materialEditor.TexturePropertySingleLine(new GUIContent("SpecularColor"),specularColorMapProp, specularColorProp);
            materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent(LitGUI.Properies.normalMap), normalMapProp);
            EditorGUI.indentLevel += 1;
            materialEditor.FloatProperty(normalStrengthProp, "法线强度");
            EditorGUI.indentLevel -= 1;
            DrawEmissionProperties(material, true);
        }

        public override void ValidateMaterial(Material material)
        {
            base.ValidateMaterial(material);
            BaseProperty.AnimationStatus(material);
            BaseProperty.SetBasePropertyKeyWorld(material);
            CoreUtils.SetKeyword(material,"_MATERIAL_FEATURE_SHEEN",IsCottonWoll(material));
        }

        private bool IsCottonWoll(Material material)
        {
            return material.HasProperty("_FabricType")&&(FabricType)material.GetFloat("_FabricType")==FabricType.CottonWool;
        }
    }
}


