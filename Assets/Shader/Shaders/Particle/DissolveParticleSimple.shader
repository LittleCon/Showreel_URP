Shader "FC/Particle/DissolveParticleSimple"
{
    Properties
    {
        _FinalColor("Final Color", Color) = (1, 1, 1, 1)
        _FinalPower("Final Power", Range(0, 60)) = 4
        _FinalOpacityPower("Final Opacity Power", Float) = 1
        [NoScaleOffset]_Ramp("Ramp", 2D) = "white" {}
        _RampColorTint("Ramp Color Tint", Color) = (1, 1, 1, 1)
        [ToggleUI]_RAMPAFFECTEDBYVERTEXCOLOR("Ramp Affected By Vertex Color", Float) = 0
        _RampAffectedByDynamics("Ramp Affected By Dynamics", Range(0, 1)) = 1
        _RampOffsetExp("Ramp Offset Exp", Range(0.2, 8)) = 1
        [NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
        _MainTexChannels("MainTex Channels", Vector) = (1, 0, 0, 0)
        _MainTexRotation("MainTex Rotation", Range(0, 1)) = 0
        _FlipbookRows("Flipbook Rows", Float) = 1
        _FlipbookColums("Flipbook Colums", Float) = 1
        [NoScaleOffset]_DissolveTexture("Dissolve Texture", 2D) = "white" {}
        [ToggleUI]_DISSOLVETEXTUREFLIP("Dissolve Texture Flip", Float) = 0
        _DissolveTextureScale("Dissolve Texture Scale", Float) = 1
        _DissolveExp("Dissolve Exp", Float) = 2
        _DissolveExpReversed("Dissolve Exp Reversed", Float) = 2
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
        [Toggle]_RAMPENABLED("Ramp Enabled", Float) = 0
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
        #pragma shader_feature_local _ _RAMPENABLED_ON
        
        #if defined(_RAMPENABLED_ON)
            #define KEYWORD_PERMUTATION_0
        #else
            #define KEYWORD_PERMUTATION_1
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_COLOR
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_NORMAL_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
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
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 color : COLOR;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 color;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 VertexColor;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord1 : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 color : INTERP2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 positionWS : INTERP3;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 normalWS : INTERP4;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
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
        float4 _FinalColor;
        float _FinalPower;
        float _FinalOpacityPower;
        float4 _Ramp_TexelSize;
        float4 _RampColorTint;
        float _RAMPAFFECTEDBYVERTEXCOLOR;
        float _RampAffectedByDynamics;
        float _RampOffsetExp;
        float4 _MainTex_TexelSize;
        float4 _MainTexChannels;
        float _MainTexRotation;
        float _FlipbookRows;
        float _FlipbookColums;
        float4 _DissolveTexture_TexelSize;
        float _DISSOLVETEXTUREFLIP;
        float _DissolveTextureScale;
        float _DissolveExp;
        float _DissolveExpReversed;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Ramp);
        SAMPLER(sampler_Ramp);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
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
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_Equal_float(float A, float B, out float Out)
        {
            Out = A == B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Fraction_float(float In, out float Out)
        {
            Out = frac(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Floor_float2(float2 In, out float2 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Rotate_Radians_float(float2 UV, float2 Center, float Rotation, out float2 Out)
        {
            //rotation matrix
            UV -= Center;
            float s = sin(Rotation);
            float c = cos(Rotation);
        
            //center rotation matrix
            float2x2 rMatrix = float2x2(c, -s, s, c);
            rMatrix *= 0.5;
            rMatrix += 0.5;
            rMatrix = rMatrix*2 - 1;
        
            //multiply the UVs by the rotation matrix
            UV.xy = mul(UV.xy, rMatrix);
            UV += Center;
        
            Out = UV;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
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
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_83fd512bebec0e8f8185cfdbb4d78d6f_Out_0_Float = _FinalPower;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Multiply_c864565a0d6acd8db22c910cae087c72_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Property_83fd512bebec0e8f8185cfdbb4d78d6f_Out_0_Float.xxxx), IN.VertexColor, _Multiply_c864565a0d6acd8db22c910cae087c72_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_a44576603cc4af889435fbff47298234_Out_0_Boolean = _RAMPAFFECTEDBYVERTEXCOLOR;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_962f2cab3fdfb782aca911c81739e744_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Ramp);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_7d9a9e78a919fa839ce7cde21da4613b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _UV_d02667c58f91438397f594a1d0c5fc2f_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Split_f94d8c7f2e53b785a0c643d889876086_R_1_Float = _UV_d02667c58f91438397f594a1d0c5fc2f_Out_0_Vector4[0];
            float _Split_f94d8c7f2e53b785a0c643d889876086_G_2_Float = _UV_d02667c58f91438397f594a1d0c5fc2f_Out_0_Vector4[1];
            float _Split_f94d8c7f2e53b785a0c643d889876086_B_3_Float = _UV_d02667c58f91438397f594a1d0c5fc2f_Out_0_Vector4[2];
            float _Split_f94d8c7f2e53b785a0c643d889876086_A_4_Float = _UV_d02667c58f91438397f594a1d0c5fc2f_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Vector2_e3b84df7d5ac628797acab0e9c629ebe_Out_0_Vector2 = float2(_Split_f94d8c7f2e53b785a0c643d889876086_R_1_Float, _Split_f94d8c7f2e53b785a0c643d889876086_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_2bb52aa54165f2889ccd401db32de974_Out_0_Float = _FlipbookColums;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_36075070ce45898a90012ee2f2186815_Out_0_Float = _FlipbookRows;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Vector2_773c933456558080be5c2200b1eb9cab_Out_0_Vector2 = float2(_Property_2bb52aa54165f2889ccd401db32de974_Out_0_Float, _Property_36075070ce45898a90012ee2f2186815_Out_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Divide_743e7bfe044eba8983da89b96cfff390_Out_2_Vector2;
            Unity_Divide_float2(_Vector2_e3b84df7d5ac628797acab0e9c629ebe_Out_0_Vector2, _Vector2_773c933456558080be5c2200b1eb9cab_Out_0_Vector2, _Divide_743e7bfe044eba8983da89b96cfff390_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Multiply_61afecff9318d684a68d5775edff403f_Out_2_Float;
            Unity_Multiply_float_float(_Property_2bb52aa54165f2889ccd401db32de974_Out_0_Float, _Property_36075070ce45898a90012ee2f2186815_Out_0_Float, _Multiply_61afecff9318d684a68d5775edff403f_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Vector2_78bf18e3f51b878383a5f888dabdf7d3_Out_0_Vector2 = float2(_Multiply_61afecff9318d684a68d5775edff403f_Out_2_Float, _Property_36075070ce45898a90012ee2f2186815_Out_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _UV_399c6dd843bb37849b5da1a917d30331_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Split_128f13bbca75ac80ab89b3779a68f931_R_1_Float = _UV_399c6dd843bb37849b5da1a917d30331_Out_0_Vector4[0];
            float _Split_128f13bbca75ac80ab89b3779a68f931_G_2_Float = _UV_399c6dd843bb37849b5da1a917d30331_Out_0_Vector4[1];
            float _Split_128f13bbca75ac80ab89b3779a68f931_B_3_Float = _UV_399c6dd843bb37849b5da1a917d30331_Out_0_Vector4[2];
            float _Split_128f13bbca75ac80ab89b3779a68f931_A_4_Float = _UV_399c6dd843bb37849b5da1a917d30331_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Float_1b591d1a1032ca8bbc6a694bc977712f_Out_0_Float = 1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Comparison_8437901419f72684adbf177d4dfb32f9_Out_2_Boolean;
            Unity_Comparison_Equal_float(_Multiply_61afecff9318d684a68d5775edff403f_Out_2_Float, _Float_1b591d1a1032ca8bbc6a694bc977712f_Out_0_Float, _Comparison_8437901419f72684adbf177d4dfb32f9_Out_2_Boolean);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Branch_c8df1bd6c346008fba757e09d5eaa7c1_Out_3_Float;
            Unity_Branch_float(_Comparison_8437901419f72684adbf177d4dfb32f9_Out_2_Boolean, 0, 1, _Branch_c8df1bd6c346008fba757e09d5eaa7c1_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Subtract_04aa625c43514280ae2b72698fbb0bfe_Out_2_Float;
            Unity_Subtract_float(_Multiply_61afecff9318d684a68d5775edff403f_Out_2_Float, _Branch_c8df1bd6c346008fba757e09d5eaa7c1_Out_3_Float, _Subtract_04aa625c43514280ae2b72698fbb0bfe_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Clamp_5a584fad72b8b78e8c49a879e9a29ac5_Out_3_Float;
            Unity_Clamp_float(_Split_128f13bbca75ac80ab89b3779a68f931_G_2_Float, 0.0001, _Subtract_04aa625c43514280ae2b72698fbb0bfe_Out_2_Float, _Clamp_5a584fad72b8b78e8c49a879e9a29ac5_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Divide_60ec8f4163180389aa2d0436ded77f52_Out_2_Float;
            Unity_Divide_float(_Clamp_5a584fad72b8b78e8c49a879e9a29ac5_Out_3_Float, _Multiply_61afecff9318d684a68d5775edff403f_Out_2_Float, _Divide_60ec8f4163180389aa2d0436ded77f52_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Fraction_e4cddc4e0451358b832284777bc195bb_Out_1_Float;
            Unity_Fraction_float(_Divide_60ec8f4163180389aa2d0436ded77f52_Out_2_Float, _Fraction_e4cddc4e0451358b832284777bc195bb_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _OneMinus_35e8ac360f53508980e76a96c95925d1_Out_1_Float;
            Unity_OneMinus_float(_Fraction_e4cddc4e0451358b832284777bc195bb_Out_1_Float, _OneMinus_35e8ac360f53508980e76a96c95925d1_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Vector2_c73017264fde988ba93ba1e9b6604a4f_Out_0_Vector2 = float2(_Fraction_e4cddc4e0451358b832284777bc195bb_Out_1_Float, _OneMinus_35e8ac360f53508980e76a96c95925d1_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Multiply_d41deb529a073089b4a9f483b125aa99_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_78bf18e3f51b878383a5f888dabdf7d3_Out_0_Vector2, _Vector2_c73017264fde988ba93ba1e9b6604a4f_Out_0_Vector2, _Multiply_d41deb529a073089b4a9f483b125aa99_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Floor_f3c81e70e88822849d12ce5734a58b36_Out_1_Vector2;
            Unity_Floor_float2(_Multiply_d41deb529a073089b4a9f483b125aa99_Out_2_Vector2, _Floor_f3c81e70e88822849d12ce5734a58b36_Out_1_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Divide_e8685989bbb790899b972d6952300328_Out_2_Vector2;
            Unity_Divide_float2(_Floor_f3c81e70e88822849d12ce5734a58b36_Out_1_Vector2, _Vector2_773c933456558080be5c2200b1eb9cab_Out_0_Vector2, _Divide_e8685989bbb790899b972d6952300328_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Add_eb15f831d610dc87b5962cae77f1460c_Out_2_Vector2;
            Unity_Add_float2(_Divide_743e7bfe044eba8983da89b96cfff390_Out_2_Vector2, _Divide_e8685989bbb790899b972d6952300328_Out_2_Vector2, _Add_eb15f831d610dc87b5962cae77f1460c_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Vector2_7e9af72080f1db8ca613897b6fbb12e9_Out_0_Vector2 = float2(0.5, 0.5);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Divide_4ef726256124128fa150c5ee40dc4946_Out_2_Vector2;
            Unity_Divide_float2(_Vector2_7e9af72080f1db8ca613897b6fbb12e9_Out_0_Vector2, _Vector2_773c933456558080be5c2200b1eb9cab_Out_0_Vector2, _Divide_4ef726256124128fa150c5ee40dc4946_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Add_7c6a41010b8c2a8b84a05e5112a269bc_Out_2_Vector2;
            Unity_Add_float2(_Divide_4ef726256124128fa150c5ee40dc4946_Out_2_Vector2, _Divide_e8685989bbb790899b972d6952300328_Out_2_Vector2, _Add_7c6a41010b8c2a8b84a05e5112a269bc_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_c1ebcc8a6d227f86a369d51862c34cd8_Out_0_Float = _MainTexRotation;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Remap_524c6fe4e510f181be5db8195f527fa6_Out_3_Float;
            Unity_Remap_float(_Property_c1ebcc8a6d227f86a369d51862c34cd8_Out_0_Float, float2 (0, 1), float2 (0, 6.28318), _Remap_524c6fe4e510f181be5db8195f527fa6_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Rotate_64d6dba85d09e98f82c0f42c1020ce8e_Out_3_Vector2;
            Unity_Rotate_Radians_float(_Add_eb15f831d610dc87b5962cae77f1460c_Out_2_Vector2, _Add_7c6a41010b8c2a8b84a05e5112a269bc_Out_2_Vector2, _Remap_524c6fe4e510f181be5db8195f527fa6_Out_3_Float, _Rotate_64d6dba85d09e98f82c0f42c1020ce8e_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _SampleTexture2D_741ddc9b542af48caf60e95bf5f540a5_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_7d9a9e78a919fa839ce7cde21da4613b_Out_0_Texture2D.tex, _Property_7d9a9e78a919fa839ce7cde21da4613b_Out_0_Texture2D.samplerstate, _Property_7d9a9e78a919fa839ce7cde21da4613b_Out_0_Texture2D.GetTransformedUV(_Rotate_64d6dba85d09e98f82c0f42c1020ce8e_Out_3_Vector2) );
            float _SampleTexture2D_741ddc9b542af48caf60e95bf5f540a5_R_4_Float = _SampleTexture2D_741ddc9b542af48caf60e95bf5f540a5_RGBA_0_Vector4.r;
            float _SampleTexture2D_741ddc9b542af48caf60e95bf5f540a5_G_5_Float = _SampleTexture2D_741ddc9b542af48caf60e95bf5f540a5_RGBA_0_Vector4.g;
            float _SampleTexture2D_741ddc9b542af48caf60e95bf5f540a5_B_6_Float = _SampleTexture2D_741ddc9b542af48caf60e95bf5f540a5_RGBA_0_Vector4.b;
            float _SampleTexture2D_741ddc9b542af48caf60e95bf5f540a5_A_7_Float = _SampleTexture2D_741ddc9b542af48caf60e95bf5f540a5_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Property_de44b4ea2d1d9c818e53a858b36a5134_Out_0_Vector4 = _MainTexChannels;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Multiply_be61e5330ea2aa8bace83cfc083bfe36_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_741ddc9b542af48caf60e95bf5f540a5_RGBA_0_Vector4, _Property_de44b4ea2d1d9c818e53a858b36a5134_Out_0_Vector4, _Multiply_be61e5330ea2aa8bace83cfc083bfe36_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Split_d562a8703d20958ab3a888b08845bee0_R_1_Float = _Multiply_be61e5330ea2aa8bace83cfc083bfe36_Out_2_Vector4[0];
            float _Split_d562a8703d20958ab3a888b08845bee0_G_2_Float = _Multiply_be61e5330ea2aa8bace83cfc083bfe36_Out_2_Vector4[1];
            float _Split_d562a8703d20958ab3a888b08845bee0_B_3_Float = _Multiply_be61e5330ea2aa8bace83cfc083bfe36_Out_2_Vector4[2];
            float _Split_d562a8703d20958ab3a888b08845bee0_A_4_Float = _Multiply_be61e5330ea2aa8bace83cfc083bfe36_Out_2_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Add_dcf5d189fb22f3808723cbb15ca1ba09_Out_2_Float;
            Unity_Add_float(_Split_d562a8703d20958ab3a888b08845bee0_R_1_Float, _Split_d562a8703d20958ab3a888b08845bee0_G_2_Float, _Add_dcf5d189fb22f3808723cbb15ca1ba09_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Add_55549db98493e182ae1a5ce029ed3243_Out_2_Float;
            Unity_Add_float(_Add_dcf5d189fb22f3808723cbb15ca1ba09_Out_2_Float, _Split_d562a8703d20958ab3a888b08845bee0_B_3_Float, _Add_55549db98493e182ae1a5ce029ed3243_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Add_60d93a4844688787883bcffc6d891585_Out_2_Float;
            Unity_Add_float(_Add_55549db98493e182ae1a5ce029ed3243_Out_2_Float, _Split_d562a8703d20958ab3a888b08845bee0_A_4_Float, _Add_60d93a4844688787883bcffc6d891585_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Clamp_381bb518cf88358e8d16440bff90c01f_Out_3_Float;
            Unity_Clamp_float(_Add_60d93a4844688787883bcffc6d891585_Out_2_Float, 0, 1, _Clamp_381bb518cf88358e8d16440bff90c01f_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_b66daa9f4ba02e8395d00445709d4877_Out_0_Boolean = _DISSOLVETEXTUREFLIP;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_0b80f0a28fcc2282b3be7e700173e90b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_DissolveTexture);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _UV_12485f7ac75a0388b0b3b3031d3840c2_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Split_f21032fde0f5c98697dc9c915b62fb54_R_1_Float = _UV_12485f7ac75a0388b0b3b3031d3840c2_Out_0_Vector4[0];
            float _Split_f21032fde0f5c98697dc9c915b62fb54_G_2_Float = _UV_12485f7ac75a0388b0b3b3031d3840c2_Out_0_Vector4[1];
            float _Split_f21032fde0f5c98697dc9c915b62fb54_B_3_Float = _UV_12485f7ac75a0388b0b3b3031d3840c2_Out_0_Vector4[2];
            float _Split_f21032fde0f5c98697dc9c915b62fb54_A_4_Float = _UV_12485f7ac75a0388b0b3b3031d3840c2_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Vector2_ac0929df58d77b86904cd2c92eca0837_Out_0_Vector2 = float2(_Split_f21032fde0f5c98697dc9c915b62fb54_R_1_Float, _Split_f21032fde0f5c98697dc9c915b62fb54_G_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_57332bd49c26848ca640cb13a829fb66_Out_0_Float = _DissolveTextureScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _UV_a72b77cba51e318bbd5ec1fbc9c0d197_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Split_bb540a7805d2038aba6830aac4e0a913_R_1_Float = _UV_a72b77cba51e318bbd5ec1fbc9c0d197_Out_0_Vector4[0];
            float _Split_bb540a7805d2038aba6830aac4e0a913_G_2_Float = _UV_a72b77cba51e318bbd5ec1fbc9c0d197_Out_0_Vector4[1];
            float _Split_bb540a7805d2038aba6830aac4e0a913_B_3_Float = _UV_a72b77cba51e318bbd5ec1fbc9c0d197_Out_0_Vector4[2];
            float _Split_bb540a7805d2038aba6830aac4e0a913_A_4_Float = _UV_a72b77cba51e318bbd5ec1fbc9c0d197_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Multiply_123b902121a4268b93d540f618b68c7a_Out_2_Float;
            Unity_Multiply_float_float(_Property_57332bd49c26848ca640cb13a829fb66_Out_0_Float, _Split_bb540a7805d2038aba6830aac4e0a913_A_4_Float, _Multiply_123b902121a4268b93d540f618b68c7a_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Multiply_bb99dd36bfb6868a8d79ef0a76d0b139_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Vector2_ac0929df58d77b86904cd2c92eca0837_Out_0_Vector2, (_Multiply_123b902121a4268b93d540f618b68c7a_Out_2_Float.xx), _Multiply_bb99dd36bfb6868a8d79ef0a76d0b139_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Add_4fd3719a9562628fb1f2d298573c0a23_Out_2_Vector2;
            Unity_Add_float2(_Multiply_bb99dd36bfb6868a8d79ef0a76d0b139_Out_2_Vector2, (_Split_bb540a7805d2038aba6830aac4e0a913_B_3_Float.xx), _Add_4fd3719a9562628fb1f2d298573c0a23_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _SampleTexture2D_994d31b6eb404285ace3132ecf65d17c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0b80f0a28fcc2282b3be7e700173e90b_Out_0_Texture2D.tex, _Property_0b80f0a28fcc2282b3be7e700173e90b_Out_0_Texture2D.samplerstate, _Property_0b80f0a28fcc2282b3be7e700173e90b_Out_0_Texture2D.GetTransformedUV(_Add_4fd3719a9562628fb1f2d298573c0a23_Out_2_Vector2) );
            float _SampleTexture2D_994d31b6eb404285ace3132ecf65d17c_R_4_Float = _SampleTexture2D_994d31b6eb404285ace3132ecf65d17c_RGBA_0_Vector4.r;
            float _SampleTexture2D_994d31b6eb404285ace3132ecf65d17c_G_5_Float = _SampleTexture2D_994d31b6eb404285ace3132ecf65d17c_RGBA_0_Vector4.g;
            float _SampleTexture2D_994d31b6eb404285ace3132ecf65d17c_B_6_Float = _SampleTexture2D_994d31b6eb404285ace3132ecf65d17c_RGBA_0_Vector4.b;
            float _SampleTexture2D_994d31b6eb404285ace3132ecf65d17c_A_7_Float = _SampleTexture2D_994d31b6eb404285ace3132ecf65d17c_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _OneMinus_55be9d8dff83e38e96d63a61d5e44214_Out_1_Float;
            Unity_OneMinus_float(_SampleTexture2D_994d31b6eb404285ace3132ecf65d17c_R_4_Float, _OneMinus_55be9d8dff83e38e96d63a61d5e44214_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Branch_cdbf97487b74948aacbfa9f23a97a2dd_Out_3_Float;
            Unity_Branch_float(_Property_b66daa9f4ba02e8395d00445709d4877_Out_0_Boolean, _OneMinus_55be9d8dff83e38e96d63a61d5e44214_Out_1_Float, _SampleTexture2D_994d31b6eb404285ace3132ecf65d17c_R_4_Float, _Branch_cdbf97487b74948aacbfa9f23a97a2dd_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_2a21252fbaca1884a5e6803d34f397a7_Out_0_Float = _DissolveExp;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Power_ef6b960f8d5e7c82a010cbd67e6beb1c_Out_2_Float;
            Unity_Power_float(_Branch_cdbf97487b74948aacbfa9f23a97a2dd_Out_3_Float, _Property_2a21252fbaca1884a5e6803d34f397a7_Out_0_Float, _Power_ef6b960f8d5e7c82a010cbd67e6beb1c_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _OneMinus_d80f09777f1ea98c84896f6780c49f8a_Out_1_Float;
            Unity_OneMinus_float(_Power_ef6b960f8d5e7c82a010cbd67e6beb1c_Out_2_Float, _OneMinus_d80f09777f1ea98c84896f6780c49f8a_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _UV_ee3e3e9bd5994b83851aa87d2a6eddaa_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Split_6aee6d71f94ec08eb4ad9feacca85310_R_1_Float = _UV_ee3e3e9bd5994b83851aa87d2a6eddaa_Out_0_Vector4[0];
            float _Split_6aee6d71f94ec08eb4ad9feacca85310_G_2_Float = _UV_ee3e3e9bd5994b83851aa87d2a6eddaa_Out_0_Vector4[1];
            float _Split_6aee6d71f94ec08eb4ad9feacca85310_B_3_Float = _UV_ee3e3e9bd5994b83851aa87d2a6eddaa_Out_0_Vector4[2];
            float _Split_6aee6d71f94ec08eb4ad9feacca85310_A_4_Float = _UV_ee3e3e9bd5994b83851aa87d2a6eddaa_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_678c7f84d859298e8212479d68e49c3f_Out_0_Float = _DissolveExpReversed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Vector2_eb855a9d39425b80b47e3ca51fbef43c_Out_0_Vector2 = float2(1, _Property_678c7f84d859298e8212479d68e49c3f_Out_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Remap_e4013a78c36d6287b0408a21cb6015e9_Out_3_Float;
            Unity_Remap_float(_Split_6aee6d71f94ec08eb4ad9feacca85310_R_1_Float, float2 (0, 1), _Vector2_eb855a9d39425b80b47e3ca51fbef43c_Out_0_Vector2, _Remap_e4013a78c36d6287b0408a21cb6015e9_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Power_7af89ed761d47a8f9a52b6c3774e7ca8_Out_2_Float;
            Unity_Power_float(_OneMinus_d80f09777f1ea98c84896f6780c49f8a_Out_1_Float, _Remap_e4013a78c36d6287b0408a21cb6015e9_Out_3_Float, _Power_7af89ed761d47a8f9a52b6c3774e7ca8_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _OneMinus_bea6cbb1313bfa898c7749f22466abc9_Out_1_Float;
            Unity_OneMinus_float(_Power_7af89ed761d47a8f9a52b6c3774e7ca8_Out_2_Float, _OneMinus_bea6cbb1313bfa898c7749f22466abc9_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Clamp_1cf19881f145e782997e41e4ebed29bf_Out_3_Float;
            Unity_Clamp_float(_OneMinus_bea6cbb1313bfa898c7749f22466abc9_Out_1_Float, 0, 1, _Clamp_1cf19881f145e782997e41e4ebed29bf_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _UV_c6bc8503923bee828c11974281800fbc_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Split_49ec77c12ec53e84bc7946ae4349692e_R_1_Float = _UV_c6bc8503923bee828c11974281800fbc_Out_0_Vector4[0];
            float _Split_49ec77c12ec53e84bc7946ae4349692e_G_2_Float = _UV_c6bc8503923bee828c11974281800fbc_Out_0_Vector4[1];
            float _Split_49ec77c12ec53e84bc7946ae4349692e_B_3_Float = _UV_c6bc8503923bee828c11974281800fbc_Out_0_Vector4[2];
            float _Split_49ec77c12ec53e84bc7946ae4349692e_A_4_Float = _UV_c6bc8503923bee828c11974281800fbc_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Remap_d54c3c89c1684382804760456dfa3982_Out_3_Float;
            Unity_Remap_float(_Split_49ec77c12ec53e84bc7946ae4349692e_R_1_Float, float2 (0, 1), float2 (-1, 1), _Remap_d54c3c89c1684382804760456dfa3982_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Add_ee5864ef0ab03c89b46d24d4a0c39039_Out_2_Float;
            Unity_Add_float(_Clamp_1cf19881f145e782997e41e4ebed29bf_Out_3_Float, _Remap_d54c3c89c1684382804760456dfa3982_Out_3_Float, _Add_ee5864ef0ab03c89b46d24d4a0c39039_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Clamp_8c6ef1c544dcfe86bd76e0dc3d177ab6_Out_3_Float;
            Unity_Clamp_float(_Add_ee5864ef0ab03c89b46d24d4a0c39039_Out_2_Float, 0, 1, _Clamp_8c6ef1c544dcfe86bd76e0dc3d177ab6_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Subtract_2982bf1d4fb054859e53bb2cdb5dde3f_Out_2_Float;
            Unity_Subtract_float(_Clamp_381bb518cf88358e8d16440bff90c01f_Out_3_Float, _Clamp_8c6ef1c544dcfe86bd76e0dc3d177ab6_Out_3_Float, _Subtract_2982bf1d4fb054859e53bb2cdb5dde3f_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Clamp_4e2180249932248ca7dbb602fbc7e7a9_Out_3_Float;
            Unity_Clamp_float(_Subtract_2982bf1d4fb054859e53bb2cdb5dde3f_Out_2_Float, 0, 1, _Clamp_4e2180249932248ca7dbb602fbc7e7a9_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Split_94534c3a81c9fd87a9fdd46e9123c9cd_R_1_Float = IN.VertexColor[0];
            float _Split_94534c3a81c9fd87a9fdd46e9123c9cd_G_2_Float = IN.VertexColor[1];
            float _Split_94534c3a81c9fd87a9fdd46e9123c9cd_B_3_Float = IN.VertexColor[2];
            float _Split_94534c3a81c9fd87a9fdd46e9123c9cd_A_4_Float = IN.VertexColor[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Multiply_c9301226c40adb838dd097f1c58427f0_Out_2_Float;
            Unity_Multiply_float_float(_Clamp_4e2180249932248ca7dbb602fbc7e7a9_Out_3_Float, _Split_94534c3a81c9fd87a9fdd46e9123c9cd_A_4_Float, _Multiply_c9301226c40adb838dd097f1c58427f0_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_73cbf15e122e77839b41fb2b613944a2_Out_0_Float = _FinalOpacityPower;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Multiply_b3251e573305f38180996b9e79d3f9e6_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_c9301226c40adb838dd097f1c58427f0_Out_2_Float, _Property_73cbf15e122e77839b41fb2b613944a2_Out_0_Float, _Multiply_b3251e573305f38180996b9e79d3f9e6_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Clamp_58631132878227898c2ac241acd31ae2_Out_3_Float;
            Unity_Clamp_float(_Multiply_b3251e573305f38180996b9e79d3f9e6_Out_2_Float, 0, 1, _Clamp_58631132878227898c2ac241acd31ae2_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_635f3348e3d36888a60317cb0ad478e0_Out_0_Float = _RampAffectedByDynamics;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Lerp_10411cf21cc2d98c9d3eaa361aa462da_Out_3_Float;
            Unity_Lerp_float(_Clamp_381bb518cf88358e8d16440bff90c01f_Out_3_Float, _Clamp_58631132878227898c2ac241acd31ae2_Out_3_Float, _Property_635f3348e3d36888a60317cb0ad478e0_Out_0_Float, _Lerp_10411cf21cc2d98c9d3eaa361aa462da_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _OneMinus_ca55f3a54be7678981a968504691a56b_Out_1_Float;
            Unity_OneMinus_float(_Lerp_10411cf21cc2d98c9d3eaa361aa462da_Out_3_Float, _OneMinus_ca55f3a54be7678981a968504691a56b_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_1028906edaba81899cd86a676c2871cf_Out_0_Float = _RampOffsetExp;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Power_4374b9f4771c8386b74a188fa76dccb2_Out_2_Float;
            Unity_Power_float(_OneMinus_ca55f3a54be7678981a968504691a56b_Out_1_Float, _Property_1028906edaba81899cd86a676c2871cf_Out_0_Float, _Power_4374b9f4771c8386b74a188fa76dccb2_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _OneMinus_40593e425bcc5e8d81877d3c846f624e_Out_1_Float;
            Unity_OneMinus_float(_Power_4374b9f4771c8386b74a188fa76dccb2_Out_2_Float, _OneMinus_40593e425bcc5e8d81877d3c846f624e_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Vector2_bed07f824956028a82af71f575331614_Out_0_Vector2 = float2(_OneMinus_40593e425bcc5e8d81877d3c846f624e_Out_1_Float, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _SampleTexture2D_5eb39482acbe6b8c907d3065a76dda13_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_962f2cab3fdfb782aca911c81739e744_Out_0_Texture2D.tex, _Property_962f2cab3fdfb782aca911c81739e744_Out_0_Texture2D.samplerstate, _Property_962f2cab3fdfb782aca911c81739e744_Out_0_Texture2D.GetTransformedUV(_Vector2_bed07f824956028a82af71f575331614_Out_0_Vector2) );
            float _SampleTexture2D_5eb39482acbe6b8c907d3065a76dda13_R_4_Float = _SampleTexture2D_5eb39482acbe6b8c907d3065a76dda13_RGBA_0_Vector4.r;
            float _SampleTexture2D_5eb39482acbe6b8c907d3065a76dda13_G_5_Float = _SampleTexture2D_5eb39482acbe6b8c907d3065a76dda13_RGBA_0_Vector4.g;
            float _SampleTexture2D_5eb39482acbe6b8c907d3065a76dda13_B_6_Float = _SampleTexture2D_5eb39482acbe6b8c907d3065a76dda13_RGBA_0_Vector4.b;
            float _SampleTexture2D_5eb39482acbe6b8c907d3065a76dda13_A_7_Float = _SampleTexture2D_5eb39482acbe6b8c907d3065a76dda13_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Property_ed93ccb5055c3f8baeab6e48c73e6924_Out_0_Vector4 = _RampColorTint;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Multiply_8bbf07a2be65628cb6df55def078eea1_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_5eb39482acbe6b8c907d3065a76dda13_RGBA_0_Vector4, _Property_ed93ccb5055c3f8baeab6e48c73e6924_Out_0_Vector4, _Multiply_8bbf07a2be65628cb6df55def078eea1_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Multiply_d68e6dff19150083843f1b394112fc12_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_8bbf07a2be65628cb6df55def078eea1_Out_2_Vector4, IN.VertexColor, _Multiply_d68e6dff19150083843f1b394112fc12_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Branch_d89bf144074f2b8796452db7388ff5d2_Out_3_Vector4;
            Unity_Branch_float4(_Property_a44576603cc4af889435fbff47298234_Out_0_Boolean, _Multiply_d68e6dff19150083843f1b394112fc12_Out_2_Vector4, _Multiply_8bbf07a2be65628cb6df55def078eea1_Out_2_Vector4, _Branch_d89bf144074f2b8796452db7388ff5d2_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Property_d295a6de26cdd58e82677f4c43180e85_Out_0_Vector4 = _FinalColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            #if defined(_RAMPENABLED_ON)
            float4 _RampEnabled_73108b8f01b5e486afa93fcc6d5070a9_Out_0_Vector4 = _Branch_d89bf144074f2b8796452db7388ff5d2_Out_3_Vector4;
            #else
            float4 _RampEnabled_73108b8f01b5e486afa93fcc6d5070a9_Out_0_Vector4 = _Property_d295a6de26cdd58e82677f4c43180e85_Out_0_Vector4;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Multiply_1439975bf04a7d8f936de85bdd004fa4_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_c864565a0d6acd8db22c910cae087c72_Out_2_Vector4, _RampEnabled_73108b8f01b5e486afa93fcc6d5070a9_Out_0_Vector4, _Multiply_1439975bf04a7d8f936de85bdd004fa4_Out_2_Vector4);
            #endif
            surface.BaseColor = (_Multiply_1439975bf04a7d8f936de85bdd004fa4_Out_2_Vector4.xyz);
            surface.Alpha = _Clamp_58631132878227898c2ac241acd31ae2_Out_3_Float;
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
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
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
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.uv1 = input.texCoord1;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.VertexColor = input.color;
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
    FallBack "Hidden/Shader Graph/FallbackError"
}