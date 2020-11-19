# day13 unity 基础内容

20201112

## 概要

​		unity 日常内容

---

### 知识点

#### 1. Serializable

​		文章参考：https://blog.csdn.net/qq_15020543/article/details/82761416。

​		序列化主要是为了持续存储目的；

```
持久存储 ![img](http://images.csdn.net/syntaxhighlighting/OutliningIndicators/None.gif)我们经常需要将对象的字段值保存到磁盘中，并在以后检索此数据。尽管不使用序列化也能完成这项工作，但这种方法通常很繁琐而且容易出错，并且在需要跟踪对象的层次结构时，会变得越来越复杂。可以想象一下编写包含大量对象的大型业务应用程序的情形，程序员不得不为每一个对象编写代码，以便将字段和属性保存至磁盘以及从磁盘还原这些字段和属性。序列化提供了轻松实现这个目标的快捷方法
```

### 2. Compute Shader

​		贴下文章：https://zhuanlan.zhihu.com/p/102104374

​		场景：**高频的重复计算**,

```c++
[numthreads(1024, 1, 1)]

void ComputeVertexBufferHistoryPixel(uint3 Gid : SV_GroupID,
                        uint3 DTid : SV_DispatchThreadID,
                        uint3 GTid : SV_GroupThreadID,

{
    // refresh velocity and position now
    if (RefreshVelocity == 1)
    {
        float2 uv = float2(Data[GI].Position.x, 0.5f);
        float y = rand(float2(uv.x, Time));//noise2d(float2(uv.x, Time));
        Data[GI].CurrentVelocity += y;
    }
    //VertexBuffer[GI * 2] = Data[GI].Position;
    float RealVelocity = Data[GI].CurrentVelocity * VELOCITY_SCALE;
    Data[GI].Position += float3(0, TimeDelta * RealVelocity, 0);
    Data[GI].Position.y = clamp(Data[GI].Position.y, -FAR_DISTANCE, FAR_DISTANCE);
    float3 Original = Data[GI].Position;
    // VertexBuffer[GI] = Original;
    int VertexPos = 6 * GI;
    float3 QuadVertex[4];
    float xOffset = 2.0f / 1920.0f;
    float yOffset = 2.0f / 1080.0f;
    if (RealVelocity < 0)
    {
    	yOffset = -yOffset;
    }
    QuadVertex[0] = float3(Original.x - xOffset, Original.y, Original.z);
    QuadVertex[1] = float3(Original.x - xOffset, Original.y + yOffset, Original.z);
    QuadVertex[2] = float3(Original.x + xOffset, Original.y + yOffset, Original.z);
    QuadVertex[3] = float3(Original.x + xOffset, Original.y, Original.z);
    // 逆时针
    VertexBuffer[VertexPos++] = QuadVertex[0];
    VertexBuffer[VertexPos++] = QuadVertex[3];
    VertexBuffer[VertexPos++] = QuadVertex[2];
    VertexBuffer[VertexPos++] = QuadVertex[0];
    VertexBuffer[VertexPos++] = QuadVertex[2];
    VertexBuffer[VertexPos++] = QuadVertex[1];
}
```

