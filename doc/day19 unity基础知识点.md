# day19 unity基础知识点

20201127

## 概要

----

## 知识点

### 1. 复制内容

```c#
GUIUtility.systemCopyBuffer = "我想复制内容";
```

​		通过对systemCopyBuffer，即可以实现复制功能；

### 2. GUIUtility 其他内容

1. keyboardControl

   获得鼠标聚焦的id。

2. hasModalWindow

   判断是否打开了Modal window，所谓modal window，即：`A modal dialog is a window that forces the user to interact with it before they can go back to using the parent application. A great example of this would be a prompt for saving, or the "open file" dialog`。即类似我们保存文件时，打开的保存界面，该界面回屏蔽其他界面的交互。

   ![](https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day19_01.png)

3.  hotControl

   获取当前点击的id（只在点击时才返回，注意跟keyboardControl区别），只能在button时才有用。

   