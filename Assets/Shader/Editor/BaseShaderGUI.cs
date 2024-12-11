using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEditor.Graphs;
using UnityEditor.Rendering;
using UnityEngine;

namespace FC.Editor.FCShader {
    public class BaseShaderGUI : ShaderGUI
    {
        /// <summary>
        /// Shader列表栏
        /// </summary>
        protected enum Expandable
        {
            /// <summary>
            /// 表面属性
            /// </summary>
            SurfaceOptions = 1 << 0,

            /// <summary>
            /// 表面属性参数输入模块
            /// </summary>
            SurfaceInputs = 1 << 1,

            /// <summary>
            /// 高级设置
            /// </summary>
            Advanced = 1 << 2,

            /// <summary>
            /// Use this for additional details foldout.
            /// </summary>
            Details = 1 << 3,
            
            Animations = 1 << 4,
            
        }

   

    /// <summary>
    /// 区分透明和不透明
    /// </summary>
    public enum SurfaceType 
        {
            Opaque,
            Transparent
        }

        /// <summary>
        /// 透明度混合模式
        /// </summary>
        public enum BlendMode
        {
            /// <summary>
            /// 自定义公式模式
            /// </summary>
            Alpha,
            Premultiply,
            /// <summary>
            /// 加法
            /// </summary>
            Additive,
            /// <summary>
            /// 乘法
            /// </summary>
            Multiply,
            Custom
        }

        /// <summary>
        /// 对应CullMode
        /// </summary>
        public enum RenderFace
        {
            Front = 1,
            Back = 2,
            Both = 0
        }

        /// <summary>
        /// 深度写入枚举
        /// </summary>
        public enum ZWriteControl
        {
            Off=0,
            On=1
        }

        public enum AxisMode
        {
            X=0,Y=1,Z=2
        }

        enum ZTestMode  // the values here match UnityEngine.Rendering.CompareFunction
        {
            Disabled = 0,
            Never = 1,
            Less = 2,
            Equal = 3,
            LEqual = 4,     // default for most rendering
            Greater = 5,
            NotEqual = 6,
            GEqual = 7,
            Always = 8,
        }

        protected MaterialEditor materialEditor { get; set; }
        protected MaterialProperty surfaceTypeProp { get; set; }

        protected MaterialProperty blendAdavantProp { get; set; }
        /// <summary>
        /// 混合模式
        /// </summary>
        protected MaterialProperty blendModeProp { get; set; }

        protected MaterialProperty srcBlendProp { get; set; }

        protected MaterialProperty srcAlphaBlendProp { get; set; }

        protected MaterialProperty dstAlphaBlendProp { get; set; }

        protected MaterialProperty dstBlendProp { get; set; }

        protected MaterialProperty blendOPProp { get; set; }

        /// <summary>
        /// The MaterialProperty for cull mode.
        /// </summary>
        protected MaterialProperty cullingProp { get; set; }


        protected MaterialProperty zWriteProp { get; set; }

        protected MaterialProperty zWriteControlProp { get; set; }
        /// <summary>
        /// The MaterialProperty for zTest.
        /// </summary>
        protected MaterialProperty ztestProp { get; set; }

        /// <summary>
        /// The MaterialProperty for alpha clip.
        /// </summary>
        protected MaterialProperty alphaClipProp { get; set; }

        /// <summary>
        /// The MaterialProperty for alpha cutoff.
        /// </summary>
        protected MaterialProperty alphaCutoffProp { get; set; }

        /// <summary>
        /// The MaterialProperty for receive shadows.
        /// </summary>
        protected MaterialProperty receiveShadowsProp { get; set; }


        // Common Surface Input properties

        /// <summary>
        /// The MaterialProperty for base map.
        /// </summary>
        protected MaterialProperty baseMapProp { get; set; }

        /// <summary>
        /// The MaterialProperty for base color.
        /// </summary>
        protected MaterialProperty baseColorProp { get; set; }

        /// <summary>
        /// The MaterialProperty for queue offset.
        /// </summary>
        protected MaterialProperty renderqueueProp { get; set; }

