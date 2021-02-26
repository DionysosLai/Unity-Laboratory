#  UnLua 原理分析之函数调用

20210113

## 1. 概要

​		UnLua的简要分析，将会通过UnLua 的Demo示例，分析其中一个文件`BP_PlayerController_C.lua`中一个具体函数的调用流程。

```lua
function BP_PlayerController_C:TurnRate(AxisValue)
	local DeltaSeconds = UE4.UGameplayStatics.GetWorldDeltaSeconds(self)
	local Value = AxisValue * DeltaSeconds * self.BaseTurnRate
	self:AddYawInput(Value)
end
```

## 2. lua 前置知识

​		在具体分析之前，先对lua一些基础内容进行简单介绍，主要涉及的是后续源码会出现的一些内容。其中，涉及到的lua源码，版本为lua 5.1。

### 2.1 lua中push和get函数

​		push和get系列函数在lua.h 文件中定义：

```c++
// lua.h
/*
** access functions (stack -> C)
*/

LUA_API int             (lua_isnumber) (lua_State *L, int idx);
LUA_API int             (lua_isstring) (lua_State *L, int idx);
....

/*
** push functions (C -> stack)
*/
LUA_API void  (lua_pushnil) (lua_State *L);
LUA_API void  (lua_pushnumber) (lua_State *L, lua_Number n);
....
```

​		其中push系列函数功能是将数据压入栈中。以lua_pushnumber函数为例：

```c++
// luai.c
LUA_API void lua_pushnumber (lua_State *L, lua_Number n) {
  lua_lock(L);
  setnvalue(L->top, n);
  api_incr_top(L);
  lua_unlock(L);
}

// lobject.h
#define setnvalue(obj,x) \
  { TValue *i_o=(obj); i_o->value.n=(x); i_o->tt=LUA_TNUMBER; }
```

​		最终会将数据存入 value.n中，并且类型设置为 `LUA_TNUMBER`。`lua_tonumber`则是获取到数据：

```c++
LUA_API lua_Number lua_tonumber (lua_State *L, int idx) {
  TValue n;
  const TValue *o = index2adr(L, idx);
  if (tonumber(o, &n))
    return nvalue(o);
  else
    return 0;
}
```

​		其中，函数`nvalue`则是value.n中取数据。注意，这里idx可以为正数或者负数。这是因为在Lua中，Lua堆栈本质是一个struct，堆栈的索引方式可以是正数或者负数。其中：正数索引表示从栈底开始，1表示栈底；负数索引表示从栈顶开始，-1表示栈顶。需要明确的是，`lua_tonumber`并没有进行出栈操作，不改变栈的内容。这个很重要。

延申阅读：

​		刚才分析中得出，number类型数据是存放在value->n字段中，其他类型一般如何保存呢，看下lobject.h 部分源码：

```c++
// lobject.h
/*
** Union of all Lua values
*/
typedef union {
  GCObject *gc;
  void *p;
  lua_Number n;
  int b;
} Value;
```

​		其中：

​    p -- 可以存一个指针, 实际上是lua中的light userdata结构

​    n -- 所有的数值存在这里, 不过是int , 还是float

​    b -- Boolean值存在这里, 注意, lua_pushinteger不是存在这里, 而是存在n中, b只存布尔

​    gc -- 其他诸如table, thread, closure, string需要内存管理垃圾回收的类型都存在这里

​    gc -- 是一个指针, 它可以指向的类型由联合体GCObject定义, 具体有string, userdata, closure, table, proto, upvalue, thread

  因此可以的得出如下结论:

​    **1. lua中, number, boolean, nil, light userdata四种类型的值是直接存在栈上元素里的, 和垃圾回收无关.**

​    **2. lua中, string, table, closure, userdata, thread存在栈上元素里的只是指针, 他们都会在生命周期结束后被垃圾回收.**



### 2.2 lua_pcall函数

