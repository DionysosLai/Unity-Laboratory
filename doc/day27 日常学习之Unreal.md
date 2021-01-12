# day27 日常学习之Unreal

20201231

## 概要



## 知识点

​		世界构建一些建议

### 1. 关卡设计

​		ctrl + B：快速定位actor位置；

​		网格对齐



​	----渲染内容

### 1. 前置工作、可视性 Visibility

​		渲染前，cpu需要计算所有物体的一切信息，包括位置、变换内容

​		可视性包括：

 1. 距离剔除

    ![](https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day27_01.png)一般我们不会设置

 2. Frustum culling 视锥体剔除

 3. Precomputed culling 预计算剔除 

    默认不开启，不常用，适用于移动设备和低端设备（内存较大，但性能有限）

	4. Visibility culling 可视性剔除

    最强大的剔除功能（有个很有用的功能：~ 可以调出控制器命令），包含：硬件遮蔽（部分硬件不支持）、软件遮蔽

### 2. basebass 基础通道

​		作用：渲染几何体所有内容。首先确定需要渲染的所有物体---下载软件renderdoc

*Dynamic instacing*动态实例化：默认开启

*G buffer* 保存了5张图

*IES Profiles* ：

*Light Function*：光照函数