        /// <summary>
        /// The MaterialProperty for emission map.
        /// </summary>
        protected MaterialProperty emissionMapProp { get; set; }

        protected MaterialProperty emissionStrengthProp { get; set; }
        /// <summary>
        /// The MaterialProperty for emission color.
        /// </summary>
        protected MaterialProperty emissionColorProp { get; set; }

        protected MaterialProperty stencilTestProp { get; set; }
        protected MaterialProperty stencilOpProp { get; set; }
        protected MaterialProperty stencilValueProp { get; set; }
        protected MaterialProperty stencilCompProp { get; set; }
        
        protected MaterialProperty emissionProcessControlProp { get; set; }
    
        protected MaterialProperty emissionHeightProp { get; set; }
        
        protected MaterialProperty emissionProcessInvProp { get; set; }
        
        protected MaterialProperty axisProp { get; set; }

        #region 动画属性
        
        protected MaterialProperty animationProp { get; set; }
        protected MaterialProperty emberColorProp { get; set; }
        protected MaterialProperty animationTillingProp { get; set; }
        protected MaterialProperty burnWidthProp { get; set; }
        protected MaterialProperty dissolveAmountProp { get; set; }
        protected MaterialProperty scrollSpeedProp { get; set; }
        protected MaterialProperty minValueProp { get; set; }
        protected MaterialProperty maxValueProp { get; set; }
        protected MaterialProperty burnOffsetProp { get; set; }
        protected MaterialProperty noiseStrengthProp { get; set; }
        protected MaterialProperty burnHardNessProp { get; set; }
        protected MaterialProperty emberHardNessProp { get; set; }
        protected MaterialProperty invertDirProp { get; set; }
        protected MaterialProperty guideNoiseProp { get; set; }
        
        protected MaterialProperty emberWidthProp { get; set; }
        
        protected MaterialProperty burnColorProp { get; set; }
        

        #endregion
        
