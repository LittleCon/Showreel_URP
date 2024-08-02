Shader "FC/Terrain_Base"
{
    Properties
    {
        _BaseMap ("Texture", 2D) = "white" {}
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
            Blend Off
            Cull Back
            ZTest LEqual
            ZWrite On 

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl" 

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

            float4 _GlobalValues[10];

            CBUFFER_START(TERRAIN)
                float4 _BaseMap_ST;
            CBUFFER_END

            TEXTURE2D(_ResultPatchMap);
            SAMPLER(sampler_ResultPatchMap);
            TEXTURE2D(_HeightMap);
            SAMPLER(sampler_HeightMap);
            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

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

            Varyings vert (Attributes input)
            {
                Varyings output;
                uint instanceID = input.instanceID;
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
                input.positionOS.xyz = vexWorldPos;


                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                output.positionCS = vertexInput.positionCS;
                output.normalWS = normalInput.normalWS;
                output.uv = TRANSFORM_TEX(terrainUV,_BaseMap);
                return output;
            }

            float4 frag (Varyings i) : SV_Target
            {
                // sample the texture
                float4 col = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap,i.uv);
                return col;
            }
            ENDHLSL
        }
    }
}
