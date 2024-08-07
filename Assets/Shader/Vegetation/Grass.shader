Shader "FC/Grass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _P1Flexibility("P1Bend",Float) = 1
        _P2Flexibility("P2Bend",Float) = 1

        _WeightP1("WeightP1",Range(0,1)) = 0.33

        _WindControl("WindControl",Range(0,1))=1
        _WaveAmplitude("WaveAmplitude",Float) = 20
        _WaveSpeed("WaveSpeed",Float) = 2
        _WavePower("WavePower",Float) = 3
        _SinOffsetRange("SinOffsetRange",Float) = 5
        _PushTipOscillationForward("PushTipOscillationForward",Float) = 1
        _TaperAmount("TaperAmount",Float) = 0.8
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
            #include "../Common/Math.hlsl"
            #include "./Grass.hlsl"
            ENDHLSL
        }
    }
}
