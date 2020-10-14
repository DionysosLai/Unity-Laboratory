// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
Shader "Laboratory/day6/Additive Mask"{
Properties {
	_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
	_MainTex ("Particle Texture", 2D) = "white" {}
	_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0

	// _MinX ("Min X", Float) = -1
    // _MaxX ("Max X", Float) = 1
    // _MinY ("Min Y", Float) = -1
    // _MaxY ("Max Y", Float) = 1
}
 
Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	Blend SrcAlpha One
	ColorMask RGB
	Cull Off Lighting Off ZWrite Off
	
	SubShader {
		Pass {
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_particles
 
			#include "UnityCG.cginc"
 
			sampler2D _MainTex;
			fixed4 _TintColor;

			// float _MinX;
            // float _MaxX;
            // float _MinY;
            // float _MaxY;

			
			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};
 
			struct v2f {
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				#ifdef SOFTPARTICLES_ON
				float4 projPos : TEXCOORD1;
				#endif

				float3 vpos : TEXCOORD2;
			};
			
			float4 _MainTex_ST;
 
			v2f vert (appdata_t v)
			{
				v2f o;

				o.vpos = UnityObjectToClipPos(v.vertex);

				o.vertex = UnityObjectToClipPos(v.vertex);
				#ifdef SOFTPARTICLES_ON
				o.projPos = ComputeScreenPos (o.vertex);
				COMPUTE_EYEDEPTH(o.projPos.z);
				#endif
				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}
 
			sampler2D_float _CameraDepthTexture;
			float _InvFade;
			
			fixed4 frag (v2f i) : SV_Target
			{
				#ifdef SOFTPARTICLES_ON
				float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
				float partZ = i.projPos.z;
				float fade = saturate (_InvFade * (sceneZ-partZ));
				i.color.a *= fade;
				#endif

				fixed4 c =2.0f * i.color * _TintColor * tex2D(_MainTex, i.texcoord);
				 
				// clip(i.vpos.x - _MinX);
				// clip(_MaxX - i.vpos.x);
				// clip(i.vpos.y - _MinY);
				// clip(_MaxY - i.vpos.y);

                return c;
			}
			ENDCG 
		}
	}	
}
}