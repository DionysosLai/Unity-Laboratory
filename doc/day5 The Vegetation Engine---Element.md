# day5 The Vegeatation Engine --- Element

2010.10.13

## 概要

​		Element 跟gameobject类似，可以给植被添加上颜色属性、控制次表面效果、添加雪花遮罩或者角色交互等。

## 创建Element

​		在Hierarchy界面中，点击右键 BOXOPHOBIC->The Vegetation Engine->Element，即可添加一个Element 对象。Element 类型有 Color、Healthiness、Leaves、Motion、Wetness等几大类。可以修改shader，进行修改。

![](https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day4_11.png)

		1. Color 类型：对植被添加颜色；
  		2. Healthiness : ...不知道是干啥的
  		3. 。。。。。后面几个，自己尝试



需要注意一个点，element好像不能被作为预设。

## 示例1 创建一个颜色Element

​		创建一个Element，并选择Colors Element shader，同时Element Mode 选择Season 类型，并配置四个季节的颜色。如图所示：

![image-20201014094445195](C:\Users\dionysoslai\AppData\Roaming\Typora\typora-user-images\image-20201014094445195.png)

​		然后，动态调整The Vegetation Engine 中的season 属性即可。



## 示例2 创建运动交互

​		看YouTube 视频链接吧：https://www.youtube.com/watch?v=eCrEdavKHc4



​		

