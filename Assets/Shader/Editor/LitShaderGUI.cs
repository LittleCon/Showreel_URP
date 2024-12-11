using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditor.Rendering;
using UnityEngine.Rendering;

namespace FC.Editor.FCShader
{
    public class LitShaderGUI : BaseShaderGUI
    {
        public MaterialProperty brightnessProp;

        public MaterialProperty tiliingProp;

        public MaterialProperty addColorProp;

        public MaterialProperty masMapProp;

        public MaterialProperty metallicProp;

        public MaterialProperty smoothnessProp;

        public MaterialProperty specularProp;

        public MaterialProperty specularColorProp;

        public MaterialProperty occlusionStrengthProp;

        public MaterialProperty normalMapProp;

        public MaterialProperty normalStrengthProp;

        public MaterialProperty detailMapProp;

        public MaterialProperty detailAlbedoMapScaleProp;

        public MaterialProperty detailNormalMapProp;

        public MaterialProperty detailNormalMapStrengthProp;

        public MaterialProperty normalTiliingProp;

        public MaterialProperty fresnelSwitchProp;

        public MaterialProperty fresnelColorProp;

        public MaterialProperty fresnelPowerProp;
        
        public MaterialProperty fresnelRampProp;

        public MaterialProperty lightMapOnProp;

        public MaterialProperty lightMapStrengthProp;

        public MaterialProperty fresnelRemapOnProp;

        public override void FindProperties(MaterialProperty[] properties)
        {
            base.FindProperties(properties);
            brightnessProp = FindProperty(LitGUI.Properies.brightness, properties,false);
            tiliingProp = FindProperty(LitGUI.Properies.tiliing, properties,false);
            addColorProp = FindProperty(LitGUI.Properies.addColor, properties,false);
            masMapProp = FindProperty(LitGUI.Properies.masMap, properties,false);
            metallicProp = FindProperty(LitGUI.Properies.metallic, properties,false);
            smoothnessProp = FindProperty(LitGUI.Properies.smoothness, properties,false);
            //specularColorProp = FindProperty(LitGUI.Properies.specularColor, properties);
            occlusionStrengthProp = FindProperty(LitGUI.Properies.occlusionStrength, properties,false);
            normalMapProp = FindProperty(LitGUI.Properies.normalMap, properties,false);
            normalStrengthProp = FindProperty(LitGUI.Properies.normalStrength, properties,false);
            detailMapProp = FindProperty(LitGUI.Properies.detailMap, properties,false);
            detailAlbedoMapScaleProp = FindProperty(LitGUI.Properies.detailAlbedoMapScale, properties,false);
            detailNormalMapProp = FindProperty(LitGUI.Properies.detailNormalMap, properties,false);
            detailNormalMapStrengthProp = FindProperty(LitGUI.Properies.detailNormalMapStrength, properties,false);
            normalTiliingProp = FindProperty(LitGUI.Properies.normalTiliing, properties,false);

            fresnelSwitchProp = FindProperty(LitGUI.Properies.fresnelSwitch, properties,false);
            fresnelColorProp = FindProperty(LitGUI.Properies.fresnelColor, properties,false);
            fresnelPowerProp = FindProperty(LitGUI.Properies.fresnelPower, properties,false);
            fresnelRampProp = FindProperty(LitGUI.Properies.fresnelRamp, properties,false);
            lightMapOnProp= FindProperty(LitGUI.Properies.lightMapOn, properties,false);
            
            lightMapStrengthProp = FindProperty(LitGUI.Properies.lightMapStrength, properties,false);
            
            fresnelRemapOnProp = FindProperty(LitGUI.Properies.fresnelRemapOn,properties,false);
        }

        public override void DrawSurfaceInputs(Material material)
        {
            base.DrawSurfaceInputs(material);
            materialEditor.RangeProperty(brightnessProp, LitGUI.Properies.brightnessName);
            materialEditor.VectorProperty(tiliingProp, LitGUI.Properies.tiliingName);
            materialEditor.ColorProperty(addColorProp, LitGUI.Properies.addColorName);
            materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent(LitGUI.Properies.masMapName), masMapProp);
            EditorGUI.indentLevel += 1;
            materialEditor.RangeProperty(metallicProp, LitGUI.Properies.metallicName);
            materialEditor.RangeProperty(smoothnessProp, LitGUI.Properies.smoothnessName);
            //materialEditor.ColorProperty(specularColorProp, LitGUI.Properies.specularColorName);
            materialEditor.RangeProperty(occlusionStrengthProp, LitGUI.Properies.occlusionStrengthName);
            EditorGUI.indentLevel -= 1;

            materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent(LitGUI.Properies.normalMap), normalMapProp);
            EditorGUI.indentLevel += 1;
            materialEditor.FloatProperty(normalStrengthProp, LitGUI.Properies.normalStrengthName);
            materialEditor.VectorProperty(normalTiliingProp, LitGUI.Properies.normalTiliingName);
            EditorGUI.indentLevel -= 1;
            DrawEmissionProperties(material, true);

            DrawFloatToggleProperty(new GUIContent(LitGUI.Properies.fresnelSwitchName), fresnelSwitchProp);
            EditorGUI.indentLevel += 1;
            materialEditor.ColorProperty(fresnelColorProp, LitGUI.Properies.fresnelColorName);
            materialEditor.FloatProperty(fresnelPowerProp, LitGUI.Properies.fresnelPowerName);
            DrawFloatToggleProperty(new GUIContent(LitGUI.Properies.fresnelRemapOnName),fresnelRemapOnProp);
            materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent(LitGUI.Properies.fresnelRampName), fresnelRampProp);
            EditorGUI.indentLevel -= 1;
        }

        /// <summary>
        /// 将材质球从某个Shader切换到当前Shader时自动执行
        /// </summary>
        /// <param name="material"></param>
        /// <param name="oldShader"></param>
        /// <param name="newShader"></param>
        public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
        {
            // Clear all keywords for fresh start
            // Note: this will nuke user-selected custom keywords when they change shaders
            material.shaderKeywords = null;

            base.AssignNewShaderToMaterial(material, oldShader, newShader);
            // Setup keywords based on the new shader
        }
        public override void FillAdditionalFoldouts(MaterialHeaderScopeList materialScopesList)
        {
            materialScopesList.RegisterHeaderScope(LitGUI.DetailProperties.detailInputs, Expandable.Details, _ => DoDetailArea(materialEditor));
        }

        /// <summary>
        /// 当材质球属性发生变更时执行
        /// </summary>
        /// <param name="material"></param>
        public override void ValidateMaterial(Material material)
        {
            base.ValidateMaterial(material);
            SetMaterialKeywords(material);
            UpdateMaterialStatus(material);
        }
        public void DoDetailArea(MaterialEditor materialEditor)
        {


            EditorGUILayout.HelpBox("细节贴图滑块代表UV缩放，细节法线贴图滑块代表法线强度", MessageType.Info, true);
            materialEditor.TexturePropertySingleLine(LitGUI.DetailProperties.detailAlbedoMapText, detailMapProp, detailAlbedoMapScaleProp);

            materialEditor.TexturePropertySingleLine(LitGUI.DetailProperties.detailNormalMapText, detailNormalMapProp, detailNormalMapStrengthProp);
            DrawFloatToggleProperty(new GUIContent(LitGUI.Properies.lightMapOnName),lightMapOnProp);
            if (lightMapOnProp!=null&&lightMapOnProp.floatValue==1.0f)
            {
                materialEditor.RangeProperty(lightMapStrengthProp, LitGUI.Properies.lightMapstrengthName);
            }

        }

        private void SetMaterialKeywords(Material material)
        {
            BaseProperty.SetBasePropertyKeyWorld(material);

            //法线贴图
            bool hasNormalMap = material.GetTexture(LitGUI.Properies.normalMap);
            CoreUtils.SetKeyword(material, "_NORMALMAP", hasNormalMap);

            //自发光贴图
            bool hasEmission = material.GetFloat("_Emission") ==1 ;
            CoreUtils.SetKeyword(material, "_EMISSION", hasEmission);
  

            //细节贴图
            bool isScaled = material.GetFloat(LitGUI.Properies.detailNormalMapStrength) != 1.0f;
            bool hasDetailMap = material.GetTexture(LitGUI.Properies.detailMap);
            CoreUtils.SetKeyword(material, "_Detail",  hasDetailMap);
            CoreUtils.SetKeyword(material, "_DETAIL_SCALED", isScaled && hasDetailMap);

            //接受阴影
            bool receiveShadow = receiveShadowsProp!=null&&receiveShadowsProp.floatValue == 0.0f;
            CoreUtils.SetKeyword(material, "_RECEIVE_SHADOWS_OFF", receiveShadow);


            bool fresnel = material.GetFloat(LitGUI.Properies.fresnelSwitch) == 1.0f;
            CoreUtils.SetKeyword(material, "_FRESNEL", fresnel);
            
            

   
        }

        private void UpdateMaterialStatus(Material material)
        {
            BaseProperty.SetMaterialStatus(material);
            if (material.HasFloat("_LightMapOn")&&material.GetFloat("_LightMapOn") == 0.0f)
            {
                material.SetFloat("_LightMapStrength", 1.0f);
            }
        }
    }
        
}
