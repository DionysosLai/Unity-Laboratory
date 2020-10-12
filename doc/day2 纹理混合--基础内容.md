# day2 纹理混合--基础内容

2020.10.08

## 概要

​		纹理混合在游戏中用处十分常见，常见的有基于高度纹理混合、透明度混合等内容。

---

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

---

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

   <img src="https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day2_02.png" style="zoom:50%;" />

2.  通道混合 

   ​		基于加操作的纹理混合是一个非常基础内容，用处并不是很广泛，更实际多的的情况是更加纹理通道进行混合。核心代码如下：

   ```glsl
   Shader "Laboratory/day2/MulAlphaTexture"
   {
       Properties
       {
   		_RTexture("Red Channel Texture",2D) = ""{}
   		_GTexture("Green Channel Texture",2D) = ""{}
   		_BTexture("Blue Channel Texture",2D) = ""{}
   		_ATexture("Alpha Channel Texture",2D) = ""{}
           _BlendTex("Blend Texture",2D) = ""{}
   		....
               sampler2D _RTexture, _GTexture, _BTexture, _ATexture, _BlendTex;
               float4 _RTexture_ST;
   		   .....
   
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
   
   ```

   ​		这里需要混合4张图片，并且根据第五章纹理的g通道进行混合，效果如下：

   <img src="https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day2_03.png" style="zoom:50%;" />

----

## 更多

​		那基于高度纹理混合是如何实现呢？透明混合又是如何实现呢？在接下来文章中，会提到这些内容