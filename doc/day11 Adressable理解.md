# day11 Adressable理解

20201106

## 概要

​		前几天，主要学习了Asset Bundle 内容，现在开始整理Adressable 相关内容。基础知识就不阐述了。

### 知识点

### 1. 根据AssetReference 加载

​		AssetReference 类提供了一种访问Addressable Assets 的方法，可以不用知道他们的地址。示例代码如下：

```c#
    public List<AssetReference> m_characters;
    bool m_AssetReady = false;
    int m_ToLoadCount;
    void Start()
    {
        m_ToLoadCount = m_characters.Count;
        foreach(var character in m_characters)
        {
            character.LoadAssetAsync<GameObject>().Completed += OnCharacterAssetLoaded;
        }
    }

    public void spawObject(int objectType)
    {
        if (m_AssetReady)
        {
            Vector3 position = Random.insideUnitSphere * 5;
            position.Set(position.x, 0, position.z);
            m_characters[objectType].InstantiateAsync(position, Quaternion.identity);
        }
    }

    void OnCharacterAssetLoaded(AsyncOperationHandle<GameObject> obj)
    {
        m_ToLoadCount--;
        if(m_ToLoadCount <= 0)
        {
            m_AssetReady = true;
        }
    }

    private void OnDestroy()
    {
        foreach(var character in m_characters)
        {
            character.ReleaseAsset();
        }
    }
```

​		首先，我们在Inspector 界面配置AssetReference 数据，通过代码``character.LoadAssetAsync<GameObject>().Completed += OnCharacterAssetLoaded;``既可实现加载方式。注意最后，需要将asset 释放出来。



### 2. 根据AssetLableReference加载

​		相对AssetReference方式，AssetLableReference可以通过打标签方式，实现群组加载功能。官网：https://docs.unity3d.com/Packages/com.unity.addressables@1.13/manual/LoadingAddressableAssets.html 如此定义：

```
Addressables.LoadAssetsAsync is also useful when used in conjunction with the Addressable label feature. If a label is passed in as the key, Addressables.LoadAssetsAsync loads every asset marked with that label.
```

​		示例代码如下：

```c#
    public IList<GameObject> m_towers;
    public AssetLabelReference m_towerLable;
    public Button[] m_towerBtns;
    private AsyncOperationHandle handle;
    void Start()
    {
        Addressables.LoadAssetsAsync<GameObject>(m_towerLable, null).Completed += OnResourcesRetrieved;
    }

    private void OnResourcesRetrieved(AsyncOperationHandle<IList<GameObject>> obj)
    {
        m_towers = obj.Result;
        handle = obj;
        foreach (var btn in m_towerBtns)
        {
            btn.interactable = true;
        }
    }

    public void InstantiateTower(int index)
    {
        if(m_towers != null)
        {
            Vector3 position = Random.insideUnitSphere * 5;
            position.Set(position.x, 0, position.z);
            Instantiate(m_towers[index], position, Quaternion.identity, null);
        }
    }

    private void OnDestroy()
    {
        Addressables.Release(handle);
    }
```

​		注意，这里我们采用函数变成了``LoadAssetsAsync``。通过以上方法，我们就可一次性将同一个标签全部加进内存中。同时，这里采用异步加载，可能导致同一个标签内容的加载顺序不一致，也就是说对于同一个`m_towers[0]`，很有可能是不一样的预设。









## 扩展

### IList与List