        protected MaterialProperty enableDitherProp { get; set; }
        protected MaterialProperty tilingTexProp { get; set; }
        protected MaterialProperty charPosAdjustProp { get; set; }
        protected MaterialProperty fadeDistanceProp { get; set; }
        protected MaterialProperty dispearDistanceProp { get; set; }
        /// <summary>
        /// 获取所有属性
        /// </summary>
        /// <param name="properties"></param>
        public virtual void FindProperties(MaterialProperty[] properties)
        {
            surfaceTypeProp = FindProperty(BaseProperty.SurfaceType, properties, false);
            blendModeProp = FindProperty(BaseProperty.BlendMode, properties, false);
            cullingProp = FindProperty(BaseProperty.Cull, properties, false);
            ztestProp = FindProperty(BaseProperty.ZTest, properties, false);
            alphaClipProp = FindProperty(BaseProperty.AlphaClip, properties, false);
            zWriteProp = FindProperty(BaseProperty.ZWrite, properties, false);
            zWriteControlProp = FindProperty(BaseProperty.ZWriteControl, properties, false);
            emissionMapProp = FindProperty(BaseProperty.EmissionMap, properties, false);
            emissionColorProp = FindProperty(BaseProperty.EmissionColor, properties, false);
            blendAdavantProp = FindProperty(BaseProperty.BlendAdavant, properties, false);
            blendOPProp = FindProperty(BaseProperty.BlendOP, properties, false);
            srcAlphaBlendProp = FindProperty(BaseProperty.SrcAlphaBlend, properties, false);
            srcBlendProp = FindProperty(BaseProperty.SrcBlend,properties,false);
            dstAlphaBlendProp = FindProperty(BaseProperty.DstAlphaBlend, properties, false);
            dstBlendProp = FindProperty(BaseProperty.DstBlend, properties, false);
            // ShaderGraph Lit and Unlit Subtargets only
            emissionStrengthProp = FindProperty(BaseProperty.EmissionStrength, properties, false);
            // ShaderGraph Lit, and Lit.shader
            receiveShadowsProp = FindProperty(BaseProperty.ReceiveShadows, properties, false);

            // The following are not mandatory for shadergraphs (it's up to the user to add them to their graph)
            alphaCutoffProp = FindProperty("_Clip", properties, false);
            baseMapProp = FindProperty("_BaseMap", properties, false);
            baseColorProp = FindProperty("_BaseColor", properties, false);
            renderqueueProp = FindProperty(BaseProperty.RenderQueue, properties, false);
            stencilTestProp = FindProperty(BaseProperty.StencilTest, properties, false);
            stencilOpProp = FindProperty(BaseProperty.StencilOp, properties, false);
            stencilValueProp = FindProperty(BaseProperty.StencilID, properties, false);
            stencilCompProp = FindProperty(BaseProperty.StencilComp, properties, false);
            emissionProcessControlProp = FindProperty(BaseProperty.EmissionProcessControl,properties, false);
            emissionHeightProp = FindProperty(BaseProperty.EmissionHeight, properties, false);
            emissionProcessInvProp = FindProperty(BaseProperty.EmissionProcessInv, properties, false);  
            
            
            //动画
            animationProp = FindProperty(BaseProperty.Animation, properties, false);
            emberColorProp = FindProperty(BaseProperty.EmberColor, properties, false);
            animationTillingProp = FindProperty(BaseProperty.AnimationTilling, properties, false);
            burnWidthProp = FindProperty(BaseProperty.BurnWidth, properties, false); 
            dissolveAmountProp = FindProperty(BaseProperty.DissolveAmount, properties, false);
            scrollSpeedProp = FindProperty(BaseProperty.ScrollSpeed, properties, false);
            minValueProp = FindProperty(BaseProperty.MinValue, properties, false);
            maxValueProp = FindProperty(BaseProperty.MaxValue, properties, false);
            burnOffsetProp = FindProperty(BaseProperty.BurnOffset, properties, false); 
            noiseStrengthProp = FindProperty(BaseProperty.NoiseStrength, properties, false); 
            burnHardNessProp = FindProperty(BaseProperty.BurnHardNess, properties, false);
            invertDirProp = FindProperty(BaseProperty.InvertDir, properties, false);
            emberHardNessProp = FindProperty(BaseProperty.EmberHardNess, properties, false);
            guideNoiseProp = FindProperty(BaseProperty.GuideNoise, properties, false);
            emberWidthProp = FindProperty(BaseProperty.EmberWidth, properties, false);
            burnColorProp = FindProperty(BaseProperty.BurnColor, properties, false);
            axisProp = FindProperty(BaseProperty.Axis, properties, false);
            
            //Dither
            enableDitherProp = FindProperty(BaseProperty.EnableDither, properties, false);
            tilingTexProp = FindProperty(BaseProperty.TilingTex, properties, false);
            charPosAdjustProp = FindProperty(BaseProperty.CharPosAdjust, properties, false);
            fadeDistanceProp = FindProperty(BaseProperty.FadeDistance, properties, false);
            dispearDistanceProp = FindProperty(BaseProperty.DispearDistance, properties, false);
        }
        bool m_FirstTimeApply = true;

        public override void ValidateMaterial(Material material)
        {
            SetQueue(material);
        }

        public void SetQueue(Material material)
        {
            float renderQueue = material.GetFloat("_RenderQueue");

            if ((surfaceTypeProp != null) && ((SurfaceType)surfaceTypeProp.floatValue == SurfaceType.Opaque))
            {
                if (alphaClipProp != null && alphaClipProp.floatValue == 1.0)
                {
                    if (renderQueue < 2450 || renderQueue >= 3000)
                        renderQueue = 2450;
                }
                else if(alphaClipProp != null && alphaClipProp.floatValue == 0.0)
                {
                    if (renderQueue < 2000 || renderQueue >= 3000)
                        renderQueue = 2000;
                }
            }else if((surfaceTypeProp != null) && ((SurfaceType)surfaceTypeProp.floatValue == SurfaceType.Transparent))
            {
                if (renderQueue < 3000)
                    renderQueue = 3000;
            }
                material.SetFloat("_RenderQueue", renderQueue);

        }
        public override void OnGUI(MaterialEditor materialEditorIn, MaterialProperty[] properties)
        {
            Material material = materialEditorIn.target as Material;
            materialEditor = materialEditorIn;
            FindProperties(properties);

            if (m_FirstTimeApply)
            {
                OnOpenGUI(material, materialEditorIn);
                m_FirstTimeApply = false;
            }

            ShaderPropertiesGUI(material);

        }

