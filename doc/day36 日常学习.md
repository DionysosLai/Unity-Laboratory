# day36 日常学习

20210222



## 概要

​		日常学习内容：

1. 编译问题
2. Houdini 字符串获取
3. Houdini 错误信息获取



## 知识点

### 1. 编译问题：

​		plugins下的代码，在UE窗口下点击编译是不生效的。需要在vs中build才能生效。这个是由于``为了提升编译速度，理论上只会编译source目录下内容，其他属于模块内容，ue认为不经常变动，没有必要每次都重新编译(猜测)``。如果要在UE窗口下生效，可以通过：``window->develop->module``生效：https://answers.unrealengine.com/questions/464330/view.html#

![img](C:/Users/dionysoslai/Documents/WXWork/1688850576066668/Cache/Image/2021-02/企业微信截图_1613981318711.png)

### 2. Houdini 获取字符串

​		从houdini获取一个字符串到UE，并不是直接返回一个string，而是通过``HAPI_StringHandle``:

```c++
// HAPI_Common.h

/// Use this with HAPI_GetString() to get the value.
/// See @ref HAPI_Fundamentals_Strings.
typedef int HAPI_StringHandle;
```

​		然后会获取到string id，根据这个id，我们就可以获取到string。

方案一：FHoudiniEngineString

​		通过FHoudiniEngineString，类似代码如下：

```c++
// 获取csv路径
HAPI_StringHandle MatNamesValueHandle;
HAPI_Result result;
FString csvPath = "";
result = FHoudiniApi::GetParmStringValue(
    FHoudiniEngine::Get().GetSession(), NodeId, TCHAR_TO_UTF8(*(FString("file"))), 0, 0, &MatNamesValueHandle);
FHoudiniEngineString(MatNamesValueHandle).ToFString(csvPath);
```

​		`GetParmStringValue`函数根据给定的参数，获取到属性面板对应参数。

方案二：HAPI_GetStringBufLength() + HAPI_GetString()

​		通过`HAPI_GetStringBufLength`获取到字符串长度（buffer），然后`HAPI_GetString()`获取。类似代码如下：

```c++
int buffer_length;
HAPI_GetStatusStringBufLength(
    nullptr, id, HAPI_STATUSVERBOSITY_ERRORS, &buffer_length );
char * buf = new char[ buffer_length ];
HAPI_GetStatusString( nullptr, id, buf );
std::string result( buf ); // result 即为字符串
delete[] buf;
```

​		注意这点代码，没经过测试，`HAPI_GetStatusStringBufLength` 第三个参数还需要测试一下。

### 3. 获取Houdini 错误信息

​		所有Houdini函数，都是返回`HAPI_Result`，其中除了`HAPI_RESULT_SUCCESS`均是错误信息，因此有些时候我们很有必要得到错误信息内容。以下函数，可以获取到具体错误信息：

```c++
static std::string get_last_error()
{
    int buffer_length;
    HAPI_GetStatusStringBufLength(
        nullptr, HAPI_STATUS_CALL_RESULT, HAPI_STATUSVERBOSITY_ERRORS, &buffer_length );
    char * buf = new char[ buffer_length ];
    HAPI_GetStatusString( nullptr, HAPI_STATUS_CALL_RESULT, buf );
    std::string result( buf );
    delete[] buf;
    return result;
}
```

###4. UE4 中采用正则表达式检测字符

```c++
#include "Internationalization/Regex.h"

bool UFunctionLib::CheckStringIsValid(const FString str, const FString Reg)
{
    FRegexPattern Pattern(Reg);
    FRegexMatcher regMatcher(Pattern, str);
    regMatcher.SetLimits(0, str.Len());
    return regMatcher.FindNext();
}
```

