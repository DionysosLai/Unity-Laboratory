#  Unreal 之创建插件和添加模式

20210331

​		当一个模块功能随着迭代越发膨胀时，或者多个模块存在关联，一般我们都会采用插件方式进行管理。UE4引擎提供了大量插件，可以通过**菜单栏-->编辑-->插件**，看到当前已有的插件。

​		备注：当前分析内容时基于UE4.26版本。

---

## 一. 创建插件

### 1.1 通过UE4编辑器创建

​		编辑器本身提供了一件创建插件方式。打开插件列表（**菜单栏-->编辑-->插件**），在右下角可以看到按钮**新插件**，点击按钮就可以打开创建插件界面，如下所示：

<img src="C:\Users\dionysoslai\AppData\Roaming\Typora\typora-user-images\image-20210331162749836.png" alt="image-20210331162749836" style="zoom:67%;" />



​		根据自己需求，选择插件类型即可（这里需要注意，新插件的生效需要重启工程）。

​		

## 1.2 通过代码方式创建

​		插件的实际能，还是需要我们在代码中编写，通过UE4创建方式只能帮我们创建一个模板，因此我们通过代码方式创建一遍，熟悉下整体流程。假设我们当前需要创建的插件名称为：PluginTest。

​		首先，我们需要在当前工程的根目录下，创建一个Plugins文件夹（如果已经存在了，就没必要重复创建），这个文件夹是专门用来存放第三方插件位置。

​		接下来，我们在Plugins目录下，创建PluginTest文件夹，这个文件夹是专门存放我们新插件内容。之后在PluginTest目录下按照如下方式创建一系列文件。

```c++
---Resources（用来存放插件资源，例如图标等）
    Icon128.png（图标，这个文件随便从引擎内部插件找一个）
---Source（用来存放具体功能代码）
    ---PluginTest（一个模块功能，可以添加多个模块）
    	---Private
    		PluginTest.cpp
    	---Public
    		PluginTest.h
    	PluginTest.Build.cs
PluginTest.uplugin（插件描述内容）
```

​		主要包含.plugin文件、Build.cs 文件和.h .cpp 模块功能文件。

#### 1.2.1 uplugin文件

