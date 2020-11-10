# day12 Adressable文档与源码理解

20201109

## 概要

​		上周，主要学习Asset Bundle 与 Addressable 内容，本周将会继续深入，并了解一些深层次原理。

---

## 知识点

### 1. 文档

​		本次文档地址：https://docs.unity3d.com/Packages/com.unity.addressables@1.8/manual/AddressableAssetsGettingStarted.html

​		版本以1.8.5。

		#### 1.1 本地加载方式

​		在Addressables Groups 窗口中，设置组成员内容时，默认Addressable Name采用路径方式，这时我们可以通过右键"Change Asset"方式，更改成我们习惯的字符串名字。

​		因此在加载时，我们可以采用AssetReference和字符串2中方式。

1. AssetReference 方式

   ​	采用AssetReference方式，可以方便我们对单个asset处理。具体代码如下：

   ```c#
       public List<AssetReference> m_characters;	// 定义AssetReference变量
       public bool m_AssetReady = false;
       int m_ToLoadCount;
       void Start()
       {
           m_ToLoadCount = m_characters.Count;
           // 加载
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
               // 实例化
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
               // 释放
               character.ReleaseAsset();
           }
       }
   ```

   

2. 字符串方式

   ​	通过"Chage Asset"，我们可以自定义字符串，使用方式如下：

   ```c#
       GameObject m_capsuleObj;
       void Start()
       {
           // 加载
           Addressables.LoadAssetAsync<GameObject>("capsule").Completed += OnLoadDone;
       }
       public void spawObject(int objectType)
       {
           Vector3 position = Random.insideUnitSphere * 5;
           position.Set(position.x, 0, position.z);
           // 2种实例化方式
           //Addressables.InstantiateAsync("capsule", position, Quaternion.identity);
           Instantiate(m_capsuleObj, position, Quaternion.identity);
       }
   
       private void OnLoadDone(AsyncOperationHandle<GameObject> obj)
       {
           // In a production environment, you should add exception handling to catch scenarios such as a null result.
           m_capsuleObj = obj.Result;
       }
   
       private void OnDestroy()
       {
           // 释放
           Addressables.Release<GameObject>(m_capsuleObj);
       }
   ```

   ​	采用字符串方式，可以定义多个asset同一个字符串，因此使用方式有所不同，具体代码如下：

   ```c#
       public IList<GameObject> m_capsuleObjs;
       private AsyncOperationHandle handle;
       void Start()
       {
           // 加载
           Addressables.LoadAssetsAsync<GameObject>("capule", null).Completed += OnLoadsDone;
       }
   
       public void spawObject(int objectType)
       {
           // 实例化
           Vector3 position = Random.insideUnitSphere * 5;
           Vector3 position1 = Random.insideUnitSphere * 5;
           position.Set(position.x, 0, position.z);
           position1.Set(position1.x, 0, position1.z);
           Instantiate(m_capsuleObjs[0], position, Quaternion.identity);
           Instantiate(m_capsuleObjs[1], position1, Quaternion.identity);
       }
   
   
       private void OnLoadsDone(AsyncOperationHandle<IList<GameObject>> obj)
       {
           // In a production environment, you should add exception handling to catch scenarios such as a null result.
           m_capsuleObjs = obj.Result;
           handle = obj;
       }
   
       private void OnDestroy()
       {
           // 释放
           Addressables.Release(handle);
       }
   ```

   ​	这里，我们配置了2个capule  asset。

   ​	这块代码的具体实现，在后续AssetLabelReference应用基本上可以一模一样。