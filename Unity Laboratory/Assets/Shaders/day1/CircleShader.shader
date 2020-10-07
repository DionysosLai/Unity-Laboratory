// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Laboratory/day1/CircleShader"
{
    Properties
    {
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv=v.uv;
                return o;
            }

            fixed4  DrawCircle(float2 screenUV, float2 pos, float radius, fixed4 color)
            {   
                return step(length(screenUV - pos), radius) * color ;
            }

            fixed4 DrawCircleClip(float2 screenUV, float2 pos, float radius, fixed4 color)
            {
                clip(length(screenUV - pos) - radius);
                return color;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 _layer0=fixed4(0,0,0,1); // 底板颜色
                fixed4 _c0 = DrawCircle(i.uv, fixed2(0.5,0.7), 0.2, fixed4(1,0,0,1));
                fixed4 _c1 = DrawCircle(i.uv, fixed2(0.4,0.5), 0.2, fixed4(0,1,0,1));
                fixed4 _c2 = DrawCircle(i.uv, fixed2(0.6,0.5), 0.2, fixed4(0,0,1,1));
                return _layer0 + _c0 + _c1 + _c2;
            }
            ENDCG
        }
    }
}
