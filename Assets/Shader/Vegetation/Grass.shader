Shader "FC/Grass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _P1Flexibility("P1Bend",Float) = 1
        _P2Flexibility("P2Bend",Float) = 1
        _BezierT("BezierT",Range(0.001,0.999))=0.5
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
                float3 color:TEXCOORD2;
                float3 normalWS:TEXCOORD1;
            };

            struct GrassData {
                
                float tile;
                float bend;
                float height;
            };

            CBUFFER_START(TERRAIN)
            float _P1Flexibility;
            float _P2Flexibility;
            float _BezierT;
            CBUFFER_END
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            StructuredBuffer<GrassData> grassDatas;

            float3 cubicBezier(float3 p0, float3 p1, float3 p2, float3 p3, float t) {
                float3 a = lerp(p0, p1, t);
                float3 b = lerp(p2, p3, t);
                float3 c = lerp(p1, p2, t);
                float3 d = lerp(a, c, t);
                float3 e = lerp(c, b, t);
                return lerp(d, e, t);
            }

            Varyings vert (Attributes input, uint instanceID : SV_InstanceID)
            {
                Varyings output;
                GrassData grassData = grassDatas[0];
                grassData.bend = 0.8;
                grassData.tile = 0.5;
                grassData.height =0.8;
                //bezierº∆À„
                float3 p0 = 0;
                float p3y = grassData.tile * grassData.height;
                float p3x = sqrt(grassData.height * grassData.height - p3y * p3y);
                float3 p3 = float3(p3x, p3y, 0);

                float3 bendDir = normalize(cross(normalize(p3), float3(0, 0, 1)));
                float3 p1 = p3 * 0.33;
                float3 p2 = p3 * 0.66;
                p1 += bendDir * grassData.bend * _P1Flexibility;
                p2 += bendDir * grassData.bend * _P2Flexibility;
                float3 newPos = cubicBezier(p0, p1, p2, p3, _BezierT);
                output.color = newPos;
                newPos += float3(input.positionOS.x, 0, input.positionOS.z);
                //---
                output.positionCS = mul(UNITY_MATRIX_MVP, float4(newPos , 1));
               /* VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                

                output.positionCS = vertexInput.positionCS;
                output.normalWS = normalInput.normalWS;*/
                output.uv = input.uv;
                return output;
            }

            float4 frag (Varyings i) : SV_Target
            {
                // sample the texture
                float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex,i.uv);
                return float4(i.color,1);
            }
            ENDHLSL
        }
    }
}
