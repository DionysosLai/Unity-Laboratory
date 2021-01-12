# day29 日常学习之Unreal 1

20210104

## 1. 概要

​		本文记录的内容是在学习UE4开发时，第一次采用UE4 C++进行编程开发遇到一些问题汇总。记录一下。

---

## 2. 编程类内容

### 2.1 查找包含的头文件

​		UE 中使用很多类的前提必须是先包含头文件，因此UE使用C++编程的第一个技巧是要学会找到相应的类头文件。比方我们要查找`UGameplayStatics`的头文件，在Google下搜索关键字`UGameplayStatics`之后，一般在第一项，会看到Unreal Engine Document标定的网页，打开网页中可以看到如下内容：

<img src="https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day29_01.png" style="zoom: 80%;" />

​		其中，header指向其头文件地址，因此我们在引用进行include即可（取Classes后面地址即可）：

```
#include "Kismet/GameplayStatics.h"
```

### 2.2 CreateDefaultSubobject

​		CreateDefaultSubobject 用来创建静态网格物体，包含UStaticMeshComponent、USphereComponent等。类似代码如下：

```c++
this->CollectableMesh = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("CollectableMesh"));
this->BaseCollisionComponent = CreateDefaultSubobject<USphereComponent>(TEXT("BaseCollisionComponent"));
```

​		TEXT包含的文字用来标定创建物体的名称。

​		这块功能在蓝图中就是添加组件功能。我们可以看到蓝图中显示如下：

![](https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day29_02.png)

​		由于对象CollectableMesh和BaseCollisionComponent是通过c++方式创建，因此我们右键无法进行删除。

### 2.3 ConstructorHelpers

​		ConstructorHelpers::FObjectFinder<T> 和 ConstructorHelpers::FClassFinder<T> 是UE4中的c++静态加载功能，相对应的有动态加载功能LoadClass。例如我们静态加载mesh 和 material：

```c++
// 静态加载一个圆柱体mesh
static ConstructorHelpers::FObjectFinder<UStaticMesh> Cylinder(TEXT("'/Game/StarterContent/Shapes/Shape_Cylinder'"));
if (Cylinder.Succeeded()) {
    ....
}
// 静态加载一个材质Material
static ConstructorHelpers::FObjectFinder<UMaterial> VulnerableMat(TEXT("'/Game/Materials/M_Enemy_Vulnerable'"));
if (VulnerableMat.Succeeded()) {
    ....
}
```

​		其中TEXT表示物件的地址StarterContent 表示引擎自带内容。

