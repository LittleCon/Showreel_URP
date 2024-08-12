Shader "FC/ClumpingVoronoi"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NumClumps("NumClumps",Float)=4
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

            CBUFFER_START(TERRAIN)
            CBUFFER_END
                float _NumClumps;
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            float2 N22(float2 p) {

                float3 a = frac(p.xyx * float3(123.34, 234.34, 345.65));
                a += dot(a, a + 34.45);
                return frac(float2(a.x * a.y, a.y * a.z));

            }
            Varyings vert (Attributes input)
            {
                Varyings output;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                output.positionCS = vertexInput.positionCS;
                output.uv = input.uv;
                return output;
            }

            float4  frag(Varyings i) : SV_Target
            {


                float pointsMask = 0;

                float radius = 0.01;
                float falloff = 0.01;

                float minDist = 100000;

                float id = 12;


                float2 clumpCentre = float2(0,0);
                for (int j = 1; j < 40; j++) {
                    float2 jj = float2(j,j);
                    float2 p = N22(jj);

                    float d = distance(p, i.uv);


                    if (d < minDist) {

                        minDist = d;
                        id = fmod((int)j,(int)_NumClumps);

                        clumpCentre = p;
                    }

                }

                float3 col = float3(id,clumpCentre);

                return float4(col,1);
            }
            ENDHLSL
        }
    }
}
