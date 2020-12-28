# day24 日常学习

## 概要



---

## 知识点

### 1. struct 问题

​		我们针对tranform 操作时，通常都是如下方式：

```c#
var localPosition = transform.localPosition;
localPosition.x = 5.0f;
transform.localPosition = localPosition;
```

​		这是因为vector3 是一个struct类型，可以理解为值类型，在接收 vector3 对象的时候，是**值拷贝**，而不是引用复制。

### 2. 静态

​		c#中包括静态方法、静态类、静态函数，其生命周期，从程序开始到程序结束，全局保持一个副本。具体可以看文章：[#之static（静态方法 静态类 静态函数）](https://www.jianshu.com/p/d0388cee645f)