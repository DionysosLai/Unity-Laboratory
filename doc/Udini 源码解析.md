# 创建一个HDA流程

​		本文主要记录基于Udini环境下，新建一个HDA资产和写数据一些基本流程。

## 一. 配置Houdini环境

​		Udini中显示HDA列表是通过xml文件，只有对xml文件添加新的HDA字段，才能正确在列表中显示出来。因此首先我们在Houdini中配置生成XML环境。

​	1.  首先，需要在Houdini中配置一个新tool 工具：

​		启动Houdini，在上方工具栏点击右键，选择``New Tool...``，这是会打开工具编辑界面，如下所示：

<img src="https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/image-20210325100918769.png" alt="image-20210325100918769" style="zoom: 80%;" />

  2. 写入执行脚本：

     接下来需要写入执行工具的py脚本，脚本内容如下：

     ```python
     def prettify(elem):
         rough_string = ET.tostring(elem, 'utf-8')
         reparsed = minidom.parseString(rough_string)
         return reparsed.toprettyxml(indent="\t")
     allNode =[]
     all_nodeType_categories = hou.nodeTypeCategories()
     rootHNode = hou.node("/obj/")
     GeoNode = rootHNode.createNode("geo")
     index1=0
     for each in all_nodeType_categories.keys():
         if(all_nodeType_categories[each].name()=="Sop"):
             for key,value in all_nodeType_categories[each].nodeTypes().items():
                 inputdescribe = ""
                 outputdescribe = ""
                 inputColor = ""
                 outputColor = ""
                 des = ""
                 showName = value.description()
                 try:
                     dften = value.allInstalledDefinitions()[0]
                     des = dften.comment()
                 except:
                     pass
                 if 1:
                     try:
                         testNode =GeoNode.createNode(key,key,False,False)
                         print testNode.type().name()
                         intputLabs = testNode.inputLabels()
                         outputLabs = testNode.outputLabels()
                         jiontex = "||"
                         outputdescribe = jiontex.join(outputLabs)
                         inputdescribe = jiontex.join(intputLabs)
                     except:
                         pass
                 des = ""    
                 subsub=ET.Element("node",{"classType":"SopNode",
                 "typeName":key,
                 "showName":showName,
                 "inputdescribe":inputdescribe,
                 "outputdescribe":outputdescribe,
                 "icon":value.icon(),
                 "maxInputs":str(value.maxNumInputs()),
                 "maxOutPuts":str(value.maxNumOutputs()),
                 "tabClass":"Primtive",
                 "describe":des
                 })
                 root.append(subsub)
     tree=ET.ElementTree(root)
     newStr=prettify(root)
     file=open(r"G:\HXClientProjectUnreal\HXNext\Houdini\XML\nodeList.xml","w")
     file.write(newStr)
     file.close()
     ```

     其中倒数第三行，会打开一个xml文件写入，这里需要改成本地xml路径

---

## 二. 创建一个新的HDA

​		当我们制作好一个HDA时（一般是以subnet形式呈现），选中HDA右键鼠标，选择``Creare Digital Asset...```，然后填入对应参数即可。

​		在制作HDA时，由于我们当前是基于Udini环境下，因此制作的HDA需要在sob 层级下。

​    	默认新创建的HDA都是锁住状态（不能更改里面参数），因此如皋该HDA需要支持动态修改参数，则修改修改HDA参数。选中HDA右键鼠标，选择``Type Properties...``，界面如下所示：

<img src="https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/image-20210325110542649.png" alt="image-20210325110542649" style="zoom: 80%;" />

​		选择Script tab，然后再Event Handler 选择 On Create选项，之后在右边写入py脚本：

```python
node = kwargs["node"]
node.allowEditingOfContents()
```

​		该脚本允许我们在创建HDA资产时，编辑资产内容。

---

## 三. Unreal 执行HDA

​		当一个HDA需要动态编辑内容时，则需要在c++ 一侧执行特定函数。当一个HDA被执行时，会执行到函数：``FHdaNodeNetworkModule::CookNodeStart``，其中每个HDA都有一个特定名称，根据名称判断具体的HDA，然后执行特定功能，例如如下一段代码：

```c++
	if (node->typeName == "GetLandscape")
	{
		SetLandscapeNodeForInputNode(node->NodeId.Get());
	}
	if (node->typeName == "HxGetPureLandscape")
	{
		SetPureLandscapeNodeForInputNode(node->NodeId.Get());
	}
```

​		其中，node参数表示该HDA具体信息，可以通过Houdini Api获得具体信息。