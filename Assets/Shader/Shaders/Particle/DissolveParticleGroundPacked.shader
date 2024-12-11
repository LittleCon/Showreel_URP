Shader "FC/Particle/DissolveParticleGroundPacked"
{
    Properties
    {
        _FinalPower("Final Power", Float) = 4
        _FinalOpacityPower("Final Opacity Power", Float) = 1
        _FinalOpacityExp("Final Opacity Exp", Range(0.2, 20)) = 1
        [NoScaleOffset]_Ramp("Ramp", 2D) = "white" {}
        _RampColorTint("Ramp Color Tint", Color) = (1, 1, 1, 1)
        _RampOffsetMultiply("Ramp Offset Multiply", Range(0, 4)) = 1
        _RampOffsetExp("Ramp Offset Exp", Range(0.2, 8)) = 1
        _RampSmoothstepMin("Ramp Smoothstep Min", Float) = 0.25
        _RampSmoothstepMax("Ramp Smoothstep Max", Float) = 0.75
        [NoScaleOffset]_PackedTex("PackedTex", 2D) = "white" {}
        _HeightSlopeControl("Height Slope Control", Range(0, 1)) = 0
        _HeightBoost("Height Boost", Float) = 1
        _HeightMapNegate("Height Map Negate", Range(0, 1)) = 0
        _AlbedoColor("Albedo Color", Color) = (0.6235294, 0.4745098, 0.427451, 1)
        _AlbedoColor2("Albedo Color 2", Color) = (0, 0, 0, 1)
        _AlbedoMapExp("Albedo Map Exp", Range(0.5, 2)) = 1
        [NoScaleOffset]_OpacityMask("Opacity Mask", 2D) = "white" {}
        _OpacityMaskScaler("Opacity Mask Scaler", Range(0.5, 2)) = 1
        _OpacityMaskPower("Opacity Mask Power", Float) = 1
        _OpacityMaskExp("Opacity Mask Exp", Range(0.2, 8)) = 0.2
        [NoScaleOffset]_SecondMask("Second Mask", 2D) = "white" {}
        _SecondMaskScaleU("Second Mask Scale U", Float) = 1
        _SecondMaskScaleV("Second Mask Scale V", Float) = 1
        _SecondMaskExp("Second Mask Exp", Range(0.2, 4)) = 1
        _SecondMaskEdgeGlow("Second Mask Edge Glow", Float) = 0
        [NoScaleOffset]_SecondMaskProfile("Second Mask Profile", 2D) = "white" {}
        [NoScaleOffset]_LavaAppearMask("Lava Appear Mask", 2D) = "white" {}
        _LavaAppearMaskScaleU("Lava Appear Mask Scale U", Float) = 1
        _LavaAppearMaskScaleV("Lava Appear Mask Scale V", Float) = 1
        _LavaAppearMaskExp("Lava Appear Mask Exp", Range(0.2, 8)) = 1
        [NoScaleOffset]_LavaNoise("Lava Noise", 2D) = "white" {}
        _LavaNoiseScaleU("Lava Noise Scale U", Float) = 1
        _LavaNoiseScaleV("Lava Noise Scale V", Float) = 1
        _LavaNoiseNegate("Lava Noise Negate", Range(0, 1)) = 0
        _LavaNoiseScrollSpeed("Lava Noise Scroll Speed", Float) = 0
        [NoScaleOffset]_LavaNoiseDistortion("Lava Noise Distortion", 2D) = "white" {}
        _LavaNoiseDistortionScaleU("Lava Noise Distortion Scale U", Float) = 1
        _LavaNoiseDistortionScaleV("Lava Noise Distortion Scale V", Float) = 1
        _LavaNoiseDistortionAmount("Lava Noise Distortion Amount", Float) = 0
        _LavaNoiseDistortionScrollSpeed("Lava Noise Distortion Scroll Speed", Float) = 0.075
        _LavaDistortionSlopeNegate("Lava Distortion Slope Negate", Range(0, 1)) = 1
        _LavaDistortionSlopeStyle("Lava Distortion Slope Style", Range(0, 1)) = 0
        _LavaOnlyInValleysNegate("Lava Only In Valleys Negate", Range(0, 1)) = 1
        _LavaOnlyInValleysExp("Lava Only In Valleys Exp", Range(0.2, 8)) = 1
        [NoScaleOffset]_SurfaceNoise("Surface Noise", 2D) = "white" {}
        _SurfaceNoiseScaleU("Surface Noise Scale U", Float) = 1
        _SurfaceNoiseScaleV("Surface Noise Scale V", Float) = 1
        _SurfaceNoiseAdd("Surface Noise Add", Range(0, 4)) = 0
        _SurfaceNoiseExp("Surface Noise Exp", Range(0.2, 4)) = 1
        [ToggleUI]_VALLEYSEMISSIONBOOSTENABLED("Valleys Emission Boost Enabled", Float) = 0
        _ValleysEmissionBoostAmount("Valleys Emission Boost Amount", Range(0, 100)) = 80
        _ValleysEmissionBoostBloom("Valleys Emission Boost Bloom", Range(0, 1)) = 1
        [NoScaleOffset]_Cracks("Cracks", 2D) = "white" {}
        _CracksScaleU("Cracks Scale U", Float) = 1
        _CracksScaleV("Cracks Scale V", Float) = 1
        _CracksNegate("Cracks Negate", Range(0, 1)) = 0
        _CracksNegateSlope("Cracks Negate Slope", Range(0, 1)) = 0
        [NoScaleOffset]_DissolveTexture("Dissolve Texture", 2D) = "white" {}
        [ToggleUI]_DISSOLVETEXTUREFLIP("Dissolve Texture Flip", Float) = 1
        _DissolveTextureScaleU("Dissolve Texture Scale U", Float) = 1
        _DissolveTextureScaleV("Dissolve Texture Scale V", Float) = 1
        _DissolveTextureRandomMin("Dissolve Texture Random Min", Range(0.5, 1)) = 0.9
        _DissolveTextureRandomMax("Dissolve Texture Random Max", Range(1, 1.5)) = 1.1
        _DissolveExp("Dissolve Exp", Float) = 6.47
        _DissolveExpReversed("Dissolve Exp Reversed", Float) = 2
        [Toggle]_LAVANOISEENABLED("Lava Noise Enabled", Float) = 0
        [Toggle]_SURFACENOISEENABLED("Surface Noise Enabled", Float) = 0
        [Toggle]_CRACKSENABLED("Cracks Enabled", Float) = 0
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Unlit"
            "Queue"="Transparent"
            "DisableBatching"="False"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalUnlitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                // LightMode: <None>
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma shader_feature _ _SAMPLE_GI
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma shader_feature_local _ _LAVANOISEENABLED_ON
        #pragma shader_feature_local _ _SURFACENOISEENABLED_ON
        #pragma shader_feature_local _ _CRACKSENABLED_ON
        
        #if defined(_LAVANOISEENABLED_ON) && defined(_SURFACENOISEENABLED_ON) && defined(_CRACKSENABLED_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_LAVANOISEENABLED_ON) && defined(_SURFACENOISEENABLED_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_LAVANOISEENABLED_ON) && defined(_CRACKSENABLED_ON)
            #define KEYWORD_PERMUTATION_2
        #elif defined(_LAVANOISEENABLED_ON)
            #define KEYWORD_PERMUTATION_3
        #elif defined(_SURFACENOISEENABLED_ON) && defined(_CRACKSENABLED_ON)
            #define KEYWORD_PERMUTATION_4
        #elif defined(_SURFACENOISEENABLED_ON)
            #define KEYWORD_PERMUTATION_5
        #elif defined(_CRACKSENABLED_ON)
            #define KEYWORD_PERMUTATION_6
        #else
            #define KEYWORD_PERMUTATION_7
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_COLOR
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_NORMAL_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_COLOR
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_UNLIT
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 color : COLOR;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 color;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 VertexColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 TimeParameters;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord1 : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 color : INTERP2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionWS : INTERP3;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalWS : INTERP4;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.color.xyzw = input.color;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.color = input.color.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _FinalPower;
        float _FinalOpacityPower;
        float _FinalOpacityExp;
        float4 _Ramp_TexelSize;
        float4 _RampColorTint;
        float _RampOffsetMultiply;
        float _RampOffsetExp;
        float _RampSmoothstepMin;
        float _RampSmoothstepMax;
        float4 _PackedTex_TexelSize;
        float _HeightSlopeControl;
        float _HeightBoost;
        float _HeightMapNegate;
        float4 _AlbedoColor;
        float4 _AlbedoColor2;
        float _AlbedoMapExp;
        float4 _OpacityMask_TexelSize;
        float _OpacityMaskScaler;
        float _OpacityMaskPower;
        float _OpacityMaskExp;
        float4 _SecondMask_TexelSize;
        float _SecondMaskScaleU;
        float _SecondMaskScaleV;
        float _SecondMaskExp;
        float _SecondMaskEdgeGlow;
        float4 _SecondMaskProfile_TexelSize;
        float4 _LavaAppearMask_TexelSize;
        float _LavaAppearMaskScaleU;
        float _LavaAppearMaskScaleV;
        float _LavaAppearMaskExp;
        float4 _LavaNoise_TexelSize;
        float _LavaNoiseScaleU;
        float _LavaNoiseScaleV;
        float _LavaNoiseNegate;
        float _LavaNoiseScrollSpeed;
        float4 _LavaNoiseDistortion_TexelSize;
        float _LavaNoiseDistortionScaleU;
        float _LavaNoiseDistortionScaleV;
        float _LavaNoiseDistortionAmount;
        float _LavaNoiseDistortionScrollSpeed;
        float _LavaDistortionSlopeNegate;
        float _LavaDistortionSlopeStyle;
        float _LavaOnlyInValleysNegate;
        float _LavaOnlyInValleysExp;
        float4 _SurfaceNoise_TexelSize;
        float _SurfaceNoiseScaleU;
        float _SurfaceNoiseScaleV;
        float _SurfaceNoiseAdd;
        float _SurfaceNoiseExp;
        float _VALLEYSEMISSIONBOOSTENABLED;
        float _ValleysEmissionBoostAmount;
        float _ValleysEmissionBoostBloom;
        float4 _Cracks_TexelSize;
        float _CracksScaleU;
        float _CracksScaleV;
        float _CracksNegate;
        float _CracksNegateSlope;
        float4 _DissolveTexture_TexelSize;
        float _DISSOLVETEXTUREFLIP;
        float _DissolveTextureScaleU;
        float _DissolveTextureScaleV;
        float _DissolveTextureRandomMin;
        float _DissolveTextureRandomMax;
        float _DissolveExp;
        float _DissolveExpReversed;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Ramp);
        SAMPLER(sampler_Ramp);
        TEXTURE2D(_PackedTex);
        SAMPLER(sampler_PackedTex);
        TEXTURE2D(_OpacityMask);
        SAMPLER(sampler_OpacityMask);
        TEXTURE2D(_SecondMask);
        SAMPLER(sampler_SecondMask);
        TEXTURE2D(_SecondMaskProfile);
        SAMPLER(sampler_SecondMaskProfile);
        TEXTURE2D(_LavaAppearMask);
        SAMPLER(sampler_LavaAppearMask);
        TEXTURE2D(_LavaNoise);
        SAMPLER(sampler_LavaNoise);
        TEXTURE2D(_LavaNoiseDistortion);
        SAMPLER(sampler_LavaNoiseDistortion);
        TEXTURE2D(_SurfaceNoise);
        SAMPLER(sampler_SurfaceNoise);
        TEXTURE2D(_Cracks);
        SAMPLER(sampler_Cracks);
        TEXTURE2D(_DissolveTexture);
        SAMPLER(sampler_DissolveTexture);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_cbd94d1f5354308ca087fedb431eb436_Out_0_Vector4 = _AlbedoColor2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_6830510532834c879ae970a973bc8c55_Out_0_Vector4 = _AlbedoColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_30885f1ec4e7a383b6ca6413adc1e12b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_PackedTex);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_0bd8d4a7ecdc0c87ab8d367fdaf89e9d_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_286c753af328f8829fbe57f023015088_R_1_Float = _UV_0bd8d4a7ecdc0c87ab8d367fdaf89e9d_Out_0_Vector4[0];
            float _Split_286c753af328f8829fbe57f023015088_G_2_Float = _UV_0bd8d4a7ecdc0c87ab8d367fdaf89e9d_Out_0_Vector4[1];
            float _Split_286c753af328f8829fbe57f023015088_B_3_Float = _UV_0bd8d4a7ecdc0c87ab8d367fdaf89e9d_Out_0_Vector4[2];
            float _Split_286c753af328f8829fbe57f023015088_A_4_Float = _UV_0bd8d4a7ecdc0c87ab8d367fdaf89e9d_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_fda406917ada068ebbf454cf9b4925b2_Out_0_Vector2 = float2(_Split_286c753af328f8829fbe57f023015088_R_1_Float, _Split_286c753af328f8829fbe57f023015088_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_b3d31c8f969c368e9d0c302a25561aaf_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_30885f1ec4e7a383b6ca6413adc1e12b_Out_0_Texture2D.tex, _Property_30885f1ec4e7a383b6ca6413adc1e12b_Out_0_Texture2D.samplerstate, _Property_30885f1ec4e7a383b6ca6413adc1e12b_Out_0_Texture2D.GetTransformedUV(_Vector2_fda406917ada068ebbf454cf9b4925b2_Out_0_Vector2) );
            float _SampleTexture2D_b3d31c8f969c368e9d0c302a25561aaf_R_4_Float = _SampleTexture2D_b3d31c8f969c368e9d0c302a25561aaf_RGBA_0_Vector4.r;
            float _SampleTexture2D_b3d31c8f969c368e9d0c302a25561aaf_G_5_Float = _SampleTexture2D_b3d31c8f969c368e9d0c302a25561aaf_RGBA_0_Vector4.g;
            float _SampleTexture2D_b3d31c8f969c368e9d0c302a25561aaf_B_6_Float = _SampleTexture2D_b3d31c8f969c368e9d0c302a25561aaf_RGBA_0_Vector4.b;
            float _SampleTexture2D_b3d31c8f969c368e9d0c302a25561aaf_A_7_Float = _SampleTexture2D_b3d31c8f969c368e9d0c302a25561aaf_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Add_eb094a1ca0366788ab2cf15df38b67b4_Out_2_Float;
            Unity_Add_float(_SampleTexture2D_b3d31c8f969c368e9d0c302a25561aaf_R_4_Float, 0, _Add_eb094a1ca0366788ab2cf15df38b67b4_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_d004c903a58b89828e01a71c6650df5a_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Cracks);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_06665ab13a2efd8996077aa88f227bbf_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_516bbc2c81df728295fc0f9b11782b97_R_1_Float = _UV_06665ab13a2efd8996077aa88f227bbf_Out_0_Vector4[0];
            float _Split_516bbc2c81df728295fc0f9b11782b97_G_2_Float = _UV_06665ab13a2efd8996077aa88f227bbf_Out_0_Vector4[1];
            float _Split_516bbc2c81df728295fc0f9b11782b97_B_3_Float = _UV_06665ab13a2efd8996077aa88f227bbf_Out_0_Vector4[2];
            float _Split_516bbc2c81df728295fc0f9b11782b97_A_4_Float = _UV_06665ab13a2efd8996077aa88f227bbf_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_824906976fe6b38eb0253c141e713b0a_Out_0_Vector2 = float2(_Split_516bbc2c81df728295fc0f9b11782b97_R_1_Float, _Split_516bbc2c81df728295fc0f9b11782b97_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_694d2734bf178483bc23dc8feb4016f8_Out_0_Float = _CracksScaleU;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_bc78e05a2d06428dbc46e87be90241c7_Out_0_Float = _CracksScaleV;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_d3c8445616b60d84973163cd0cf28fa4_Out_0_Vector2 = float2(_Property_694d2734bf178483bc23dc8feb4016f8_Out_0_Float, _Property_bc78e05a2d06428dbc46e87be90241c7_Out_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Multiply_fd0559179e09fe829b85fa084ed22e40_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_824906976fe6b38eb0253c141e713b0a_Out_0_Vector2, _Vector2_d3c8445616b60d84973163cd0cf28fa4_Out_0_Vector2, _Multiply_fd0559179e09fe829b85fa084ed22e40_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_84f695f5b94abd82ad76370893d51ffe_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_d004c903a58b89828e01a71c6650df5a_Out_0_Texture2D.tex, _Property_d004c903a58b89828e01a71c6650df5a_Out_0_Texture2D.samplerstate, _Property_d004c903a58b89828e01a71c6650df5a_Out_0_Texture2D.GetTransformedUV(_Multiply_fd0559179e09fe829b85fa084ed22e40_Out_2_Vector2) );
            float _SampleTexture2D_84f695f5b94abd82ad76370893d51ffe_R_4_Float = _SampleTexture2D_84f695f5b94abd82ad76370893d51ffe_RGBA_0_Vector4.r;
            float _SampleTexture2D_84f695f5b94abd82ad76370893d51ffe_G_5_Float = _SampleTexture2D_84f695f5b94abd82ad76370893d51ffe_RGBA_0_Vector4.g;
            float _SampleTexture2D_84f695f5b94abd82ad76370893d51ffe_B_6_Float = _SampleTexture2D_84f695f5b94abd82ad76370893d51ffe_RGBA_0_Vector4.b;
            float _SampleTexture2D_84f695f5b94abd82ad76370893d51ffe_A_7_Float = _SampleTexture2D_84f695f5b94abd82ad76370893d51ffe_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_8ddbc7dff7227b8185f03501ae13b1b4_Out_0_Float = _CracksNegate;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _OneMinus_95f9468024f9c1879ad468e5ec548a7e_Out_1_Float;
            Unity_OneMinus_float(_Property_8ddbc7dff7227b8185f03501ae13b1b4_Out_0_Float, _OneMinus_95f9468024f9c1879ad468e5ec548a7e_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_db0877fb9c33b387a9635644f6b39725_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_84f695f5b94abd82ad76370893d51ffe_R_4_Float, _OneMinus_95f9468024f9c1879ad468e5ec548a7e_Out_1_Float, _Multiply_db0877fb9c33b387a9635644f6b39725_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Add_f929c130729c4b8bbd9fc9765e4ed295_Out_2_Float;
            Unity_Add_float(_Multiply_db0877fb9c33b387a9635644f6b39725_Out_2_Float, _Property_8ddbc7dff7227b8185f03501ae13b1b4_Out_0_Float, _Add_f929c130729c4b8bbd9fc9765e4ed295_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Add_ce0cf089c5891f819a1c6ca50c03e8ce_Out_2_Float;
            Unity_Add_float(_SampleTexture2D_b3d31c8f969c368e9d0c302a25561aaf_G_5_Float, 0, _Add_ce0cf089c5891f819a1c6ca50c03e8ce_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_e0c50a726afe1d8f9a403a753551a3b3_Out_0_Float = _CracksNegateSlope;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_73f5ec723e1fb58e8a96a369bb59bf53_Out_2_Float;
            Unity_Multiply_float_float(_Add_ce0cf089c5891f819a1c6ca50c03e8ce_Out_2_Float, _Property_e0c50a726afe1d8f9a403a753551a3b3_Out_0_Float, _Multiply_73f5ec723e1fb58e8a96a369bb59bf53_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Add_ae898c7c50ed238d90635d721efbca22_Out_2_Float;
            Unity_Add_float(_Add_f929c130729c4b8bbd9fc9765e4ed295_Out_2_Float, _Multiply_73f5ec723e1fb58e8a96a369bb59bf53_Out_2_Float, _Add_ae898c7c50ed238d90635d721efbca22_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_5fde86c9b31b45888d5fda02f8513828_Out_3_Float;
            Unity_Clamp_float(_Add_ae898c7c50ed238d90635d721efbca22_Out_2_Float, 0, 1, _Clamp_5fde86c9b31b45888d5fda02f8513828_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Float_fbfce7979517ba899e6cf36752e1ad96_Out_0_Float = 1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_CRACKSENABLED_ON)
            float _CracksEnabled_0e667cb8e3ee9881a642073afeadf6bb_Out_0_Float = _Clamp_5fde86c9b31b45888d5fda02f8513828_Out_3_Float;
            #else
            float _CracksEnabled_0e667cb8e3ee9881a642073afeadf6bb_Out_0_Float = _Float_fbfce7979517ba899e6cf36752e1ad96_Out_0_Float;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_f760b4723a0aa78c923796adaf364111_Out_2_Float;
            Unity_Multiply_float_float(_Add_eb094a1ca0366788ab2cf15df38b67b4_Out_2_Float, _CracksEnabled_0e667cb8e3ee9881a642073afeadf6bb_Out_0_Float, _Multiply_f760b4723a0aa78c923796adaf364111_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Add_bd4c5000960ef98fa1557468023626bb_Out_2_Float;
            Unity_Add_float(_SampleTexture2D_b3d31c8f969c368e9d0c302a25561aaf_B_6_Float, 0, _Add_bd4c5000960ef98fa1557468023626bb_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_0d6862a12cd82f8cbfd69896bfecf379_Out_0_Float = _HeightMapNegate;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Add_6787d27c0e7eaf859f809bd75dbb586b_Out_2_Float;
            Unity_Add_float(_Add_bd4c5000960ef98fa1557468023626bb_Out_2_Float, _Property_0d6862a12cd82f8cbfd69896bfecf379_Out_0_Float, _Add_6787d27c0e7eaf859f809bd75dbb586b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_bdfc64868de7028e9af984fadf0b1319_Out_3_Float;
            Unity_Clamp_float(_Add_6787d27c0e7eaf859f809bd75dbb586b_Out_2_Float, 0, 1, _Clamp_bdfc64868de7028e9af984fadf0b1319_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_caa9e8a71bf1798bb41d704d6b0df03d_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_f760b4723a0aa78c923796adaf364111_Out_2_Float, _Clamp_bdfc64868de7028e9af984fadf0b1319_Out_3_Float, _Multiply_caa9e8a71bf1798bb41d704d6b0df03d_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_5df75e2f0b073d8783e6cdd6a60c3c72_Out_0_Float = _AlbedoMapExp;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_4ab6c01b74e87d818d21a54b4debaf2d_Out_2_Float;
            Unity_Power_float(_Multiply_caa9e8a71bf1798bb41d704d6b0df03d_Out_2_Float, _Property_5df75e2f0b073d8783e6cdd6a60c3c72_Out_0_Float, _Power_4ab6c01b74e87d818d21a54b4debaf2d_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Add_1f8b2d8060996087bbec729f409fc77a_Out_2_Float;
            Unity_Add_float(_SampleTexture2D_b3d31c8f969c368e9d0c302a25561aaf_A_7_Float, 0, _Add_1f8b2d8060996087bbec729f409fc77a_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_fbdeaa13af5c698daf4e07a77f3ba2ee_Out_0_Float = _HeightSlopeControl;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_9631f2a0e5963f8495f916e535bcb0d6_Out_2_Float;
            Unity_Multiply_float_float(_Add_1f8b2d8060996087bbec729f409fc77a_Out_2_Float, _Property_fbdeaa13af5c698daf4e07a77f3ba2ee_Out_0_Float, _Multiply_9631f2a0e5963f8495f916e535bcb0d6_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_d51fb91f65a4fc898930b25439ab0ee8_Out_2_Float;
            Unity_Subtract_float(_Power_4ab6c01b74e87d818d21a54b4debaf2d_Out_2_Float, _Multiply_9631f2a0e5963f8495f916e535bcb0d6_Out_2_Float, _Subtract_d51fb91f65a4fc898930b25439ab0ee8_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_718dfb281145b487b3f945b354fbc33e_Out_3_Float;
            Unity_Clamp_float(_Subtract_d51fb91f65a4fc898930b25439ab0ee8_Out_2_Float, 0, 1, _Clamp_718dfb281145b487b3f945b354fbc33e_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Lerp_629f74e1e348258dad2769378b8e65d4_Out_3_Vector4;
            Unity_Lerp_float4(_Property_cbd94d1f5354308ca087fedb431eb436_Out_0_Vector4, _Property_6830510532834c879ae970a973bc8c55_Out_0_Vector4, (_Clamp_718dfb281145b487b3f945b354fbc33e_Out_3_Float.xxxx), _Lerp_629f74e1e348258dad2769378b8e65d4_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_f9d4f1409db2bc88b6d42fa79f52d71b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Ramp);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_786bba4695499b8097b7e5bc2eaaae3a_Out_0_Float = _RampOffsetMultiply;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_0a00cec3c513d984b7ceeae0c3e83b24_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_LavaNoise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_03caaa62cb71bb8ab953b95239ec05ac_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_LavaNoiseDistortion);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_84654174f39fa983bca3ebe6307050ff_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_43917feb4f410780af084b8559ffc221_R_1_Float = _UV_84654174f39fa983bca3ebe6307050ff_Out_0_Vector4[0];
            float _Split_43917feb4f410780af084b8559ffc221_G_2_Float = _UV_84654174f39fa983bca3ebe6307050ff_Out_0_Vector4[1];
            float _Split_43917feb4f410780af084b8559ffc221_B_3_Float = _UV_84654174f39fa983bca3ebe6307050ff_Out_0_Vector4[2];
            float _Split_43917feb4f410780af084b8559ffc221_A_4_Float = _UV_84654174f39fa983bca3ebe6307050ff_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_028048d12902188983507205b3138df9_Out_0_Vector2 = float2(_Split_43917feb4f410780af084b8559ffc221_R_1_Float, _Split_43917feb4f410780af084b8559ffc221_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_88b4d0c5d21a7183a57db653a779d1ae_Out_0_Float = _LavaNoiseDistortionScaleU;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_ebe5e0ddcde3198ba0854ef0cecb43bb_Out_0_Float = _LavaNoiseDistortionScaleV;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_299ed772bf4c69889e67b9c3218465c5_Out_0_Vector2 = float2(_Property_88b4d0c5d21a7183a57db653a779d1ae_Out_0_Float, _Property_ebe5e0ddcde3198ba0854ef0cecb43bb_Out_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Multiply_91ea1c267339e98aa1fa289edb65bea3_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_028048d12902188983507205b3138df9_Out_0_Vector2, _Vector2_299ed772bf4c69889e67b9c3218465c5_Out_0_Vector2, _Multiply_91ea1c267339e98aa1fa289edb65bea3_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_bed3418745528b86a5dbb9c2950dabc6_Out_0_Float = _LavaNoiseDistortionScrollSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_e9dd2e4a97f469879425ead977ad2a4c_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_bed3418745528b86a5dbb9c2950dabc6_Out_0_Float, _Multiply_e9dd2e4a97f469879425ead977ad2a4c_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Add_10cdf561edb5bc88a717b517d8895cc8_Out_2_Vector2;
            Unity_Add_float2(_Multiply_91ea1c267339e98aa1fa289edb65bea3_Out_2_Vector2, (_Multiply_e9dd2e4a97f469879425ead977ad2a4c_Out_2_Float.xx), _Add_10cdf561edb5bc88a717b517d8895cc8_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_9efe7b617abec3889725fb27fda2f7c2_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_03caaa62cb71bb8ab953b95239ec05ac_Out_0_Texture2D.tex, _Property_03caaa62cb71bb8ab953b95239ec05ac_Out_0_Texture2D.samplerstate, _Property_03caaa62cb71bb8ab953b95239ec05ac_Out_0_Texture2D.GetTransformedUV(_Add_10cdf561edb5bc88a717b517d8895cc8_Out_2_Vector2) );
            float _SampleTexture2D_9efe7b617abec3889725fb27fda2f7c2_R_4_Float = _SampleTexture2D_9efe7b617abec3889725fb27fda2f7c2_RGBA_0_Vector4.r;
            float _SampleTexture2D_9efe7b617abec3889725fb27fda2f7c2_G_5_Float = _SampleTexture2D_9efe7b617abec3889725fb27fda2f7c2_RGBA_0_Vector4.g;
            float _SampleTexture2D_9efe7b617abec3889725fb27fda2f7c2_B_6_Float = _SampleTexture2D_9efe7b617abec3889725fb27fda2f7c2_RGBA_0_Vector4.b;
            float _SampleTexture2D_9efe7b617abec3889725fb27fda2f7c2_A_7_Float = _SampleTexture2D_9efe7b617abec3889725fb27fda2f7c2_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_bd0202192e9a908fa64adac2651f79bf_Out_0_Float = _LavaNoiseDistortionAmount;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_937093991fe57886aa15480514427209_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_9efe7b617abec3889725fb27fda2f7c2_R_4_Float, _Property_bd0202192e9a908fa64adac2651f79bf_Out_0_Float, _Multiply_937093991fe57886aa15480514427209_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _OneMinus_be34308b748e908f8588e0208be8c658_Out_1_Float;
            Unity_OneMinus_float(_Add_ce0cf089c5891f819a1c6ca50c03e8ce_Out_2_Float, _OneMinus_be34308b748e908f8588e0208be8c658_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_0e172543f836438f8ae3dd7855b1501b_Out_2_Float;
            Unity_Power_float(_OneMinus_be34308b748e908f8588e0208be8c658_Out_1_Float, 8, _Power_0e172543f836438f8ae3dd7855b1501b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_a1856fa2a918738ca2021669a7d40b5a_Out_0_Float = _LavaDistortionSlopeStyle;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Lerp_19659d88d9fd4d8aa81e406132d9bfff_Out_3_Float;
            Unity_Lerp_float(_Power_0e172543f836438f8ae3dd7855b1501b_Out_2_Float, _Add_1f8b2d8060996087bbec729f409fc77a_Out_2_Float, _Property_a1856fa2a918738ca2021669a7d40b5a_Out_0_Float, _Lerp_19659d88d9fd4d8aa81e406132d9bfff_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_100d1d9374ffa4809c20e664703780e5_Out_0_Float = _LavaDistortionSlopeNegate;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Add_8bd0afabe256638e9adb2b2d7cd550a1_Out_2_Float;
            Unity_Add_float(_Lerp_19659d88d9fd4d8aa81e406132d9bfff_Out_3_Float, _Property_100d1d9374ffa4809c20e664703780e5_Out_0_Float, _Add_8bd0afabe256638e9adb2b2d7cd550a1_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_8f21858fc41cb2899c1b337fd48bc252_Out_3_Float;
            Unity_Clamp_float(_Add_8bd0afabe256638e9adb2b2d7cd550a1_Out_2_Float, 0, 1, _Clamp_8f21858fc41cb2899c1b337fd48bc252_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_2e723d8b26c87987b5d0bc858f157f00_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_937093991fe57886aa15480514427209_Out_2_Float, _Clamp_8f21858fc41cb2899c1b337fd48bc252_Out_3_Float, _Multiply_2e723d8b26c87987b5d0bc858f157f00_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_df8f2e36973218818f008879744942ae_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_894520fea85732828cef2b1fe1e691a9_R_1_Float = _UV_df8f2e36973218818f008879744942ae_Out_0_Vector4[0];
            float _Split_894520fea85732828cef2b1fe1e691a9_G_2_Float = _UV_df8f2e36973218818f008879744942ae_Out_0_Vector4[1];
            float _Split_894520fea85732828cef2b1fe1e691a9_B_3_Float = _UV_df8f2e36973218818f008879744942ae_Out_0_Vector4[2];
            float _Split_894520fea85732828cef2b1fe1e691a9_A_4_Float = _UV_df8f2e36973218818f008879744942ae_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_2f6a8d8da7e12987aa01f976795c49d9_Out_0_Vector2 = float2(_Split_894520fea85732828cef2b1fe1e691a9_R_1_Float, _Split_894520fea85732828cef2b1fe1e691a9_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_ad79d3d91a23a088ab8660acbfb2f751_Out_0_Float = _LavaNoiseScaleU;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_02f44f2c0e9eca8bb1fe880dda413f4c_Out_0_Float = _LavaNoiseScaleV;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_ac678e0a5ba5fb8ead5893f688733e5f_Out_0_Vector2 = float2(_Property_ad79d3d91a23a088ab8660acbfb2f751_Out_0_Float, _Property_02f44f2c0e9eca8bb1fe880dda413f4c_Out_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Multiply_484bcb42d28cce89896f3190dde40deb_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_2f6a8d8da7e12987aa01f976795c49d9_Out_0_Vector2, _Vector2_ac678e0a5ba5fb8ead5893f688733e5f_Out_0_Vector2, _Multiply_484bcb42d28cce89896f3190dde40deb_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_7842dac4d2d8c08a9d1cd2a6c901d9ff_Out_0_Float = _LavaNoiseScrollSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_b099a9edbf03fe80adce5d690cd1ce99_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_7842dac4d2d8c08a9d1cd2a6c901d9ff_Out_0_Float, _Multiply_b099a9edbf03fe80adce5d690cd1ce99_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Add_c815351a1143108c8cdbde2743c75dd9_Out_2_Vector2;
            Unity_Add_float2(_Multiply_484bcb42d28cce89896f3190dde40deb_Out_2_Vector2, (_Multiply_b099a9edbf03fe80adce5d690cd1ce99_Out_2_Float.xx), _Add_c815351a1143108c8cdbde2743c75dd9_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Add_cb5db7a0e32cb08b96dc46e041551fee_Out_2_Vector2;
            Unity_Add_float2((_Multiply_2e723d8b26c87987b5d0bc858f157f00_Out_2_Float.xx), _Add_c815351a1143108c8cdbde2743c75dd9_Out_2_Vector2, _Add_cb5db7a0e32cb08b96dc46e041551fee_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_6f6dcd08d5f76b8daa6d339bdc0c7459_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0a00cec3c513d984b7ceeae0c3e83b24_Out_0_Texture2D.tex, _Property_0a00cec3c513d984b7ceeae0c3e83b24_Out_0_Texture2D.samplerstate, _Property_0a00cec3c513d984b7ceeae0c3e83b24_Out_0_Texture2D.GetTransformedUV(_Add_cb5db7a0e32cb08b96dc46e041551fee_Out_2_Vector2) );
            float _SampleTexture2D_6f6dcd08d5f76b8daa6d339bdc0c7459_R_4_Float = _SampleTexture2D_6f6dcd08d5f76b8daa6d339bdc0c7459_RGBA_0_Vector4.r;
            float _SampleTexture2D_6f6dcd08d5f76b8daa6d339bdc0c7459_G_5_Float = _SampleTexture2D_6f6dcd08d5f76b8daa6d339bdc0c7459_RGBA_0_Vector4.g;
            float _SampleTexture2D_6f6dcd08d5f76b8daa6d339bdc0c7459_B_6_Float = _SampleTexture2D_6f6dcd08d5f76b8daa6d339bdc0c7459_RGBA_0_Vector4.b;
            float _SampleTexture2D_6f6dcd08d5f76b8daa6d339bdc0c7459_A_7_Float = _SampleTexture2D_6f6dcd08d5f76b8daa6d339bdc0c7459_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_f4a6c9bebbd42d8eb26b59154fe7e772_Out_0_Float = _LavaNoiseNegate;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Add_a3582c5d934af68cb9e40371279dfaa0_Out_2_Float;
            Unity_Add_float(_SampleTexture2D_6f6dcd08d5f76b8daa6d339bdc0c7459_R_4_Float, _Property_f4a6c9bebbd42d8eb26b59154fe7e772_Out_0_Float, _Add_a3582c5d934af68cb9e40371279dfaa0_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_a0aea232790920849ee0fdb650fa9269_Out_3_Float;
            Unity_Clamp_float(_Add_a3582c5d934af68cb9e40371279dfaa0_Out_2_Float, 0, 1, _Clamp_a0aea232790920849ee0fdb650fa9269_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_LAVANOISEENABLED_ON)
            float _LavaNoiseEnabled_9b5f5e626bdc9883a7497184623756e9_Out_0_Float = _Clamp_a0aea232790920849ee0fdb650fa9269_Out_3_Float;
            #else
            float _LavaNoiseEnabled_9b5f5e626bdc9883a7497184623756e9_Out_0_Float = 1;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_f98630901662ab86887f02cb3502bdfc_Out_2_Float;
            Unity_Multiply_float_float(_Property_786bba4695499b8097b7e5bc2eaaae3a_Out_0_Float, _LavaNoiseEnabled_9b5f5e626bdc9883a7497184623756e9_Out_0_Float, _Multiply_f98630901662ab86887f02cb3502bdfc_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_0521be3b967b8884ad6c8c7a779b30a7_Out_0_Float = _RampSmoothstepMin;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_22ae91223b40208bbf5ebf944bb9890d_Out_0_Float = _RampSmoothstepMax;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_b3e4145f94877b828dfc2e3aa918f4d4_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_LavaAppearMask);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_293a4be9b9806e8a92dc82ba6c4ab795_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_ac0462abb5755980ae114edd54a74735_R_1_Float = _UV_293a4be9b9806e8a92dc82ba6c4ab795_Out_0_Vector4[0];
            float _Split_ac0462abb5755980ae114edd54a74735_G_2_Float = _UV_293a4be9b9806e8a92dc82ba6c4ab795_Out_0_Vector4[1];
            float _Split_ac0462abb5755980ae114edd54a74735_B_3_Float = _UV_293a4be9b9806e8a92dc82ba6c4ab795_Out_0_Vector4[2];
            float _Split_ac0462abb5755980ae114edd54a74735_A_4_Float = _UV_293a4be9b9806e8a92dc82ba6c4ab795_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_515a0fc3ae406f8e9338ec69f596e7b3_Out_0_Vector2 = float2(_Split_ac0462abb5755980ae114edd54a74735_R_1_Float, _Split_ac0462abb5755980ae114edd54a74735_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_946bbc1610c18c82ba03f07da59af07b_Out_0_Float = _LavaAppearMaskScaleU;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_73046abc602b1f8d875934cc1cf33d77_Out_0_Float = _LavaAppearMaskScaleV;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_b21a2f34d0d2578a9d6b03b8454a60f1_Out_0_Vector2 = float2(_Property_946bbc1610c18c82ba03f07da59af07b_Out_0_Float, _Property_73046abc602b1f8d875934cc1cf33d77_Out_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Multiply_2a46ade55cba2487b5e9843aa0f2529f_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_515a0fc3ae406f8e9338ec69f596e7b3_Out_0_Vector2, _Vector2_b21a2f34d0d2578a9d6b03b8454a60f1_Out_0_Vector2, _Multiply_2a46ade55cba2487b5e9843aa0f2529f_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_df59a1f6638065899e89c298f8bb57f6_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_b3e4145f94877b828dfc2e3aa918f4d4_Out_0_Texture2D.tex, _Property_b3e4145f94877b828dfc2e3aa918f4d4_Out_0_Texture2D.samplerstate, _Property_b3e4145f94877b828dfc2e3aa918f4d4_Out_0_Texture2D.GetTransformedUV(_Multiply_2a46ade55cba2487b5e9843aa0f2529f_Out_2_Vector2) );
            float _SampleTexture2D_df59a1f6638065899e89c298f8bb57f6_R_4_Float = _SampleTexture2D_df59a1f6638065899e89c298f8bb57f6_RGBA_0_Vector4.r;
            float _SampleTexture2D_df59a1f6638065899e89c298f8bb57f6_G_5_Float = _SampleTexture2D_df59a1f6638065899e89c298f8bb57f6_RGBA_0_Vector4.g;
            float _SampleTexture2D_df59a1f6638065899e89c298f8bb57f6_B_6_Float = _SampleTexture2D_df59a1f6638065899e89c298f8bb57f6_RGBA_0_Vector4.b;
            float _SampleTexture2D_df59a1f6638065899e89c298f8bb57f6_A_7_Float = _SampleTexture2D_df59a1f6638065899e89c298f8bb57f6_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _OneMinus_fc99e085b57f2789bb9f565484583af6_Out_1_Float;
            Unity_OneMinus_float(_SampleTexture2D_df59a1f6638065899e89c298f8bb57f6_R_4_Float, _OneMinus_fc99e085b57f2789bb9f565484583af6_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_bc36adb912abb6828fef704199bfd5bd_Out_0_Float = _LavaAppearMaskExp;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_b7b256d2b6336081af6c859de5db3984_Out_2_Float;
            Unity_Power_float(_OneMinus_fc99e085b57f2789bb9f565484583af6_Out_1_Float, _Property_bc36adb912abb6828fef704199bfd5bd_Out_0_Float, _Power_b7b256d2b6336081af6c859de5db3984_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _OneMinus_880aaeb186b16e8fb85253600d7174eb_Out_1_Float;
            Unity_OneMinus_float(_Power_b7b256d2b6336081af6c859de5db3984_Out_2_Float, _OneMinus_880aaeb186b16e8fb85253600d7174eb_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_c1625964e6e73a88953ec8fa41ff7eac_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_c582bae1a8262680ac86aa96eceb768e_R_1_Float = _UV_c1625964e6e73a88953ec8fa41ff7eac_Out_0_Vector4[0];
            float _Split_c582bae1a8262680ac86aa96eceb768e_G_2_Float = _UV_c1625964e6e73a88953ec8fa41ff7eac_Out_0_Vector4[1];
            float _Split_c582bae1a8262680ac86aa96eceb768e_B_3_Float = _UV_c1625964e6e73a88953ec8fa41ff7eac_Out_0_Vector4[2];
            float _Split_c582bae1a8262680ac86aa96eceb768e_A_4_Float = _UV_c1625964e6e73a88953ec8fa41ff7eac_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Add_8ef4bce3464c8d808a0cdd3b44b50219_Out_2_Float;
            Unity_Add_float(_OneMinus_880aaeb186b16e8fb85253600d7174eb_Out_1_Float, _Split_c582bae1a8262680ac86aa96eceb768e_B_3_Float, _Add_8ef4bce3464c8d808a0cdd3b44b50219_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_517244684d7ce089955ba9514e28d517_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_SurfaceNoise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_f2797e4fd6fb618f8b29ebd1d2ef67c4_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_b17809d3e5bad28fa4c02df4d016809d_R_1_Float = _UV_f2797e4fd6fb618f8b29ebd1d2ef67c4_Out_0_Vector4[0];
            float _Split_b17809d3e5bad28fa4c02df4d016809d_G_2_Float = _UV_f2797e4fd6fb618f8b29ebd1d2ef67c4_Out_0_Vector4[1];
            float _Split_b17809d3e5bad28fa4c02df4d016809d_B_3_Float = _UV_f2797e4fd6fb618f8b29ebd1d2ef67c4_Out_0_Vector4[2];
            float _Split_b17809d3e5bad28fa4c02df4d016809d_A_4_Float = _UV_f2797e4fd6fb618f8b29ebd1d2ef67c4_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_5cba92c1441efb869c4270f853178c86_Out_0_Vector2 = float2(_Split_b17809d3e5bad28fa4c02df4d016809d_R_1_Float, _Split_b17809d3e5bad28fa4c02df4d016809d_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_b0eeaaf98a175b86b0680f42e6ee8564_Out_0_Float = _SurfaceNoiseScaleU;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_92801b979a81c480bf655cce92dc21fd_Out_0_Float = _SurfaceNoiseScaleV;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_062d2a47a9308685a9b472f126986efc_Out_0_Vector2 = float2(_Property_b0eeaaf98a175b86b0680f42e6ee8564_Out_0_Float, _Property_92801b979a81c480bf655cce92dc21fd_Out_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Multiply_33cc5d0f80bb628d9c19bdf87040fc50_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_5cba92c1441efb869c4270f853178c86_Out_0_Vector2, _Vector2_062d2a47a9308685a9b472f126986efc_Out_0_Vector2, _Multiply_33cc5d0f80bb628d9c19bdf87040fc50_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_633255f0bda1e186a9ef712db5dc45f8_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_517244684d7ce089955ba9514e28d517_Out_0_Texture2D.tex, _Property_517244684d7ce089955ba9514e28d517_Out_0_Texture2D.samplerstate, _Property_517244684d7ce089955ba9514e28d517_Out_0_Texture2D.GetTransformedUV(_Multiply_33cc5d0f80bb628d9c19bdf87040fc50_Out_2_Vector2) );
            float _SampleTexture2D_633255f0bda1e186a9ef712db5dc45f8_R_4_Float = _SampleTexture2D_633255f0bda1e186a9ef712db5dc45f8_RGBA_0_Vector4.r;
            float _SampleTexture2D_633255f0bda1e186a9ef712db5dc45f8_G_5_Float = _SampleTexture2D_633255f0bda1e186a9ef712db5dc45f8_RGBA_0_Vector4.g;
            float _SampleTexture2D_633255f0bda1e186a9ef712db5dc45f8_B_6_Float = _SampleTexture2D_633255f0bda1e186a9ef712db5dc45f8_RGBA_0_Vector4.b;
            float _SampleTexture2D_633255f0bda1e186a9ef712db5dc45f8_A_7_Float = _SampleTexture2D_633255f0bda1e186a9ef712db5dc45f8_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_c2a1666620ffc68ab0faf55b6606f377_Out_0_Float = _SurfaceNoiseAdd;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_9d8366d0ce337f8d958eb2040b621a44_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_633255f0bda1e186a9ef712db5dc45f8_R_4_Float, _Property_c2a1666620ffc68ab0faf55b6606f377_Out_0_Float, _Multiply_9d8366d0ce337f8d958eb2040b621a44_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_ab69d85ab2554886ba5d541c75624b87_Out_2_Float;
            Unity_Subtract_float(_Add_ce0cf089c5891f819a1c6ca50c03e8ce_Out_2_Float, _Multiply_9631f2a0e5963f8495f916e535bcb0d6_Out_2_Float, _Subtract_ab69d85ab2554886ba5d541c75624b87_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_cf6cc11fc16b098ea3bc02d773fdef86_Out_3_Float;
            Unity_Clamp_float(_Subtract_ab69d85ab2554886ba5d541c75624b87_Out_2_Float, 0, 1, _Clamp_cf6cc11fc16b098ea3bc02d773fdef86_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_2689907a9e1b418ab1659c797b9af389_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_9d8366d0ce337f8d958eb2040b621a44_Out_2_Float, _Clamp_cf6cc11fc16b098ea3bc02d773fdef86_Out_3_Float, _Multiply_2689907a9e1b418ab1659c797b9af389_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_0e231aab4164e48b98d449975b235ba7_Out_0_Float = _SurfaceNoiseExp;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_749c5b3341f58b82ac64455928042fad_Out_2_Float;
            Unity_Power_float(_Multiply_2689907a9e1b418ab1659c797b9af389_Out_2_Float, _Property_0e231aab4164e48b98d449975b235ba7_Out_0_Float, _Power_749c5b3341f58b82ac64455928042fad_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_SURFACENOISEENABLED_ON)
            float _SurfaceNoiseEnabled_4157c4aaede57a8aa36a4bfa6276b10f_Out_0_Float = _Power_749c5b3341f58b82ac64455928042fad_Out_2_Float;
            #else
            float _SurfaceNoiseEnabled_4157c4aaede57a8aa36a4bfa6276b10f_Out_0_Float = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_37231a3d7291ec85988fe6fdb4120277_Out_2_Float;
            Unity_Multiply_float_float(_Add_ce0cf089c5891f819a1c6ca50c03e8ce_Out_2_Float, _Clamp_bdfc64868de7028e9af984fadf0b1319_Out_3_Float, _Multiply_37231a3d7291ec85988fe6fdb4120277_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_af744f59d9a4598e8c8be40e087f40f6_Out_0_Float = _HeightBoost;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_a16d3007be15c9859ac1218c66326363_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_37231a3d7291ec85988fe6fdb4120277_Out_2_Float, _Property_af744f59d9a4598e8c8be40e087f40f6_Out_0_Float, _Multiply_a16d3007be15c9859ac1218c66326363_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_6377db96d463908499a978935d8d022d_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_a16d3007be15c9859ac1218c66326363_Out_2_Float, _CracksEnabled_0e667cb8e3ee9881a642073afeadf6bb_Out_0_Float, _Multiply_6377db96d463908499a978935d8d022d_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_9292879d26fb7d83970a4d0011aaf215_Out_2_Float;
            Unity_Subtract_float(_Multiply_6377db96d463908499a978935d8d022d_Out_2_Float, _Multiply_9631f2a0e5963f8495f916e535bcb0d6_Out_2_Float, _Subtract_9292879d26fb7d83970a4d0011aaf215_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_8eefce6a2222fc8dac2b3c53477ce67a_Out_3_Float;
            Unity_Clamp_float(_Subtract_9292879d26fb7d83970a4d0011aaf215_Out_2_Float, 0, 1, _Clamp_8eefce6a2222fc8dac2b3c53477ce67a_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Add_cbc3c4420439858281aa5a889de98977_Out_2_Float;
            Unity_Add_float(_SurfaceNoiseEnabled_4157c4aaede57a8aa36a4bfa6276b10f_Out_0_Float, _Clamp_8eefce6a2222fc8dac2b3c53477ce67a_Out_3_Float, _Add_cbc3c4420439858281aa5a889de98977_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _OneMinus_df4afaa6972cc78f89c5b902eab15dcf_Out_1_Float;
            Unity_OneMinus_float(_Add_cbc3c4420439858281aa5a889de98977_Out_2_Float, _OneMinus_df4afaa6972cc78f89c5b902eab15dcf_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Float_79f67c270a273d8cbe0c1844dd488dac_Out_0_Float = 1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_9631d17e2b139f8b8299ba66aedde862_Out_2_Float;
            Unity_Subtract_float(_OneMinus_df4afaa6972cc78f89c5b902eab15dcf_Out_1_Float, _Float_79f67c270a273d8cbe0c1844dd488dac_Out_0_Float, _Subtract_9631d17e2b139f8b8299ba66aedde862_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Add_ef83b402feef2c87a30e0fc21396318b_Out_2_Float;
            Unity_Add_float(_Add_8ef4bce3464c8d808a0cdd3b44b50219_Out_2_Float, _Subtract_9631d17e2b139f8b8299ba66aedde862_Out_2_Float, _Add_ef83b402feef2c87a30e0fc21396318b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_7127c5aace7ed489842039ed5d566d17_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_SecondMaskProfile);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_ba6538c3d139cb809e0284f4670ad345_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_SecondMask);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_eb1cf0842d22858caf633f48832bc89e_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_60a289d4ab66bd84a4fd5e5247c80dc7_R_1_Float = _UV_eb1cf0842d22858caf633f48832bc89e_Out_0_Vector4[0];
            float _Split_60a289d4ab66bd84a4fd5e5247c80dc7_G_2_Float = _UV_eb1cf0842d22858caf633f48832bc89e_Out_0_Vector4[1];
            float _Split_60a289d4ab66bd84a4fd5e5247c80dc7_B_3_Float = _UV_eb1cf0842d22858caf633f48832bc89e_Out_0_Vector4[2];
            float _Split_60a289d4ab66bd84a4fd5e5247c80dc7_A_4_Float = _UV_eb1cf0842d22858caf633f48832bc89e_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_cd9587f6b5bb338289a09b12bcd496c6_Out_0_Vector2 = float2(_Split_60a289d4ab66bd84a4fd5e5247c80dc7_R_1_Float, _Split_60a289d4ab66bd84a4fd5e5247c80dc7_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_646615a2432a238e8615f191323f8276_Out_0_Float = _SecondMaskScaleU;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_0567ef1ff0c95e8ab955b70ba7847f25_Out_0_Float = _SecondMaskScaleV;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_1d3ec47c10060f89a8c0fc7b21477c8a_Out_0_Vector2 = float2(_Property_646615a2432a238e8615f191323f8276_Out_0_Float, _Property_0567ef1ff0c95e8ab955b70ba7847f25_Out_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Multiply_803aa22d67189c81adce75cc8623ee81_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_cd9587f6b5bb338289a09b12bcd496c6_Out_0_Vector2, _Vector2_1d3ec47c10060f89a8c0fc7b21477c8a_Out_0_Vector2, _Multiply_803aa22d67189c81adce75cc8623ee81_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_25ebc50cf43b4b88aec0edf4aacae63c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ba6538c3d139cb809e0284f4670ad345_Out_0_Texture2D.tex, _Property_ba6538c3d139cb809e0284f4670ad345_Out_0_Texture2D.samplerstate, _Property_ba6538c3d139cb809e0284f4670ad345_Out_0_Texture2D.GetTransformedUV(_Multiply_803aa22d67189c81adce75cc8623ee81_Out_2_Vector2) );
            float _SampleTexture2D_25ebc50cf43b4b88aec0edf4aacae63c_R_4_Float = _SampleTexture2D_25ebc50cf43b4b88aec0edf4aacae63c_RGBA_0_Vector4.r;
            float _SampleTexture2D_25ebc50cf43b4b88aec0edf4aacae63c_G_5_Float = _SampleTexture2D_25ebc50cf43b4b88aec0edf4aacae63c_RGBA_0_Vector4.g;
            float _SampleTexture2D_25ebc50cf43b4b88aec0edf4aacae63c_B_6_Float = _SampleTexture2D_25ebc50cf43b4b88aec0edf4aacae63c_RGBA_0_Vector4.b;
            float _SampleTexture2D_25ebc50cf43b4b88aec0edf4aacae63c_A_7_Float = _SampleTexture2D_25ebc50cf43b4b88aec0edf4aacae63c_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_f025a78a05709a8c83ca8367cc6d37fa_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_faa64e07b3c9a186bee3ac0e947c8d1a_R_1_Float = _UV_f025a78a05709a8c83ca8367cc6d37fa_Out_0_Vector4[0];
            float _Split_faa64e07b3c9a186bee3ac0e947c8d1a_G_2_Float = _UV_f025a78a05709a8c83ca8367cc6d37fa_Out_0_Vector4[1];
            float _Split_faa64e07b3c9a186bee3ac0e947c8d1a_B_3_Float = _UV_f025a78a05709a8c83ca8367cc6d37fa_Out_0_Vector4[2];
            float _Split_faa64e07b3c9a186bee3ac0e947c8d1a_A_4_Float = _UV_f025a78a05709a8c83ca8367cc6d37fa_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Add_36624fb36ea2495b9ffe05d4d42220ca_Out_2_Float;
            Unity_Add_float(_Split_faa64e07b3c9a186bee3ac0e947c8d1a_A_4_Float, 10, _Add_36624fb36ea2495b9ffe05d4d42220ca_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Add_28e470ca6eec2988a40a85567ffafc2f_Out_2_Float;
            Unity_Add_float(_SampleTexture2D_25ebc50cf43b4b88aec0edf4aacae63c_R_4_Float, _Add_36624fb36ea2495b9ffe05d4d42220ca_Out_2_Float, _Add_28e470ca6eec2988a40a85567ffafc2f_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_ce5c029c8551288890505f088c2b6612_Out_3_Float;
            Unity_Clamp_float(_Add_28e470ca6eec2988a40a85567ffafc2f_Out_2_Float, 0, 1, _Clamp_ce5c029c8551288890505f088c2b6612_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _OneMinus_72a27d88c112b386ba7215e653895d9a_Out_1_Float;
            Unity_OneMinus_float(_Clamp_ce5c029c8551288890505f088c2b6612_Out_3_Float, _OneMinus_72a27d88c112b386ba7215e653895d9a_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_f30790af5bfe1d80a4b8e6faf673c357_Out_0_Float = _SecondMaskExp;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_7a323b9407e9518ea08983cbb4a7af41_Out_2_Float;
            Unity_Power_float(_OneMinus_72a27d88c112b386ba7215e653895d9a_Out_1_Float, _Property_f30790af5bfe1d80a4b8e6faf673c357_Out_0_Float, _Power_7a323b9407e9518ea08983cbb4a7af41_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _OneMinus_4dab8d9d8b910c8382abed8813ac30d9_Out_1_Float;
            Unity_OneMinus_float(_Power_7a323b9407e9518ea08983cbb4a7af41_Out_2_Float, _OneMinus_4dab8d9d8b910c8382abed8813ac30d9_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_de83488e6b255a8fb2baa9d2ac650a74_Out_0_Vector2 = float2(_OneMinus_4dab8d9d8b910c8382abed8813ac30d9_Out_1_Float, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_62a92809434b8f8d9eed9f59404c5fda_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_7127c5aace7ed489842039ed5d566d17_Out_0_Texture2D.tex, _Property_7127c5aace7ed489842039ed5d566d17_Out_0_Texture2D.samplerstate, _Property_7127c5aace7ed489842039ed5d566d17_Out_0_Texture2D.GetTransformedUV(_Vector2_de83488e6b255a8fb2baa9d2ac650a74_Out_0_Vector2) );
            float _SampleTexture2D_62a92809434b8f8d9eed9f59404c5fda_R_4_Float = _SampleTexture2D_62a92809434b8f8d9eed9f59404c5fda_RGBA_0_Vector4.r;
            float _SampleTexture2D_62a92809434b8f8d9eed9f59404c5fda_G_5_Float = _SampleTexture2D_62a92809434b8f8d9eed9f59404c5fda_RGBA_0_Vector4.g;
            float _SampleTexture2D_62a92809434b8f8d9eed9f59404c5fda_B_6_Float = _SampleTexture2D_62a92809434b8f8d9eed9f59404c5fda_RGBA_0_Vector4.b;
            float _SampleTexture2D_62a92809434b8f8d9eed9f59404c5fda_A_7_Float = _SampleTexture2D_62a92809434b8f8d9eed9f59404c5fda_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_1d39078c395b5a8fa98dbb0b4e46b22f_Out_2_Float;
            Unity_Multiply_float_float(_Add_1f8b2d8060996087bbec729f409fc77a_Out_2_Float, _SampleTexture2D_62a92809434b8f8d9eed9f59404c5fda_R_4_Float, _Multiply_1d39078c395b5a8fa98dbb0b4e46b22f_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_527d0654ad7b1d8d8352cef8c354b08c_Out_0_Float = _SecondMaskEdgeGlow;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_c75af490f6d4a28f9dde2d303fd642a4_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_1d39078c395b5a8fa98dbb0b4e46b22f_Out_2_Float, _Property_527d0654ad7b1d8d8352cef8c354b08c_Out_0_Float, _Multiply_c75af490f6d4a28f9dde2d303fd642a4_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Add_1587142256b56789a3db3d9709325af2_Out_2_Float;
            Unity_Add_float(_Add_ef83b402feef2c87a30e0fc21396318b_Out_2_Float, _Multiply_c75af490f6d4a28f9dde2d303fd642a4_Out_2_Float, _Add_1587142256b56789a3db3d9709325af2_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_988f6b67aa3633828aefd1fff18d955a_Out_3_Float;
            Unity_Clamp_float(_Add_1587142256b56789a3db3d9709325af2_Out_2_Float, 0, 1, _Clamp_988f6b67aa3633828aefd1fff18d955a_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Smoothstep_cea7208b04fa3f80b81355fa6eb5f853_Out_3_Float;
            Unity_Smoothstep_float(_Property_0521be3b967b8884ad6c8c7a779b30a7_Out_0_Float, _Property_22ae91223b40208bbf5ebf944bb9890d_Out_0_Float, _Clamp_988f6b67aa3633828aefd1fff18d955a_Out_3_Float, _Smoothstep_cea7208b04fa3f80b81355fa6eb5f853_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_615361c55b75988c9ce60266387635db_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_f98630901662ab86887f02cb3502bdfc_Out_2_Float, _Smoothstep_cea7208b04fa3f80b81355fa6eb5f853_Out_3_Float, _Multiply_615361c55b75988c9ce60266387635db_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _OneMinus_e5c90e870fe918819863178ce401a293_Out_1_Float;
            Unity_OneMinus_float(_Add_ce0cf089c5891f819a1c6ca50c03e8ce_Out_2_Float, _OneMinus_e5c90e870fe918819863178ce401a293_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_a9c6af86190d0d8ea6ebadc34bb138e4_Out_0_Float = _LavaOnlyInValleysExp;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_024298f41f81ca8a98b34edf6aca9254_Out_2_Float;
            Unity_Power_float(_OneMinus_e5c90e870fe918819863178ce401a293_Out_1_Float, _Property_a9c6af86190d0d8ea6ebadc34bb138e4_Out_0_Float, _Power_024298f41f81ca8a98b34edf6aca9254_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_9a5b1e97ca95e58c95aa819364889784_Out_0_Float = _LavaOnlyInValleysNegate;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Add_4c6abb23aa0fc18db7ec476c0bc1e916_Out_2_Float;
            Unity_Add_float(_Power_024298f41f81ca8a98b34edf6aca9254_Out_2_Float, _Property_9a5b1e97ca95e58c95aa819364889784_Out_0_Float, _Add_4c6abb23aa0fc18db7ec476c0bc1e916_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_254c526562e05384ab9a04ba3673667f_Out_3_Float;
            Unity_Clamp_float(_Add_4c6abb23aa0fc18db7ec476c0bc1e916_Out_2_Float, 0, 1, _Clamp_254c526562e05384ab9a04ba3673667f_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_32fcaa0c56d8a289936ab331a1c7de69_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_615361c55b75988c9ce60266387635db_Out_2_Float, _Clamp_254c526562e05384ab9a04ba3673667f_Out_3_Float, _Multiply_32fcaa0c56d8a289936ab331a1c7de69_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _OneMinus_aef19170c8cadd8986f20b36563fbe26_Out_1_Float;
            Unity_OneMinus_float(_Multiply_32fcaa0c56d8a289936ab331a1c7de69_Out_2_Float, _OneMinus_aef19170c8cadd8986f20b36563fbe26_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_fb7e5c882f85c38b9993cac7888eac35_Out_0_Float = _RampOffsetExp;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_d074adbfb64d178d9c8b7871db187bf8_Out_2_Float;
            Unity_Power_float(_OneMinus_aef19170c8cadd8986f20b36563fbe26_Out_1_Float, _Property_fb7e5c882f85c38b9993cac7888eac35_Out_0_Float, _Power_d074adbfb64d178d9c8b7871db187bf8_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _OneMinus_6a701aac361bce81a9711af83cb5e750_Out_1_Float;
            Unity_OneMinus_float(_Power_d074adbfb64d178d9c8b7871db187bf8_Out_2_Float, _OneMinus_6a701aac361bce81a9711af83cb5e750_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_12da75a0bbd6c4858c3ee44e90f510f1_Out_0_Vector2 = float2(_OneMinus_6a701aac361bce81a9711af83cb5e750_Out_1_Float, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_f7e5038adae6c08a8464b98721428d5b_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_f9d4f1409db2bc88b6d42fa79f52d71b_Out_0_Texture2D.tex, _Property_f9d4f1409db2bc88b6d42fa79f52d71b_Out_0_Texture2D.samplerstate, _Property_f9d4f1409db2bc88b6d42fa79f52d71b_Out_0_Texture2D.GetTransformedUV(_Vector2_12da75a0bbd6c4858c3ee44e90f510f1_Out_0_Vector2) );
            float _SampleTexture2D_f7e5038adae6c08a8464b98721428d5b_R_4_Float = _SampleTexture2D_f7e5038adae6c08a8464b98721428d5b_RGBA_0_Vector4.r;
            float _SampleTexture2D_f7e5038adae6c08a8464b98721428d5b_G_5_Float = _SampleTexture2D_f7e5038adae6c08a8464b98721428d5b_RGBA_0_Vector4.g;
            float _SampleTexture2D_f7e5038adae6c08a8464b98721428d5b_B_6_Float = _SampleTexture2D_f7e5038adae6c08a8464b98721428d5b_RGBA_0_Vector4.b;
            float _SampleTexture2D_f7e5038adae6c08a8464b98721428d5b_A_7_Float = _SampleTexture2D_f7e5038adae6c08a8464b98721428d5b_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_db624b15da10428ea4a23eaa2933c4bc_Out_0_Float = _FinalPower;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_a70d8e97a6ac34809d58b76dc60276a3_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_f7e5038adae6c08a8464b98721428d5b_RGBA_0_Vector4, (_Property_db624b15da10428ea4a23eaa2933c4bc_Out_0_Float.xxxx), _Multiply_a70d8e97a6ac34809d58b76dc60276a3_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_95d949f98686f18cac7c13f075d4e1bf_Out_0_Vector4 = _RampColorTint;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_8804404b13920f869ec4d55fb24c7ba8_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_a70d8e97a6ac34809d58b76dc60276a3_Out_2_Vector4, _Property_95d949f98686f18cac7c13f075d4e1bf_Out_0_Vector4, _Multiply_8804404b13920f869ec4d55fb24c7ba8_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_152b94cbb48274889d939d7a82b7dda6_Out_0_Boolean = _VALLEYSEMISSIONBOOSTENABLED;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _OneMinus_bf9b25e56aafbb8eafbc03a626c5a184_Out_1_Float;
            Unity_OneMinus_float(_Add_ce0cf089c5891f819a1c6ca50c03e8ce_Out_2_Float, _OneMinus_bf9b25e56aafbb8eafbc03a626c5a184_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_a67933cd8c95468c980f48e9034ae573_Out_0_Float = _ValleysEmissionBoostAmount;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Float_c7a39eb0426b0f8fbc4b30ff0c8ae479_Out_0_Float = 1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Add_22cc51e699b0a08e86d0f6c2dd8d494f_Out_2_Float;
            Unity_Add_float(_Property_a67933cd8c95468c980f48e9034ae573_Out_0_Float, _Float_c7a39eb0426b0f8fbc4b30ff0c8ae479_Out_0_Float, _Add_22cc51e699b0a08e86d0f6c2dd8d494f_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_67b4dd5aea556f8fa7fb24ea70a43001_Out_2_Float;
            Unity_Multiply_float_float(_OneMinus_bf9b25e56aafbb8eafbc03a626c5a184_Out_1_Float, _Add_22cc51e699b0a08e86d0f6c2dd8d494f_Out_2_Float, _Multiply_67b4dd5aea556f8fa7fb24ea70a43001_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_4a038a414fd0dc87a838d41e97a668c2_Out_2_Float;
            Unity_Subtract_float(_Multiply_67b4dd5aea556f8fa7fb24ea70a43001_Out_2_Float, _Property_a67933cd8c95468c980f48e9034ae573_Out_0_Float, _Subtract_4a038a414fd0dc87a838d41e97a668c2_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_e4fce87b2e0ae38a8328dd3cb8900f12_Out_3_Float;
            Unity_Clamp_float(_Subtract_4a038a414fd0dc87a838d41e97a668c2_Out_2_Float, 0, 1, _Clamp_e4fce87b2e0ae38a8328dd3cb8900f12_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_b0970982c9e5338a91c1a0a2a789aa25_Out_3_Float;
            Unity_Branch_float(_Property_152b94cbb48274889d939d7a82b7dda6_Out_0_Boolean, _Clamp_e4fce87b2e0ae38a8328dd3cb8900f12_Out_3_Float, _Add_eb094a1ca0366788ab2cf15df38b67b4_Out_2_Float, _Branch_b0970982c9e5338a91c1a0a2a789aa25_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _OneMinus_6c4dd0ce4a8575899024bd27fdc25039_Out_1_Float;
            Unity_OneMinus_float(_Branch_b0970982c9e5338a91c1a0a2a789aa25_Out_3_Float, _OneMinus_6c4dd0ce4a8575899024bd27fdc25039_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_331f0014955316889c6589599ba9cef6_Out_2_Float;
            Unity_Multiply_float_float(_OneMinus_6c4dd0ce4a8575899024bd27fdc25039_Out_1_Float, _Add_1f8b2d8060996087bbec729f409fc77a_Out_2_Float, _Multiply_331f0014955316889c6589599ba9cef6_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_16b4e791fb09c58ca757ae71094539df_Out_0_Float = _ValleysEmissionBoostBloom;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_d6737dce0d370582a0bd0232e36504f8_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_331f0014955316889c6589599ba9cef6_Out_2_Float, _Property_16b4e791fb09c58ca757ae71094539df_Out_0_Float, _Multiply_d6737dce0d370582a0bd0232e36504f8_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Add_ec309ddb4b685984a345f9ea7c9fcac6_Out_2_Float;
            Unity_Add_float(_Multiply_d6737dce0d370582a0bd0232e36504f8_Out_2_Float, _Branch_b0970982c9e5338a91c1a0a2a789aa25_Out_3_Float, _Add_ec309ddb4b685984a345f9ea7c9fcac6_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Float_e8094274cb4ab583be5b6c15f87d2739_Out_0_Float = 1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Add_a4f6a6b7a6d2588aa7fc69d5f7ca6636_Out_2_Float;
            Unity_Add_float(_Add_ec309ddb4b685984a345f9ea7c9fcac6_Out_2_Float, _Float_e8094274cb4ab583be5b6c15f87d2739_Out_0_Float, _Add_a4f6a6b7a6d2588aa7fc69d5f7ca6636_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_f065adff4648e282a1e7907b43de1b4a_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_8804404b13920f869ec4d55fb24c7ba8_Out_2_Vector4, (_Add_a4f6a6b7a6d2588aa7fc69d5f7ca6636_Out_2_Float.xxxx), _Multiply_f065adff4648e282a1e7907b43de1b4a_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_bb33c960c7e40b8bb5de95b154df250f_Out_2_Float;
            Unity_Multiply_float_float(_Clamp_988f6b67aa3633828aefd1fff18d955a_Out_3_Float, _Smoothstep_cea7208b04fa3f80b81355fa6eb5f853_Out_3_Float, _Multiply_bb33c960c7e40b8bb5de95b154df250f_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_596ddcdd95db5c8f84542d57e42d2465_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_f065adff4648e282a1e7907b43de1b4a_Out_2_Vector4, (_Multiply_bb33c960c7e40b8bb5de95b154df250f_Out_2_Float.xxxx), _Multiply_596ddcdd95db5c8f84542d57e42d2465_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_0d66069e4237608dbe53e154e4fa3c55_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_d18fe22818842a88b984652b736e6b29_R_1_Float = _UV_0d66069e4237608dbe53e154e4fa3c55_Out_0_Vector4[0];
            float _Split_d18fe22818842a88b984652b736e6b29_G_2_Float = _UV_0d66069e4237608dbe53e154e4fa3c55_Out_0_Vector4[1];
            float _Split_d18fe22818842a88b984652b736e6b29_B_3_Float = _UV_0d66069e4237608dbe53e154e4fa3c55_Out_0_Vector4[2];
            float _Split_d18fe22818842a88b984652b736e6b29_A_4_Float = _UV_0d66069e4237608dbe53e154e4fa3c55_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_29857c35049b0384ba12beee27fe19c9_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_596ddcdd95db5c8f84542d57e42d2465_Out_2_Vector4, (_Split_d18fe22818842a88b984652b736e6b29_G_2_Float.xxxx), _Multiply_29857c35049b0384ba12beee27fe19c9_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Add_cf7efe372c0b5784b5a05514770041b4_Out_2_Vector4;
            Unity_Add_float4(_Lerp_629f74e1e348258dad2769378b8e65d4_Out_3_Vector4, _Multiply_29857c35049b0384ba12beee27fe19c9_Out_2_Vector4, _Add_cf7efe372c0b5784b5a05514770041b4_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_43d23b4b5e2c128486c24d4911dcb3fe_Out_0_Float = _FinalOpacityPower;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_6a47be0fcb1f8e8988451b5569e19b85_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_OpacityMask);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_2cc41a282cd91b8c9c107716cfe48237_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_05a9b1de2fb2b283bdf58fa06541e94e_R_1_Float = _UV_2cc41a282cd91b8c9c107716cfe48237_Out_0_Vector4[0];
            float _Split_05a9b1de2fb2b283bdf58fa06541e94e_G_2_Float = _UV_2cc41a282cd91b8c9c107716cfe48237_Out_0_Vector4[1];
            float _Split_05a9b1de2fb2b283bdf58fa06541e94e_B_3_Float = _UV_2cc41a282cd91b8c9c107716cfe48237_Out_0_Vector4[2];
            float _Split_05a9b1de2fb2b283bdf58fa06541e94e_A_4_Float = _UV_2cc41a282cd91b8c9c107716cfe48237_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_e630cebe9198498ea2e67d597fd536c7_Out_0_Vector2 = float2(_Split_05a9b1de2fb2b283bdf58fa06541e94e_R_1_Float, _Split_05a9b1de2fb2b283bdf58fa06541e94e_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_e3705ba0af02ce80906069d30a10aa5d_Out_0_Vector2 = float2(0, 1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_c5d10064898da28a9d3b292247164fa3_Out_0_Vector2 = float2(-1, 1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Remap_e2af3df921a7518a87f62dcaeafb9b3e_Out_3_Vector2;
            Unity_Remap_float2(_Vector2_e630cebe9198498ea2e67d597fd536c7_Out_0_Vector2, _Vector2_e3705ba0af02ce80906069d30a10aa5d_Out_0_Vector2, _Vector2_c5d10064898da28a9d3b292247164fa3_Out_0_Vector2, _Remap_e2af3df921a7518a87f62dcaeafb9b3e_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_28bdc0ad15c677868fcefcb6d7b1472e_Out_0_Float = _OpacityMaskScaler;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Multiply_c481934beaa2d08bae5066c6bc3fc4a3_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Remap_e2af3df921a7518a87f62dcaeafb9b3e_Out_3_Vector2, (_Property_28bdc0ad15c677868fcefcb6d7b1472e_Out_0_Float.xx), _Multiply_c481934beaa2d08bae5066c6bc3fc4a3_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_81f19448a8934d8b8cb74dbbc03aad43_Out_0_Vector2 = float2(-1, 1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_6dd004fc6165b980bbafc0eb13426110_Out_0_Vector2 = float2(0, 1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Remap_03ad26fe388ace8e8a157e90a5831279_Out_3_Vector2;
            Unity_Remap_float2(_Multiply_c481934beaa2d08bae5066c6bc3fc4a3_Out_2_Vector2, _Vector2_81f19448a8934d8b8cb74dbbc03aad43_Out_0_Vector2, _Vector2_6dd004fc6165b980bbafc0eb13426110_Out_0_Vector2, _Remap_03ad26fe388ace8e8a157e90a5831279_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_77e8ede07872fb87a9835782b28317c1_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_6a47be0fcb1f8e8988451b5569e19b85_Out_0_Texture2D.tex, _Property_6a47be0fcb1f8e8988451b5569e19b85_Out_0_Texture2D.samplerstate, _Property_6a47be0fcb1f8e8988451b5569e19b85_Out_0_Texture2D.GetTransformedUV(_Remap_03ad26fe388ace8e8a157e90a5831279_Out_3_Vector2) );
            float _SampleTexture2D_77e8ede07872fb87a9835782b28317c1_R_4_Float = _SampleTexture2D_77e8ede07872fb87a9835782b28317c1_RGBA_0_Vector4.r;
            float _SampleTexture2D_77e8ede07872fb87a9835782b28317c1_G_5_Float = _SampleTexture2D_77e8ede07872fb87a9835782b28317c1_RGBA_0_Vector4.g;
            float _SampleTexture2D_77e8ede07872fb87a9835782b28317c1_B_6_Float = _SampleTexture2D_77e8ede07872fb87a9835782b28317c1_RGBA_0_Vector4.b;
            float _SampleTexture2D_77e8ede07872fb87a9835782b28317c1_A_7_Float = _SampleTexture2D_77e8ede07872fb87a9835782b28317c1_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_f4bb98f52bc9fc8baadde6672d6475f7_Out_0_Float = _OpacityMaskPower;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_d5c9bcb243870b8796f414920174c3d9_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_77e8ede07872fb87a9835782b28317c1_R_4_Float, _Property_f4bb98f52bc9fc8baadde6672d6475f7_Out_0_Float, _Multiply_d5c9bcb243870b8796f414920174c3d9_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_06f65c3691e42f8fb1308e947aa21d64_Out_3_Float;
            Unity_Clamp_float(_Multiply_d5c9bcb243870b8796f414920174c3d9_Out_2_Float, 0, 1, _Clamp_06f65c3691e42f8fb1308e947aa21d64_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _OneMinus_d47eadfacadd0188bf2c641dd6cb500b_Out_1_Float;
            Unity_OneMinus_float(_Clamp_06f65c3691e42f8fb1308e947aa21d64_Out_3_Float, _OneMinus_d47eadfacadd0188bf2c641dd6cb500b_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_bbaa43ccecc57089a218b95421fd191f_Out_0_Float = _OpacityMaskExp;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_93a163950a4bef8ebab2ed8cea15d9df_Out_2_Float;
            Unity_Power_float(_OneMinus_d47eadfacadd0188bf2c641dd6cb500b_Out_1_Float, _Property_bbaa43ccecc57089a218b95421fd191f_Out_0_Float, _Power_93a163950a4bef8ebab2ed8cea15d9df_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _OneMinus_3a2ab9b92d716387b6294cf2ee2461bf_Out_1_Float;
            Unity_OneMinus_float(_Power_93a163950a4bef8ebab2ed8cea15d9df_Out_2_Float, _OneMinus_3a2ab9b92d716387b6294cf2ee2461bf_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_2486c812e8379a8295ef523dfe86559a_Out_3_Float;
            Unity_Clamp_float(_OneMinus_3a2ab9b92d716387b6294cf2ee2461bf_Out_1_Float, 0.001, 0.999, _Clamp_2486c812e8379a8295ef523dfe86559a_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_79bb4e1b0dc9ab8c9b9fa4c942d6ba71_Out_2_Float;
            Unity_Multiply_float_float(_Property_43d23b4b5e2c128486c24d4911dcb3fe_Out_0_Float, _Clamp_2486c812e8379a8295ef523dfe86559a_Out_3_Float, _Multiply_79bb4e1b0dc9ab8c9b9fa4c942d6ba71_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_65765b663bc7a78c8521b9e13032536f_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_79bb4e1b0dc9ab8c9b9fa4c942d6ba71_Out_2_Float, _SampleTexture2D_62a92809434b8f8d9eed9f59404c5fda_G_5_Float, _Multiply_65765b663bc7a78c8521b9e13032536f_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_fb74307434f9748bb5c6eec6b9ad7dff_Out_3_Float;
            Unity_Clamp_float(_Multiply_65765b663bc7a78c8521b9e13032536f_Out_2_Float, 0, 1, _Clamp_fb74307434f9748bb5c6eec6b9ad7dff_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_305d4955c7477c88bdbba42728979ee7_Out_0_Boolean = _DISSOLVETEXTUREFLIP;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_f11d97f4b731af87a726ced1ff00d330_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_DissolveTexture);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_b04096909614a78fa362ee5f59729b68_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_f373c39af2c359848c1aaaf1bb2b46ca_R_1_Float = _UV_b04096909614a78fa362ee5f59729b68_Out_0_Vector4[0];
            float _Split_f373c39af2c359848c1aaaf1bb2b46ca_G_2_Float = _UV_b04096909614a78fa362ee5f59729b68_Out_0_Vector4[1];
            float _Split_f373c39af2c359848c1aaaf1bb2b46ca_B_3_Float = _UV_b04096909614a78fa362ee5f59729b68_Out_0_Vector4[2];
            float _Split_f373c39af2c359848c1aaaf1bb2b46ca_A_4_Float = _UV_b04096909614a78fa362ee5f59729b68_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_f6e76e6bbf4724899be8dc243f519d61_Out_0_Vector2 = float2(_Split_f373c39af2c359848c1aaaf1bb2b46ca_R_1_Float, _Split_f373c39af2c359848c1aaaf1bb2b46ca_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_df2a4ea09e40418cb6e2cb59a993d9c1_Out_0_Float = _DissolveTextureScaleU;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_894e9d571393448dba889015d79e4fcb_Out_0_Float = _DissolveTextureScaleV;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_7c4976d1b5e5aa8d8d3abb4ba9a3f612_Out_0_Vector2 = float2(_Property_df2a4ea09e40418cb6e2cb59a993d9c1_Out_0_Float, _Property_894e9d571393448dba889015d79e4fcb_Out_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Multiply_70ab4399850e3a8093ce7a008ca305dc_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_f6e76e6bbf4724899be8dc243f519d61_Out_0_Vector2, _Vector2_7c4976d1b5e5aa8d8d3abb4ba9a3f612_Out_0_Vector2, _Multiply_70ab4399850e3a8093ce7a008ca305dc_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_bac9499178868681ab6cafbbd1e5db8a_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_db94a60898776689aac5cfc6bfd7bf84_R_1_Float = _UV_bac9499178868681ab6cafbbd1e5db8a_Out_0_Vector4[0];
            float _Split_db94a60898776689aac5cfc6bfd7bf84_G_2_Float = _UV_bac9499178868681ab6cafbbd1e5db8a_Out_0_Vector4[1];
            float _Split_db94a60898776689aac5cfc6bfd7bf84_B_3_Float = _UV_bac9499178868681ab6cafbbd1e5db8a_Out_0_Vector4[2];
            float _Split_db94a60898776689aac5cfc6bfd7bf84_A_4_Float = _UV_bac9499178868681ab6cafbbd1e5db8a_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_c574c1605395388182a7b2a55e3e2386_Out_0_Float = _DissolveTextureRandomMin;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_1d8dafa9219cd5829b9914f33c42381f_Out_0_Float = _DissolveTextureRandomMax;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_7c6eec4d0b9cab8a8ea899a95eb43c11_Out_0_Vector2 = float2(_Property_c574c1605395388182a7b2a55e3e2386_Out_0_Float, _Property_1d8dafa9219cd5829b9914f33c42381f_Out_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Remap_5d2f9ea26fa4e783b52602879cc7bbbb_Out_3_Float;
            Unity_Remap_float(_Split_db94a60898776689aac5cfc6bfd7bf84_B_3_Float, float2 (0, 120), _Vector2_7c6eec4d0b9cab8a8ea899a95eb43c11_Out_0_Vector2, _Remap_5d2f9ea26fa4e783b52602879cc7bbbb_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Multiply_b9107083c43e3d8f845315fc45e9e87a_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Multiply_70ab4399850e3a8093ce7a008ca305dc_Out_2_Vector2, (_Remap_5d2f9ea26fa4e783b52602879cc7bbbb_Out_3_Float.xx), _Multiply_b9107083c43e3d8f845315fc45e9e87a_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Add_9283aa655c7734878bb457e72d86ce82_Out_2_Vector2;
            Unity_Add_float2(_Multiply_b9107083c43e3d8f845315fc45e9e87a_Out_2_Vector2, (_Split_db94a60898776689aac5cfc6bfd7bf84_B_3_Float.xx), _Add_9283aa655c7734878bb457e72d86ce82_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_3f27d353dbe7668f8292528a2fa3b4a7_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_f11d97f4b731af87a726ced1ff00d330_Out_0_Texture2D.tex, _Property_f11d97f4b731af87a726ced1ff00d330_Out_0_Texture2D.samplerstate, _Property_f11d97f4b731af87a726ced1ff00d330_Out_0_Texture2D.GetTransformedUV(_Add_9283aa655c7734878bb457e72d86ce82_Out_2_Vector2) );
            float _SampleTexture2D_3f27d353dbe7668f8292528a2fa3b4a7_R_4_Float = _SampleTexture2D_3f27d353dbe7668f8292528a2fa3b4a7_RGBA_0_Vector4.r;
            float _SampleTexture2D_3f27d353dbe7668f8292528a2fa3b4a7_G_5_Float = _SampleTexture2D_3f27d353dbe7668f8292528a2fa3b4a7_RGBA_0_Vector4.g;
            float _SampleTexture2D_3f27d353dbe7668f8292528a2fa3b4a7_B_6_Float = _SampleTexture2D_3f27d353dbe7668f8292528a2fa3b4a7_RGBA_0_Vector4.b;
            float _SampleTexture2D_3f27d353dbe7668f8292528a2fa3b4a7_A_7_Float = _SampleTexture2D_3f27d353dbe7668f8292528a2fa3b4a7_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _OneMinus_3001debfa6ad1c81b63da9d01cb45c02_Out_1_Float;
            Unity_OneMinus_float(_SampleTexture2D_3f27d353dbe7668f8292528a2fa3b4a7_R_4_Float, _OneMinus_3001debfa6ad1c81b63da9d01cb45c02_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Branch_b482d626a9a84083831a26344a586336_Out_3_Float;
            Unity_Branch_float(_Property_305d4955c7477c88bdbba42728979ee7_Out_0_Boolean, _OneMinus_3001debfa6ad1c81b63da9d01cb45c02_Out_1_Float, _SampleTexture2D_3f27d353dbe7668f8292528a2fa3b4a7_R_4_Float, _Branch_b482d626a9a84083831a26344a586336_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_b9e47ce49bddb88abb40143bda0be2b8_Out_0_Float = _DissolveExp;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_abab7f0f71778280b804bf49943a76a3_Out_2_Float;
            Unity_Power_float(_Branch_b482d626a9a84083831a26344a586336_Out_3_Float, _Property_b9e47ce49bddb88abb40143bda0be2b8_Out_0_Float, _Power_abab7f0f71778280b804bf49943a76a3_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _OneMinus_43ff8bb9dbae798cbad5644a8e629a78_Out_1_Float;
            Unity_OneMinus_float(_Power_abab7f0f71778280b804bf49943a76a3_Out_2_Float, _OneMinus_43ff8bb9dbae798cbad5644a8e629a78_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_299a1ec8f17a6084b3e23a9a70db20c6_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_31ee4940cb0883839f3ee53bb11f11dd_R_1_Float = _UV_299a1ec8f17a6084b3e23a9a70db20c6_Out_0_Vector4[0];
            float _Split_31ee4940cb0883839f3ee53bb11f11dd_G_2_Float = _UV_299a1ec8f17a6084b3e23a9a70db20c6_Out_0_Vector4[1];
            float _Split_31ee4940cb0883839f3ee53bb11f11dd_B_3_Float = _UV_299a1ec8f17a6084b3e23a9a70db20c6_Out_0_Vector4[2];
            float _Split_31ee4940cb0883839f3ee53bb11f11dd_A_4_Float = _UV_299a1ec8f17a6084b3e23a9a70db20c6_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_9b933e718233638b8b4af2d387a3121e_Out_0_Float = _DissolveExpReversed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float2 _Vector2_aac89571485d35848188f9d4f5a4a3f8_Out_0_Vector2 = float2(1, _Property_9b933e718233638b8b4af2d387a3121e_Out_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Remap_2ef5bd19c001898594144c092e4d81a4_Out_3_Float;
            Unity_Remap_float(_Split_31ee4940cb0883839f3ee53bb11f11dd_R_1_Float, float2 (0, 1), _Vector2_aac89571485d35848188f9d4f5a4a3f8_Out_0_Vector2, _Remap_2ef5bd19c001898594144c092e4d81a4_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_6fd18693b05ba986b2b2c615a975e316_Out_2_Float;
            Unity_Power_float(_OneMinus_43ff8bb9dbae798cbad5644a8e629a78_Out_1_Float, _Remap_2ef5bd19c001898594144c092e4d81a4_Out_3_Float, _Power_6fd18693b05ba986b2b2c615a975e316_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _OneMinus_d3f3d49e0d495d859c199c17d16b1207_Out_1_Float;
            Unity_OneMinus_float(_Power_6fd18693b05ba986b2b2c615a975e316_Out_2_Float, _OneMinus_d3f3d49e0d495d859c199c17d16b1207_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_7d37b6fd0048378e9dc0a1af5ead10dc_Out_3_Float;
            Unity_Clamp_float(_OneMinus_d3f3d49e0d495d859c199c17d16b1207_Out_1_Float, 0, 1, _Clamp_7d37b6fd0048378e9dc0a1af5ead10dc_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_98e05319dc2df384bc8302a77cc097fd_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_b7f72866e59472839e2200e27f194fed_R_1_Float = _UV_98e05319dc2df384bc8302a77cc097fd_Out_0_Vector4[0];
            float _Split_b7f72866e59472839e2200e27f194fed_G_2_Float = _UV_98e05319dc2df384bc8302a77cc097fd_Out_0_Vector4[1];
            float _Split_b7f72866e59472839e2200e27f194fed_B_3_Float = _UV_98e05319dc2df384bc8302a77cc097fd_Out_0_Vector4[2];
            float _Split_b7f72866e59472839e2200e27f194fed_A_4_Float = _UV_98e05319dc2df384bc8302a77cc097fd_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Remap_394b7a76b07e5e8e97c0248a4f09a352_Out_3_Float;
            Unity_Remap_float(_Split_b7f72866e59472839e2200e27f194fed_R_1_Float, float2 (0, 1), float2 (-1, 1), _Remap_394b7a76b07e5e8e97c0248a4f09a352_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Add_dc4872c41f092883b9c04ff857579107_Out_2_Float;
            Unity_Add_float(_Clamp_7d37b6fd0048378e9dc0a1af5ead10dc_Out_3_Float, _Remap_394b7a76b07e5e8e97c0248a4f09a352_Out_3_Float, _Add_dc4872c41f092883b9c04ff857579107_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_b86cc0aca1aca781a6cecd3306643e2c_Out_3_Float;
            Unity_Clamp_float(_Add_dc4872c41f092883b9c04ff857579107_Out_2_Float, 0, 1, _Clamp_b86cc0aca1aca781a6cecd3306643e2c_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Subtract_1f498790df5d6582a2de0fc95b846755_Out_2_Float;
            Unity_Subtract_float(_Clamp_fb74307434f9748bb5c6eec6b9ad7dff_Out_3_Float, _Clamp_b86cc0aca1aca781a6cecd3306643e2c_Out_3_Float, _Subtract_1f498790df5d6582a2de0fc95b846755_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_81e16c656c6b5387b539209f5d232f9d_Out_3_Float;
            Unity_Clamp_float(_Subtract_1f498790df5d6582a2de0fc95b846755_Out_2_Float, 0, 1, _Clamp_81e16c656c6b5387b539209f5d232f9d_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Split_88f6e46f57c8a0848fb71dacdeb730da_R_1_Float = IN.VertexColor[0];
            float _Split_88f6e46f57c8a0848fb71dacdeb730da_G_2_Float = IN.VertexColor[1];
            float _Split_88f6e46f57c8a0848fb71dacdeb730da_B_3_Float = IN.VertexColor[2];
            float _Split_88f6e46f57c8a0848fb71dacdeb730da_A_4_Float = IN.VertexColor[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Multiply_5bbe542fb94c9a8a95e78114ca761afb_Out_2_Float;
            Unity_Multiply_float_float(_Clamp_81e16c656c6b5387b539209f5d232f9d_Out_3_Float, _Split_88f6e46f57c8a0848fb71dacdeb730da_A_4_Float, _Multiply_5bbe542fb94c9a8a95e78114ca761afb_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _OneMinus_b33624e26a9a0b8fafa360b929da64c1_Out_1_Float;
            Unity_OneMinus_float(_Multiply_5bbe542fb94c9a8a95e78114ca761afb_Out_2_Float, _OneMinus_b33624e26a9a0b8fafa360b929da64c1_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_8bc2b712636cc4819e3e7c9231b95e63_Out_0_Float = _FinalOpacityExp;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Power_7a655e893d9bd08cb346ac00388c201b_Out_2_Float;
            Unity_Power_float(_OneMinus_b33624e26a9a0b8fafa360b929da64c1_Out_1_Float, _Property_8bc2b712636cc4819e3e7c9231b95e63_Out_0_Float, _Power_7a655e893d9bd08cb346ac00388c201b_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _OneMinus_085258a959ee588eba2be56818fddb6d_Out_1_Float;
            Unity_OneMinus_float(_Power_7a655e893d9bd08cb346ac00388c201b_Out_2_Float, _OneMinus_085258a959ee588eba2be56818fddb6d_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Clamp_c96916b3112b50809ef4d5e7244954f0_Out_3_Float;
            Unity_Clamp_float(_OneMinus_085258a959ee588eba2be56818fddb6d_Out_1_Float, 0, 1, _Clamp_c96916b3112b50809ef4d5e7244954f0_Out_3_Float);
            #endif
            surface.BaseColor = (_Add_cf7efe372c0b5784b5a05514770041b4_Out_2_Vector4.xyz);
            surface.Alpha = _Clamp_c96916b3112b50809ef4d5e7244954f0_Out_3_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv1 = input.texCoord1;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.VertexColor = input.color;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
      
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphUnlitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}