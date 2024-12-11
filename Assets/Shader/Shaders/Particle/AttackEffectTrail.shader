Shader "FC/Particle/AttackEffect/Trail"
{
    Properties
    {
		_BaseMap ("Particle Texture", 2D) = "white" {}
        _BaseColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
		[Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("SrcBlend", Int) = 5
		[Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("DstBlend", Int) = 10
		_EmissiveMultiply("Emissive Multiply", Float) = 1
		_OpacityMultiply("Opacity Multiply", Float) = 1
		_MainTiling("Main Tiling", Vector) = (1,1,1,1)
		_MainTexturePower("Main Texture Power", Float) = 1
		[KeywordEnum(None,Add,Lerp)] _Blend("Blend", Float) = 0
		_TimeScale1("Time Scale 1", Float) = 1
		_TimeScale2("Time Scale 2", Float) = 1
		_TextureMaskAlpha("Texture Mask Alpha", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
        Blend [_SrcBlend] [_DstBlend]
		ColorMask RGB
		Cull Off
		Lighting Off 
		ZWrite Off
		ZTest LEqual
        
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "AttackEffectTrailInput.hlsl"
            #include "AttackEffectTrailPass.hlsl"
         
            ENDHLSL
        }
    }
}
