# day25 日常学习

20211224

## 概要



----

# 知识点

### 1. unity 预处理

​		相关文章：https://eam727.blog.csdn.net/article/details/53900780

平台预处理：

| 名称                   | 描写叙述                                                     |
| ---------------------- | ------------------------------------------------------------ |
| UNITY_EDITOR           | Unity编辑器                                                  |
| UNITY_STANDALONE_OSX   | 专门为Mac OS(包括Universal，PPC和Intelarchitectures）平台的定义 |
| UNITY_DASHBOARD_WIDGET | Mac OS Dashboard widget (Mac OS仪表板小部件)。               |
| UNITY_STANDALONE_WIN   | Windows系统                                                  |
| UNITY_STANDALONE_LINUX | LINUX的独立的应用程序                                        |
| UNITY_STANDALONE       | 独立的平台 (Mac, Windows or Linux).                          |
| UNITY_WEBPLAYER        | 网页播放器（包括Windows和Mac Web播放器可执行文件）。         |
| UNITY_WII              | Wii游戏机平台。                                              |
| UNITY_IPHONE           | 苹果系统                                                     |
| UNITY_ANDROID          | 安卓系统                                                     |
| UNITY_PS3              | PlayStation 3                                                |
| UNITY_XBOX360          | VBOX360系统                                                  |
| UNITY_NACL             | 谷歌原生客户端（使用这个必须另外使用UNITY_WEBPLAYER）        |
| UNITY_FLASH            | Adobe Flash                                                  |

版本预处理：

| UNITY_2_6   | Platform define for the major version of Unity 2.6.          |
| ----------- | ------------------------------------------------------------ |
| UNITY_2_6_1 | Platform define for specific version 1 from the major release 2.6. |
| UNITY_3_0   | Platform define for the major version of Unity 3.0.          |
| UNITY_3_0_0 | Platform define for the specific version 0 of Unity 3.0.     |
| UNITY_3_1   | Platform define for major version of Unity 3.1.              |
| UNITY_3_2   | Platform define for major version of Unity 3.2.              |
| UNITY_3_3   | Platform define for major version of Unity 3.3.              |
| UNITY_3_4   | Platform define for major version of Unity 3.4.              |
| UNITY_3_5   | Platform define for major version of Unity 3.5.              |
| UNITY_4_0   | Platform define for major version of Unity 4.0.              |
| UNITY_4_0_1 | Platform define for major version of Unity 4.0.1.            |
| UNITY_4_1   | Platform define for major version of Unity 4.1.              |
| UNITY_4_2   | Platform define for major version of Unity 4.2.              |