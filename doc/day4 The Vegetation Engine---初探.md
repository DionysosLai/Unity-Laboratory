# day4 The Vegetation Engine --- 初探

2020.10.12

## 概要

​		The Vegetation Engine 是一款基于Unity 植被处理插件，官网地址：https://assetstore.unity.com/packages/tools/utilities/the-vegetation-engine-159647

​		从目前看来，该插件可以提供一系列高质量植被shader和植被设计工具。前段时间，原神游戏中的人物与植被交互方法，该插件就能很好的提供。

​		文档地址：

​		https://docs.google.com/document/d/145JOVlJ1tE-WODW45YoJ6Ixg23mFc56EnB_8Tbwloz8/edit#



## 开始学习

### 1. 导入插件

​		当我们首次导入插件后，需要进行安装，点击**Install**按钮即可。

<img src="https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day4_01.png" style="zoom:50%;" />

​		然后，需要安装一些渲染引擎和管线。这里我们选Standart 和 Unity Rendering 即可。后期如果要修改，可以通过 Window->BOXOPHOBIC->The Vegetation Engine->Hub 配置。

<img src="https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day4_02.png" style="zoom: 80%;" />

### 2. 添加控制器

​		管理器是整个插件的核心（目前看来是这样的），通过如图方式，可以在Hierarchy 中添加一个The Vegetation Engine，通过名字可以看到，这个应该就是植被的引擎了。

<img src="https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day4_03.png" style="zoom: 67%;" />

  1. Global Motion： 全局的风和湍流设置。其中植物叶子的点击交互由交互元件控制（这里，应该是指element）

  2. Global Seasons： 用来控制季节变化。其中Season 滑条并不会自己滑动，只会将当前的season传递给vegetation element（必须要有The Vegetation Element，不然很多效果看不出来，比方这里的season 变化。因此，我们有必要给season一个控制器，控制season slide 自主变化。

  3. Global Wetness：控制湿度变化。类似season

  4. Global Overlay：允许添加雪、灰尘、雨滴到场景的植被上。

  5. Global Size Fade：用来控制植被距离多远，就开始淡出视线。（这个功能，我一直没看到过，哭了）

  6. Global Volume：这个应该是最复杂的元素了。首先，所有需要受到插件效果的植被，都必须包含在这volume中，可以通过Gizmos 查看，如图所示

     <img src="https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day4_04.png" style="zoom:67%;" />

     文档中，有提到Global Volume会渲染具体element 到3个render texture 中，这块不好理解。其中，还有具体还有一些设置也没看懂。后期再看吧。



