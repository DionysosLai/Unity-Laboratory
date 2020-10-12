Shader "Laboratory/day3/highTextureBlend"
{
    Properties
    {
    	_Splat0 ("Layer 1(RGBA)", 2D) = "white" {}
    	_Splat1 ("Layer 2(RGBA)", 2D) = "white" {}
    	_Splat2 ("Layer 3(RGBA)", 2D) = "white" {}
    	_Splat3 ("Layer 4(RGBA)", 2D) = "white" {}
    	_Control ("Control (RGBA)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv_Control : TEXCOORD0;
                float2 uv_Splat0 : TEXCOORD1;
                float2 uv_Splat1 : TEXCOORD2;
                float2 uv_Splat2 : TEXCOORD3;
                float2 uv_Splat3 : TEXCOORD3;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv_Control : TEXCOORD0;
                float2 uv_Splat0 : TEXCOORD1;
                float2 uv_Splat1 : TEXCOORD2;
                float2 uv_Splat2 : TEXCOORD3;
                float2 uv_Splat3 : TEXCOORD4;
            };

            sampler2D _Control, _Splat0, _Splat1, _Splat2, _Splat3;
            float4 _Control_ST, _Splat0_ST, _Splat1_ST, _Splat2_ST, _Splat3_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv_Control = TRANSFORM_TEX(v.uv_Control, _Control);
                o.uv_Splat0 = TRANSFORM_TEX(v.uv_Splat0, _Splat0);
                o.uv_Splat1 = TRANSFORM_TEX(v.uv_Splat1, _Splat1);
                o.uv_Splat2 = TRANSFORM_TEX(v.uv_Splat2, _Splat2);
                o.uv_Splat3 = TRANSFORM_TEX(v.uv_Splat3, _Splat3);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 splat_control = tex2D(_Control, i.uv_Control);
                half4 lay1 = tex2D(_Splat0, i.uv_Splat0);
                half4 lay2 = tex2D(_Splat1, i.uv_Splat1);
                half4 lay3 = tex2D(_Splat2, i.uv_Splat2);
                half4 lay4 = tex2D(_Splat3, i.uv_Splat3);

                fixed4 finalColor;
                finalColor.a = 1.0;
                finalColor.rgb = (lay1 * splat_control.r + lay2 * splat_control.g + lay3 * splat_control.b + lay4 * splat_control.a);
                return finalColor;
            }
            ENDCG
        }
    }
}
