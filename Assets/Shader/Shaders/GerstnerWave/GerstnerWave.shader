Shader "FC/Water/GerstnerWave"
{
    Properties
    {
        _NormalMap ("NormalMap", 2D) = "bump" {}
        _BumpScale("BumpScale",Range(0,5))=1
        _FoamMap("FoamMap", 2D) = "white" {}
        _Speed("WaveSpeed",Float)=1.0
        _AbsorptionScatteringRamp("_AbsorptionScatteringRamp",2D)= "white" {}
        [Space(20)]
		_StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" }
        LOD 100

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp] 
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Pass
        {
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _REFLECTION_PLANARREFLECTION
            #pragma shader_feature _ USE_STRUCTURED_BUFFER
             #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "./WaterHelp.hlsl"
            
         

            TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);
            TEXTURE2D(_FoamMap); SAMPLER(sampler_FoamMap);
            CBUFFER_START(UnityPerMaterial)
            float _BumpScale;
            float _Speed;
            float4 _AbsorptionScatteringColor;
            CBUFFER_END

            WaterVertexOutput vert (WaterVertexInput v)
            {
                
                WaterVertexOutput o;// = (WaterVertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.uv.xy = v.texcoord; // geo uvs
                o.posWS = TransformObjectToWorld(v.vertex.xyz);

                o = WaveVertexOperations(o,_Speed);
                
                return o;
            }

            float4 frag (WaterVertexOutput i) : SV_Target
            {
                // sample the texture

                UNITY_SETUP_INSTANCE_ID(i);
                half3 screenUV = i.shadowCoord.xyz / i.shadowCoord.w;

                //获取水深
                float rawD = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture,screenUV );
	            float d = LinearEyeDepth(rawD, _ZBufferParams);
                float waterDepth = d- i.clipPos.w;
                
                float4 normal1 = SAMPLE_TEXTURE2D(_NormalMap,sampler_NormalMap, i.uv)*2-1;
                float4 normal2 = SAMPLE_TEXTURE2D(_NormalMap,sampler_NormalMap, i.uv.zw)*2-1;
                float4 normal = (normal1+normal2*0.5)* saturate(waterDepth * 0.25 + 0.25);

                float3 normalWS = normalize(i.normal + half3(normal.x, 0, normal.y) * _BumpScale);

                //根据法线和水深计算扭曲参数
                half2 distortion = DistortionUVs(waterDepth.x, normalWS);
                distortion = screenUV.xy + distortion;
                float rawD2 = LoadSceneDepth(distortion );
	            float d2 = LinearEyeDepth(rawD2, _ZBufferParams);
                waterDepth = d2- i.clipPos.w;
                distortion = waterDepth.x < 0 ? screenUV.xy : distortion;
                waterDepth = waterDepth < 0 ? d : waterDepth;

                //菲涅尔折射
                // half fresnelTerm = CalculateFresnelTerm(normalWS, i.viewDir.xyz);
                 half waterDepth2 = WaterTextureDepth(i.posWS);
                 half vtxOffset = pow(saturate((-waterDepth2 + 0.5) * 0.2), 2);
                // half fresnelFadeTerm = pow(saturate(vtxOffset * 16.f), 16.f);
                // half fresnelFadeScale = pow(saturate(1.f - normalize(i.viewDir).y), 2);
                // fresnelFadeTerm = saturate(fresnelFadeTerm * fresnelFadeScale * 12);
                half fresnelTerm = 0;

                //水面反射
                half2 reflectUV = screenUV.xy+normalWS.zx*half2(0.02,0.15);
                float3 reflection= SAMPLE_TEXTURE2D_LOD(_ReflectionRT,sampler_ReflectionRT_linear_clamp,reflectUV,0).rgb;
            
                //折射
                //half3 refraction = SAMPLE_TEXTURE2D_LOD(_CameraOpaqueTexture, sampler_CameraOpaqueTexture_linear_clamp, distortion, waterDepth * 0.25).rgb;
                //half3 scatterFactor = SAMPLE_TEXTURE2D(_AbsorptionScatteringRamp, sampler_AbsorptionScatteringRamp, half2(waterDepth/_MaxDepth, 0.0h)).rgb;
                //refraction*=scatterFactor;

                //散射
                Light lightData = GetMainLight(TransformWorldToShadowCoord(i.posWS));
                half3 directLighting = dot(lightData.direction, half3(0, 1, 0)) * lightData.color*0.1;
                directLighting += saturate(pow(dot(i.viewDir, -lightData.direction) * i.additionalData.z, 3)) * 5 * lightData.color*0.1;
                float shadow = lightData.shadowAttenuation;
                float GI = half3(0,0,0);

                float3 sss = directLighting *shadow ;
                float3 scatterFactor2 = SAMPLE_TEXTURE2D(_AbsorptionScatteringRamp, sampler_AbsorptionScatteringRamp, half2(waterDepth/_MaxDepth, 0.375h)).rgb;
                sss*=scatterFactor2.rgb*0.5;
                
               

                //浮沫
                float wd = WaterTextureDepth(i.posWS);
	            wd = wd + i.posWS.y;
                half3 foamMap = SAMPLE_TEXTURE2D(_FoamMap, sampler_FoamMap,  i.uv.zw).rgb; //r=thick, g=medium, b=light
                half depthEdge = saturate(waterDepth.x * 20);
                half waveFoam = saturate(i.additionalData.z - 0.75 * 0.5); // wave tips
                half depthAdd = saturate(1 - waterDepth.x * 4) * 0.5;
                half edgeFoam = saturate((1 - min(waterDepth.x, wd) * 0.5 - 0.25) + depthAdd) * depthEdge;
                half foamBlendMask = max(max(waveFoam, edgeFoam), 0);//waterFX.r * 2);
                half3 foamBlend = SAMPLE_TEXTURE2D(_AbsorptionScatteringRamp, sampler_AbsorptionScatteringRamp, half2(foamBlendMask, 0.66)).rgb;
                half foamMask = saturate(length(foamMap * foamBlend) * 1.5 - 0.1);
            //custom-begin: Fade out fresnel in shallows
                half foamFadeTerm = saturate(vtxOffset * 16.f);
                foamMask *= 1.f - foamFadeTerm;
                half3 foam = foamMask.xxx * (lightData.shadowAttenuation * lightData.color + GI);

                


                //高光
                BRDFData brdfData;
                half alpha = 1;
                InitializeBRDFData(half3(0, 0, 0), 0, half3(1, 1, 1), 0.95, alpha, brdfData);
                half3 spec = DirectBDRF(brdfData, normalWS, lightData.direction, i.viewDir) * shadow * lightData.color;
                spec *= saturate(1.f - foamFadeTerm * 2);

                float3 finalColor = lerp(sss + spec, foam, foamMask);//lerp(refraction+ sss + spec, foam, foamMask);

                return float4(finalColor,1);
            }
            ENDHLSL
        }
    }
}
