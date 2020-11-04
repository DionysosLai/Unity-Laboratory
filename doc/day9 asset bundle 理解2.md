# day9 asset bundle 理解2

20201103

## 概要

​		这是day8 文章的继续

## 知识点

### 1. Resources

​		很多老的项目都会使用Resources方式，文章[Resources目录的优点与痛点](https://blog.uwa4d.com/archives/USparkle_Addressable2.html)大概讲了一下Resources 方式的一些方面问题。

### 2. Asset Bundle 实践1

​		Unity 教程[Asset Bundle 教程](https://docs.unity3d.com/cn/2019.4/Manual/AssetBundlesIntro.html)，系列教程可以大致浏览一下。其中主要会讲到几点。

#### 2.1 如何打包

​		打包源码如下：

``` c#
    [MenuItem("Assets/Build AssetBundles")]
    static void BuildAllAssetBundles()
    {
        string assetBundleDirectory = "Assets/AssetBundles";
        if (!Directory.Exists(assetBundleDirectory))
        {
            Directory.CreateDirectory(assetBundleDirectory);
        }
        AssetBundleManifest ss = BuildPipeline.BuildAssetBundles(assetBundleDirectory,
                                        BuildAssetBundleOptions.None,
                                        BuildTarget.StandaloneWindows);
    }
```

​		首先，我们创建一个AssetBundles文件夹，然后将标记好的资源全部导入到这个文件夹中。对于资源标记问题，其中有2个需要填写的内容，这块目前没怎么搞懂。

#### 2.2 使用Asset Bundle

​		使用Asset Bundle 大概有4种api方式，其中LoadFromFile最高效。大致源码如下：

```c#
void Start()
{
    var materialsAB = AssetBundle.LoadFromFile(Path.Combine(Application.dataPath, Path.Combine("AssetBundles", "arts.day2")));
    var myLoadedAssetBundle = AssetBundle.LoadFromFile(Path.Combine(Application.dataPath, Path.Combine("AssetBundles", "pre.test")));
    if (myLoadedAssetBundle == null)
    {
        Debug.Log("Failed to load AssetBundle!");
        return;
    }
    var prefab = myLoadedAssetBundle.LoadAsset<GameObject>("Cube");
    Instantiate(prefab);
}
```

​		其中，我们加载2个Asset Bundle，并从pre.test 资产中加载了Cube这个预设，并实例化对象。

#### 2.3 依赖问题

​		在实际项目中，可能会遇到多个Asset Bundle包含相同信息问题。比方2个Asset Bundle 都中的预设都采用了同一个材质，但这个材质并没有导入到一个对应Asset Bundle 中，那么形成Asset Bundle 时，这个原先2个Asset Bundle 都会包含这个材质信息。造成资源冗余问题。

​		另一个问题，如上面代码所示，pre.test Bundle 中的Cube预设的材质在arts.day2 中，因此使用时，Cube预设时，需要保证arts.day2已经加载在内存中。当然顺序可以不要求。

