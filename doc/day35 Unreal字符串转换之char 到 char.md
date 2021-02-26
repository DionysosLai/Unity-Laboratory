# day35 Unreal字符串转换之char* 到 char**

20210219

​		在UE开发过程中，经常会碰到一些字符串转换内容，比方场景string to char，string to int 等等。这些内容，大体上就是常见C++ 基础内容，因此很容易在网上上找到一些类似解决方案。

​		这篇文章讲述内容，特定与UE4 环境下，不适用常用C++ 环境。

​		需求如下：

​		现有一堆字符串数据，数据格式为TArray<FString>，需要将这些数据转换为char** 格式，方便其他插件接收。

---

## 方案一：

​		很简单，我们首先会想到TArray 提供的GetData() 方法，该方法会返回第一个数据的地址，因为我们具体实现如下：TArray<FString> ==> TArray<const char*> ==> TArray.GetData()，类似源码如下：

```c++
TArray<FString> SourceValue;
.....	// 对SourceValue塞入数据
TArray<const char*> OutValue;
OutValue.AddUninitialized(SourceValue.Num());	// 分配空间
for (int i = 0; i < SourceValue.Num(); i++)
{
    std::string str = TCHAR_TO_ANSI(*SourceValue[i]);
    OutValue[i] = &str[0]; 
}
const char** ThePointerYouWant = OutValue.GetData();	// 最终得到想要的数据。
```

​		以上代码应该是没有任何问题，但最终运行结果，会导致OutValue[0] == OutValue[1] == OutValue[2] ....问题，即原先的数据都将会被重新覆盖为最后一个数据。

---

## 方案二：

​		方案二则是在方案一上的代码改造，纯粹用来测试使用。改造代码如下：

```c++
TArray<FString> SourceValue;
.....	// 对SourceValue塞入数据
TArray<const char*> OutValue;
OutValue.AddUninitialized(SourceValue.Num());	// 分配空间
// 使用笨方法，但实际工程完全不能用，纯粹用来测试
OutValue[0] = TCHAR_TO_ANSI(*SourceValue[0]);
OutValue[1] = TCHAR_TO_ANSI(*SourceValue[1]);
...
const char** ThePointerYouWant = OutValue.GetData();	// 最终得到想要的数据。
```

​		这是结果没有任何问题。因此，看不出方案一有啥问题。

---

## 方案三：

​		方案三是不再利用UE4 提供的TArray，改用std::vector。先将FString转换为string，再转换为char*。具体源码如下：

```c++
TArray<FString> SourceValue;
.....	// 对SourceValue塞入数据
std::vector<std::string> StringArray;
for (int I = 0; I < SourceValue.Num(); I++)
{
    StringArray.push_back(std::string(TCHAR_TO_UTF8(*(SourceValue[I]))));
}
std::vector<const char*> CharPtrArray;
for (int I = 0; I < StringArray.size(); I++)
{
    CharPtrArray.push_back(StringArray[I].c_str());
}
const char** ThePointerYouWant = CharPtrArray.data();
```

​		最终，这个方案不再有任何问题。根据这个方案，反推方案一代码，估计问题是出现在``std::string str = TCHAR_TO_ANSI(*SourceValue[i]);``这一行。我们将string存起来后，再次改造下，看看效果如何。

----

## 方案四：

​		结合方案一和方案三代码，引入中间变量，保存string。具体代码如下

```c++
TArray<FString> SourceValue;
.....	// 对SourceValue塞入数据
// 保存中间代码
std::vector<std::string> StringArray;
for (int I = 0; I < SourceValue.Num(); I++)
{
    StringArray.push_back(std::string(TCHAR_TO_UTF8(*(SourceValue[I]))));
}
TArray<const char*> outValue;
for (int i = 0; i < StringArray.size(); i++)
{
    outValue.Add(StringArray[i].c_str());
}
const char** ThePointerYouWant = outValue.GetData();
```

​		这个方案也没有任何问题。因此，我们有理由相信C++在编译时，可能对这个``std::string str = TCHAR_TO_ANSI(*SourceValue[i]);``进行了特殊处理。这个问题期待后续能够解决。

---

## 总结

​		目前还是处于UE4学习阶段，在项目中会遇到各种；另一方面，C++需要重新捡起来，避免出现各种玄学问题。总之保持总结，不怕麻烦。