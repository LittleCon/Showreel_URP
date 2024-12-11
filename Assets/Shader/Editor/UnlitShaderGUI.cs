using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditor.Rendering;
using UnityEngine.Rendering;

namespace FC.Editor.FCShader
{
    public class UnlitShaderGUI : BaseShaderGUI
    {
        public MaterialProperty emissionMap;
        public MaterialProperty tiling;
        public MaterialProperty emissionColor;
        public MaterialProperty emissionStrength;
        public MaterialProperty enableVertexColor;
        public override void FindProperties(MaterialProperty[] properties)
        {
            base.FindProperties(properties);
            tiling =FindProperty("_Tiliing", properties);
            
            emissionMap = FindProperty("_EmissionMap", properties);
            emissionColor =FindProperty("_EmissionColor", properties);
            emissionStrength =FindProperty("_EmissionStrength", properties);
            enableVertexColor = FindProperty("_EnableVertexColor", properties);
        }
        public override void DrawSurfaceInputs(Material material)
        {
            base.DrawSurfaceInputs(material);
            materialEditor.VectorProperty(tiling, "Tiling");
            DrawFloatToggleProperty(new GUIContent("EnableVertexColor"),enableVertexColor);
            DrawEmissionProperties(material, true);
            
        }
        public override void ValidateMaterial(Material material)
        {
            BaseProperty.SetBasePropertyKeyWorld(material);
            bool hasEmission = material.GetFloat("_Emission") == 1;
            bool canControlEmission = hasEmission&&material.GetFloat("_EmissionProcessControl")==1;
            bool hasVertexColor = material.GetFloat("_EnableVertexColor") == 1;
            CoreUtils.SetKeyword(material, "_EMISSION", hasEmission);
            CoreUtils.SetKeyword(material, "_EMISSION_PROCESSCONTROL", canControlEmission);
            CoreUtils.SetKeyword(material, "_ENABLE_VERTEX_COLOR", hasVertexColor);
            UpdateMaterialStatus(material);
        }

        private void UpdateMaterialStatus(Material material)
        {
            BaseProperty.SetMaterialStatus(material);

        }
    }
}
