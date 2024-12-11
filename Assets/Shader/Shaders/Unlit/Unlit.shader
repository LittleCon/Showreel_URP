Shader "FC/General/Unlit"
{
    Properties
    {
        [Enum(Off, 0, On, 1)] _ZWrite ("Z Write", Float) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTest ("ZTest", Float) = 4
       
         _Surface("__surface", Float) = 0.0
       
        [Toggle] _AlphaClip ("Alpha Clip", Float) = 0
        _Clip("Clip", Range(0.0, 1.0)) = 0.5
        
        [BaseMapture] _BaseMap("BaseMap", 2D) = "white" {}
        [MainColor] _BaseColor("BaseColor", Color) = (1,1,1,1)
        _Tiliing ("Tiliing", vector) = (1, 1, 0, 0)
        
        _EmissionMap("EmissionMask", 2D) = "white" {}
        [HDR]_EmissionColor("EmissionColor",Color)=(1,1,1)
        _EmissionHeight("EmissionHeight",Float)=0
        _EmissionProcessInv("EmissionProcessInv",Float)=0
        _EmissionProcessControl("_EmissionProcessControl",Float)=0
        _EmissionStrength("EmissionStrength", Range(0.0, 16)) =1.0
        _Emission("Emission",Float)=0
        _EnableVertexColor ("EnableVertexColor",float) = 0
        
         //动画
        _Animation("Animation",Float)=0.0
        _Animation_Axis("AnimationAxis",Float)=0.0
        _GuideNoise("GuideNoise",2D)="white" {}
        [HDR]_EmberColor("EmberColor",Color)=(0,0,0,0)
        _AnimationTilling("AnimationTilling",Float)=1
         [HDR]_BurnColor("BurnColor",Color)=(0,0,0,0)
        _MinValue("MinValue",Float)=0
        _MaxValue("MaxValue",Float)=0
        _InvertDir("InvertDir",Float)=0
        _BurnOffset("BurnOffset",Range(0,2))=1
        _EmberWidth("EmberWidth",Range(0,3))=0.4
        _NoiseStrength("NoiseStrength",Range(0,12))=1
        _BurnHardNess("BurnHardNess",Range(0,1))=0
        _EmberHardNess("EmberHardNess",Range(0,1))=0
        _BurnWidth("BurnWidth",Range(0,1))=0
        _DissolveAmount("DissolveAmount",Range(0,1))=0
        _ScrollSpeed("ScrollSpeed",Float)=0.0
        
        _Blend ("__Blend", Float) = 0
        _BlendAdavant("__BlendAdavant",Float)=0
        _Cull("__cull", Float) = 2.0
        _ZWriteControl("__ZWriteControl",Float)=0.0
        _Stencil("__Stencil",Float)=0.0
        _RenderQueue("RenderQueue", Float) =2000
        [Enum(Off, 0, On, 1)] _Blend1 ("Blend", Float) = 1
        [Enum(UnityEngine.Rendering.BlendOp)]
        _BlendOp("BlendOp", int) = 0
        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcBlend("Blend src", int) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstBlend("Blend dst", int) = 8
         _SrcAlphaBlend("SrcAlphaBlend", int) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstAlphaBlend("DstAlphaBlend", int) = 8
        
        [Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp ("Stencil Comparison", Float) = 7
        _StencilID ("Stencil ID", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        [HideInInspector] _AlphaToMask("__alphaToMask", Float) = 0.0
       //[Toggle(_RECEIVE_SHADOWS_OFF)]_PBR_MASK ("_RECEIVE_SHADOWS_OFF", Float) = 0
    }
    SubShader
    {
          Tags
        {
            "RenderType" = "Opaque"
            "IgnoreProjector" = "True"
            "UniversalMaterialType" = "Unlit"
            "RenderPipeline" = "UniversalPipeline"
        }
        Stencil
        {
           Ref [_StencilID]
           Comp [_StencilComp]
           Pass [_StencilOp]
           ReadMask [_StencilReadMask]
           WriteMask [_StencilWriteMask]
        }
        AlphaToMask [_AlphaToMask] 
        BlendOp [_BlendOp]
        Blend [_SrcBlend][_DstBlend],[_SrcAlphaBlend][_DstAlphaBlend]
        ZWrite [_ZWrite]
        ZTest [_ZTest]
        Cull[_Cull]

        Pass
        {
            Name"QCForwardUnlit"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
          
            HLSLPROGRAM
            #pragma target 3.5

            // Material Keywords
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _EMISSION_PROCESSCONTROL
            #pragma shader_feature_local_fragment _ENABLE_VERTEX_COLOR

            #pragma shader_feature_local_fragment _ANIMATION_ON
            #pragma shader_feature_local_fragment _ANIMATION_AXIS_X _ANIMATION_AXIS_Y _ANIMATION_AXIS_Z
            
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "UnlitInput.hlsl"
            #include "UnlitForwardPass.hlsl"
            ENDHLSL
        }

        /*Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }

            // -------------------------------------
            // Render State Commands
            Cull Off

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex UniversalVertexMeta
            #pragma fragment UniversalFragmentMetaLit

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
            #pragma shader_feature EDITOR_VISUALIZATION

            // -------------------------------------
            // Includes
            #include "LitInput.hlsl"
            #include "LitMetaPass.hlsl"

            ENDHLSL
        }*/

    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "FC.Editor.QCShader.UnlitShaderGUI"
}
