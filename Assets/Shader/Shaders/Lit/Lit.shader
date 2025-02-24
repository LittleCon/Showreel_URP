Shader "FC/General/Lit"
{
    Properties
    {
        
        
        _EnableDither("Enable Dither", Float) = 0
        [NoScaleOffset]_TilingTex("TilingTex", 2D) = "white" {}
        _TilingValue("TilingValue",  Vector) = (1,1,0,0)
        _CharPosAdjust("CharPosAdjust", Range( 0 , 1)) = 0.5
        _FadeDistance("FadeDistance",Range( 0 , 1)) = 0.3
        _DispearDistance("DispearDistance",Range( 0 , 1)) = 0.2

        [MainTexture]_BaseMap ("BaseMap", 2D) = "white" {}
        [MainColor]_BaseColor("BaseColor",Color)=(1,1,1,1)
       
        _Brightness("Brightness",Range(0,16))=1
        _Tiliing ("Tiliing", vector) = (1, 1, 0, 0)

        _AddColor("AddColor",Color)=(0,0,0,0)
        //PBR
        _MASMap("MASTex",2D)= "white"{}
        _Metallic("Metallic",Range(0,1.0))=0.0
        //_MetallicTex("MetallicTex",2D)="white"{}
        _Smoothness("Smoothness",Range(0.0, 1.0)) = 1.0
        //_SpecularColor("SpecularColor", Color) = (0.2, 0.2, 0.2)
        //_SpecularTex("SpecularTex", 2D) = "white" {}

        _OcclusionStrength("OcclusionStrength", Range(0.0, 1.0)) = 1.0
        //_OcclusionTex("OcclusionTex", 2D) = "white" {}

        _NormalMap("NormalMap",2D)="bump"{}
        _NormalTiliing("NormalTiliing",Vector)=(1,1,0,0)
        _NormalStrength("NormalStrength",Float)=1.0
        
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
        

        _FresnelSwitch("FresnelSwitch",Float)=0.0
        [HDR]_FresnelColor("FresnelColor",Color)=(0,0,0,0)
        _FresnelPow("FresnelPow",Float)=1
        _FresnelRampOn("FresnelRemapOn",Float)=0
        _FresnelRamp("FresnelRamp",2D)="white"{}
        _Emission("Emission",Float)=0
        _EmissionMap("EmissionMask",2D)="white"{}
        [HDR]_EmissionColor("EmissionColor",Color)=(1,1,1)
        _EmissionStrength("EmissionStrength", Range(0.0, 16.0)) =1.0


        _DetailMap("DetailMap",2D)="white"{}
        _DetailAlbedoMapScale("Scale", Range(0.0, 2.0)) = 1.0
        _DetailNormalMap("DetailNormalMap",2D)="bump"{}
        _DetailNormalMapStrength("DetailNormalMapStrength", Range(0.0, 2.0)) = 1.0
        
        [Enum(Off, 0, On, 1)] _ZWrite ("Z Write", Float) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTest ("ZTest", Float) = 4

         _Surface("__surface", Float) = 0.0
       
        [Toggle] _AlphaClip ("Alpha Clip", Float) = 0
        _Clip("Clip", Range(0.0, 1.0)) = 0.5
        
        [Toggle]_LightMapOn("LightMapOn",Float)=0
        _LightMapStrength("LightMapStrength",Range(0,1))=1
        _Blend ("__Blend", Float) = 0
        _BlendAdavant("__BlendAdavant",Float)=0
        _Cull("__cull", Float) = 2.0
        _ZWriteControl("__ZWriteControl",Float)=0.0
        _Stencil("__Stencil",Float)=0.0
        _RenderQueue("RenderQueue", Float) =2000
        [ToggleUI] _ReceiveShadows("Receive Shadows", Float) = 1.0
        [Enum(UnityEngine.Rendering.BlendOp)]
        _BlendOp("BlendOp", int) = 0
        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcBlend("Blend src", int) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstBlend("Blend dst", int) = 8
        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcAlphaBlend("SrcAlphaBlend", int) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstAlphaBlend("DstAlphaBlend", int) = 8
        
       

        [Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp ("Stencil Comparison", Float) = 7
        _StencilID ("Stencil ID", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        [HideInInspector] _AlphaToMask("__alphaToMask", Float) = 0.0


//        //烘焙时 Unity会在shader里寻找命名为"_MainTex"的贴图 如果找不到 那就默认Alpha是1 阴影的AlphaTest失效
//        //或者在已有的主帖图加上[MainTexture]
//        [HideInInspector] _MainTex("BaseMap", 2D) = "white" {}

        
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
            "UniversalMaterialType" = "Lit"
        }
      

        Pass
        {
            Name"QCForwardLit"
            Tags
            {
                "LightMode" = "UniversalForward"
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
          
            HLSLPROGRAM
            #pragma target 3.5

            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _ENABLE_DITHER
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local _DETAIL
            #pragma shader_feature_local _FRESNEL
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local_fragment _ANIMATION_ON
            #pragma shader_feature_local_fragment _ANIMATION_AXIS_X _ANIMATION_AXIS_Y _ANIMATION_AXIS_Z
            #pragma multi_compile _ _ADDITIONAL_LIGHTS //_ADDITIONAL_LIGHTS_VERTEX 
           
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile  _ LIGHTMAP_ON
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile_fog
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            //贴花
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            #include "LitInput.hlsl"
            #include "LitForwardPass.hlsl"
            
           


            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _ALPHATEST_ON
           // #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
           // #pragma multi_compile_instancing
           // #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Universal Pipeline keywords

            // -------------------------------------
            // Unity defined keywords
           // #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            // -------------------------------------
            // Includes
            #include "LitInput.hlsl"
            #include "../../ShaderLibrary/ShadowCasterPass.hlsl"
            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            ColorMask R
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include "LitInput.hlsl"
            #include "../../ShaderLibrary/DepthOnlyPass.hlsl"
            ENDHLSL
        }

        Pass
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
            #pragma shader_feature EDITOR_VISUALIZATION

            // -------------------------------------
            // Includes
            #include "LitInput.hlsl"
            #include "LitMetaPass.hlsl"

            ENDHLSL
        }

    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "FC.Editor.FCShader.LitShaderGUI"
}