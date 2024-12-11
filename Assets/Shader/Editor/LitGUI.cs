using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public static class LitGUI
{

    public struct Properies
    {
        public static readonly string brightness = "_Brightness";

        public static readonly string brightnessName = "亮度";


        public static readonly string tiliing = "_Tiliing";

        public static readonly string tiliingName = "全局UV缩放（不影响细节贴图部分）";

        public static readonly string addColor = "_AddColor";

        public static readonly string addColorName = "附加色";

        public static readonly string masMap = "_MASMap";

        public static readonly string masMapName = "MAS贴图";

        public static readonly string metallic = "_Metallic";

        public static readonly string metallicName = "金属度";

        public static readonly string smoothness = "_Smoothness";

        public static readonly string smoothnessName = "光滑度";

        public static readonly string specularColor = "_SpecularColor";

        public static readonly string specularColorName = "高光颜色";

        public static readonly string occlusionStrength = "_OcclusionStrength";

        public static readonly string occlusionStrengthName = "Occlusion强度";

        public static readonly string normalMap = "_NormalMap";

        public static readonly string normalMapName = "法线贴图";

        public static readonly string normalStrength = "_NormalStrength";

        public static readonly string normalStrengthName = "法线贴图强度";

        public static readonly string detailMap = "_DetailMap";

        public static readonly string detailMapName = "细节贴图";

        public static readonly string detailAlbedoMapScale = "_DetailAlbedoMapScale";

        public static readonly string detailAlbedoMapScaleName = "细节贴图UV缩放";

        public static readonly string detailNormalMap = "_DetailNormalMap";

        public static readonly string detailNormalMapName = "细节法线贴图";

        public static readonly string detailNormalMapStrength = "_DetailNormalMapStrength";

        public static readonly string detailNormalMapStrengthName = "细节法线贴图强度";

        public static readonly string normalTiliing = "_NormalTiliing";

        public static readonly string normalTiliingName = "法线贴图Tiliing";

        public static readonly string fresnelSwitch = "_FresnelSwitch";

        public static readonly string fresnelSwitchName = "菲涅尔边缘效应";

        public static readonly string fresnelColor = "_FresnelColor";

        public static readonly string fresnelColorName = "菲涅尔颜色";

        public static readonly string fresnelPower = "_FresnelPow";

        public static readonly string fresnelPowerName = "菲涅尔指数";

        public static readonly string fresnelRamp= "_FresnelRamp";
        
        public static readonly string fresnelRampName= "菲涅尔Ramp";

        public static readonly string lightMapOnName = "开启光照贴图过渡";
        
        public static readonly string lightMapOn = "_LightMapOn";
        
        public static readonly string lightMapStrength = "_LightMapStrength";

        public static readonly string lightMapstrengthName = "光照贴图强度";
        
        public static readonly string fresnelRemapOn = "_FresnelRampOn";
        public static readonly string fresnelRemapOnName = "开启Remap贴图";

    }

    public struct DetailProperties 
    {
        public static readonly GUIContent detailInputs = EditorGUIUtility.TrTextContent("细节部分");
       

        public static readonly GUIContent detailAlbedoMapText = EditorGUIUtility.TrTextContent(Properies.detailMapName);

        public static readonly GUIContent detailNormalMapText = EditorGUIUtility.TrTextContent(Properies.detailNormalMapName);

        public static readonly GUIContent detailAlbedoMapScaleInfo = EditorGUIUtility.TrTextContent(Properies.detailNormalMapStrength);
    }
}
