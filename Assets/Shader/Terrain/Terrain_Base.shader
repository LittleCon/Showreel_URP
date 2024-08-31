Shader "FC/Terrain_Base"
{
    Properties
    {
        _BaseMap ("Texture", 2D) = "white" {}
        _NormalMap("NormalMap",2D) = "white"{}
        _HeightMap("HeightMap", 2D) = "white" {}
        _ResultPatchMap("_RenderPatchMap",2D) = "white"{}
        _SplatMap ("SplatMap",2D)= "white"{}
        _AlbedoArray("AlbedoArray",2DArray) = "white"{}
    }
    SubShader
    {
        Tags { 
            "RenderPipeline" = "UniversalPipeline"
                "RenderType" = "Opaque"
                "Queue" = "Geometry" }
        LOD 100

        HLSLINCLUDE
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl" 
            #include "../../Script/Runtime/Envrinment/Terrain/TerrainDataStructDefine.hlsl"
            #include"../../Script/Runtime//Envrinment//Terrain//GPUTerrainFunc.hlsl"
            #include "TerrainFunc.hlsl"
          
        struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS:NORMAL;
                float4 tangentOS:TANGENT;
                float2 uv : TEXCOORD0;
                uint instanceID : SV_InstanceID;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS:TEXCOORD1;
                float2 normalUV:TEXCOORD2;
                float3 viewDirWS:TEXCOORD3;
                float2 feedbackUV:TEXCOORD4;
            };

            TEXTURE2D(_ResultPatchMap);
            SAMPLER(sampler_ResultPatchMap);
            TEXTURE2D(_HeightMap);
            SAMPLER(sampler_HeightMap);


            CBUFFER_START(TERRAinput)
            float4 _BaseMap_ST;
            float4 _BlendTexArray_TexelSize;
            float4 _AlbedoTexArray_TexelSize;

            float4 _VTFeedbackParam;
            float4 _VTRealRect;

            float2 _AlphaMapSize;
            int _TotalArrayLength;
            float _BlendScaleArrayShader[8];
            float _BlendSharpnessArrayShader[8];
            float _HeightBlendEnd;
            float4 _GlobalValues[10];
            CBUFFER_END
        ENDHLSL

        Pass
        {
            Name    "TerrainLit"
            Blend Off
            Cull Back
            ZTest LEqual
            ZWrite On 

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            
            TEXTURE2D(_SplatMap);
            SAMPLER(sampler_SplatMap);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
           
           
            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);


            TEXTURE2D_ARRAY(_AlbedoTexArray);         SAMPLER(sampler_AlbedoTexArray);
            TEXTURE2D_ARRAY(_NormalTexArray);         SAMPLER(sampler_NormalTexArray);
            TEXTURE2D_ARRAY(_MinMaxHeightMap);         SAMPLER(sampler_MinMaxHeightMap);
            TEXTURE2D(_Noise);        SAMPLER(sampler_Noise);
            Texture2D _BlendTexArray;
           
            #include "TerrainLit.hlsl"
            
            ENDHLSL
        }
        Pass
        {
            Name "TerrainFeedBack"
            Tags {"LightMode" = "Feedback"}
            HLSLPROGRAM
            #include "VTFeedBack.hlsl"	
            #pragma vertex vert
            #pragma fragment VTFragFeedback


            ENDHLSL
        }
    }
}
