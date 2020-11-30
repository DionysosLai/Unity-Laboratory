# day18 unity 基础内容

20201126

## 概要

​		基础内容

---

## 知识点

#### 1. 关于DateTime 24小时进制

问题链接：https://stackoverflow.com/questions/3023649/hour-from-datetime-in-24-hours-format。

**You can get the desired result with the code below. Two'H' in `HH` is for 24-hour format.**

```c#
private static void GenerateUnityPackageName()
{
    Debug.Log("QFramwork_" + DateTime.Now.ToString("yyyyMMdd_HH"));
}
out: QFramwork_20201126_17
```

```c#
private static void GenerateUnityPackageName()
{
    Debug.Log("QFramwork_" + DateTime.Now.ToString("yyyyMMdd_hh"));
}
out: QFramwork_20201126_05
```



#### 2. 保存内容

```c#
string path = EditorUtility.SaveFilePanel("导出 unitypackage", "", defaultName, "unitypackage");
```

​		该函数可以打开一个保存界面。

### 3. 获取选中内容

​		unity 提供Selection类，用来标记鼠标选中的文件内容。

```c#
1. Selection.objects.Length 选中内容的长度
2. AssetDatabase.GetAssetPath(Selection.objects[index]); --- 获得某个object的路径
```

​		这里有个问题，鼠标选择时需要具体选择到内容



### 4. 导出package

```c#
public static void ExportPackage(string assetPathName, string fileName, ExportPackageOptions flags);
```

​		该函数可以用来导出package 包。