using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using static FC.Editor.FCShader.BaseShaderGUI;
namespace FC.Editor.FCShader
{
    public static class BaseProperty
    {
        public static readonly string SurfaceType = "_Surface";
        public static readonly string BlendMode = "_Blend";
        public static readonly string AlphaClip = "_AlphaClip";
        public static readonly string AlphaToMask = "_AlphaToMask";
        public static readonly string BlendAdavant = "_BlendAdavant";
        public static readonly string BlendOP = "_BlendOp";
        public static readonly string SrcBlend = "_SrcBlend";
        public static readonly string DstBlend = "_DstBlend";
        public static readonly string SrcBlendAlpha = "_SrcBlendAlpha";
        public static readonly string SrcAlphaBlend = "_SrcAlphaBlend";
        public static readonly string DstBlendAlpha = "_DstBlendAlpha";
        public static readonly string DstAlphaBlend = "_DstAlphaBlend";
        public static readonly string ZWrite = "_ZWrite";
        public static readonly string Cull = "_Cull";
        public static readonly string ReceiveShadows = "_ReceiveShadows";
        public static readonly string RenderQueue = "_RenderQueue";
        // for ShaderGraph shaders only
        public static readonly string ZTest = "_ZTest";
        public static readonly string ZWriteControl = "_ZWriteControl";

        public static readonly string StencilTest = "_Stencil";
        public static readonly string StencilID = "_StencilID";
        public static readonly string StencilOp = "_StencilOp";
        public static readonly string StencilComp = "_StencilComp";
        // Global Illumination requires some properties to be named specifically:
        public static readonly string EmissionMap = "_EmissionMap";
        public static readonly string EmissionColor = "_EmissionColor";
        public static readonly string EmissionStrength = "_EmissionStrength";
        public static readonly string EmissionProcessControl = "_EmissionProcessControl";
        public static readonly string EmissionHeight = "_EmissionHeight";
        public static readonly string EmissionProcessInv = "_EmissionProcessInv";
        
        //AnimationData
        public static readonly string Animation = "_Animation";
        public static readonly string EmberColor = "_EmberColor";
        public static readonly string BurnColor = "_BurnColor";
        public static readonly string MinValue = "_MinValue";
        public static readonly string MaxValue = "_MaxValue";
        public static readonly string BurnOffset = "_BurnOffset";
        public static readonly string NoiseStrength = "_NoiseStrength";
        public static readonly string BurnHardNess = "_BurnHardNess";
        public static readonly string EmberHardNess = "_EmberHardNess";
        public static readonly string InvertDir = "_InvertDir";
        public static readonly string EmberWidth = "_EmberWidth";

        public static readonly string AnimationTilling = "_AnimationTilling";
        public static readonly string BurnWidth = "_BurnWidth";
        public static readonly string DissolveAmount = "_DissolveAmount";
        public static readonly string ScrollSpeed = "_ScrollSpeed";
        public static readonly string GuideNoise = "_GuideNoise";
        public static readonly string Axis = "_Animation_Axis";
        
        //Dither
        public static readonly string EnableDither = "_EnableDither";
        public static readonly string TilingTex = "_TilingTex";
        public static readonly string CharPosAdjust = "_CharPosAdjust";
        public static readonly string FadeDistance = "_FadeDistance";
        public static readonly string DispearDistance = "_DispearDistance";

        public static void SetBasePropertyKeyWorld(Material material)
        {
            float alphaClipValue = material.GetFloat(AlphaClip);
            CoreUtils.SetKeyword(material, "_ALPHATEST_ON", alphaClipValue == 1.0f);
        }

        public static void SetMaterialStatus(Material material)
        {
            var surfaceTypeValue = material.GetFloat(SurfaceType);
            var alphaBlend = material.GetFloat(BlendAdavant) == 4.0f;
            var zWriteControl = material.GetFloat(ZWriteControl) == 0.0f;
            var blendFastMode = material.GetFloat(BlendMode);
            var isClip = material.GetFloat(AlphaClip);
            //opaque
            if (surfaceTypeValue == 0.0f)
            {
                material.SetFloat(BlendMode, 0.0f);
                material.SetFloat(BlendOP, 0.0f);
                material.SetFloat(SrcBlend, 1.0f);
                material.SetFloat(DstBlend, 0.0f);
                material.SetFloat(SrcAlphaBlend, 1.0f);
                material.SetFloat(DstAlphaBlend, 0.0f);
                if (isClip == 1.0f)
                {
                    material.SetOverrideTag("RenderType", "AlphaTest");
                }
                else
                {
                    material.SetOverrideTag("RenderType", "Opaque");
                   
                }
                if (zWriteControl)
                {
                    material.SetFloat(ZWrite, 1.0f);
                    material.SetFloat(ZTest, 4);
                }
            }
            else if(surfaceTypeValue == 1.0f )
            {
                if (zWriteControl)
                {
                    material.SetFloat(ZWrite, 0.0f);
                    material.SetFloat(ZTest, 4);
                }
                //未开启混合
                if (alphaBlend)
                {
                    
                    material.SetFloat(BlendMode, 0.0f);
                    material.SetFloat(BlendOP, 0.0f);
                    material.SetFloat(SrcBlend, 5.0f);
                    material.SetFloat(DstBlend, 8.0f);
                }
               
                material.SetOverrideTag("RenderType", "Transparent");
            }

           
            material.renderQueue = (int)material.GetFloat("_RenderQueue");

           
            if (material.HasProperty(EnableDither) && material.GetFloat(EnableDither) == 1.0f)
            {
                material.EnableKeyword("_ENABLE_DITHER");
            }
            else
            {
                material.DisableKeyword("_ENABLE_DITHER");
            }

            AnimationStatus(material);
        }

        public static void AnimationStatus(Material material)
        {
            if (material.HasProperty(Animation) && material.GetFloat(Animation) == 1.0f)
            {
                material.EnableKeyword("_ANIMATION_ON");
                float axisValue = material.GetFloat(Axis);
                if (axisValue == 0)
                {
                    material.EnableKeyword("_ANIMATION_AXIS_X");
                    material.DisableKeyword("_ANIMATION_AXIS_Z");
                    material.DisableKeyword("_ANIMATION_AXIS_Y");
                }
                else if(axisValue == 1)
                {
                    material.DisableKeyword("_ANIMATION_AXIS_X");
                    material.DisableKeyword("_ANIMATION_AXIS_Z");
                    material.EnableKeyword("_ANIMATION_AXIS_Y");
                }else if (axisValue==2)
                {
                    material.DisableKeyword("_ANIMATION_AXIS_X");
                    material.EnableKeyword("_ANIMATION_AXIS_Z");
                    material.DisableKeyword("_ANIMATION_AXIS_Y");
                }
                
            }
            else
            {
                material.DisableKeyword("_ANIMATION_ON");
            }

        }
    }
}