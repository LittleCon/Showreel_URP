Shader "FC/Particular/Ice"
{
    Properties
    {
        [Header(PBR)]
        [BaseMapture]_BaseMap ("BaseMap", 2D) = "white" {}
        [MainColor]_BaseColor("BaseColor",Color)=(1,1,1,1)
        _MASMap("MASTex",2D)= "white"{}
        _Metallic("Metallic",Range(0,1.0))=0.0
        _Smoothness("Smoothness",Range(0.0, 1.0)) = 1.0
        _OcclusionStrength("OcclusionStrength", Range(0.0, 1.0)) = 1.0
        _NormalMap("NormalMap",2D)="bump"{}
        _NormalTiliing("NormalTiliing",Vector)=(1,1,0,0)
        _NormalStrength("NormalStrength",Float)=1.0
        
        [Header(FogColor)]
        _FogColor("FogColor", Color) = (0.16, 0.42, 0.47, 0.0)
        _FogBase("FogBase", Float) = 0.3
        _FogDensity("FogDensity", Float) = 0.33
        _ShapeSphereRadius("ShapeSphereRadius", Float) = 0.5

        [Header(Dust)]
        [HDR]_DustColor("DustColor", Color) = (1,1,1,1)
        _DustTexture("DustTexture", 2D) = "white" {}
        _DustTextureUVAnim("DustTextureUVAnim", Vector) = (0,0,0,0)
        _DustDepthShift("DustDepthShift", Float) = 0.5
        _DustLayerBetween("DustLayerBetween", Float) = 0.5

        [Header(Cracks)]
        _CracksColor("Cracks Color", Color) = (0.1, 0.6, 1.0, 0.7)
        _CracksSDFTexture("Cracks SDF Texture", 2D) = "black" {}
        [IntRange]_CracksDepthIterations("Cracks Depth Iterations", Range(0,10)) = 5
        _CracksDepthScale("Cracks Depth Scale", Float) = 0.09
        _CracksDepthStepSize("Cracks Depth StepSize", Float) = 0.1
        _CracksDistortion("Cracks Distortion", Float) = 0.02
        _CracksHeight("Cracks Height", Float) = 0.8
        _CracksWidth("Cracks Width", Float) = 0.1

        [Header(Reflection)]
        _ReflectionColor("Reflection Color", Color) = (1,1,1,1)
        [noscaleoffset]_ReflectionTexture("Reflection Texture", Cube) = "black" {}

        [Header(Refraction)]
        [Toggle(_ENABLE_REFRACTION)]_EnableRefraction("Enable Refraction", Float) = 0
        _RefractionColor("Refraction Color", Color) = (1,1,1,1)
        _FresnelPower("Fresnel Power", Float) = 5.0
        _FresnelBias("Fresnel Bias", Float) = 1.0
        
        _MaskMap("Mask Map",2D) = "white"{}
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "Queue"="Geometry" "UniversalMaterialType" = "Lit"
        }

        Pass
        {
            Name "Lit"

            HLSLPROGRAM
            #pragma target 3.5

            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ENABLE_REFRACTION
            #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
            // -------------------------------------

            #pragma vertex IcePassVertex
            #pragma fragment IcePassFragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "IceInput.hlsl"
            #include "IceForwardPass.hlsl"
            ENDHLSL
        }
    }
}