​		lua_pcall函数是用来执行函数调用，函数位于栈底，然后依次向上是第一个参数，第二个参数，源码如下：

```c++
LUA_API int lua_pcall (lua_State *L, int nargs, int nresults, int errfunc) {
  struct CallS c;
  int status;
  ptrdiff_t func;
  lua_lock(L);
  api_checknelems(L, nargs+1);
  checkresults(L, nargs, nresults);
  if (errfunc == 0)
    func = 0;
  else {
    StkId o = index2adr(L, errfunc);
    api_checkvalidindex(L, o);
    func = savestack(L, o);
  }
  c.func = L->top - (nargs+1);  /* function to be called */
  c.nresults = nresults;
  status = luaD_pcall(L, f_call, &c, savestack(L, c.func), func);
  adjustresults(L, nresults);
  lua_unlock(L);
  return status;
}
```

​		其中`api_checknelems`和`checkresults`用来校验参数个数。`c.func = L->top - (nargs+1);`表示要调用的函数，因为在调用之前，我们必须先将参数压入栈中，因此func函数位置在nargs+1中。

### 2.3 lua 元表（Metatable）

​		在 Lua table中我们可以访问对应key得到value指，但无法对两个table进行操作。因此，Lua 提供了元表，允许我们改变table行为，每个行为关联了对应元方法。例如，使用元表我们可以很简单计算两个table的相加操作。

​		关键函数：

* `setmetatable(table,metatable)`: 对指定 table 设置元表(metatable)，如果元表(metatable)中存在 __metatable 键值，setmetatable 会失败
* `getmetatable(table)`:返回对象的元表。

#### 2.3.1 __index

​		__index 用来对象访问。	

​		当通过键值来访问table时，如果这个键没有值（如果有值，则第一优先访问），那么lua就会寻找metatable中的__index 值。

* 如果__index 包含一个table，lua就会在table中查找相应的键值；

* 如果__index包含一个函数，lua就会调用函数，table和键会作为参数传递给函数；

#### 2.3.2 __newindex

​		__newindex用来对象更新。

​		当给table一个缺少的索引赋值时，解释器就会查找\___newindex元方法；如果存在则调用这个\_\__index方法而不进行赋值操作。

​		注意，__index为函数或者table，作用不一样。如果为函数，示例如下：

```lua
mytable = setmetatable({key1 = "value1"}, {
  __newindex = function(mytable, key, value)
		rawset(mytable, key, "\""..value.."\"")
  end
})

mytable.key1 = "new value"
mytable.key2 = 4

print(mytable.key1,mytable.key2)

-- 输出: new value    "4"
```

### 2.4 lua_gettop和 lua_settop

​		lua_gettop 和 lua_settop 分别是对栈的操作。

```c++
LUA_API int lua_gettop (lua_State *L) {
  return cast_int(L->top - L->base);
}
```

​		lua_gettop: 即返回栈顶索引（即栈长度）。

```c++
LUA_API void lua_settop (lua_State *L, int idx) {
  lua_lock(L);
  if (idx >= 0) {
    api_check(L, idx <= L->stack_last - L->base);
    while (L->top < L->base + idx)
      setnilvalue(L->top++);
    L->top = L->base + idx;
  }
  else {
    api_check(L, -(idx+1) <= (L->top - L->base));
    L->top += idx+1;  /* `subtract' index (index is negative) */
  }
  lua_unlock(L);
}
```

​		从`L->top = L->base + idx;或者L->top += idx+1;`，可以看出lua_settop将栈顶设置为一个指定的位置，即修改栈中元素的数量。同时，根据idx值，会对数据进行清空或者补偿操作。主题来说，如果idx值比原栈顶高，则高的部分nil补足，如果值比原栈低，则原栈高出的部分舍弃。所以可以用lua_settop(0)来清空栈。



​		额外一句：分析lua代码时，一定要注意lua 堆栈的情况。lua里面很多操作，都是直接操作堆栈。比方下面一段代码：

```c++
    int32 n = lua_getmetatable(L, 1);       // get meta table of table/userdata (first parameter passed in)
    check(n == 1 && lua_istable(L, -1));
    lua_pushvalue(L, 2);                    // push key
    int32 Type = lua_rawget(L, -2);