引申阅读：[[UE4]C++静态加载问题：ConstructorHelpers::FClassFinder()和FObjectFinder()](https://blog.csdn.net/or_7r_ccl/article/details/53174023)

### 2.4 UGameplayStatics

​		UGameplayStatics是一个非常实用的静态类，用来快速获取类对象。例如：

```c++
// 获取游戏模式
APacmanGameModeBase* GameMode = Cast<APacmanGameModeBase>(UGameplayStatics::GetGameMode(this));
// 获取角色
APacmancharacter* Pacman = Cast<APacmancharacter>(UGameplayStatics::GetPlayerPawn(this, 0));
```

### 2.5 自定义拓展相关

​		`UPROPERTY`用来出翔编辑器设置。原型：``UPROPERTY(属性1,属性2...)``。类似代码如下：

```c++
UPROPERTY(VisibleAnywhere, Category = Collectable)
UStaticMeshComponent* CollectableMesh;
```

​		其中, VisibleAnywhere表示编辑器面板中可见，Category表示分类功能。类似功能还有：

​		EditAnywhere: 表示暴露在编辑器以便随时编辑的变量

​		BlueprintReadWrite: 支持蓝图对该变量的读写操作等等

​		引申阅读：[UPROPERTY属性修饰符](https://blog.csdn.net/ccccce/article/details/102498815)、[UE4编辑器扩展踩坑血泪史](https://zhuanlan.zhihu.com/p/58204579)

### 2.6 C++新特性与UE下C++内容

 #### 2.6.1 UE下的内联函数

​		与通常c++内联函数inline方式不一样，UE下C++内联关键字是`FORCEINLINE`(手动狗头，为啥要这样写？？？？)，示例如下：

```c++
FORCEINLINE void SetCurrentHP(float CurrentHP){this->CurrentHP=CurrentHP;}
FORCEINLINE float GetCurrentHP(){return CurrentHP;}
```

#### 2.6.2 强类型枚举类

​		在标准C++中，枚举类型并不是类型安全的。枚举类型被视为整数，这使得两种不同的枚举类型之间可以进行比较。例如：

```c++
enum Enumeration1
{
    Val1, // 0
    Val2, // 1
    Val3 = 100,
    Val4 /* = 101 */
};
```

​		其中Enumeration1.Val4 == 101，结果为true。因此，在C++11中引入一种特别的"枚举类"，采用`enum class`方式。例如：

```c++
enum class EGameState : short
{
	EMenu,
	EPlaying,
	EPause,
	EWin,
	EGameOver
};
```

​		这里short用来表示类型。

---

## 3. UE 操作内容

### 3.1 设置起始关卡

​		当我们创建一个新关卡时，如果需要将这个关卡设置为起始关卡，需要在`地图和模式`中进行相关设置：**编辑->项目设置->项目->地图和模式**，界面如下所示：

![](https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day29_03.png)

​		根据需要设定相应关卡即可。

### 3.2 轴映射和操作映射

​		操作映射针对按下和松开2个处理，轴映射针对持续的输入（类似遥感的输入），需要在`输入`中进行设置：**编辑->项目设置->引擎->输入**，界面如下：

![](https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day29_04.png)

​		设置好之后，需要在C++层面进行配置：

```c++
void APacmancharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
	Super::SetupPlayerInputComponent(PlayerInputComponent);

	PlayerInputComponent->BindAxis("MoveX", this, &APacmancharacter::MoveXAxis);
	PlayerInputComponent->BindAxis("MoveY", this, &APacmancharacter::MoveYAxis);

	PlayerInputComponent->BindAction("NewGame", IE_Pressed, this, &APacmancharacter::NewGame);
	PlayerInputComponent->BindAction("ReStart", IE_Pressed, this, &APacmancharacter::ReStart);
	PlayerInputComponent->BindAction("Pause", IE_Pressed, this, &APacmancharacter::Pause);
}

void APacmancharacter::MoveXAxis(float AxixValue)
{
	...
}

void APacmancharacter::ReStart()
{
	...
}
```

​		其中函数`SetupPlayerInputComponent`是用来绑定输入和执行函数。

​		PS:在蓝图中如何设置呢？

### 3.3 碰撞通道

​		默认情况下，在UE中设置的Actor对象都会互相碰撞（添加了碰撞胶囊体之后）；另一个方面只有设置了正确的碰撞检测类型，才能处理好碰撞信息。因此，我们需要在`碰撞`中进行设置：**编辑->项目设置->引擎->碰撞**界面如下：

![](https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day29_05.png)

​		这里有一点需要注意下：Preset显示内容中，并不会有一个下拉控件，因此有时候这个界面偏小时，会将部分内容遮挡住，这时需要我们将界面拉大，才能看到剩下内容。

​		首先，在`Object Channels`中，点击`新建Object通道`，可以新建一个通道。这里，我们新建了一个Enemy，默认类型会Block的通道。

​		然后，在Preset中，新建一个碰撞类型。这里，我们同样添加了一个Enemy，设置如下：

![](https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day29_06.png)

​		其中，WoldStatic表示一个静态对象，比方墙、建筑等；Pawn表示主角，设置为重叠类型，表示会跟主角进行碰撞检测。

​		最后，将关卡的特定对象进行碰撞预设设定，如下所示：

![](https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day29_07.png)

​		剩下的工作，我们就是在C++层面进行碰撞检测了。

```c++
// .h 文件
UFUNCTION()
void OnCollision(class UPrimitiveComponent* HitComp, class AActor* OtherActor, class UPrimitiveComponent* OtherComp, int OtherBodyIndex, bool bFromSweep, const FHitResult & SweepResult);

// .cpp 文件
AEnemyCharacter::AEnemyCharacter()
{
 	// Set this character to call Tick() every frame.  You can turn this off to improve performance if you don't need it.
	PrimaryActorTick.bCanEverTick = true;
	SetActorEnableCollision(true);
}

// Called when the game starts or when spawned
void AEnemyCharacter::BeginPlay()
{
	Super::BeginPlay();
	GetCapsuleComponent()->OnComponentBeginOverlap.AddDynamic(this, &AEnemyCharacter::OnCollision);
}
void APacmancharacter::OnColliOnsion(UPrimitiveComponent* HitComp, AActor* OtherActor, UPrimitiveComponent* OtherComp, int OtherBodyIndex, bool bFromSweep, const FHitResult& SweepResult)
{
    if (OtherActor->IsA(ACollectables::StaticClass())) {
        ACollectables* collectable = Cast<ACollectables>(OtherActor);
	   ...
    }
}

```

​		默认情况下时不开启物理碰撞，因此首先需要启用碰撞功能；然后在`BeginPlay`中，我们需要对碰撞执行函数进行绑定，`OnComponentBeginOverlap`表示开始重叠时处理。

​		这里，需要注意一点，`OnColliOnsion`函数需要按照这个标准来写，具体原因还不了解。

​		延申阅读：[UE4 Collision 文档](https://docs.unrealengine.com/en-US/InteractiveExperiences/Physics/Collision/index.html)、[UE4物理精粹Part 3：Collision](https://zhuanlan.zhihu.com/p/91669703)

### 3.4 导航设置

​		UE4中对导航功能制作的非常完善，用起来非常方便。选中：**放置actor->体积->导航网格体边界体积**拖到场景中，进行一个简单的位置和大小配置，然后在编辑按下P键，既可看到类似如下界面：

![](https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day29_10.png)

![](https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day29_09.png)

​		默认情况下导航配置一般都会有些问题，因此我们需要根据项目进行简单配置：**编辑->项目设置->引擎->导航网络体**中进行设置，这里我们修改了默认单元大小和单元高度，如下所示：

![](https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day29_11.png)

​		最后，我们需要在C++层面进行导航工作：

```c++
#include "NavigationSystem/Public/NavigationSystem.h"
...
void AEnemyAIController::SearchNewPoint()
{
    // 获取当前关卡导航系统
	UNavigationSystemV1* Navmesh = UNavigationSystemV1::GetCurrent(this);
	if (Navmesh) {
		const float SearchRad = 10000.0f;
		FNavLocation RandomPt;
        // 随机寻找要给可以到达点
		const bool bFound = Navmesh->GetRandomReachablePointInRadius(Bot->GetActorLocation(), SearchRad, RandomPt);
		if (bFound) {
			....
		}
	}
}
```

​		为了能够编译成功，需要在工程名.Build.cs 文件中进行修改：在`PublicDependencyModuleNames` 中，添加`NavigationSystem`

```c#
PublicDependencyModuleNames.AddRange(new string[] { "Core", "CoreUObject", "Engine", "InputCore", "NavigationSystem" });
```

​		Build.cs 是UE 构建相关内容，延申阅读：[[[UE\]理解UnrealBuildTool](http://blog.coolcoding.cn/?p=1485)](http://blog.coolcoding.cn/?p=1485)、[理解UnrealBuildTool](https://zhuanlan.zhihu.com/p/57186557)

---

## 4. 编译内容

### 4.1 莫名其妙闪退

​		在调试过程中遇到好几次编译闪退问题，类似报错``Unhandled Exception: EXCEPTION_ACCESS_VIOLATION reading address 0x00000000``，不管是重启UE、还是重启电脑都没有用。后来，将新增的h和cpp文件删掉之后，再次添加就莫名奇妙的好了。

​		这个纯属经验之谈。

### 4.2 编译乱码

​		在UE下或者VS下编译时，遇到乱码问题，其解决方案只有将VS的语言包设置成纯English，其他方案都无法通过。打开Visual Studio Installer进行更改。

<img src="https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day29_12.png" style="zoom:80%;" />



---

## 5. 总结

​		在纯粹C++下进行编程，门槛会比采用蓝图开发难度大很多，这里有很大一部分原因是由于C++编程能力限制吧。不过用蓝图进行数值计算和逻辑处理也很麻烦，需要连接太多节点。另一方面，初学者刚刚使用蓝图时，对于节点理解不透彻，经常会有一些灵魂提问：这是啥，这是啥，这TM又是啥？。。。哈哈。综合考虑还是蓝图配好C++方式最好。当然实际项目，肯定要引入lua内容。