        /// <summary>
        /// 调用区域绘制API
        /// </summary>
        /// <param name="material"></param>
        public void ShaderPropertiesGUI(Material material)
        {
            m_MaterialScopeList.DrawHeaders(materialEditor, material);
        }

        protected virtual uint materialFilter => uint.MaxValue;
        readonly MaterialHeaderScopeList m_MaterialScopeList = new MaterialHeaderScopeList(uint.MaxValue & ~(uint)Expandable.Advanced);


        public virtual void FillAdditionalFoldouts(MaterialHeaderScopeList materialScopesList) { }
        
        /// <summary>
        /// 设定各区域绘制内容
        /// </summary>
        /// <param name="material"></param>
        /// <param name="materialEditor"></param>
        public virtual void OnOpenGUI(Material material, MaterialEditor materialEditor)
        {
            var filter = (Expandable)materialFilter;

            if (filter.HasFlag(Expandable.SurfaceOptions))
                m_MaterialScopeList.RegisterHeaderScope(BaseStyle.SurfaceOptions, (uint)Expandable.SurfaceOptions, DrawSurfaceOptions);
            if (filter.HasFlag(Expandable.SurfaceInputs))
                m_MaterialScopeList.RegisterHeaderScope(BaseStyle.SurfaceInputs, (uint)Expandable.SurfaceInputs, DrawSurfaceInputs);
            if(filter.HasFlag(Expandable.Animations))
                m_MaterialScopeList.RegisterHeaderScope(BaseStyle.AnimationOptions,(uint)Expandable.Animations,DrawAnimationOptions);
            if (filter.HasFlag(Expandable.Details))
                FillAdditionalFoldouts(m_MaterialScopeList);
            if (filter.HasFlag(Expandable.Advanced))
                m_MaterialScopeList.RegisterHeaderScope(BaseStyle.AdvancedLabel, (uint)Expandable.Advanced, DrawAdvancedOptions);


        }

        public virtual void DrawAnimationOptions(Material material)
        {
            //拥有Animation才绘制
            if (material.HasProperty("_Animation"))
            {
                DrawFloatToggleProperty(new GUIContent("开启动画"),animationProp);
                if (material.GetFloat("_Animation") == 1.0)
                {
                    DrawDissolve(material);
                }
            }
        }

        public void DrawDissolve(Material material)
        {
            materialEditor.TexturePropertySingleLine(new GUIContent("溶解噪声"), guideNoiseProp, emberColorProp);
            materialEditor.FloatProperty(animationTillingProp, "噪声Tilling");
            materialEditor.RangeProperty(noiseStrengthProp, "噪声强度");
            materialEditor.RangeProperty(dissolveAmountProp, "显隐");
            DoPopup(new GUIContent("溶解轴向"),axisProp, Enum.GetNames(typeof(AxisMode)));
            materialEditor.FloatProperty(scrollSpeedProp, "噪声滚动速度");
            DrawFloatToggleProperty(new GUIContent("反向溶解"),invertDirProp);
            materialEditor.FloatProperty(minValueProp, "溶解起点位置");
            materialEditor.FloatProperty(maxValueProp, "溶解终点位置");
            
            materialEditor.RangeProperty(emberHardNessProp,"EmberHardness");
            materialEditor.RangeProperty(emberWidthProp, "待溶解区域宽度");
            materialEditor.ColorProperty(burnColorProp, "溶解燃烧色");
            materialEditor.RangeProperty(burnHardNessProp, "BurnHardness");
            materialEditor.RangeProperty(burnWidthProp, "溶解区域宽度");
            materialEditor.RangeProperty(burnOffsetProp, "溶解区域偏移");
            
        }

