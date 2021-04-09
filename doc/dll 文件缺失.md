# dll文件缺失



![img](C:/Users/dionysoslai/Documents/WXWork/1688850576066668/Cache/Image/2021-04/企业微信截图_16177553178073.png)被这个问题困扰了一天，别人那里可以我这里就是卡住，重新编译各种手段都试过了依然不行。决心找到彻底的解决办法，找到了2个办法同步一下。

出现这个报错一般是Windows的DLL加载失败，定位UE的LoadModulesForProject源码发现其没有调用GetLastError()输出（其实调用了也没用，Error太多了）。
（1）为了定位哪些DLL加载失败，可以下载Windows Kit， 启用Windows Debugger Tools中的Show Loader Snaps，重启电脑，再启动VS即可有详细的Error Log输出。![img](C:/Users/dionysoslai/Documents/WXWork/1688850576066668/Cache/Image/2021-04/企业微信截图_16177557814716.png)![img](C:/Users/dionysoslai/Documents/WXWork/1688850576066668/Cache/Image/2021-04/企业微信截图_16177561744958.png)然后就知道是哪个dll缺失了。（注意，可能会报多个DLL缺失，需要找parent!=null的那个DLL）

上面是复杂方法，需要安装对应环境，再说个偷懒的简单方法：
（2）VS中会报错UE4Editor_PSD2UMG.dll加载失败，此时直接用记事本把这个dll打开，虽然是二进制的文件，但可以直接搜索.dll，就知道这个模块依赖哪些DLL了，一般不超过20个。![img](C:/Users/dionysoslai/Documents/WXWork/1688850576066668/Cache/Image/2021-04/企业微信截图_16177563913453.png)