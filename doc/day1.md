# Day1 绘制一个圆

2020.10.04

## 背景

​		最近刚刚将《shader 入门精要》一书看完，虽然是针对unity版本5.6制作内容，但其实还是有很多东西值得学习。比方里面提到消融效果、水面波纹效果等，原理都是一致的。不过，是采用cg语言编写的，现在最新的unity 2020 版本都是采用hg语言了，然后还有shader graph 工具。这些都是需要与时俱进内容。

​		不过，这些内容暂时不影响一些原理理解与学习。因此，后续URP和上面说得内容将在接下来一段时间进行学习。当前任务，是一天一个主题，剖析一些知乎、km等遇到的一些内容，尝试搞懂，甚至进行进阶。

---

## 概要

​		绘制一个圆，相对来说是一个非常简单的内容，这个正好是我前几个月面试OPPO时，面试官提到的一个问题。当时说的不是很好，今天我们好好剖析它。

---

## 前置知识点

1. step 与 clip 区别

   ​		step 原型

   ```c++
   float step(float edge, float x)  
   vec2 step(vec2 edge, vec2 x)  
   vec3 step(vec3 edge, vec3 x)  
   vec4 step(vec4 edge, vec4 x)
   
   vec2 step(float edge, vec2 x)  
   vec3 step(float edge, vec3 x)  
   vec4 step(float edge, vec4 x)
   ```

   ​		如果x小于edge，则返回0， 否则返回1.

   ​		clip 原型

   ```glsl
   void clip(float4 x);
   void clip(float3 x);
   void clip(float2 x);
   void clip(float1 x);
   void clip(float  x);
   
   等同于：
   void clip(float4 x)
   {
     if (any(x < 0))
       discard;
   }
   ```

   ​		如果x小于0，则抛弃。注意，该函数没有返回值

2. lenght(v)

   原型

   ```glsl
   float length(float x)  
   float length(vec2 x)  
   float length(vec3 x)  
   float length(vec4 x)
   ```

   ​		返回一个向量的摸，即sqrt(dot(v,v))

3.  关于数据输入问题

   ​		由于需要材质需要挂载到给object对象上（这点当时想了好久，如何在scene 中显示一个圆），因此我们需要提供一个Quad object，并在将材质挂载在该对象上。

---

## 实践

	1. 创建一个场景同时天空盒去掉，顺带创建一个Quad 对象；
 	2. 创建一个shader和材质，分别命名为CircleShader 和 CircleMat，并将材质改成该shader；将CircleMat 材质挂载在Qard 对象上，以上创建内容，均会存储在对应day1文件夹中（今后类似步骤不在一一指出来）；

经过以上步骤后，场景中显示如下：

![Alt text](https://github.com/DionysosLai/Unity-Laboratory/blob/main/doc/res/day1/01.png)

打开CircleShader，重点是修改片段着色器。

1. 由于我们这里用不到一些自定义参数，因此需要将

   ``` glsl
   Properties
   {
       _MainTex ("Texture", 2D) = "white" {}
   }
   修改成
   Properties
   {
       _MainTex ("Texture", 2D) = "white" {}
   }
   ```

2. 采用lerp语句，抛弃超过原点一定距离得点，具体代码如下

   ```glsl
   fixed4 frag (v2f i) : SV_Target
   {
       return step(length(i.uv - fixed2(0.5, 0.5)), 0.3);
   }
   ```

   这里原点取object 中心点，半径为0.3。效果如下：

   ![Alt text](https://github.com/DionysosLai/Unity-Laboratory/blob/main/doc/res/day1/02.png)

One More

​		这里，我们可以自定义圆形的圆心和颜色值，并封装成一个独立函数：

```glsl
fixed4  DrawCircle(float2 screenUV, float2 pos, float radius, fixed4 color)
{   
    return step(length(screenUV - pos), radius) * color ;
}
```

​		自定义位置、半径和颜色三个参数

​		最终，我们将`frag` 函数改写成:

```glsl
fixed4 frag (v2f i) : SV_Target
{
    fixed4 _layer0=fixed4(0,0,0,1); // 底板颜色
    fixed4 _c0 = DrawCircle(i.uv, fixed2(0.5,0.7), 0.2, fixed4(1,0,0,1));
    fixed4 _c1 = DrawCircle(i.uv, fixed2(0.4,0.5), 0.2, fixed4(0,1,0,1));
    fixed4 _c2 = DrawCircle(i.uv, fixed2(0.6,0.5), 0.2, fixed4(0,0,1,1));
    return _layer0 + _c0 + _c1 + _c2;
}
```

​		这里，我们画了一个基本三原色图像。具体效果如下：

![Alt text](https://github.com/DionysosLai/Unity-Laboratory/blob/main/doc/res/day1/03.png)

----

## 更多

### 1. 一个问题

​		当模型的的Scale中x和y不一致时，明显得不到正圆，这个该如何解决？如图所示，此时该如何解决...

![Alt text](https://github.com/DionysosLai/Unity-Laboratory/blob/main/doc/res/day1/04.png)