        public virtual void DrawAdvancedOptions(Material material)
        {
            if (material.HasProperty("_EnableDither"))
            {
                DrawFloatToggleProperty(new GUIContent("Enable Dither"),enableDitherProp);
                if (material.GetFloat("_EnableDither") == 1.0)
                {
                    DrawDither(material);
                }
            }
            DrawQueue();
           
            //GPUInstance绘制开关
            materialEditor.EnableInstancingField();
        }

        public void DrawDither(Material material)
        {
            materialEditor.TextureProperty(tilingTexProp,("TilingTex") );
            materialEditor.FloatProperty(charPosAdjustProp, "CharPosAdjust");
            materialEditor.FloatProperty(fadeDistanceProp, "FadeDistance");
            materialEditor.FloatProperty(dispearDistanceProp, "DispearDistance");
        }

        protected void DrawQueue()
        {
            float originalLabelWidth = EditorGUIUtility.labelWidth;
            
            materialEditor.FloatProperty(renderqueueProp, "RenderQueue");
        }

        public virtual void DrawSurfaceInputs(Material material)
        {
            DrawBaseProperties(material);
        }

        public virtual void DrawBaseProperties(Material material)
        {
            if (baseMapProp != null && baseColorProp != null) // Draw the baseMap, most shader will have at least a baseMap
            {
                materialEditor.TexturePropertySingleLine(BaseStyle.baseMap, baseMapProp, baseColorProp);
            }
        }

        /// <summary>
        /// 封装了内置的Pop属性绘制
        /// </summary>
        /// <param name="label"></param>
        /// <param name="property"></param>
        /// <param name="options"></param>
        public void DoPopup(GUIContent label, MaterialProperty property, string[] options)
        {
            if (property != null)
                materialEditor.PopupShaderProperty(property, label, options);
        }

        public void DrawAlphaBlend(Material material)
        {
            DoPopup(BaseStyle.blendingMode, blendModeProp, BaseStyle.blendModeNames);
            BlendMode blendFastMode = (BlendMode)material.GetFloat(BaseProperty.BlendMode);
            UnityEngine.Rendering.BlendMode srcBlendRGB = UnityEngine.Rendering.BlendMode.One;
            UnityEngine.Rendering.BlendMode dstBlendRGB = UnityEngine.Rendering.BlendMode.Zero;
            UnityEngine.Rendering.BlendMode srcBlendA = UnityEngine.Rendering.BlendMode.One;
            UnityEngine.Rendering.BlendMode dstBlendA = UnityEngine.Rendering.BlendMode.Zero;
            bool custom = true;
            switch (blendFastMode)
            {
                // srcRGB * srcAlpha + dstRGB * (1 - srcAlpha)
                // preserve spec:
                // srcRGB * (<in shader> ? 1 : srcAlpha) + dstRGB * (1 - srcAlpha)
                case BlendMode.Alpha:
                    srcBlendRGB = UnityEngine.Rendering.BlendMode.SrcAlpha;
                    dstBlendRGB = UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha;
                    srcBlendA = UnityEngine.Rendering.BlendMode.One;
                    dstBlendA = dstBlendRGB;
                    custom = false;
                    break;

                // srcRGB < srcAlpha, (alpha multiplied in asset)
                // srcRGB * 1 + dstRGB * (1 - srcAlpha)
                case BlendMode.Premultiply:
                    srcBlendRGB = UnityEngine.Rendering.BlendMode.One;
                    dstBlendRGB = UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha;
                    srcBlendA = srcBlendRGB;
                    dstBlendA = dstBlendRGB;
                    custom = false;
                    break;

                // srcRGB * srcAlpha + dstRGB * 1, (alpha controls amount of addition)
                // preserve spec:
                // srcRGB * (<in shader> ? 1 : srcAlpha) + dstRGB * (1 - srcAlpha)
                case BlendMode.Additive:
                    srcBlendRGB = UnityEngine.Rendering.BlendMode.SrcAlpha;
                    dstBlendRGB = UnityEngine.Rendering.BlendMode.One;
                    srcBlendA = UnityEngine.Rendering.BlendMode.One;
                    dstBlendA = dstBlendRGB;
                    custom = false;
                    break;

                // srcRGB * 0 + dstRGB * srcRGB
                // in shader alpha controls amount of multiplication, lerp(1, srcRGB, srcAlpha)
                // Multiply affects color only, keep existing alpha.
                case BlendMode.Multiply:
                    srcBlendRGB = UnityEngine.Rendering.BlendMode.DstColor;
                    dstBlendRGB = UnityEngine.Rendering.BlendMode.Zero;
                    srcBlendA = UnityEngine.Rendering.BlendMode.Zero;
                    dstBlendA = UnityEngine.Rendering.BlendMode.One;
                    custom = false;
                    break;
                case BlendMode.Custom:
                    custom = true;
                    break;
            }

            if (!custom )
            {
                material.SetFloat("_SrcBlend", (float)srcBlendRGB);
                material.SetFloat("_DstBlend", (float)dstBlendRGB);
                material.SetFloat("_SrcAlphaBlend", (float)srcBlendA);
                material.SetFloat("_DstAlphaBlend", (float)dstBlendA);
            }
        
        }

