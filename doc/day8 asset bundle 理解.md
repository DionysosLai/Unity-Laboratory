# day8 asset bundle 理解

20201102

##  概要

​		由于之前对asset bundle 理解不是很透，因此专门对这块内容进行一次加强学习。

## 知识点

### 1. meta 文件

​		meta文件是unity管理文件的重要技术之一。具体文章可以看这篇[Managing Meta Files in Unity](https://www.forrestthewoods.com/blog/managing_meta_files_in_unity/)。主要有以下4个规则：

- 第一次导入资源的时候Unity会自动生成。

- 在Unity的面板里移动位置，Unity会自动帮你同步.meta文件。

- 在Unity打开的情况下，单独删除.meta，Unity可以确保重新生成的GUID和现有的一样。

- 在Unity关闭的情况下，移动或者删除.meta文件，Unity无法恢复到原有的GUID，也就是说引用会丢失。

  

  具体需要注意的是文件的的 guid，这是一个全局唯一索引id。同时，文中提到*对于文件夹的meta文件，没有作用，可以不用提交*。这点可以进行项目参考。

  guid 主要是用来标识文件，像我们一般再inspctor 界面中的资源索引，就是通过这个来实现。

### 2.  Unity 资源映射

​		unity 通过File GUIDS 、Local IDs和GUIDS和路径的映射表完成完整的资源映射关系。具体文章可以看[浅谈Assets——Unity资源映射](https://blog.uwa4d.com/archives/USparkle_Addressable1.html)。

​		其中， File guid 即meta 文件中的guid，**local id 没搞懂是哪个东东**。



### 3. Unity 文件详解

​		[Unity文件、文件引用、Meta详解](https://blog.uwa4d.com/archives/USparkle_inf_UnityEngine.html)这篇文章非常好，详细解释整套Unity 文件系统。

​		这里，对刚才Local id进行解释：通过GUID找到任何一个文件，通过FileID找到其中的某个子文件

### 4. Unity 资源加载

​		[入门必看：Unity资源加载及管理](https://mp.weixin.qq.com/s/0XFQt8LmqoTxxst_kKDMjw?)一文详细解释了Unity 资源加载机器管理内容，其中，对于Asset bundle 的运用讲的比较详细，建议仔细阅读并实践。