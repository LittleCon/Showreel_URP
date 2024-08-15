Shader "FC/Terrain_SplatMap"
{
    Properties
    {
        _BaseMap ("Texture", 2D) = "white" {}
        _NormalMap("NormalMap",2D) = "white"{}
        _HeightMap("HeightMap", 2D) = "white" {}
        _ResultPatchMap("_RenderPatchMap",2D) = "white"{}
        _SplatMap1 ("SplatMap1",2D)= "white"{}
        _SplatMap2("SplatMap2",2D) = "white"{}
        _SplatMap3("SplatMap3",2D) = "white"{}
        _SplatMap4("SplatMap4",2D) = "black"{}

        _DirtMap("_dirtMap",2D) = "white"{}
        _GrassMap("_GrassMap",2D) = "white"{}
        _RoadMap("_RoadMap",2D) = "white"{}
        _HouseMap("_HouseMap",2D) = "white"{}
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
                float3 positionWS:TEXCOORD1;
                float2 normalUV:TEXCOORD2;
                float3 viewDirWS:TEXCOORD3;
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

            CBUFFER_START(TERRAinput)
                float4 _BaseMap_ST;

                float4 _BlendTexArray_TexelSize;
                float4 _AlbedoTexArray_TexelSize;
                float2 _AlphaMapSize;
                int _TotalArrayLength;
                float _BlendScaleArrayShader[8];
                float _BlendSharpnessArrayShader[8];
                float _HeightBlendEnd;
            CBUFFER_END
            
            TEXTURE2D(_SplatMap1);
            SAMPLER(sampler_SplatMap1);
            TEXTURE2D(_SplatMap2);
            SAMPLER(sampler_SplatMap2);
            TEXTURE2D(_SplatMap3);
            SAMPLER(sampler_SplatMap3);
            TEXTURE2D(_SplatMap4);
            SAMPLER(sampler_SplatMap4);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            TEXTURE2D(_ResultPatchMap);
            SAMPLER(sampler_ResultPatchMap);
            TEXTURE2D(_HeightMap);
            SAMPLER(sampler_HeightMap);
            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            TEXTURE2D(_GrassMap);
            SAMPLER(sampler_GrassMap);
            TEXTURE2D(_DirtMap);
            SAMPLER(sampler_DirtMap);
            TEXTURE2D(_RoadMap);
            SAMPLER(sampler_RoadMap);
            TEXTURE2D(_HouseMap);
            SAMPLER(sampler_HouseMap);

           

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
                output.uv = TRANSFORM_TEX(terrainUV,_BaseMap);
                output.normalUV=terrainUV;
                output.positionWS = vertexInput.positionWS;
                output.viewDirWS = GetWorldSpaceViewDir(output.positionWS);
                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                float splatMap1 = SAMPLE_TEXTURE2D(_SplatMap1, sampler_SplatMap1,input.normalUV);
                float splatMap2 = SAMPLE_TEXTURE2D(_SplatMap2, sampler_SplatMap2, input.normalUV);
                float splatMap3 = SAMPLE_TEXTURE2D(_SplatMap3, sampler_SplatMap3, input.normalUV);
                float splatMap4 = SAMPLE_TEXTURE2D(_SplatMap4, sampler_SplatMap4, input.normalUV);

                float3 dirt = SAMPLE_TEXTURE2D(_DirtMap, sampler_DirtMap, input.uv);
                float3 grass = SAMPLE_TEXTURE2D(_GrassMap, sampler_GrassMap, input.uv);
                float3 road = SAMPLE_TEXTURE2D(_RoadMap, sampler_RoadMap, input.uv);
                float3 house = SAMPLE_TEXTURE2D(_HouseMap, sampler_HouseMap, input.uv);
                
                float3 albedo = 0;
      
                albedo = house;
              
                
                // sample the texture
                //float4 col = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap,input.uv);
                //float4 normal = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap,input.normalUV);
                //float4 splatMask= SAMPLE_TEXTURE2D(_SplatMap, sampler_SplatMap,input.normalUV);
                //normal = 2.0 * normal - 1.0;
                //Light lightData=GetMainLight();
                //

                //float3 diffuseColor =lightData.color*(max(0,dot( lightData.direction,normal))*0.5+0.5)*col.xyz;
                //float3 viewDir = normalize(_WorldSpaceCameraPos.xyz-input.positionWS);

                //float halfDir = normalize(lightData.direction+viewDir);

                //float3 specularColor = 0;//lightData.color* pow(saturate(dot(normal , halfDir)),1000);
                //float4 finalColor = float4(diffuseColor+specularColor,1);
                //return finalColor;
                half3 normal = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.normalUV);
                normal.xy = normal.xy * 2 - 1;
                normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
                normal = normalize(normal);
                BRDFData brdfData;
                half alpha = 1;
                InitializeBRDFData(albedo, 0, half3(0, 0, 0), 0, alpha, brdfData);
                half4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
                Light mainLight = GetMainLight(shadowCoord, input.positionWS, 0);

                BRDFData brdfDataClearCoat = (BRDFData)0;
                half3 color = LightingPhysicallyBased(brdfData, brdfDataClearCoat,
                    mainLight,
                    normal.xzy, input.viewDirWS,
                    0, false);
            /*    half3 albedo = albedo1.rgb * w1 + albedo2.rgb * w2 + albedo3 * w3;
                
                half3 normal2 = SAMPLE_TEXTURE2D_ARRAY(_NormalTexArray, sampler_NormalTexArray, texUV, index2);
                half3 normal3 = SAMPLE_TEXTURE2D_ARRAY(_NormalTexArray, sampler_NormalTexArray, texUV, index3);
                half3 normal = normal1.rgb * w1 + normal2.rgb * w2 + normal3 * w3;

               

                BRDFData brdfData;
                half alpha = 1;
                InitializeBRDFData(albedo, 0, half3(0, 0, 0), 0, alpha, brdfData);
                half4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
                Light mainLight = GetMainLight(shadowCoord, input.positionWS, 0);

                BRDFData brdfDataClearCoat = (BRDFData)0;
                half3 color = LightingPhysicallyBased(brdfData, brdfDataClearCoat,
                    mainLight,
                    normal.xzy, input.viewDirWS,
                    0, false);*/
                return  half4(color, 1);

            }
            ENDHLSL
        }
    }
}