        /// <summary>
        /// 表面类型数据绘制区域
        /// </summary>
        /// <param name="material"></param>
        public virtual void DrawSurfaceOptions(Material material)
        {
            DoPopup(BaseStyle.surfaceType, surfaceTypeProp, BaseStyle.surfaceTypeNames);

            if ((surfaceTypeProp != null) && ((SurfaceType)surfaceTypeProp.floatValue == SurfaceType.Transparent))
            {
                DrawAlphaBlend(material);
                //if (material.HasProperty(Property.BlendModePreserveSpecular))
                //{
                //    //BlendMode blendMode = (BlendMode)material.GetFloat(Property.BlendMode);
                //    //var isDisabled = blendMode == BlendMode.Multiply || blendMode == BlendMode.Premultiply;
                //    //if (!isDisabled)
                //    //    DrawFloatToggleProperty(Styles.preserveSpecularText, preserveSpecProp, 1, isDisabled);
                //}
             
            }
        
            DoPopup(BaseStyle.cullingText, cullingProp, BaseStyle.renderFaceNames);
            DrawFloatToggleProperty(BaseStyle.zWriteControlTex, zWriteControlProp);
            if (zWriteControlProp!=null&& zWriteControlProp.floatValue == 1.0f)
            {
                EditorGUI.indentLevel += 1;
                DoPopup(BaseStyle.zWrite, zWriteProp, BaseStyle.zwriteNames);
                materialEditor.IntPopupShaderProperty(ztestProp, BaseStyle.ztestText.text, BaseStyle.ztestNames, BaseStyle.ztestValues);
                EditorGUI.indentLevel -= 1;
            }
           

            DrawFloatToggleProperty(BaseStyle.alphaClipText, alphaClipProp);

            if ((alphaClipProp != null) && (alphaCutoffProp != null) && (alphaClipProp.floatValue == 1))
                materialEditor.ShaderProperty(alphaCutoffProp, BaseStyle.alphaClipThresholdText, 1);

            DrawFloatToggleProperty(BaseStyle.receiveShadowText, receiveShadowsProp);

            if (((SurfaceType)surfaceTypeProp.floatValue == SurfaceType.Transparent&& blendModeProp.floatValue == 4.0f))
            {
                DrawFloatToggleProperty(BaseStyle.blendAdavant, blendAdavantProp);

                if (blendAdavantProp.floatValue == 1.0f)
                {
                    EditorGUI.indentLevel += 1;
                    DoPopup(BaseStyle.blendOP, blendOPProp, BaseStyle.blendOPEnum);
                    DoPopup(BaseStyle.srcBlend, srcBlendProp, BaseStyle.blendMode);
                    DoPopup(BaseStyle.srcAlphaBlend, srcAlphaBlendProp, BaseStyle.blendMode);
                    DoPopup(BaseStyle.dstBlend, dstBlendProp, BaseStyle.blendMode);
                    DoPopup(BaseStyle.dstAlphaBlend, dstAlphaBlendProp, BaseStyle.blendMode);
                    EditorGUI.indentLevel -= 1;
                }
            }

            DrawFloatToggleProperty(BaseStyle.stencilTest, stencilTestProp);
            if(stencilTestProp.floatValue == 1.0f)
            {
                EditorGUI.indentLevel += 1;
                materialEditor.FloatProperty(stencilValueProp, BaseStyle.stencilValue.text);
                DoPopup(BaseStyle.stencilMode, stencilCompProp, BaseStyle.stencilModeNames);
                DoPopup(BaseStyle.stencilOp, stencilOpProp, BaseStyle.stencilOpNames);
                EditorGUI.indentLevel -= 1;
            }
        }


