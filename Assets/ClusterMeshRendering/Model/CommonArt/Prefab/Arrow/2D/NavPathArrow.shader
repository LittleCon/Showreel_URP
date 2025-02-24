Shader "URP/NavPathArrow"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        _ScrollYSpeed("Y Scroll Speed", Range(-20, 20)) = 2
        _TillingX("Tilling X", float) = 1
        _TillingY("Tilling Y", float) = 1
        [Toggle] _AlphaTest ("Alpha Clip", Float) = 0
        _AlphaThreshold("Alpha Threshold", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Geometry" "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"
        }
        LOD 100
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            half4 _Color;
            half _ScrollYSpeed;
            half _TillingX;
            half _TillingY;
            half _AlphaThreshold;
        CBUFFER_END

        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);


        
        ENDHLSL

        Pass
        {
            Cull Off
            //ZWrite Off
            //Blend SrcAlpha OneMinusSrcAlpha
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag   
            #pragma shader_feature_local_fragment _ALPHATEST_ON

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };


            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv * float2(_TillingX, _TillingY);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv;
                uv.y += -_ScrollYSpeed * _Time;
                half l = 1 - SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv).r;
                half4 col = l * _Color;
                #if defined(_ALPHATEST_ON)
                clip(col.a - _AlphaThreshold);
                #endif
                return col;
            }
            ENDHLSL
        }
    }
}