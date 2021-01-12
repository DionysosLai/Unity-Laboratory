# day26 日常学习之Unreal

20201230

## 概要

​		Unreal日常学习1，主要关于世界构建内容

## 知识点

### 1. Reflection Captures

​		发射捕获器，包括：球体捕获、盒体捕获、平面捕获；

![](https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day26_01.png)

### 2. Volumes



### 3. HLOD

​		参考资料：https://www.52vr.com/extDoc/ue4/CHN/Engine/HLOD/HowTo/BuildingHLODs/index.html、https://zhuanlan.zhihu.com/p/110979817

​		Hierarchical Lod 即分层Lod，原理：在Lod基础上，不单独针对模型进行动态简化，而是以集群为单位生成代理模型，从而达到更进一步优化。主要有2个步骤：

  1. 生成集群（Generate clusters)

     决定了如何对场景中的模型进行分组，以及分组数量、是否生成材质等。通过对模型的合理分组(考虑空间、观察频率、以及制作者自定策略)，我们得到了由不同分组的组内模型所组成的集群

		2.  生成代理模型（Generate Proxy meshes)

     成代理模型即是对原本的集群生成新的网格体，在这一过程中，会将材质进行组合，并且生成新的光照贴图(如果需要)。所谓代理模型，即是在不需要精确观察模型的时候使用一个简单的模型代替之前的一堆模型.

**代理模型的存在大大降低了场景模型的复杂程度，并且也可以通过一定的设置进而降低Draw Call。**