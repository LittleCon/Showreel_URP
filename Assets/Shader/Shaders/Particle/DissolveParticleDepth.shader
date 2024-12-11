Shader "FC/Particle/DissolveParticleDepth"
{
    Properties
    {
        _FinalColor("Final Color", Color) = (1, 1, 1, 1)
        _FinalPower("Final Power", Range(0, 60)) = 0
        _FinalOpacityPower("Final Opacity Power", Range(1, 8)) = 1
        _FinalOpacityExp("Final Opacity Exp", Range(0.2, 8)) = 1
        [NoScaleOffset]_Ramp("Ramp", 2D) = "white" {}
        _RampColorTint("Ramp Color Tint", Color) = (1, 1, 1, 1)
        [ToggleUI]_RAMPAFFECTEDBYVERTEXCOLOR("Ramp Affected By Vertex Color", Float) = 0
        _RampAffectedByDynamics("Ramp Affected By Dynamics", Range(0, 1)) = 1
        _RampOffsetMultiply("Ramp Offset Multiply", Float) = 1
        _RampOffsetExp("Ramp Offset Exp", Range(0.2, 8)) = 1
        [ToggleUI]_RIMMASKFLIP("Rim Mask Flip", Float) = 0
        _RimMaskExp("Rim Mask Exp", Range(0.2, 8)) = 1
        [NoScaleOffset]_OffsetNoise("Offset Noise", 2D) = "white" {}
        _OffsetPower("Offset Power", Float) = 0.5
        _OffsetScaleWithSizeFixSwitch("Offset Scale With Size Fix Switch", Range(0, 1)) = 1
        [NoScaleOffset]_DissolveNoise("Dissolve Noise", 2D) = "white" {}
        [ToggleUI]_DISSOLVENOISEFLIP("Dissolve Noise Flip", Float) = 0
        _DissolveNoiseExp("Dissolve Noise Exp", Float) = 6.47
        _DissolveNoiseExpReversed("Dissolve Noise Exp Reversed", Float) = 2
        [ToggleUI]_DEPTHFADEMAXMODE("Depth Fade Max Mode", Float) = 1
        [ToggleUI]_DEPTHFADEFLIP("Depth Fade Flip", Float) = 1
        _DepthFadeDistance("Depth Fade Distance", Float) = 1
        _DepthFadeExp("Depth Fade Exp", Float) = 2
        _LossyScaleGlobal("_LossyScaleGlobal", Float) = 1
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
        [Toggle]_RAMPENABLED("Ramp Enabled", Float) = 0
        [Toggle]_RIMMASKENABLED("Rim Mask Enabled", Float) = 0
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
        Cull Off
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
        #pragma shader_feature_local _ _RAMPENABLED_ON
        #pragma shader_feature_local _ _RIMMASKENABLED_ON
        
        #if defined(_RAMPENABLED_ON) && defined(_RIMMASKENABLED_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_RAMPENABLED_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_RIMMASKENABLED_ON)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_COLOR
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_NORMAL_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_COLOR
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_CULLFACE
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_UNLIT
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define REQUIRE_DEPTH_TEXTURE
        #endif
        
        
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
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 color : COLOR;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 color;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 WorldSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 WorldSpaceViewDirection;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 WorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 NDCPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 PixelPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 VertexColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float FaceSign;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 WorldSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 AbsoluteWorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 color : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS : INTERP2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalWS : INTERP3;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
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
        float4 _FinalColor;
        float _FinalPower;
        float _FinalOpacityPower;
        float _FinalOpacityExp;
        float4 _Ramp_TexelSize;
        float4 _RampColorTint;
        float _RAMPAFFECTEDBYVERTEXCOLOR;
        float _RampAffectedByDynamics;
        float _RampOffsetMultiply;
        float _RampOffsetExp;
        float _RIMMASKFLIP;
        float _RimMaskExp;
        float4 _OffsetNoise_TexelSize;
        float _OffsetPower;
        float _OffsetScaleWithSizeFixSwitch;
        float4 _DissolveNoise_TexelSize;
        float _DISSOLVENOISEFLIP;
        float _DissolveNoiseExp;
        float _DissolveNoiseExpReversed;
        float _DEPTHFADEMAXMODE;
        float _DEPTHFADEFLIP;
        float _DepthFadeDistance;
        float _DepthFadeExp;
        float _LossyScaleGlobal;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Ramp);
        SAMPLER(sampler_Ramp);
        TEXTURE2D(_OffsetNoise);
        SAMPLER(sampler_OffsetNoise);
        TEXTURE2D(_DissolveNoise);
        SAMPLER(sampler_DissolveNoise);
        
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
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Round_float(float In, out float Out)
        {
            Out = round(In);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Negate_float3(float3 In, out float3 Out)
        {
            Out = -1 * In;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void CustomDepthBlend_float(float4 spr, float dist, float depthnode, out float DepthBlendResult){
            float4 sp = spr / spr.w;
            sp.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? sp.z : sp.z * 0.5 + 0.5;
            
            //float screenDepth6 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( sp.xy ),_ZBufferParams);
            
            float distanceDepth6 = abs( ( depthnode - LinearEyeDepth( sp.z,_ZBufferParams ) ) / ( dist ) );
            DepthBlendResult = distanceDepth6;
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
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
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_bb13871e7f87bd8abe7b83a3abb9faab_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_OffsetNoise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_f345c3b231c23885b43da93e6b29653d_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_f345c3b231c23885b43da93e6b29653d_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_bb13871e7f87bd8abe7b83a3abb9faab_Out_0_Texture2D.tex, _Property_bb13871e7f87bd8abe7b83a3abb9faab_Out_0_Texture2D.samplerstate, _Property_bb13871e7f87bd8abe7b83a3abb9faab_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy), 0);
            #endif
            float _SampleTexture2DLOD_f345c3b231c23885b43da93e6b29653d_R_5_Float = _SampleTexture2DLOD_f345c3b231c23885b43da93e6b29653d_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_f345c3b231c23885b43da93e6b29653d_G_6_Float = _SampleTexture2DLOD_f345c3b231c23885b43da93e6b29653d_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_f345c3b231c23885b43da93e6b29653d_B_7_Float = _SampleTexture2DLOD_f345c3b231c23885b43da93e6b29653d_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_f345c3b231c23885b43da93e6b29653d_A_8_Float = _SampleTexture2DLOD_f345c3b231c23885b43da93e6b29653d_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_22fd55b8200bf189bf56ffde190c4eaa_Out_2_Vector3;
            Unity_Multiply_float3_float3((_SampleTexture2DLOD_f345c3b231c23885b43da93e6b29653d_R_5_Float.xxx), IN.WorldSpaceNormal, _Multiply_22fd55b8200bf189bf56ffde190c4eaa_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_d636888d5bc37a8391492835227c0035_Out_0_Float = _LossyScaleGlobal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_bd63d4b2b8b1118cb79fbc79e81911fb_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_22fd55b8200bf189bf56ffde190c4eaa_Out_2_Vector3, (_Property_d636888d5bc37a8391492835227c0035_Out_0_Float.xxx), _Multiply_bd63d4b2b8b1118cb79fbc79e81911fb_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_0f5e702f34f4ec8185c20937e62c6793_Out_0_Float = _OffsetPower;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_d4a31aad82b4db8ab9f582561563d81c_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_bd63d4b2b8b1118cb79fbc79e81911fb_Out_2_Vector3, (_Property_0f5e702f34f4ec8185c20937e62c6793_Out_0_Float.xxx), _Multiply_d4a31aad82b4db8ab9f582561563d81c_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_3570cd4530a68c8586ca7814905d4bc1_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_74dff857cd563585b2dd37b3f35dc717_R_1_Float = _UV_3570cd4530a68c8586ca7814905d4bc1_Out_0_Vector4[0];
            float _Split_74dff857cd563585b2dd37b3f35dc717_G_2_Float = _UV_3570cd4530a68c8586ca7814905d4bc1_Out_0_Vector4[1];
            float _Split_74dff857cd563585b2dd37b3f35dc717_B_3_Float = _UV_3570cd4530a68c8586ca7814905d4bc1_Out_0_Vector4[2];
            float _Split_74dff857cd563585b2dd37b3f35dc717_A_4_Float = _UV_3570cd4530a68c8586ca7814905d4bc1_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_5b988463970cf98fa774036b8cbf9d69_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_d4a31aad82b4db8ab9f582561563d81c_Out_2_Vector3, (_Split_74dff857cd563585b2dd37b3f35dc717_R_1_Float.xxx), _Multiply_5b988463970cf98fa774036b8cbf9d69_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_6c1b9417a16ef48a9e2c4f6d2a368589_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_82cfa9f849fad78e8e5725ee81b5378f_R_1_Float = _UV_6c1b9417a16ef48a9e2c4f6d2a368589_Out_0_Vector4[0];
            float _Split_82cfa9f849fad78e8e5725ee81b5378f_G_2_Float = _UV_6c1b9417a16ef48a9e2c4f6d2a368589_Out_0_Vector4[1];
            float _Split_82cfa9f849fad78e8e5725ee81b5378f_B_3_Float = _UV_6c1b9417a16ef48a9e2c4f6d2a368589_Out_0_Vector4[2];
            float _Split_82cfa9f849fad78e8e5725ee81b5378f_A_4_Float = _UV_6c1b9417a16ef48a9e2c4f6d2a368589_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_9dda3b103ab4148c83fea912707b1887_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_5b988463970cf98fa774036b8cbf9d69_Out_2_Vector3, (_Split_82cfa9f849fad78e8e5725ee81b5378f_A_4_Float.xxx), _Multiply_9dda3b103ab4148c83fea912707b1887_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_492553fbb2020f80afe68745c10f6423_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_c98aa7df73ea528bbe5650f048b9ba67_R_1_Float = _UV_492553fbb2020f80afe68745c10f6423_Out_0_Vector4[0];
            float _Split_c98aa7df73ea528bbe5650f048b9ba67_G_2_Float = _UV_492553fbb2020f80afe68745c10f6423_Out_0_Vector4[1];
            float _Split_c98aa7df73ea528bbe5650f048b9ba67_B_3_Float = _UV_492553fbb2020f80afe68745c10f6423_Out_0_Vector4[2];
            float _Split_c98aa7df73ea528bbe5650f048b9ba67_A_4_Float = _UV_492553fbb2020f80afe68745c10f6423_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_50b277c6882010838029c7c9a82fbad9_Out_0_Vector3 = float3(_Split_c98aa7df73ea528bbe5650f048b9ba67_G_2_Float, _Split_c98aa7df73ea528bbe5650f048b9ba67_B_3_Float, _Split_c98aa7df73ea528bbe5650f048b9ba67_A_4_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Distance_56c264fa8441288d80df779122648b65_Out_2_Float;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _Vector3_50b277c6882010838029c7c9a82fbad9_Out_0_Vector3, _Distance_56c264fa8441288d80df779122648b65_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_4ef9e32110268880a9a7d1feec3b43a7_Out_0_Float = _OffsetScaleWithSizeFixSwitch;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Round_f15f490bde0f3381b94d3d91337a57ad_Out_1_Float;
            Unity_Round_float(_Property_4ef9e32110268880a9a7d1feec3b43a7_Out_0_Float, _Round_f15f490bde0f3381b94d3d91337a57ad_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Lerp_77eb13d2d64f2b859315f6b4901a3b88_Out_3_Float;
            Unity_Lerp_float(1, _Distance_56c264fa8441288d80df779122648b65_Out_2_Float, _Round_f15f490bde0f3381b94d3d91337a57ad_Out_1_Float, _Lerp_77eb13d2d64f2b859315f6b4901a3b88_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_1590b45d65bb2c83bb598fd2f18e5c17_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_9dda3b103ab4148c83fea912707b1887_Out_2_Vector3, (_Lerp_77eb13d2d64f2b859315f6b4901a3b88_Out_3_Float.xxx), _Multiply_1590b45d65bb2c83bb598fd2f18e5c17_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_5e70af977259848db5039f4a7732f1f6_Out_2_Vector3;
            Unity_Add_float3(_Multiply_1590b45d65bb2c83bb598fd2f18e5c17_Out_2_Vector3, IN.ObjectSpacePosition, _Add_5e70af977259848db5039f4a7732f1f6_Out_2_Vector3);
            #endif
            description.Position = _Add_5e70af977259848db5039f4a7732f1f6_Out_2_Vector3;
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
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c5b4f21328d5ab8c92f71092846b4b48_Out_0_Float = _FinalPower;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_c0218668e3155082bf08c5e28558fea4_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_a8bdd03ac83d9c8a9d2de7f1ee318be2_R_1_Float = _UV_c0218668e3155082bf08c5e28558fea4_Out_0_Vector4[0];
            float _Split_a8bdd03ac83d9c8a9d2de7f1ee318be2_G_2_Float = _UV_c0218668e3155082bf08c5e28558fea4_Out_0_Vector4[1];
            float _Split_a8bdd03ac83d9c8a9d2de7f1ee318be2_B_3_Float = _UV_c0218668e3155082bf08c5e28558fea4_Out_0_Vector4[2];
            float _Split_a8bdd03ac83d9c8a9d2de7f1ee318be2_A_4_Float = _UV_c0218668e3155082bf08c5e28558fea4_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Clamp_84ecbbe6bc30b988a7087dc3ce584f8c_Out_3_Float;
            Unity_Clamp_float(_Split_a8bdd03ac83d9c8a9d2de7f1ee318be2_B_3_Float, 0, 1, _Clamp_84ecbbe6bc30b988a7087dc3ce584f8c_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_62c0772ca26a6b8bba0c12deaf0e61ac_Out_2_Float;
            Unity_Multiply_float_float(_Property_c5b4f21328d5ab8c92f71092846b4b48_Out_0_Float, _Clamp_84ecbbe6bc30b988a7087dc3ce584f8c_Out_3_Float, _Multiply_62c0772ca26a6b8bba0c12deaf0e61ac_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_42a6ecbde5e97d85a71b4c295d461959_Out_0_Boolean = _RAMPAFFECTEDBYVERTEXCOLOR;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_76b6d58427bcf781b8ca1b06fc7eda7e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Ramp);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_96b142e451433a8294ab966060a47dea_Out_0_Float = _RampOffsetMultiply;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_4a68bf77621983808a2a074c034183e3_Out_0_Boolean = _DEPTHFADEMAXMODE;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_1455270687b96a85aa52e7f0e6a8eae1_Out_0_Boolean = _RIMMASKFLIP;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _IsFrontFace_5d2f93d8b1fd158798be1cb487c6d8f6_Out_0_Boolean = max(0, IN.FaceSign.x);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Negate_b2c98f04848fa884aeb825a8f55d61b6_Out_1_Vector3;
            Unity_Negate_float3(IN.WorldSpaceNormal, _Negate_b2c98f04848fa884aeb825a8f55d61b6_Out_1_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Branch_36d344a08c8fb08591e421271bbf1438_Out_3_Vector3;
            Unity_Branch_float3(_IsFrontFace_5d2f93d8b1fd158798be1cb487c6d8f6_Out_0_Boolean, IN.WorldSpaceNormal, _Negate_b2c98f04848fa884aeb825a8f55d61b6_Out_1_Vector3, _Branch_36d344a08c8fb08591e421271bbf1438_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Normalize_2fc20b48f93e808e975c2430eed47705_Out_1_Vector3;
            Unity_Normalize_float3(IN.WorldSpaceViewDirection, _Normalize_2fc20b48f93e808e975c2430eed47705_Out_1_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _DotProduct_f16260798fdd1d8f8f4d1dd5799cbdc9_Out_2_Float;
            Unity_DotProduct_float3(_Branch_36d344a08c8fb08591e421271bbf1438_Out_3_Vector3, _Normalize_2fc20b48f93e808e975c2430eed47705_Out_1_Vector3, _DotProduct_f16260798fdd1d8f8f4d1dd5799cbdc9_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_d94ed2fec96b538b8044bd8da5de1209_Out_1_Float;
            Unity_OneMinus_float(_DotProduct_f16260798fdd1d8f8f4d1dd5799cbdc9_Out_2_Float, _OneMinus_d94ed2fec96b538b8044bd8da5de1209_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_29ab9a71f26a88808f3b53ac77121753_Out_1_Float;
            Unity_OneMinus_float(_OneMinus_d94ed2fec96b538b8044bd8da5de1209_Out_1_Float, _OneMinus_29ab9a71f26a88808f3b53ac77121753_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_c0370920baffc7869c4ae84e0029f24d_Out_3_Float;
            Unity_Branch_float(_Property_1455270687b96a85aa52e7f0e6a8eae1_Out_0_Boolean, _OneMinus_29ab9a71f26a88808f3b53ac77121753_Out_1_Float, _OneMinus_d94ed2fec96b538b8044bd8da5de1209_Out_1_Float, _Branch_c0370920baffc7869c4ae84e0029f24d_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Clamp_0cb54210672fb584b3fd307b3110ba04_Out_3_Float;
            Unity_Clamp_float(_Branch_c0370920baffc7869c4ae84e0029f24d_Out_3_Float, 0, 1, _Clamp_0cb54210672fb584b3fd307b3110ba04_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_a489bc5fa1d4ab888b17b1c9a02c8186_Out_0_Float = _RimMaskExp;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Power_b7e1657661e8ba8eb3067b8d83635ac9_Out_2_Float;
            Unity_Power_float(_Clamp_0cb54210672fb584b3fd307b3110ba04_Out_3_Float, _Property_a489bc5fa1d4ab888b17b1c9a02c8186_Out_0_Float, _Power_b7e1657661e8ba8eb3067b8d83635ac9_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(_RIMMASKENABLED_ON)
            float _RimMaskEnabled_d2078e517db04a839a3cfe047c152baf_Out_0_Float = _Power_b7e1657661e8ba8eb3067b8d83635ac9_Out_2_Float;
            #else
            float _RimMaskEnabled_d2078e517db04a839a3cfe047c152baf_Out_0_Float = 1;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_5f0a20ff17356f8cadfcf223e7af548e_Out_0_Boolean = _DEPTHFADEFLIP;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _ScreenPosition_89ebecf77a272888b9359bce6bdf4652_Out_0_Vector4 = IN.ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_5ec591f2557e3c85b95fa18da15bcddd_Out_0_Float = _DepthFadeDistance;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _SceneDepth_80f7dde02deb088d8e6f3d97f77b0c3a_Out_1_Float;
            Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_80f7dde02deb088d8e6f3d97f77b0c3a_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _CustomDepthBlendCustomFunction_32d597c3c1865380aaa04c9f73f69bc1_DepthBlendResult_0_Float;
            CustomDepthBlend_float(_ScreenPosition_89ebecf77a272888b9359bce6bdf4652_Out_0_Vector4, _Property_5ec591f2557e3c85b95fa18da15bcddd_Out_0_Float, _SceneDepth_80f7dde02deb088d8e6f3d97f77b0c3a_Out_1_Float, _CustomDepthBlendCustomFunction_32d597c3c1865380aaa04c9f73f69bc1_DepthBlendResult_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_887405ed71f94c819ad71e0a3409ba95_Out_1_Float;
            Unity_OneMinus_float(_CustomDepthBlendCustomFunction_32d597c3c1865380aaa04c9f73f69bc1_DepthBlendResult_0_Float, _OneMinus_887405ed71f94c819ad71e0a3409ba95_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_4d9d1e11cc41eb868ee134f869c4316b_Out_3_Float;
            Unity_Branch_float(_Property_5f0a20ff17356f8cadfcf223e7af548e_Out_0_Boolean, _OneMinus_887405ed71f94c819ad71e0a3409ba95_Out_1_Float, _CustomDepthBlendCustomFunction_32d597c3c1865380aaa04c9f73f69bc1_DepthBlendResult_0_Float, _Branch_4d9d1e11cc41eb868ee134f869c4316b_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Clamp_a32675cd378e018c96f269eed871956c_Out_3_Float;
            Unity_Clamp_float(_Branch_4d9d1e11cc41eb868ee134f869c4316b_Out_3_Float, 0, 1, _Clamp_a32675cd378e018c96f269eed871956c_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_3838b3977690b6868bb868acc7c47677_Out_0_Float = _DepthFadeExp;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Power_2a1fc257fcfebc8cacb955e0fdc516c2_Out_2_Float;
            Unity_Power_float(_Clamp_a32675cd378e018c96f269eed871956c_Out_3_Float, _Property_3838b3977690b6868bb868acc7c47677_Out_0_Float, _Power_2a1fc257fcfebc8cacb955e0fdc516c2_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Clamp_e57af19f5585728ba422eef8a9b4788a_Out_3_Float;
            Unity_Clamp_float(_Power_2a1fc257fcfebc8cacb955e0fdc516c2_Out_2_Float, 0, 1, _Clamp_e57af19f5585728ba422eef8a9b4788a_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Maximum_3985635732a0188ea46245a0508102e5_Out_2_Float;
            Unity_Maximum_float(_RimMaskEnabled_d2078e517db04a839a3cfe047c152baf_Out_0_Float, _Clamp_e57af19f5585728ba422eef8a9b4788a_Out_3_Float, _Maximum_3985635732a0188ea46245a0508102e5_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_9cd05943f8b7fd8ca8effe2ddc6f0672_Out_2_Float;
            Unity_Multiply_float_float(_RimMaskEnabled_d2078e517db04a839a3cfe047c152baf_Out_0_Float, _Clamp_e57af19f5585728ba422eef8a9b4788a_Out_3_Float, _Multiply_9cd05943f8b7fd8ca8effe2ddc6f0672_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_e5f32dc4714baa88be4a5244d8b426e1_Out_3_Float;
            Unity_Branch_float(_Property_4a68bf77621983808a2a074c034183e3_Out_0_Boolean, _Maximum_3985635732a0188ea46245a0508102e5_Out_2_Float, _Multiply_9cd05943f8b7fd8ca8effe2ddc6f0672_Out_2_Float, _Branch_e5f32dc4714baa88be4a5244d8b426e1_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Clamp_3507197ce9831087a36b865141aeef9e_Out_3_Float;
            Unity_Clamp_float(_Branch_e5f32dc4714baa88be4a5244d8b426e1_Out_3_Float, 0, 1, _Clamp_3507197ce9831087a36b865141aeef9e_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_a221b65bfdca8a8391287bfd583c0ece_Out_2_Float;
            Unity_Multiply_float_float(_Clamp_3507197ce9831087a36b865141aeef9e_Out_3_Float, 1, _Multiply_a221b65bfdca8a8391287bfd583c0ece_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_01d14a4195f6ce8e821b6a9a072a0913_Out_0_Boolean = _DISSOLVENOISEFLIP;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_5f177ae93748e08a9696d751133f1d27_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_DissolveNoise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_991126dc73251a83965adfa292a06cb9_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_5f177ae93748e08a9696d751133f1d27_Out_0_Texture2D.tex, _Property_5f177ae93748e08a9696d751133f1d27_Out_0_Texture2D.samplerstate, _Property_5f177ae93748e08a9696d751133f1d27_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_991126dc73251a83965adfa292a06cb9_R_4_Float = _SampleTexture2D_991126dc73251a83965adfa292a06cb9_RGBA_0_Vector4.r;
            float _SampleTexture2D_991126dc73251a83965adfa292a06cb9_G_5_Float = _SampleTexture2D_991126dc73251a83965adfa292a06cb9_RGBA_0_Vector4.g;
            float _SampleTexture2D_991126dc73251a83965adfa292a06cb9_B_6_Float = _SampleTexture2D_991126dc73251a83965adfa292a06cb9_RGBA_0_Vector4.b;
            float _SampleTexture2D_991126dc73251a83965adfa292a06cb9_A_7_Float = _SampleTexture2D_991126dc73251a83965adfa292a06cb9_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_a64e5a3cf90b898085407a475eb4a359_Out_1_Float;
            Unity_OneMinus_float(_SampleTexture2D_991126dc73251a83965adfa292a06cb9_R_4_Float, _OneMinus_a64e5a3cf90b898085407a475eb4a359_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Branch_0ed62f3465902d808b63f98c291205e6_Out_3_Float;
            Unity_Branch_float(_Property_01d14a4195f6ce8e821b6a9a072a0913_Out_0_Boolean, _OneMinus_a64e5a3cf90b898085407a475eb4a359_Out_1_Float, _SampleTexture2D_991126dc73251a83965adfa292a06cb9_R_4_Float, _Branch_0ed62f3465902d808b63f98c291205e6_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_741f54a3fd38048289b87b7ffde6e97a_Out_0_Float = _DissolveNoiseExp;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Power_be247ee57ea3778f86c6c569cc8851ea_Out_2_Float;
            Unity_Power_float(_Branch_0ed62f3465902d808b63f98c291205e6_Out_3_Float, _Property_741f54a3fd38048289b87b7ffde6e97a_Out_0_Float, _Power_be247ee57ea3778f86c6c569cc8851ea_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_a406e11ce4c66e8397d0f890e2f4dbc7_Out_1_Float;
            Unity_OneMinus_float(_Power_be247ee57ea3778f86c6c569cc8851ea_Out_2_Float, _OneMinus_a406e11ce4c66e8397d0f890e2f4dbc7_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_3c2c3bfea069008f87aba7588b86a2a7_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_8d0c56a0ba9c068293644c7dc33bc617_R_1_Float = _UV_3c2c3bfea069008f87aba7588b86a2a7_Out_0_Vector4[0];
            float _Split_8d0c56a0ba9c068293644c7dc33bc617_G_2_Float = _UV_3c2c3bfea069008f87aba7588b86a2a7_Out_0_Vector4[1];
            float _Split_8d0c56a0ba9c068293644c7dc33bc617_B_3_Float = _UV_3c2c3bfea069008f87aba7588b86a2a7_Out_0_Vector4[2];
            float _Split_8d0c56a0ba9c068293644c7dc33bc617_A_4_Float = _UV_3c2c3bfea069008f87aba7588b86a2a7_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_6833f87ed8ea1082a426f346328e6305_Out_0_Float = _DissolveNoiseExpReversed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Vector2_0afdacb5a3ee428689ccf5962f0514a3_Out_0_Vector2 = float2(1, _Property_6833f87ed8ea1082a426f346328e6305_Out_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Remap_4923a78877390a8db2d9e6de5dfe4d30_Out_3_Float;
            Unity_Remap_float(_Split_8d0c56a0ba9c068293644c7dc33bc617_A_4_Float, float2 (0, 1), _Vector2_0afdacb5a3ee428689ccf5962f0514a3_Out_0_Vector2, _Remap_4923a78877390a8db2d9e6de5dfe4d30_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Power_b30592a275a2b38c9bb9c9c17034992d_Out_2_Float;
            Unity_Power_float(_OneMinus_a406e11ce4c66e8397d0f890e2f4dbc7_Out_1_Float, _Remap_4923a78877390a8db2d9e6de5dfe4d30_Out_3_Float, _Power_b30592a275a2b38c9bb9c9c17034992d_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_f6e0ec371be2ab8d9847221d372ad81a_Out_1_Float;
            Unity_OneMinus_float(_Power_b30592a275a2b38c9bb9c9c17034992d_Out_2_Float, _OneMinus_f6e0ec371be2ab8d9847221d372ad81a_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Clamp_3b80820b18c61589a3f89a8a05532d3c_Out_3_Float;
            Unity_Clamp_float(_OneMinus_f6e0ec371be2ab8d9847221d372ad81a_Out_1_Float, 0, 1, _Clamp_3b80820b18c61589a3f89a8a05532d3c_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_d5afaeee116cdc8ea31bc7d6f9110060_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_3e14a725f9d34483bcdb8b58af09cac9_R_1_Float = _UV_d5afaeee116cdc8ea31bc7d6f9110060_Out_0_Vector4[0];
            float _Split_3e14a725f9d34483bcdb8b58af09cac9_G_2_Float = _UV_d5afaeee116cdc8ea31bc7d6f9110060_Out_0_Vector4[1];
            float _Split_3e14a725f9d34483bcdb8b58af09cac9_B_3_Float = _UV_d5afaeee116cdc8ea31bc7d6f9110060_Out_0_Vector4[2];
            float _Split_3e14a725f9d34483bcdb8b58af09cac9_A_4_Float = _UV_d5afaeee116cdc8ea31bc7d6f9110060_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Remap_5dd504e4d971498e884c7f862a55a8d3_Out_3_Float;
            Unity_Remap_float(_Split_3e14a725f9d34483bcdb8b58af09cac9_A_4_Float, float2 (0, 1), float2 (-1, 1), _Remap_5dd504e4d971498e884c7f862a55a8d3_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Add_892ae98f520eb4839d924f54cd09857e_Out_2_Float;
            Unity_Add_float(_Clamp_3b80820b18c61589a3f89a8a05532d3c_Out_3_Float, _Remap_5dd504e4d971498e884c7f862a55a8d3_Out_3_Float, _Add_892ae98f520eb4839d924f54cd09857e_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Clamp_de69afddc78a318db7553a71700034ec_Out_3_Float;
            Unity_Clamp_float(_Add_892ae98f520eb4839d924f54cd09857e_Out_2_Float, 0, 1, _Clamp_de69afddc78a318db7553a71700034ec_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_bd9814d95d455580a351c10a9ef25b2f_Out_1_Float;
            Unity_OneMinus_float(_Clamp_de69afddc78a318db7553a71700034ec_Out_3_Float, _OneMinus_bd9814d95d455580a351c10a9ef25b2f_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_d47283792bf49f86a65df37eaf93f90c_Out_0_Float = _RampAffectedByDynamics;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Lerp_2ec7807147c9d28e9823dbe195609df1_Out_3_Float;
            Unity_Lerp_float(_Multiply_a221b65bfdca8a8391287bfd583c0ece_Out_2_Float, _OneMinus_bd9814d95d455580a351c10a9ef25b2f_Out_1_Float, _Property_d47283792bf49f86a65df37eaf93f90c_Out_0_Float, _Lerp_2ec7807147c9d28e9823dbe195609df1_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_f79c773c001cc489ad6e10aaba6b57bc_Out_2_Float;
            Unity_Multiply_float_float(_Property_96b142e451433a8294ab966060a47dea_Out_0_Float, _Lerp_2ec7807147c9d28e9823dbe195609df1_Out_3_Float, _Multiply_f79c773c001cc489ad6e10aaba6b57bc_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_e0e2894d9be90480b38229679a8c95c5_Out_0_Float = _RampOffsetExp;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Power_9f025adf91439684927f78d23193dd96_Out_2_Float;
            Unity_Power_float(_Multiply_f79c773c001cc489ad6e10aaba6b57bc_Out_2_Float, _Property_e0e2894d9be90480b38229679a8c95c5_Out_0_Float, _Power_9f025adf91439684927f78d23193dd96_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Clamp_f461d8fc0ecd4d82b8df9cbef572ac10_Out_3_Float;
            Unity_Clamp_float(_Power_9f025adf91439684927f78d23193dd96_Out_2_Float, 0, 1, _Clamp_f461d8fc0ecd4d82b8df9cbef572ac10_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Vector2_80e7b2565e843282ac464b6f5e29a77e_Out_0_Vector2 = float2(_Clamp_f461d8fc0ecd4d82b8df9cbef572ac10_Out_3_Float, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_cd62eec958ad0c85bc1a4ad68e3fa503_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_76b6d58427bcf781b8ca1b06fc7eda7e_Out_0_Texture2D.tex, _Property_76b6d58427bcf781b8ca1b06fc7eda7e_Out_0_Texture2D.samplerstate, _Property_76b6d58427bcf781b8ca1b06fc7eda7e_Out_0_Texture2D.GetTransformedUV(_Vector2_80e7b2565e843282ac464b6f5e29a77e_Out_0_Vector2) );
            float _SampleTexture2D_cd62eec958ad0c85bc1a4ad68e3fa503_R_4_Float = _SampleTexture2D_cd62eec958ad0c85bc1a4ad68e3fa503_RGBA_0_Vector4.r;
            float _SampleTexture2D_cd62eec958ad0c85bc1a4ad68e3fa503_G_5_Float = _SampleTexture2D_cd62eec958ad0c85bc1a4ad68e3fa503_RGBA_0_Vector4.g;
            float _SampleTexture2D_cd62eec958ad0c85bc1a4ad68e3fa503_B_6_Float = _SampleTexture2D_cd62eec958ad0c85bc1a4ad68e3fa503_RGBA_0_Vector4.b;
            float _SampleTexture2D_cd62eec958ad0c85bc1a4ad68e3fa503_A_7_Float = _SampleTexture2D_cd62eec958ad0c85bc1a4ad68e3fa503_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_ae269219209a0183b9091214d8b79c96_Out_0_Vector4 = _RampColorTint;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Multiply_8ae9b2f891abf68b9c88fc077a66e36a_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_cd62eec958ad0c85bc1a4ad68e3fa503_RGBA_0_Vector4, _Property_ae269219209a0183b9091214d8b79c96_Out_0_Vector4, _Multiply_8ae9b2f891abf68b9c88fc077a66e36a_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Multiply_dced4c21aba46e8eb8c17bc38b3f3b74_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_8ae9b2f891abf68b9c88fc077a66e36a_Out_2_Vector4, IN.VertexColor, _Multiply_dced4c21aba46e8eb8c17bc38b3f3b74_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Branch_c5618914160f0d81bfdeae8b709c14ba_Out_3_Vector4;
            Unity_Branch_float4(_Property_42a6ecbde5e97d85a71b4c295d461959_Out_0_Boolean, _Multiply_dced4c21aba46e8eb8c17bc38b3f3b74_Out_2_Vector4, _Multiply_8ae9b2f891abf68b9c88fc077a66e36a_Out_2_Vector4, _Branch_c5618914160f0d81bfdeae8b709c14ba_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_5aa4b3a62f496087ae058f4de0155145_Out_0_Vector4 = _FinalColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Multiply_83663112754191859c1154901cbcaaca_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_5aa4b3a62f496087ae058f4de0155145_Out_0_Vector4, IN.VertexColor, _Multiply_83663112754191859c1154901cbcaaca_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(_RAMPENABLED_ON)
            float4 _RampEnabled_5ba9272fb7ec35828c0f7e9aff184ba5_Out_0_Vector4 = _Branch_c5618914160f0d81bfdeae8b709c14ba_Out_3_Vector4;
            #else
            float4 _RampEnabled_5ba9272fb7ec35828c0f7e9aff184ba5_Out_0_Vector4 = _Multiply_83663112754191859c1154901cbcaaca_Out_2_Vector4;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Multiply_8ff33379dee45383a23247df503f75da_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Multiply_62c0772ca26a6b8bba0c12deaf0e61ac_Out_2_Float.xxxx), _RampEnabled_5ba9272fb7ec35828c0f7e9aff184ba5_Out_0_Vector4, _Multiply_8ff33379dee45383a23247df503f75da_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_be34e289c4033187b12326dc40db0039_Out_0_Float = _FinalOpacityPower;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_c660e414753e3987b8175c3f4726dca3_Out_2_Float;
            Unity_Multiply_float_float(_Property_be34e289c4033187b12326dc40db0039_Out_0_Float, _Multiply_a221b65bfdca8a8391287bfd583c0ece_Out_2_Float, _Multiply_c660e414753e3987b8175c3f4726dca3_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Clamp_17872f5164ab7c8393009dd450e10e83_Out_3_Float;
            Unity_Clamp_float(_Multiply_c660e414753e3987b8175c3f4726dca3_Out_2_Float, 0, 1, _Clamp_17872f5164ab7c8393009dd450e10e83_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_749144adb06c188087794f44c5b231a1_Out_2_Float;
            Unity_Subtract_float(_Clamp_17872f5164ab7c8393009dd450e10e83_Out_3_Float, _Clamp_de69afddc78a318db7553a71700034ec_Out_3_Float, _Subtract_749144adb06c188087794f44c5b231a1_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_11e0212f4d3f1289b6708e0dda10c866_Out_1_Float;
            Unity_OneMinus_float(_Subtract_749144adb06c188087794f44c5b231a1_Out_2_Float, _OneMinus_11e0212f4d3f1289b6708e0dda10c866_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_7f0ab829aad6d48db3ed761c0e6919a1_Out_0_Float = _FinalOpacityExp;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Power_635d3fa877ed1185b38c1e1195dd50c4_Out_2_Float;
            Unity_Power_float(_OneMinus_11e0212f4d3f1289b6708e0dda10c866_Out_1_Float, _Property_7f0ab829aad6d48db3ed761c0e6919a1_Out_0_Float, _Power_635d3fa877ed1185b38c1e1195dd50c4_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_088d19cbd3554683b887d41dc366497d_Out_1_Float;
            Unity_OneMinus_float(_Power_635d3fa877ed1185b38c1e1195dd50c4_Out_2_Float, _OneMinus_088d19cbd3554683b887d41dc366497d_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Clamp_e6430aa36d5f338d8513a1bc299c6d6f_Out_3_Float;
            Unity_Clamp_float(_OneMinus_088d19cbd3554683b887d41dc366497d_Out_1_Float, 0, 1, _Clamp_e6430aa36d5f338d8513a1bc299c6d6f_Out_3_Float);
            #endif
            surface.BaseColor = (_Multiply_8ff33379dee45383a23247df503f75da_Out_2_Vector4.xyz);
            surface.Alpha = _Clamp_e6430aa36d5f338d8513a1bc299c6d6f_Out_3_Float;
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
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.AbsoluteWorldSpacePosition =                 GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 =                                        input.uv0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv1 =                                        input.uv1;
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
        
            
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float3 unnormalizedNormalWS = input.normalWS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        #endif
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        #endif
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpacePosition = input.positionWS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #endif
        
        
            #if UNITY_UV_STARTS_AT_TOP
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #else
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.VertexColor = input.color;
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
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