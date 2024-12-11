Shader "FC/Effect/RefelctionPlane"
{
    // Created by #AUTHOR# on #DATE#
    Properties
    {
        _BaseColor("BaseColor",Color)=(1,1,1,1)
        _NormalMap("NormalMap",2D) = "white"{}
        _Speed("NormalSpeed 1(xy) NormalSpeed 2(zw)",Vector)=(0.5,0.5,-0.3,-0.3)
        _NormalStrength("NormalStrength",Range(0,10))=1
        _Offset("_Offset",Vector)=(0.5,0.5,-0.3,-0.3)
        
        //BasePropery
        [Enum(Off, 0, On, 1)] _ZWrite ("Z Write", Float) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTest ("ZTest", Float) = 4

         _Surface("__surface", Float) = 0.0
       
        [Toggle] _AlphaClip ("Alpha Clip", Float) = 0
        _Clip("Clip", Range(0.0, 1.0)) = 0.5

        _Blend ("__Blend", Float) = 0
        _BlendAdavant("__BlendAdavant",Float)=0
        _Cull("__cull", Float) = 2.0
        _ZWriteControl("__ZWriteControl",Float)=0.0
        _Stencil("__Stencil",Float)=0.0
        _RenderQueue("RenderQueue", Float) =2000
        [ToggleUI] _ReceiveShadows("Receive Shadows", Float) = 1.0
        [Enum(UnityEngine.Rendering.BlendOp)]
        _BlendOp("BlendOp", int) = 0
        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcBlend("Blend src", int) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstBlend("Blend dst", int) = 8
        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcAlphaBlend("SrcAlphaBlend", int) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstAlphaBlend("DstAlphaBlend", int) = 8
        
        _RenderQueue("RenderQueue",Float)=2000
        
       

        [Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp ("Stencil Comparison", Float) = 7
        _StencilID ("Stencil ID", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        [HideInInspector] _AlphaToMask("__alphaToMask", Float) = 0.0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
            "UniversalMaterialType" = "Lit"
        }

        Pass
        {
            Name "RefelctionPlane"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            Stencil
            {
                Ref [_StencilID]
                Comp [_StencilComp]
                Pass [_StencilOp]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
            }
            AlphaToMask [_AlphaToMask] 
            BlendOp [_BlendOp]
            Blend [_SrcBlend][_DstBlend],[_SrcAlphaBlend][_DstAlphaBlend]
            ZWrite [_ZWrite]
            ZTest [_ZTest]
            Cull[_Cull]
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "RefelctionPlaneInput.hlsl"
            #include "RefelctionPlanePass.hlsl"

            
            ENDHLSL
        }
    }
    
}
