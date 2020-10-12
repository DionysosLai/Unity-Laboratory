Shader "Laboratory/day3/highTextureBlend4"
{
    Properties
    {
    	_Splat0 ("Layer 1(RGBA)", 2D) = "white" {}
    	_Splat1 ("Layer 2(RGBA)", 2D) = "white" {}
    	_Splat2 ("Layer 3(RGBA)", 2D) = "white" {}
    	_Splat3 ("Layer 4(RGBA)", 2D) = "white" {}
    	_Control ("_Control(RGBA)", 2D) = "white" {}
        _Weight("Blend Weight" , Range(0.001,1)) = 0.2
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

            sampler2D _Splat0, _Splat1, _Splat2, _Splat3, _Control;
            float4 _Splat0_ST, _Splat1_ST, _Splat2_ST, _Splat3_ST, _Control_ST;
            float _Weight;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv_Splat0 = TRANSFORM_TEX(v.uv_Splat0, _Splat0);
                o.uv_Splat1 = TRANSFORM_TEX(v.uv_Splat1, _Splat1);
                o.uv_Splat2 = TRANSFORM_TEX(v.uv_Splat2, _Splat2);
                o.uv_Splat3 = TRANSFORM_TEX(v.uv_Splat3, _Splat3);
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
                b1 = max(b1 - (mm - _Weight), 0) * splat_control.r;
                b2 = max(b2 - (mm - _Weight), 0) * splat_control.g;

                return (lay1.rgb * b1 + lay2.rgb * b2)/(b1 + b2);
            }   

            inline half4 blendWithControl2(half high1, half high2, half high3, half high4, half4 control) 
            {
                half4 blend ;
                
                blend.r = high1 * control.r;
                blend.g = high2 * control.g;
                blend.b = high3 * control.b;
                blend.a = high4 * control.a;
                
                half ma = max(blend.r, max(blend.g, max(blend.b, blend.a)));
                blend = max(blend - ma +_Weight , 0) * control;
                return blend/(blend.r + blend.g + blend.b + blend.a);
            }                               

            fixed4 frag(v2f i) : SV_Target
            {
                half4 lay1 = tex2D(_Splat0, i.uv_Splat0);
                half4 lay2 = tex2D(_Splat1, i.uv_Splat1);
                half4 lay3 = tex2D(_Splat2, i.uv_Splat2);
                half4 lay4 = tex2D(_Splat3, i.uv_Splat3);
                half4 splat_control = tex2D(_Control, i.uv_Control);

                half4 blend = blendWithControl2(lay1.a,lay2.a,lay3.a,lay4.a,splat_control);
                
                fixed4 finalColor;
                finalColor.a = 1.0;
                finalColor.rgb = blend.r * lay1 + blend.g * lay2 + blend.b * lay3 + blend.a * lay4;//混合
                return finalColor;
            }
            ENDCG
        }
    }
}
