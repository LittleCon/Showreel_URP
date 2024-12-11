// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FC/Particle/Default"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
		[Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("SrcBlend", Int) = 5
		[Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("DstBlend", Int) = 10
		_EmissiveMultiply("Emissive Multiply", Float) = 1
		_OpacityMultiply("Opacity Multiply", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

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
				
				
                CBUFFER_START(UnityPerMaterial)
				 sampler2D _MainTex;
				 float4 _TintColor;
				 float4 _MainTex_ST;
				 float _InvFade;
				 int _DstBlend;
				 int _SrcBlend;
				 float _EmissiveMultiply;
				 float _OpacityMultiply;
                CBUFFER_END

				v2f vert ( appdata_t v  )
				{
					v2f o;
					VertexPositionInputs vertexInput = GetVertexPositionInputs(v.positionOS.xyz);
                    o.positionCS = vertexInput.positionCS;
					o.color = v.color;
					o.texcoord = v.texcoord;
					return o;
				}

				float4 frag ( v2f i  ) : SV_Target
				{

					float2 uv_MainTex = i.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
					float4 finalColor = ( _TintColor * tex2D( _MainTex, uv_MainTex ) * i.color *2.2 );
					finalColor = (float4(( _EmissiveMultiply * (finalColor).rgb ) , saturate( ( (finalColor).a * _OpacityMultiply ) )));
					

					return finalColor;
				}
				ENDHLSL 
			}
		}	


		
	}
	
	
