Shader "FC/Effect/HolographicProjection"
{
    Properties
    {
        [HDR]_BaseColor("BaseColor",COLOR)=(1,1,1,1)
        _Alpha("Alpha",Range(0,1))=1
        
        _EmissionMask("EmissionMask",2D) = "white"{}
        _LineDensity("LineDensity",Float)=1
        //Normal
        _NormalMap("NormalMap",2D)="white"{}
        _NormalScale("NormalStrength",Float)=4
        _NormalEffect("NormalEffect",Float)=1
        
        //line1
        _Line1Map("Line1Map",2D) = "white"{}
        [HDR]_Line1Color("Line1Color",Color)=(1,1,1,1)
        _Line1Speed("Line1Speed",Float)=0
        _Line1Frequency("Line1Frequency",Float)=100
        _Line1HardNess("Line1HardNess",Float)=4.6
        _Line1InvertedThinckness("Line1InvertedThinckness",Range(0,1))=0
        _Line1Alpha("Line1Alpha",Float)=1.78
        
        _Line2Map("Line2Map",2D) = "white"{}
        _Line2Speed("Line2Speed",Float)=0
        _Line2Frequency("Line2Frequency",Float)=100
        _Line2HardNess("Line2HardNess",Float)=4.6
        _Line2InvertedThinckness("Line2InvertedThinckness",Range(0,1))=0
        _Line2Alpha("Line2Alpha",Float)=1.78
        
        
        //Fresnel
        _FresnelPower("FresnelPower",Float)=2
        _FresnelScale("FresnelScale",Float)=0
        _FresnelAlphaPower("FresnelAlphaPower",Float)=0
        _FresnelAlphaScale("FresnelAlphaScale",Float)=2
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        AlphaToMask Off
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
			ZWrite On
			ZTest LEqual
			ColorMask RGBA
			Cull Back
			Offset 0 , 0
            Name "HolographicProjection"
            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _AXIS_X _AXIS_Y _AXIS_Z
            #pragma shader_feature _USE_WORLDPOSITION _USE_OBJECTPOSITION
            // make fog work

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include  "HolographicProjectionPass.hlsl"
           
            ENDHLSL
        }
    }
}