```

​		lua_getmetatable功能时获取栈上对应index内容的元素，若有则压入栈中，返回1，若无则不压入栈，返回0。

​		lua_pushvalue功能是将栈index为2的元素复制一份，压到栈顶。

​		lua_rawget(L, -2)功能：获取t[k]的值压入栈顶，t为index所指内容，k为栈顶内容，获取完后将k出栈，结果入栈。

​		那么假设刚开始栈的情况是：

![image-20210115151634542](https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/image-20210115151634542.png)

​		因此，我们在阅读lua代码时，务必要保证栈情况的清晰，不然很多参数都会云里雾里。



---

## 3. Unlua 前置知识

### 3.1 UnLua 内容

​		UnLua git 地址：https://github.com/Tencent/UnLua。git官网中包含一个运行Demo和UnLua源码，一下涉及的源码均来自这里。

### 3.2 UnLua 简单入门

​		附上一个链接：https://imzlp.me/posts/36659/，这篇文章内容讲得很细致，算是对git 官网的补充。



---

## 4. UnLua 源码解析之UE4.UGameplayStatics的执行流程

​		有了上面前置知识，我们接下来分析下UnLua与UE4交互内容。	

​		UnLua Demo提供了一个完整的示例，其中，lua的初始入口函数为`UnLua.lua`文件，相关绑定均在这个文件中定义。随便打开一个文件，比方`BP_PlayerController_C.lua`文件，可以看到如下类似代码：

```lua
function BP_PlayerController_C:TurnRate(AxisValue)
	local DeltaSeconds = UE4.UGameplayStatics.GetWorldDeltaSeconds(self)
	local Value = AxisValue * DeltaSeconds * self.BaseTurnRate
	self:AddYawInput(Value)
end
```

​		这段函数的关键是要获取到UE4中UGameplayStatics类提供的GetWorldDeltaSeconds方法，从而获得到相应数据。

​		那么问题：**UE4.UGameplayStatics.GetWorldDeltaSeconds(self)**是如何调用到C++那块呢？

### 4.1 lua侧到C++

​		通过`UnLua.lua`文件分析，可以发现UE4实际就是Lua中的_G( _G，全局变量，它存储全局的环境）。

```lua
if WITH_UE4_NAMESPACE then
	print("WITH_UE4_NAMESPACE==true");
else
	local global_mt = {}
	global_mt.__index = global_index
	setmetatable(_G, global_mt)
	UE4 = _G

	print("WITH_UE4_NAMESPACE==false");
end
```

​		其中，`WITH_UE4_NAMESPACE`在UnLuaBase.h文件中定义，设置为0，因此走else分支。因此执行逻辑变成：

```lua
UE4.UGameplayStatics ==> _G.UGameplayStatics
```

​		同时我们为_G赋予了__index元方法（该元方法global_index是一个函数）:

```lua
local function global_index(t, k)
	if type(k) == "string" then
		local s = str_sub(k, 1, 1)
		if s == "U" or s == "A" or s == "F" then
			RegisterClass(k)
		elseif s == "E" then
			RegisterEnum(k)
		end
	end
	return rawget(t, k)
end
```

​		由于UGameplayStatics以U开头，逻辑将执行RegisterClass分支。则执行逻辑将变成：

```lua
UE4.UGameplayStatics ==> _G.UGameplayStatics ==> RegisterClass(UGameplayStatics)
```

​		需要注意的是RegisterClass 是一个全局方法，在UE4初始化UnLua时，就已经被定义好了。这时，就从lua侧到c++侧了。RegisterClass 的定义详见 LuaContext.h 文件：

```c++
/** LuaContext.h
 * Create Lua state (main thread) and register/create base libs/tables/classes
 */
