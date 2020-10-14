# day6 粒子模拟大海消耗

2020.10.14

## 概要

​		采用粒子模拟大海效果。主要会涉及粒子系统、柏林噪声知识点。原文地址如下，这里做一些基础调整

​		http://www.manew.com/forum.php?mod=viewthread&tid=47123&extra=page%3D&page=1

## 前置知识点

		### 1. 粒子系统

​		基础内容，不多讲

### 2. 柏林噪声

​		

## 实践

### 1.  初始化

​		首先，我们需要创建一个空创建，并创建一个空Object，同时添加粒子系统组件（Components->Effects->Particle System添加Particle System组件）；创建一个C#脚本，并挂载在object对象上。脚本初始代码如下：

```c#
using UnityEngine;
using System.Collections;


public class ParticleSea : MonoBehaviour
{
    public ParticleSystem particle;
    private ParticleSystem.Particle[] particlesArray;

    public int seaResolution = 25;
    void Start()
    {
        particlesArray = new ParticleSystem.Particle[seaResolution * seaResolution];
        particle.maxParticles = seaResolution * seaResolution;
        particle.Emit(seaResolution * seaResolution);
        particle.GetParticles(particlesArray);
    }
}

```

​		这里，需要注意函数GetParticles，这个应该是用来获得粒子的引用对象，将生成的粒子都放入数组中进行管理。最后不要忘记在Inspector界面设置particle对象。

![](https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day6_01.gif)

### 2. 设置粒子位置

​		接下来，需要动态设置粒子位置。这里我们先点击添加如下代码：

```c#
	....
    public float spacing = 0.25f;
	....
    void Update()
    {
        for (int i = 0; i < seaResolution; i++)
        {
            for (int j = 0; j < seaResolution; j++)
            {
                particlesArray[i * seaResolution + j].position =  new Vector3(i * spacing, j * spacing, 0);
            }
            particle.SetParticles(particlesArray, particlesArray.Length);
        }
    }
}

```

​		同时，需要对粒子系统做几个基础设置：

​		Looping: False, Prewarm: False，Start Lifetime: 100，Play on Awake: False，Emission Rate over Time: 0，同时Renderer选项中，材质设置为sea。效果如下：

![](https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day6_02.png)

### 3. 柏林噪声

​		**柏林噪声可以基于x和y轴，产生很完美的z轴输出**，为此，我们修改代码如下：

```c#
	...
    public float noiseScale = 0.2f;
    public float heightScale = 3f;
	...
    void Update()
    {
        for (int i = 0; i < seaResolution; i++)
        {
            for (int j = 0; j < seaResolution; j++)
            {
                float zPos = Mathf.PerlinNoise(i * noiseScale, j * noiseScale) * heightScale;
                particlesArray[i * seaResolution + j].position = new Vector3(i * spacing, zPos, j * spacing);
            }
        }
        particle.SetParticles(particlesArray, particlesArray.Length);
    }
}

```

​		效果如下：

<img src="https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day6_03.png" style="zoom:67%;" />

​		需要注意的是，这里交换了y和z的值，y值采用zPos。

### 4. 动态海面

​		由于柏林噪声的输入根据x和y值，因此我们动态修改x和y值即可。完整代码如下：

```c#
	...
    private float perlinNoiseAnimX = 0.01f;
    private float perlinNoiseAnimY = 0.01f;
	...
    void Update()
    {
        for (int i = 0; i < seaResolution; i++)
        {
            for (int j = 0; j < seaResolution; j++)
            {
                float zPos = Mathf.PerlinNoise(i * noiseScale + perlinNoiseAnimX, j * noiseScale + perlinNoiseAnimY) * heightScale;
                particlesArray[i * seaResolution + j].position = new Vector3(i * spacing, zPos, j * spacing);
            }
        }

        perlinNoiseAnimX += 0.01f;
        perlinNoiseAnimY += 0.01f;

        particle.SetParticles(particlesArray, particlesArray.Length);
    }
}

```

​		调整Inspector 参数，将ParticleSea预制件的位置改为(-12.5,-5,0)，并将ParticleSea这个类的参数改为Resolution: 50, Spacing: 0.5。具体效果如下：

![](https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day6_02.gif.gif)



### 5. 动态变化颜色

​		Gradient变量可以动态获取颜色属性，因此我们通过设置山谷透明度和改变山的颜色，使整体效果更棒。附录最终代码：

```c#
using UnityEngine;
using System.Collections;


public class ParticleSea : MonoBehaviour
{
    public ParticleSystem particle;
    private ParticleSystem.Particle[] particlesArray;

    public int seaResolution = 25;
    public float spacing = 0.25f;

    public float noiseScale = 0.2f;
    public float heightScale = 3f;

    private float perlinNoiseAnimX = 0.01f;
    private float perlinNoiseAnimY = 0.01f;

    public Gradient colorGradient;

    void Start()
    {
        particlesArray = new ParticleSystem.Particle[seaResolution * seaResolution];
        particle.maxParticles = seaResolution * seaResolution;
        particle.Emit(seaResolution * seaResolution);
        particle.GetParticles(particlesArray);
    }

    void Update()
    {
        for (int i = 0; i < seaResolution; i++)
        {
            for (int j = 0; j < seaResolution; j++)
            {
                float zPos = Mathf.PerlinNoise(i * noiseScale + perlinNoiseAnimX, j * noiseScale + perlinNoiseAnimY);
                particlesArray[i * seaResolution + j].startColor = colorGradient.Evaluate(zPos);
                particlesArray[i * seaResolution + j].position = new Vector3(i * spacing, zPos * heightScale, j * spacing);
            }
        }

        perlinNoiseAnimX += 0.01f;
        perlinNoiseAnimY += 0.01f;

        particle.SetParticles(particlesArray, particlesArray.Length);
    }
}
```

​		调整一下参数：*Resolution: 100, Spacing: 0.3, Noise Scale: 0.05, Height Scale: 3*

​		最终效果如下：

![](https://raw.githubusercontent.com/DionysosLai/PicGoImage/main/day6_04.png)



## 总结

​		这次，其实重点需要学习柏林噪声的应用。其次是一些粒子系统设置内容。下次讲讲柏林噪声在渲染方面的运用。