​		uplugin文件跟uproject文件功能类似，都是描述一系列配置信息，可以参看知乎文章[UE4 .uplugin和.uproject](https://zhuanlan.zhihu.com/p/114649056)。以下列出uplugin配置信息的具体含义和参考值：

```c++
{
   "FileVersion": 1, // 无效（这个字段，引擎代码中没看到描述字段，应该是之前遗留下来。）
   "Version": 1, // 插件版本
   "VersionName": "1.0", // 插件版本显示名称，提供给UI 显示
   "FriendlyName": "PluginTest", // 插件名称
   "Description": "Plugin Test", // 插件描述内容
   "Category": "Other",	// 插件类别，用来在引擎插件界面归类，其他类别包括2D、AI等
   "CreatedBy": "dio",	// 作者
   "CreatedByURL": "",  // 同上
   "DocsURL": "", // 文档路径
   "MarketplaceURL": "", // 插件售卖地址，可以用来给项目指定作用（如果当前项目没有安装，可以指定到整个路径去下载）
   "SupportURL": "", // 售后url
   "CanContainContent": true, // 插件是否可以包含content
   "IsBetaVersion": false, // 是否是beta版本
   "IsExperimentalVersion": false, // 是否是实验版本
   "Installed": false, // 表示默认是否启用，一般为false
   "Modules": [ // 插件里面拥有的模块（可以有多个模块）
      {
         "Name": "PluginTest", // 模块名称
         "Type": "Editor", // 对应环境下，该模块被加载（当前选择的Editor模式下）
         "LoadingPhase": "Default" // 模块加载时机（当前为默认时机，即在引擎初始化中加载，这个时机是在游戏模块加载之后执行）
      }
   ]
}
```

​		以上配置信息大部分都定义在文件``Engine\Source\Runtime\Projects\Public\PluginDescriptor.h``中。其中，比较关键的是Version和Modules字段。其中Modules中Type字段表示模块加载环境，具体参数有：

```c++
namespace EHostType
{
	enum Type
	{
		Runtime // 除了在program模式下，都会加载.
		RuntimeNoCommandlet,
		RuntimeAndProgram,
		CookedOnly, // 在cook 游戏时加载
		UncookedOnly, // 不在游戏cook时加载
		Developer, // 只在开发（Development）模式和编辑模式下加载，打包（Shipping）后不加载
		DeveloperTool, // bBuildDeveloperTools 参数为true时加载
		Editor, // 仅在编辑器启动时加载
		EditorNoCommandlet, // 仅在编辑器启动，且不在commandlet模式下加载
		EditorAndProgram,
		Program, // 独立的应用程序类型
		ServerOnly,
		ClientOnly,
		ClientOnlyNoCommandlet,
		Max
	};
};
```

​		比较常用的有Runtime和Editor2个模式，其他暂时没遇到。比较特使的是Program，指的是独立应用程序，暂时还没搞清楚是做什么用的，待后续实际用到时再补充。以上信息定义在文件：``Engine\Source\Runtime\Projects\Public\ModuleDescriptor.h``中。

​		Modules中另一个关键字段是LoadingPhase，表示的是加载阶段，用于控制该模块在什么时候加载和启动，默认为“Default”。具体参数有：

```c++
namespace ELoadingPhase
{
	enum Type
	{
		EarliestPossible,
		PostConfigInit, // 在配置信息加载后，引擎模块加载前加载该模块
		PostSplashScreen,
		PreEarlyLoadingScreen,
		PreLoadingScreen,
		PreDefault, // 在一般模块加载前加载
		Default, // 在加载引擎模块时加载
		PostDefault,
		PostEngineInit, // 在引擎模块加载后加载
		None, // 不要自动加载该模块
		Max
	};
};

```

​		一般我们采用默认设置Default，在引擎模块加载时一起加载。

#### 1.2.2 build.cs 文件

​		build.cs 文件则为每个模块的配置文件，一个插件可以有多个模块，因此各个模块的build.cs都是独立分开的。文件的作用为UnrealBuildTool（UBT）描述每个Module的“环境”依赖信息。由于这个配置文件为.cs形式，因此支持包括c#打印输出、变量定义、函数定义等特性。build.cs 文件内容如下所示：

```c#
public class PluginTest : ModuleRules
{
	public PluginTest(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = ModuleRules.PCHUsageMode.UseExplicitOrSharedPCHs;
		
		PublicIncludePaths.AddRange(
			new string[] {}
			);
		PrivateIncludePaths.AddRange(
			new string[] {}
			);
		PublicDependencyModuleNames.AddRange(
			new string[]
			{
				"Core",
			}
			);
		PrivateDependencyModuleNames.AddRange(
			new string[]
			{
				"Projects",	"InputCore", "UnrealEd", "ToolMenus", "CoreUObject", "Engine", "Slate",	"SlateCore",				
			}
			);
		DynamicallyLoadedModuleNames.AddRange(
			new string[]{}
			);
	}
}
```

​		其中PublicDependencyModuleNames表示公共依赖模块名称列表，这个库表示我们public 代码所需要的模块（由于我们一般在public中放的都是h文件，因此这个目录依赖的很少。

​		PrivateDependencyModuleNames表示私有依赖模块名称列表。这些依赖模块都是我们的private代码所依赖的模块，但我们的public文件中不会有对这些模块的依赖。由于主要代码都是在private中，因此这个依赖模块会比较多。

​		PublicIncludePaths表示暴露给其他模块使用的公共依赖头文件路径（如果是在Public目录下则不需要添加），这样比如public/xxx目录，添加到这里的之后，代码总包含目录可以去掉相对路径xxx