void FLuaContext::CreateState()
{
	    ...
        // register global Lua functions
        lua_register(L, "RegisterEnum", Global_RegisterEnum);
        lua_register(L, "RegisterClass", Global_RegisterClass);
        ...
}
```

​		该函数将RegisterClass赋给Global_RegisterClass方法。因此，lua调用RegisterClass方法后，最终会调用到C++方面的Global_RegisterClass函数。并且会将lua脚本调用时的参数依次压入Lua栈中，然后依次压入第一个参数、第二个参数等。这个类似前面提到的lua_pcall函数。例如下面例子：

```c++
lua_getglobal(L, "add");        // 获取函数，压入栈中  
lua_pushnumber(L, 10);          // 压入第一个参数  
lua_pushnumber(L, 20);          // 压入第二个参数 
int iRet = lua_pcall(L, 2, 1, 0);// 调用函数，调用完成以后，会将返回值压入栈中，2表示参数个数，1表示返回结果个数。 
```

​		接下来，看下Global_RegisterClass函数：

```c++
// LuaContext.h
int32 Global_RegisterClass(lua_State *L)
{
    int32 NumParams = lua_gettop(L);
    if (NumParams < 1)
    {
        UNLUA_LOGERROR(L, LogUnLua, Warning, TEXT("%s: Invalid parameters!"), ANSI_TO_TCHAR(__FUNCTION__));
        return 0;
    }

    RegisterClass(L, lua_tostring(L, 1));
    return 0;
}
```

​		其中，lua_gettop前面讲过，会返回栈长度，代表了当前栈有几个元素。因为Lua调用C++将参数一次压入栈中，即lua_gettop(L)返回了几，就代表了lua那边传进来了几个参数，这里传入的是"UGameplayStatics"，NumParams值为1 。最终调用结果变成：

```c++
RegisterClass(UGameplayStatics) ==> Global_RegisterClass() ==> RegisterClass(L, lua_tostring(L, 1)) 
==> RegisterClass(L, "UGameplayStatics")
```

​		接下来看下RegisterClass 函数：

```c++
FClassDesc* RegisterClass(lua_State *L, const char *ClassName, const char *SuperClassName)
{
    FString Name(ClassName);
    TArray<FClassDesc*> Chain;
    FClassDesc *ClassDesc = nullptr;
	...
    else
    {
        ClassDesc = GReflectionRegistry.RegisterClass(*Name, &Chain);
    }
    if (!RegisterClassInternal(L, ClassDesc, Chain))
    {
        UE_LOG(LogUnLua, Warning, TEXT("%s: Failed to register class %s!"), ANSI_TO_TCHAR(__FUNCTION__), *Name);
    }
    return ClassDesc;
}
```

​		由于SuperClassName为空，以上代码我们略去了SuperClassName相关代码部分。首先，我们会调用`GReflectionRegistry.RegisterClass`:

```c++
FClassDesc* FReflectionRegistry::RegisterClass(const TCHAR *InName, TArray<FClassDesc*> *OutChain)
{
    const TCHAR *Name = (InName[0] == 'U' || InName[0] == 'A' || InName[0] == 'F' || InName[0] == 'E') ? InName + 1 : InName;
    UStruct *Struct = FindObject<UStruct>(ANY_PACKAGE, Name);       // find first
    if (!Struct)
    {
        Struct = LoadObject<UStruct>(nullptr, Name);                // load if not found
    }
    return RegisterClass(Struct, OutChain);
}
```

​		FindObject 函数UE4自带一个功能：返回一个找到对象的指针。因此，这个函数的功能时利用UE4的反射获取了UGameplayStatics这个对象类型，然后执行注册，即记录反射信息到UnLua的反射库中。至于之后`RegisterClass(Struct, OutChain);`本质上就是将UGameplayStatics记录到UnLua反射库中。这些都是在TMap上进行操作，对应头文件定义如下：

```c++
TMap<FName, FClassDesc*> Name2Classes;
TMap<UStruct*, FClassDesc*> Struct2Classes;
TMap<UStruct*, FClassDesc*> NonNativeStruct2Classes;
TMap<FName, FEnumDesc*> Enums;
TMap<UFunction*, FFunctionDesc*> Functions;
```

​		其中对UGameplayStatics的操作将会涉及Name2Classes、Struct2Classes、NonNativeStruct2Classes，另外两个分别是给枚举和函数（PS：对类的注册比较复杂，可以先看下对Function的注册，原理都是一样）。

​		接下，将执行函数`RegisterClassInternal`，该函数主要功能是为UGameplayStatics，以及它的父类们分别创建一个Lua元表，元表名为元表名为“UWidgetBluprintLibrary”，同时设置这个元表的一些元方法，目的是将来设这个元表给Lua，使得Lua可以和C++交互。这些元方法包括copy 和gc。核心功能需要看下`RegisterClassCore`。

​		至此，RegisterClass功能已基本完成。将流程总结下：

```c++
UE4.UGameplayStatics ==> _G.UGameplayStatics ==> RegisterClass(UGameplayStatics) // 在lua侧完成
==> Global_RegisterClass() // lua 绑定 C++函数
==> RegisterClass(L, lua_tostring(L, 1)) ==> RegisterClass(L, "UGameplayStatics") // 简单参数判断
==> GReflectionRegistry.RegisterClass(*(UGameplayStatics), &Chain) // 利用UE4反射获取对象，并保存到UnLua反射库中，方便下次查找
==> RegisterClassInternal(L, ClassDesc, Chain) // 为UGameplayStatics创建元表，使得Lua可以和C++交互（包括copy、gc）
```

​		现在``UE4.UGameplayStatics.GetWorldDeltaSeconds(self)``的解析，我们已经明白了：UE4.UGameplayStatics会为UGameplayStatics先进行了记录反射信息、创建元表等工作。那么最终：

```c++
UE4.UGameplayStatics.GetWorldDeltaSeconds(self) ==> UGameplayStatics.GetWorldDeltaSeconds(self) // 注意UGameplayStatics是一个table
```

### 4.2 函数的查找

​		根据RegisterClassCore里面的源码分析：

```c++
**
 * Register a class
 */
