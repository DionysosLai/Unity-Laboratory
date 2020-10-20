Shader "Laboratory/day7/potTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RigOffset("RigOffset",Range(0,5)) = 0.2
        _RippleFreq("RippleFreq",Range(0,10)) = 1
        _Strengh("Strengh",Range(0,5)) = 1
        _Dirction("Dirction",vector) = (1,0,0,1)
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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float _RigOffset, _Strengh, _RippleFreq;
            float4 _MainTex_ST, _Dirction;


            v2f vert (appdata v)
            {
                v2f o;

                float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
                //限制根部以下顶点(pos.y < _RootRigOffset)运动
                float offset_multiper = step(_RigOffset, worldPos.y) * (worldPos.y - _RigOffset);
                // //sin控制来回摆动，wpos为随机因子
                // float ripple = sin(_Time.y * _RippleFreq * UNITY_PI * 2 + wpos.x * wpos.z * 10) * _Strengh;
                // //最终融合 _OffsetRadio控制整体偏移
                // float3 offset = (ripple - _OffsetRadio) * _Dirction.xyz * offset_multiper;
                // v.vertex.xyz += offset;

                float ripple = sin(_Time.y * _RippleFreq * UNITY_PI * 2) * _Strengh;
                float3 offset = ripple  * _Dirction.xyz * offset_multiper;

                v.vertex.xyz += offset;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
