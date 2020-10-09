Shader "Laboratory/day2/MulAlphaTexture"
{
    Properties
    {
		_RTexture("Red Channel Texture",2D) = ""{}
		_GTexture("Green Channel Texture",2D) = ""{}
		_BTexture("Blue Channel Texture",2D) = ""{}
		_ATexture("Alpha Channel Texture",2D) = ""{}
        _BlendTex("Blend Texture",2D) = ""{}
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

            sampler2D _RTexture, _GTexture, _BTexture, _ATexture, _BlendTex;
            float4 _RTexture_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _RTexture);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float4 RTex = tex2D(_RTexture, i.uv);
                float4 GTex = tex2D(_GTexture, i.uv);
                float4 BTex = tex2D(_BTexture, i.uv);
                float4 ATex = tex2D(_ATexture, i.uv);
                float4 blendData = tex2D(_BlendTex, i.uv);


                //使用线性插值对纹理进行混合
                float4 finalColor;
                finalColor = lerp(RTex, GTex, blendData.g);
                finalColor = lerp(finalColor, BTex, blendData.g);
                finalColor = lerp(finalColor, ATex, blendData.g);
                finalColor.a = 1.0;

                return finalColor;
            }
            ENDCG
        }
    }
}