static bool RegisterClassCore(lua_State *L, FClassDesc *InClass, const FClassDesc *InSuperClass, UnLua::IExportedClass **ExportedClasses, int32 NumExportedClasses)
{
   	...
    lua_pushstring(L, "__index");                           // 2
    lua_pushcfunction(L, Class_Index);                      // 3
    lua_rawset(L, -3);
	...
 }
```

​		由于表UGameplayStatics没有GetWorldDeltaSeconds键，因此会调用Class_Index函数（原理查看前面提到lua元表：__index）功能。根据Class_Index源码，会首先调用GetField函数。

```c++
/**
 * Get a field (property or function)
 */
static int32 GetField(lua_State *L)
{
  	    ...// 以上代码是对Lua栈一系列操作，目的会了获取ClassName和FieldName
        const char *ClassName = lua_tostring(L, -1);
        const char *FieldName = lua_tostring(L, 2);
        lua_pop(L, 1);

        FClassDesc *ClassDesc = GReflectionRegistry.FindClass(ClassName);
        check(ClassDesc);
        FScopedSafeClass SafeClass(ClassDesc);
        FFieldDesc *Field = ClassDesc->RegisterField(FieldName);
    	// 判断Field是否获取成功
        if (Field && Field->IsValid())
        {
		   ...
            if (!bCached)
            {
                PushField(L, Field);                // Property / closure
                lua_pushvalue(L, 2);                // key
                lua_pushvalue(L, -2);               // Property / closure
                lua_rawset(L, -4);
            }
		   ...
        }
        else
        {
		....	
        }
    }
    lua_remove(L, -2);
    return 1;
}
```

​		最终在本例中，ClassName-->UGameplayStatics，FieldName-->GetWorldDeltaSeconds。``FClassDesc *ClassDesc = GReflectionRegistry.FindClass(ClassName);``这是为了找到对应反射信息FClassDesc。注意，这个反射信息就是我们前面提到的UnLua反射库注册内容。

​		``FFieldDesc *Field = ClassDesc->RegisterField(FieldName)``是根据FieldName获取对应Field的反射信息，找到对应的FProperty或FProperty，并缓存在Unlua自己的数据结构中，供后续取用。

​		执行RegisterField函数之后，GetField会继续执行，判断Filed是否获取成功、是否来自基类等。重点是``PushField``函数，会将Field压入Lua栈中。``PushField``源码如下：

```c++
/**
 * Push a field (property or function)
 */
