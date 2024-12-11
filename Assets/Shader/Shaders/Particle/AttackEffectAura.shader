Shader "FC/Particle/AttackEffect/Aura"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
		[Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("SrcBlend", Int) = 5
		[Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("DstBlend", Int) = 10
		[KeywordEnum(None,Add,Lerp)] _Blend("Blend", Float) = 0
		_EmissiveMultiply("Emissive Multiply", Float) = 1
		_OpacityMultiply("Opacity Multiply", Float) = 1
		_MainTexturePower("Main Texture Power", Float) = 1
		_Tiling("Tiling", Vector) = (1,1,1,1)
		_TimeScale1("Time Scale 1", Float) = 1
		_TimeScale2("Time Scale 2", Float) = 1
		[Toggle(_USEUVGRADIENT_ON)] _UseUVGradient("Use UV Gradient", Float) = 0

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
			
			Pass {
			
				HLSLPROGRAM
				
			
				
				#pragma vertex vert
				#pragma fragment frag
				#pragma target 2.0
				#pragma multi_compile_local _BLEND_NONE _BLEND_ADD _BLEND_LERP
				#pragma shader_feature_local _USEUVGRADIENT_ON


				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

				struct appdata_t 
				{
					float4 positionOS : POSITION;
					float4 color : COLOR;
					float4 texcoord : TEXCOORD0;
					
				};

				struct v2f 
				{
					float4 positionCS : SV_POSITION;
					float4 color : COLOR;
					float4 texcoord : TEXCOORD0;
					
				};
				
				
	

				//Don't delete this comment
				//  sampler2D_float _CameraDepthTexture;
                CBUFFER_START(UnityPerMaterial)
				 float4 _TintColor;
				 float4 _MainTex_ST;
				 float4 _Tiling;
				 float _InvFade;
				 int _DstBlend;
				 int _SrcBlend;
				 float _EmissiveMultiply;
				 float _TimeScale1;
				 float _MainTexturePower;
				 float _TimeScale2;
				 float _OpacityMultiply;
                CBUFFER_END
				 TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);


				v2f vert ( appdata_t v  )
				{
					v2f output;
		            VertexPositionInputs vertexInput = GetVertexPositionInputs(v.positionOS.xyz);
                    output.positionCS = vertexInput.positionCS;
				
					output.color = v.color;
					output.texcoord = v.texcoord;
					return output;
				}

				float4 frag ( v2f i  ) : SV_Target
				{
					float time1 = _Time.y * _TimeScale1;
					float2 uv1 = i.texcoord.xy * (_Tiling).xy + float2( 0,0 );
					uv1 = ( time1 * float2( 1,0 ) + uv1);
					float albedo1_R = pow( SAMPLE_TEXTURE2D( _MainTex,sampler_MainTex, uv1 ).r , _MainTexturePower );
					float time2 = _Time.y * _TimeScale2;
					float2 uv2 = i.texcoord.xy * (_Tiling).zw + float2( 0,0 );
					uv2 = ( time2 * float2( 1,0 ) + uv2);
					float albedo2_R = pow( SAMPLE_TEXTURE2D( _MainTex,sampler_MainTex, uv2 ).r, _MainTexturePower );
					float albedo_R = lerp( albedo1_R , albedo2_R , 0.5);
					#if defined(_BLEND_NONE)
					 albedo_R = albedo1_R;
					#elif defined(_BLEND_ADD)
					 albedo_R = ( albedo1_R + albedo2_R );
					#elif defined(_BLEND_LERP)
					 albedo_R = albedo_R;
					#else
					 albedo_R = albedo1_R;
					#endif
					float2 uv3 = i.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
					#ifdef _USEUVGRADIENT_ON
					float staticSwitch139 = saturate( uv3.x );
					#else
					float staticSwitch139 = 1.0;
					#endif
					float4 finalColor = ( _TintColor * saturate( albedo_R ) * i.color * staticSwitch139 );
					finalColor = (float4(( _EmissiveMultiply * float4( (finalColor).rgb , 0.0 ) * 1 ).rgb , saturate( ( (finalColor).a * _OpacityMultiply ) )));
					
					return finalColor;
				}
				ENDHLSL 
			}
		}	

		
	}
	
