Shader "FC/Particle/Laser"
{
    Properties
    {
        _BaseMap ("Texture", 2D) = "white" {}
        _Noise("Noise", 2D) = "white" {}
        _Flow("Flow", 2D) = "white" {}
        _Mask("Mask", 2D) = "white" {}
        _DissolveProcess("Process",Float)=1
        _SpeedMainTexUVNoiseZW("Speed MainTex U/V + Noise Z/W", Vector) = (0,0,0,0)
        _DistortionSpeedXYPowerZ("Distortion Speed XY Power Z", Vector) = (0,0,0,0)
        _Emission("Emission", Float) = 2
        [HDR]_Color("Color", Color) = (0.5,0.5,0.5,1)
        _Opacity("Opacity", Range( 0 , 1)) = 1
        [Enum(Cull Off,0, Cull Front,1, Cull Back,2)] _CullMode("Culling", Float) = 0
        [HideInInspector] _texcoord( "", 2D ) = "white" {}
    }
    SubShader
    {
         Tags
        {
            "RenderType" = "Transparent"
            "Queue"="Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
        }

        Pass
        {
            Name"Laser"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGB
            Cull[_CullMode]
            Lighting Off 
            ZWrite Off
            ZTest LEqual
            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex LaserVert
            #pragma fragment LaserFrag
            // make fog work

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "LaserInput.hlsl"
            #include "LaserPass.hlsl"
           
            ENDHLSL
        }
    }
}
