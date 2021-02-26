# Unreal之Houdini Api 学习1

20210226

​		目前游戏领域中，程序化内容生产（Procedural  Content Generation， PCG）的比重越来越重，其中Houdini工具的运用占据了主要比例。目前网上很多资料都是偏向于美术侧，本文着重讲一些程序侧方向，主要是平时学习的记录。

​		Houdini Api地址：https://www.sidefx.com/docs/hengine17.5/index.html。

## 一. 版本问题

​		Houdini 对于版本要求很高，在项目中一般我们都是要求每个人安装的版本都必须一致。在学习过程中，需要区分下Houdini 软件版本和api版本，一面误导。

​		其中Houdini软件版本指的是我们实际安装软件的版本，一般在软件icon上就能看到。例如如下所示：

![image-20210226183641997](https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/image-20210226183641997.png)

​		Houdini Api 版本则只能通过代码中查看，查看位置：``HAPI_Version.h``中：

```c++
// The two components of the Houdini Engine (marketed) version.
#define HAPI_VERSION_HOUDINI_ENGINE_MAJOR 3
#define HAPI_VERSION_HOUDINI_ENGINE_MINOR 2
```

​		这里指定了我当前使用的Houdini Api 版本是3.2。同时，在这一个文件中也记录了对应的软件版本：

```c++
// The three components of the Houdini version that HAPI is
// expecting to compile against.
#define HAPI_VERSION_HOUDINI_MAJOR 17
#define HAPI_VERSION_HOUDINI_MINOR 5
#define HAPI_VERSION_HOUDINI_BUILD 391
#define HAPI_VERSION_HOUDINI_PATCH 0
```

​		另一方面，Houdini api 库提供函数``HAPI_GetEnvInt()``用来获取版本内容，通过给定``HAPI_EnvIntType``字段可获取到特定版本信息，类似代码如下：

```c++
int32 RunningMajor = 0;
int32 RunningMinor = 0;
int32 RunningBuild = 0;
int32 RunningPatch = 0;

if ( FHoudiniApi::IsHAPIInitialized() )
{
    const HAPI_Session * Session = FHoudiniEngine::Get().GetSession();
    // Retrieve version numbers for running Houdini.
    FHoudiniApi::GetEnvInt( HAPI_ENVINT_VERSION_HOUDINI_MAJOR, &RunningMajor );
    FHoudiniApi::GetEnvInt( HAPI_ENVINT_VERSION_HOUDINI_MINOR, &RunningMinor );
    FHoudiniApi::GetEnvInt( HAPI_ENVINT_VERSION_HOUDINI_BUILD, &RunningBuild );
    FHoudiniApi::GetEnvInt( HAPI_ENVINT_VERSION_HOUDINI_PATCH, &RunningPatch );
}
```

​		Ps：由于本地是Unreal版本的Houdini 库，与原生Houdini库存在一些差异，但并不影响理解，因此就手动改代码了。

---

## 二. 文件介绍

​		Houdini 安装之后，会提供Houdini Api库文件（同时会提供unity、unreal、maya等平台库文件）。路径参考如下：

```c++
C:\Program Files\Side Effects Software\Houdini 17.5.391\toolkit\include\HAPI
```

​		库文件包含：

```c++
HAPI.h // 声明所有API格式
HAPI_Common.h // 定义用到结构和枚举类
HAPI_Version.h // 版本信息
HAPI_Helpers.h // 声明一些用来初始化结构的函数
HAPI_API.h // 链接库 和其他一些定义
```

---

## 三. 对字符串的处理

​		