using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace FC.Editor.FCShader
{
    public static class HairProperties
    {
        public static string ambientOcclusionMap = "_AmbientOcclusionMap";
        
        public static string aoRemapMin = "_AORemapMin";
        
        public static string aoRemapMax = "_AORemapMax";
        
        public static string smoothness = "_Smoothness";
        
        public static string smoothnessRemapMin = "_SmoothnessRemapMin";
        
        public static string smoothnessRemapMax = "_SmoothnessRemapMax";
        
        public static string specularColor = "_SpecularColor";
        
        public static string specularTintColor = "_SpecularTintColor";
        
        public static string specularMultiplier = "_SpecularMultiplier";
        
        public static string specularShift = "_SpecularShift";
        
        public static string secondarySpecularMultiplier = "_SecondarySpecularMultiplier";

        public static string secondarySpecularShift = "_SecondarySpecularShift";

        public static string transmissionColor = "_TransmissionColor";
        
        public static string transmissionIntensity = "_TransmissionIntensity";

        public static string normalStrength = "_NormalStrength";
        
        public static string normalMap = "_NormalMap";
    }

    public class HairShaderGUI : BaseShaderGUI
    {
        public MaterialProperty ambientOcclusionMapPorp;
        
        public MaterialProperty aoRemapMinPorp;
        
        public MaterialProperty aoRemapMaxPorp;

        public MaterialProperty smoothnessProp;
        
        public MaterialProperty smoothnessRemapMinProp;
        
        public MaterialProperty smoothnessRemapMaxProp;

        public MaterialProperty specularColorProp;
        
        public MaterialProperty specularTintColorProp;
        
        public MaterialProperty specularMultiplierProp;
        
        public MaterialProperty specularShiftProp;
        
        public MaterialProperty secondarySpecularMultiplierProp;
        
        public MaterialProperty secondarySpecularShiftProp;

        public MaterialProperty transmissionColorProp;
        
        public MaterialProperty transmissionIntensityProp;
        
        public MaterialProperty normalMapProp;

        public MaterialProperty normalStrengthProp;
        
        

        public override void FindProperties(MaterialProperty[] properties)
        {
            base.FindProperties(properties);
            ambientOcclusionMapPorp = FindProperty(HairProperties.ambientOcclusionMap, properties, false);
            aoRemapMaxPorp = FindProperty(HairProperties.aoRemapMax, properties, false);
            aoRemapMinPorp = FindProperty(HairProperties.aoRemapMin, properties, false);
            smoothnessRemapMinProp = FindProperty(HairProperties.smoothnessRemapMin, properties, false);
            smoothnessRemapMaxProp = FindProperty(HairProperties.smoothnessRemapMax, properties, false);
            specularColorProp= FindProperty(HairProperties.specularColor, properties, false);
            specularTintColorProp= FindProperty(HairProperties.specularTintColor, properties, false);
            normalMapProp = FindProperty(HairProperties.normalMap, properties, false);
            specularMultiplierProp= FindProperty(HairProperties.specularMultiplier, properties, false);
            specularShiftProp = FindProperty(HairProperties.specularShift, properties, false);
            secondarySpecularMultiplierProp= FindProperty(HairProperties.secondarySpecularMultiplier, properties, false);
            secondarySpecularShiftProp = FindProperty(HairProperties.secondarySpecularShift, properties, false);
            transmissionColorProp = FindProperty(HairProperties.transmissionColor, properties, false);
            transmissionIntensityProp = FindProperty(HairProperties.transmissionIntensity, properties, false);
            normalStrengthProp = FindProperty(HairProperties.normalStrength, properties, false);
            smoothnessProp = FindProperty(HairProperties.smoothness, properties, false);
        }

        public override void DrawSurfaceInputs(Material material)
        {
            base.DrawSurfaceInputs(material);
            materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent(LitGUI.Properies.normalMap), normalMapProp);
            EditorGUI.indentLevel += 1;
            materialEditor.RangeProperty(normalStrengthProp, LitGUI.Properies.normalStrengthName);
            EditorGUI.indentLevel -= 1;


            materialEditor.TextureProperty(ambientOcclusionMapPorp, "AO贴图");
            materialEditor.RangeProperty(aoRemapMinPorp, "AO贴图最小值");
            materialEditor.RangeProperty(aoRemapMaxPorp, "AO贴图最大值");

            materialEditor.RangeProperty(smoothnessProp, "光滑度");

            materialEditor.RangeProperty(smoothnessRemapMinProp, "光滑度最小值");
            materialEditor.RangeProperty(smoothnessRemapMaxProp, "光滑度最大值");

            materialEditor.ColorProperty(specularColorProp, "高光色");
            materialEditor.RangeProperty(specularMultiplierProp, "高光色强度");
            materialEditor.RangeProperty(specularShiftProp, "高光偏移");
            
            materialEditor.ColorProperty(specularTintColorProp, "高光底色");
            materialEditor.RangeProperty(secondarySpecularMultiplierProp, "高光底色强度");
            materialEditor.RangeProperty(secondarySpecularShiftProp, "高光底色偏移");

            materialEditor.ColorProperty(transmissionColorProp, "_TransmissionColor");
            
            materialEditor.RangeProperty(transmissionIntensityProp, "_TransmissionIntensity");


        }

        public override void ValidateMaterial(Material material)
        {
            base.ValidateMaterial(material);
            BaseProperty.SetBasePropertyKeyWorld(material);
            BaseProperty.AnimationStatus(material);
        }
    }
}