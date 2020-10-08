# day2 纹理混合--基础内容

2020.10.08

## 概要

​		纹理混合在游戏中用处十分常见，常见的有基于高度纹理混合、透明度混合等内容。

## 前置知识点

​		首先，我们需要能够实现最基本的纹理贴图实现。完整shader代码如下：

```glsl
Shader "Laboratory/day2/SingleTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float4 mainTex = tex2D(_MainTex, i.uv);
                return mainTex;
            }
            ENDCG
        }
    }
}

```

​		具体效果图如下所示：具体效果查看Scenes/day2/day2_1

<img src="https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day2_01.png" style="zoom:50%;" />

## 实践

1. 基础混合

   ​		这里，我们再次添加一张纹理，直接对采集之后的纹理进行最基础**加**操作。核心代码如下:

   ```glsl
   Shader "Laboratory/day2/MulTexture"
   {
       Properties
       {
           _MainTex ("Main Texture", 2D) = "white" {}
           _SecTex ("Seccond Texture", 2D) = "white" {}
       	....
               sampler2D _MainTex, _SecTex;
               float4 _MainTex_ST;
   		   ....	
               fixed4 frag(v2f i) : SV_Target
               {
                   float4 mainTex = tex2D(_MainTex, i.uv);
                   float4 secTex = tex2D(_MainTex, i.uv);
                   return mainTex + secTex;
               }
               ENDCG
           }
       }
   }
   
   ```

   ​		具体效果图如下所示：具体效果查看Scenes/day2/day2_2

   

2.  