static void PushField(lua_State *L, FFieldDesc *Field)
{
    check(Field && Field->IsValid());
    if (Field->IsProperty())
    {
        FPropertyDesc *Property = Field->AsProperty();
        lua_pushlightuserdata(L, Property);                     // Property
    }
    else
    {
        FFunctionDesc *Function = Field->AsFunction();
        lua_pushlightuserdata(L, Function);                     // Function
        if (Function->IsLatentFunction())
        {
            lua_pushcclosure(L, Class_CallLatentFunction, 1);   // closure
        }
        else
        {
            lua_pushcclosure(L, Class_CallUFunction, 1);        // closure
        }
    }
}
```

​		如果是一个属性，则获取FPropertyDesc，这是UnLua自己的反射类型（定义在PropertyDesc.h 文件中）。由于GetWorldDeltaSeconds是一个方法，因此不走这个分支，因此将会压栈一个闭包（IsLatentFunction函数，官方文档解释：测试一个函数是不是潜在函数。这是啥意思啊）。这里，暂时搞不懂Class_CallLatentFunction和Class_CallUFunction的区别，不过二者，最终都将会调用CallUE函数。

​		至此，GetField函数执行完毕。总结起来就是：根据Lua栈信息，获取到FClassDesc和FFieldDesc信息，然后设置执行的后续内容（FFunctionDesc或者FPropertyDesc）。现在，我们继续分析下Class_Index函数：

```c++
/**
 * __index meta methods for class
 */
int32 Class_Index(lua_State *L)
{
    GetField(L);
    if (lua_islightuserdata(L, -1))
    {
		...
    }
    return 1;
}
```

​		由于GetField(L)的最终结果是在Lua栈顶存入闭包，并不是lightuserdata类型，分支不执行，直接return 1（return 1表示有一个返回参数。根据Lua和C++交互机制，调用开始时，Lua会把从左到右的Lua参数依次压入栈；调用结束时，C++会把返回值依次压入栈中，同时return返回值个数，lua会根据return的返回值个数，依次去栈顶取出返回值）。到目前为止，lua代码``UE4.UGameplayStatics.GetWorldDeltaSeconds(self)``内容已经全部执行完毕，最终结果就是返回给Lua一个**Class_CallUFunction+ 包含GetWorldDeltaSeconds函数的FFunctionDesc指针**。

### 4.3 闭包执行

​		那么真正执行到UE4中UGameplayStatics的GetWorldDeltaSeconds，返回一个每帧的时间呢？由于Lua栈顶是一个闭包，Class_Index 函数将会返回1，因此Lua会获取到栈顶数据，即闭包。通过闭包，将会执行Class_CallUFunction函数，该函数最终会调用到CallUE函数。CallUE函数的功能，将会执行到给定的UFunction（UFunction定义在UE4库Class.h）。

```c++
/**
 * Call the UFunction
 */
