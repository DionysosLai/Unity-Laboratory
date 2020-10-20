# day7 顶点运动动画--叶子运动

2020.10.20

## 概要

​		前段时间，我们研究了The Vegetation Engine 插件，粗略讲了一下操作步骤，仙子啊我们理清下大概实现原理（后期阅读了源码，再做一次分析吧~~~），本文主要参考[顶点动画的应用1-植被随风摆动](https://zhuanlan.zhihu.com/p/138404140)一文，对其中一些步骤稍微拆解了一下。

---

## 前置知识点

​		叶子运动，主要靠顶点偏移实现，因此我们主要需要解决2个问题：

1. 如何获取叶子节点；
2. 如何叶子运动模拟；
3. 草运动方式和树运动方式（树运动方式比较复杂，分为树枝运动和树叶围绕树枝扰动）；

---

## 实践

### 1. 草

​		草运动方式比较简单，这里我们已盆栽模型为例。先简单创建一个空场景，并创建一个material和Unlit shader，将shader挂载在该material上，并赋予Tex_0120_5纹理。最终效果如下：

<img src="https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day7_01.png" style="zoom:67%;" />

#### 1.1 初始运动

​		由于一般叶子都是来回运动，因此我们采用最基础的sin函数，同时为了方便调整幅度，sin函数会乘以一个幅度系数。具体代码如下：

```glsl
Shader "Laboratory/day7/potTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Strengh("Strengh",Range(0,5)) = 1
        _Dirction("Dirction",vector) = (1,0,0,1)
    }
    SubShader
    {
      ....

            v2f vert (appdata v)
            {
                v2f o;
                float ripple = sin(_Time.y) * _Strengh;
                float3 offset = ripple * _Dirction.xyz;

                v.vertex.xyz += offset;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
	...
        }
    }
    Fallback "Diffuse"
}

```

​		将最终得到的offset与vertex 相加，就可以实现简单顶点偏移。同时，我们附加了一个方向变量，控制偏移方向。最终效果如图所示：

![](https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day7_01.gif)

#### 1.2 获取叶子顶点

​		从上图可以看出，目前偏移方式整体进行偏移，明显不符合运动规律，因此我们现在要只让叶子部分运动。将底盆和叶子部分分离，只需要简单根据高度分开就行。具体代码如下：

```glsl
   ...
	Properties
    {
        ...
        _RigOffset("RigOffset",Range(0,5)) = 0.2
    }
		...
            v2f vert (appdata v)
            {
                v2f o;

                float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
                //限制根部以下顶点(pos.y < _RigOffset)运动
                float offset_multiper = step(_RigOffset, worldPos.y);
                float ripple = sin(_Time.y) * _Strengh;
                float3 offset = ripple * _Dirction.xyz * offset_multiper;
			...
            }

```

​		_RigOffset 参数是为了方便控制高度属性，最终运动效果如下：

<img src="https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day7_02.gif.gif" style="zoom:80%;" />

​		可以看出来，运动方式有点儿鬼畜。这是因为从上到底，运动的幅度都是一样大（理论上应该类似杠杆摆幅），因此修改代码如下：

```glsl
float offset_multiper = step(_RigOffset, worldPos.y) * (worldPos.y - _RigOffset);
```

​		到目前为止，基本上对盆栽的运动模拟已经完成，最终效果如下：

<img src="https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day7_03.gif" style="zoom:80%;" />

### 2. 树叶

---

## 参考资料

1. 顶点动画的应用1-植被随风摆动: https://zhuanlan.zhihu.com/p/138404140

