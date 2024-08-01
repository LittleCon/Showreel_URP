Shader "FC/Terrain_Base"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _HeightMap("HeightMap", 2D) = "white" {}
        _ResultPatchMap("_RenderPatchMap",2D) = "white"{}
    }
    SubShader
    {
        Tags { 
            "RenderPipeline" = "UniversalPipeline"
                "RenderType" = "Opaque"
                "Queue" = "Geometry" }
        LOD 100

        Pass
        {
            Blend One Zero,One Zero
            Cull Back
            ZTest LEqual
            ZWrite On 

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl" 

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS:NORMAL;
                float4 tangentOS:TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS:TEXCOORD1;
            };

            struct BaseData {
                float3 cameraWorldPos;
                float fov;
                float patchSize;
                int nodeDevidePatchNum;
                float worldSize;
                float worldHeightScale;
                float lodJudgeFector;
                float2 hizMapSize;
                int gridNum;
                int maxLOD;
            };


            CBUFFER_START(TERRAIN)
                 float4 _GlobalValues[10];
            CBUFFER_END

            TEXTURE2D(_ResultPatchMap);
            SAMPLER(sampler_ResultPatchMap);
            TEXTURE2D(_HeightMap);
            SAMPLER(sampler_HeightMap);
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            #include "TerrainFunc.hlsl"


            inline BaseData GenerateBaseData(float4 valueList[10]) {
                BaseData baseData;
                baseData.cameraWorldPos = float3(valueList[0].x, valueList[0].y, valueList[0].z);
                baseData.fov = valueList[0].w;
                baseData.patchSize = valueList[1].z;
                baseData.nodeDevidePatchNum = valueList[2].x;
                baseData.worldSize = valueList[1].y;
                baseData.gridNum = valueList[1].w;
                baseData.worldHeightScale = valueList[2].z;
                baseData.lodJudgeFector = valueList[2].y;
                baseData.maxLOD = valueList[1].x;
                baseData.hizMapSize.x = valueList[2].w;
                baseData.hizMapSize.y = valueList[3].x;
                return baseData;
            }

            Varyings vert (Attributes input, uint instanceID : SV_InstanceID)
            {
                //将resultPatchMap中的数据读取出来
                uint y = instanceID * 2 / 512;
                uint x = instanceID * 2 - y * 512;
                float2 uv0 = (1.0 / 512) * (uint2(x, y) + 0.5);
                float2 uv1 = (1.0 / 512) * (uint2 (x + 1, y) + 0.5);

                float4 pix0 = SAMPLE_TEXTURE2D_LOD(_ResultPatchMap, sampler_ResultPatchMap, uv0,0);
                float4 pix1 = SAMPLE_TEXTURE2D_LOD(_ResultPatchMap, sampler_ResultPatchMap, uv1,0);

                BaseData baseData = GenerateBaseData(_GlobalValues);
                float3 vexWorldPos = CalTerrainVertexPos(baseData, input.positionOS, pix0, pix1);
                float2 terrainUV = vexWorldPos.xz / baseData.worldSize + 0.5;
                float terrainHeight = SAMPLE_TEXTURE2D_LOD(_HeightMap,sampler_HeightMap, terrainUV,0);
                vexWorldPos.y = (terrainHeight - 0.5) * 2 * baseData.worldHeightScale;
               // input.positionOS.xyz = vexWorldPos;


                Varyings output;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                output.positionCS = vertexInput.positionCS;
                output.normalWS = normalInput.normalWS;
                output.uv = input.uv;
                return output;
            }

            float4 frag (Varyings i) : SV_Target
            {
                // sample the texture
                float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex,i.uv);
                return float4(1,1,1,1);
            }
            ENDHLSL
        }
    }
}
