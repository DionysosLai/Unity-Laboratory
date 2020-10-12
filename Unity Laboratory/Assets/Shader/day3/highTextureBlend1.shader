Shader "Laboratory/day3/highTextureBlend1"
{
    Properties
    {
    	_Splat0 ("Layer 1(RGBA)", 2D) = "white" {}
    	_Splat1 ("Layer 2(RGBA)", 2D) = "white" {}
    	_Control ("_Control(RGBA)", 2D) = "white" {}
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
                float2 uv_Splat3 : TEXCOORD4;
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

            sampler2D _Splat0, _Splat1, _Control;
            float4 _Splat0_ST, _Splat1_ST, _Control_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv_Splat0 = TRANSFORM_TEX(v.uv_Splat0, _Splat0);
                o.uv_Splat1 = TRANSFORM_TEX(v.uv_Splat1, _Splat1);
                o.uv_Control = TRANSFORM_TEX(v.uv_Control, _Control);
                return o;
            }

            float3 blend(float4 lay1, float4 lay2)
            {
                return lay1.a > lay2.a ? lay1.rgb : lay2.rgb;
            }

            float3 blendWithControl(float4 lay1, float4 lay2, float4 splat_control)
            {
                return lay1.a * splat_control.r > lay2.a * splat_control.g ? lay1.rgb : lay2.rgb;
            }   

            float3 blendWithControl1(float4 lay1, float4 lay2, float4 splat_control)
            {
                float b1 = lay1.a * splat_control.r;
                float b2 = lay2.a * splat_control.g;
                float mm = max(b1, b2);
                b1 = max(b1 - (mm - 0.3), 0) * splat_control.r;
                b2 = max(b2 - (mm - 0.3), 0) * splat_control.g;

                return (lay1.rgb * b1 + lay2.rgb * b2)/(b1 + b2);
            }                      

            fixed4 frag(v2f i) : SV_Target
            {
                half4 lay1 = tex2D(_Splat0, i.uv_Splat0);
                half4 lay2 = tex2D(_Splat1, i.uv_Splat1);
                half4 splat_control = tex2D(_Control, i.uv_Control);

                fixed4 finalColor;
                finalColor.a = 1.0;
                finalColor.rgb = blend(lay1, lay2);
                //finalColor.rgb = blendWithControl(lay1, lay2, splat_control);
                //finalColor.rgb = blendWithControl1(lay1, lay2, splat_control);
                return finalColor;
            }
            ENDCG
        }
    }
}