int32 FFunctionDesc::CallUE(lua_State *L, int32 NumParams, void *Userdata)
{
  	...// FinalFunction一些处理
    {
        if (bRemote)
        {
            Object->CallRemoteFunction(FinalFunction, Params, nullptr, nullptr);
        }
        else
        {
            Object->UObject::ProcessEvent(FinalFunction, Params);
        }
    }

    int32 NumReturnValues = PostCall(L, NumParams, FirstParamIndex, Params, CleanupFlags);      // push 'out' properties to Lua stack
    return NumReturnValues;
}
```

​		CallUE 函数会分别对函数和数据进行预先处理，最终将会执行`ProcessEvent`（bRemote 默认为false）。`ProcessEvent`是一个UE4接口，功能是通过虚拟机，直接传入函数的反射类型和参数缓存，实现调用这个函数，即，调用UGameplayStatics::GetWorldDeltaSeconds这个C++函数。调用完后，会把返回值放入Params缓存区中。 从Params中读出返回值，返回值是一个C++类型，然后转换成Lua对象并将Lua对象压入到Lua栈中，返回返回值个数。Lua那边就收到了最终的返回值（这个机制跟刚才Class_Index 返回1是一样的）。

### 4.4 调用流程总结

​		以上，我们将整个调用过程分析完毕。总结下具体过程图：

```c++
// 创建对应类元表
UE4.UGameplayStatics ==> _G.UGameplayStatics ==> RegisterClass(UGameplayStatics) // 在lua侧完成
==> Global_RegisterClass() // lua 绑定 C++函数
==> RegisterClass(L, lua_tostring(L, 1)) ==> RegisterClass(L, "UGameplayStatics") // 简单参数判断
==> GReflectionRegistry.RegisterClass(*(UGameplayStatics), &Chain) // 利用UE4反射获取对象，并保存到UnLua反射库中，方便下次查找
==> RegisterClassInternal(L, ClassDesc, Chain) // 为UGameplayStatics创建元表，使得Lua可以和C++交互（包括copy、gc）
// 查找对应函数，并存入闭包中。
==> 类.__index ==> Class_Index // 根据元表性值，新键值将调用Class_Index函数
==> GetFiled ==> PushField // 往Lua栈中，压入属性FPropertyDesc或者函数闭包
==> Class_Index 返回1， Lua获取到栈顶元素，这里是一个函数闭包。
// 执行函数闭包内容
==> Class_CallUFunction // 闭包
==> CallUE ==> UObject::ProcessEvent // UE4接口，将会通过虚拟机直接传入函数的反射类型和参数，实现函数调用，同时会保存调用后的返回值。
==> CallUE 将会返回ProcessEvent返回值个数，Lua侧将会从栈顶依次收到具体值。
```



---

## 5. 一些思考

​		暂时UnLua实际实践不多，因此先摘入一下UnLua主要一些问题和缺陷，主要是参考官网的Issues：https://github.com/Tencent/UnLua/issues

### 5.1 多lua_State 支持

​		https://github.com/Tencent/UnLua/issues/78

​		目前UnLua不支持多state方案，在pie模式下开多个窗口，会导致公用变量冲突问题，就是A客户端初始化了公用变量，B跟C客户端缺访问不到。

​		UE4 Pie模式运行相关文档：https://docs.unrealengine.com/zh-CN/Basics/HowTo/PIE/index.html

### 5.2 多继承导致不能递归访问到所有基类

​		https://github.com/Tencent/UnLua/issues/131

​		这是由于UnLua里的Super只是简单模拟了“继承”语义，在继承多层的情况下会有问题，Super不会主动向下遍历Super。“父类” 不是 Class () 返回的表的元表，只设置在 Super 这个 field 上。

​		这个带确认~~~~

### 5.3 TArray 下标规则从1开始

​		https://github.com/Tencent/UnLua/issues/41

​		这个应该是为了适应lua默认的下标起始设定。

### 5.4 不支持导出类的static成员

​		https://github.com/Tencent/UnLua/issues/22

​		曲线救国，不可以直接导出类的 static 成员，但可以为它封装一个 static 方法。





​		