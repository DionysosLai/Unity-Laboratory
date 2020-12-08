# day21 基础内容

20201208

## 概要

​		日常学到一些内容

---

## 知识点

### 1. 双重校验锁

​		偶尔看到一段代码，如下：

```c#
    #region instance
    private static readonly object obj = new object();
    private static DebugTrace m_instance;
    public static DebugTrace Instance
    {
        get
        {
            if (m_instance == null)
            {
                lock (obj)
                {
                    if (m_instance == null)
                        m_instance = new DebugTrace();
                }
            }
            return m_instance;
        }
    }
    #endregion
```

​		涉及的是一个线程安全问题，这里采用了双重校验锁方案。其他内容，可以参考：[c#中单例模式和双重检查锁](https://blog.csdn.net/zhongliangtang/article/details/81564749)

### 2. 锁定log信息

​		锁定log信息，可以用来自定义保存log信息，api 如下：

```c#
        public static event LogCallback logMessageReceivedThreaded;
        public static event LogCallback logMessageReceived;
```

​		代码示例如下：

```c#
    private void Application_logMessageReceivedThreaded(string logString, string stackTrace, LogType type)
    {
        //  Debug.Log(stackTrace);  //打包后staackTrace为空 所以要自己实现
        if (type != LogType.Warning)
        {
            // StackTrace stack = new StackTrace(1,true); //跳过第二?（1）帧
            StackTrace stack = new StackTrace(true);  //捕获所有帧
            string stackStr = string.Empty;

            int frameCount = stack.FrameCount;  //帧数
            if (this.showFrames > frameCount) this.showFrames = frameCount;  //如果帧数大于总帧速 设置一下

            //自定义输出帧数,可以自行试试查看效果
            for (int i = stack.FrameCount - this.showFrames; i < stack.FrameCount; i++)
            {
                StackFrame sf = stack.GetFrame(i);  //获取当前帧信息
                                                    // 1:第一种    ps:GetFileLineNumber 在发布打包后获取不到
                stackStr += "at [" + sf.GetMethod().DeclaringType.FullName +
                            "." + sf.GetMethod().Name +
                            ".Line:" + sf.GetFileLineNumber() + "]\n            ";

                //或者直接调用tostring 显示数据过多 且打包后有些数据获取不到
                // stackStr += sf.ToString();
            }

            //或者 stackStr = stack.ToString();
            string content = string.Format("time: {0}   logType: {1}    logString: {2} \nstackTrace: {3} {4} ",
                                               DateTime.Now.ToString("HH:mm:ss"), type, logString, stackStr, "\r\n");
            streamWriter.WriteLine(content);
            streamWriter.Flush();
        }
    }
    
    private void CreateOutlog()
    {
		...
		Application.logMessageReceivedThreaded += Application_logMessageReceivedThreaded;
    }

    /// <summary>
    /// 关闭跟踪日志信息
    /// </summary>
    public void CloseTrace()
    {
        Application.logMessageReceivedThreaded -= Application_logMessageReceivedThreaded;
	   ...
    }
```

​		文章参考：https://blog.csdn.net/K20132014/article/details/86528716?utm_medium=distribute.pc_category.none-task-blog-new-2.nonecase&depth_1-utm_source=distribute.pc_category.none-task-blog-new-2.nonecase