        private void DrawEmissionTextureProperty()
        {
            if ((emissionMapProp == null) || (emissionColorProp == null))
                return;

            using (new EditorGUI.IndentLevelScope(2))
            {
                materialEditor.TexturePropertyWithHDRColor(BaseStyle.emissionMap, emissionMapProp, emissionColorProp, false);
            }
        }
        protected virtual void DrawEmissionProperties(Material material, bool keyword)
        {
            var emissive = true;
            emissive = materialEditor.EmissionEnabledProperty();
            using (new EditorGUI.DisabledScope(!emissive))
            {
                DrawEmissionTextureProperty();
            }
            materialEditor.RangeProperty(emissionStrengthProp, BaseStyle.emissionStrengthName.text);
            material.SetFloat("_Emission", emissive?1:0);
            // If texture was assigned and color was black set color to white
            if ((emissionMapProp != null) && (emissionColorProp != null))
            {
                var hadEmissionTexture = emissionMapProp?.textureValue != null;
                var brightness = emissionColorProp.colorValue.maxColorComponent;
                if (emissionMapProp.textureValue != null && !hadEmissionTexture && brightness <= 0f)
                    emissionColorProp.colorValue = Color.white;
            }

            bool canControl = material.HasProperty("_EmissionProcessControl");

            if (canControl)
            {
                DrawFloatToggleProperty(new GUIContent("自发光进度控制"),emissionProcessControlProp);
                materialEditor.FloatProperty(emissionHeightProp, "高度控制");
                DrawFloatToggleProperty(new GUIContent("反向控制"),emissionProcessInvProp);
            }

            if (emissive)
            {
                // Change the GI emission flag and fix it up with emissive as black if necessary.
                materialEditor.LightmapEmissionFlagsProperty(MaterialEditor.kMiniTextureFieldLabelIndentLevel, true);
            }
        }

        

        public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
        {
            // Clear all keywords for fresh start
            // Note: this will nuke user-selected custom keywords when they change shaders
            material.shaderKeywords = null;

            base.AssignNewShaderToMaterial(material, oldShader, newShader);

            // Setup keywords based on the new shader
        }
        internal static void DrawFloatToggleProperty(GUIContent styles, MaterialProperty prop, int indentLevel = 0, bool isDisabled = false)
        {
            if (prop == null)
                return;

            EditorGUI.BeginDisabledGroup(isDisabled);
            EditorGUI.indentLevel += indentLevel;
            EditorGUI.BeginChangeCheck();
            MaterialEditor.BeginProperty(prop);
            bool newValue = EditorGUILayout.Toggle(styles, prop.floatValue == 1);
            if (EditorGUI.EndChangeCheck())
                prop.floatValue = newValue ? 1.0f : 0.0f;
            MaterialEditor.EndProperty();
            EditorGUI.indentLevel -= indentLevel;
            EditorGUI.EndDisabledGroup();
        }

  
        public class BaseStyle
        {
            public static readonly GUIContent SurfaceOptions =EditorGUIUtility.TrTextContent("基础功能", "基础功能数据");
            public static readonly GUIContent AnimationOptions =EditorGUIUtility.TrTextContent("动画功能", "动画功能数据");

            public static readonly GUIContent surfaceType = EditorGUIUtility.TrTextContent("材质类型", "是否是透明材质");
            public static readonly string[] surfaceTypeNames = Enum.GetNames(typeof(SurfaceType));


            public static readonly string[] blendModeNames = Enum.GetNames(typeof(BlendMode));
            public static readonly GUIContent blendingMode = EditorGUIUtility.TrTextContent("透明度混合模式");

            public static readonly GUIContent cullingText = EditorGUIUtility.TrTextContent("剔除模式","Front-剔除正面，Back剔除后面，Both双面渲染");

            public static readonly string[] renderFaceNames = Enum.GetNames(typeof(RenderFace));

            public static readonly GUIContent zWriteControlTex = EditorGUIUtility.TrTextContent("自定义深度控制");

            public static readonly GUIContent zWrite = EditorGUIUtility.TrTextContent("深度写入");
            public static readonly string[] zwriteNames = Enum.GetNames(typeof(ZWriteControl));

            public static readonly GUIContent ztestText = EditorGUIUtility.TrTextContent("深度测试方式");
            //public static readonly string[] zwriteNames = Enum.GetNames(typeof(ZWriteControl));
            public static readonly string[] ztestNames = Enum.GetNames(typeof(ZTestMode)).Skip(1).ToArray();
            public static readonly int[] ztestValues = ((int[])Enum.GetValues(typeof(ZTestMode))).Skip(1).ToArray();

            public static readonly GUIContent alphaClipText = EditorGUIUtility.TrTextContent("透明度测试","透贴使用");
            public static readonly GUIContent alphaClipThresholdText = EditorGUIUtility.TrTextContent("透明度裁剪阈值");


            public static readonly GUIContent receiveShadowText = EditorGUIUtility.TrTextContent("接受阴影");


            public static readonly GUIContent SurfaceInputs = EditorGUIUtility.TrTextContent("表面数据");

            public static readonly GUIContent baseMap = EditorGUIUtility.TrTextContent("Albedo");
            public static readonly GUIContent AdvancedLabel = EditorGUIUtility.TrTextContent("高级选项");

            public static readonly GUIContent emissionMap = EditorGUIUtility.TrTextContent("自发光贴图");

            public static readonly GUIContent blendAdavant = EditorGUIUtility.TrTextContent("混合自定义");
            public static readonly GUIContent blendOP = EditorGUIUtility.TrTextContent("混合计算模式(BlendOP)");
            public static readonly string[] blendOPEnum = Enum.GetNames(typeof(UnityEngine.Rendering.BlendOp));
            public static readonly GUIContent srcBlend = EditorGUIUtility.TrTextContent("源颜色混合因子(Scr)");
            public static readonly GUIContent dstBlend = EditorGUIUtility.TrTextContent("目标颜色混合因子(Dst)");
            public static readonly string[] blendMode = Enum.GetNames(typeof(UnityEngine.Rendering.BlendMode));

            public static readonly GUIContent srcAlphaBlend = EditorGUIUtility.TrTextContent("源颜色透明度混合因子(ScrAlpha)");
            public static readonly GUIContent dstAlphaBlend = EditorGUIUtility.TrTextContent("目标颜色透明度混合因子(DstAlpha)");


            //Stencil
            public static readonly GUIContent stencilTest = EditorGUIUtility.TrTextContent("自定义模板测试");
            public static readonly GUIContent stencilValue = EditorGUIUtility.TrTextContent("模板值");
            public static readonly GUIContent stencilOp = EditorGUIUtility.TrTextContent("通过测试后的操作");
            public static readonly string[] stencilOpNames = Enum.GetNames(typeof(UnityEngine.Rendering.StencilOp));
            public static readonly GUIContent stencilMode = EditorGUIUtility.TrTextContent("模板值比较方式");
            public static readonly string[] stencilModeNames = Enum.GetNames(typeof(UnityEngine.Rendering.CompareFunction));

            public static readonly GUIContent realTimeRender = EditorGUIUtility.TrTextContent("实时阴影");

            public static readonly GUIContent emissionStrengthName = EditorGUIUtility.TrTextContent("自发光强度");
            
        }

    }

}

