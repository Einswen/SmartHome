# 小凌派-RK2206开发板基础外设开发——ADC控制

## 实验内容

本示例将演示如何在小凌派-RK2206开发板上使用IOT库的ADC接口，进行ADC编程开发。例程将创建一个任务，读取按键的ADC值，并打印到串口。

![小凌派-RK2206](/vendor/lockzhiner/rk2206/docs/figures/lockzhiner-rk2206.jpg)

## 程序设计

ADC在日常设备中非常常见，以下我们将演示IOT库的ADC接口如何进行读取按键的ADC值，并打印到串口。

### API分析

#### 头文件

```c
base/iot_hardware/peripheral/interfaces/kits/iot_adc.h
```

### 初始化ADC设备：IoTAdcInit

```c
unsigned int IoTAdcInit(unsigned int id);
```

**描述：**

初始化ADC设备。

**参数：**


| 参数 | 类型         | 描述    |
| ---- | ------------ | ------- |
| id   | unsigned int | ADC通道 |

ADC通道有7个，对应以下7个引脚：


| id | GPIO      |
| -- | --------- |
| 0  | GPIO0_PC0 |
| 1  | GPIO0_PC1 |
| 2  | GPIO0_PC2 |
| 3  | GPIO0_PC3 |
| 4  | GPIO0_PC4 |
| 5  | GPIO0_PC5 |
| 6  | GPIO0_PC6 |
| 7  | GPIO0_PC7 |

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_adc.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
unsigned int IoTAdcInit(unsigned int id) {

  unsigned int ret = 0;
  uint32_t *pGrfSocCon29 = (uint32_t *)(0x41050000U + 0x274U);
  uint32_t ulValue;

  if (id < 0 || id > 7) {
    PRINT_ERR("id(%d) > 7 or id(%d) < 0\n", id, id);
    return IOT_FAILURE;
  }

  m_adcKey.ctrl1.gpio = GPIO0_PC0 + id;

  ret = DevIoInit(m_adcKey);
  if (ret != LZ_HARDWARE_SUCCESS) {
    PRINT_ERR("%s, %s, %d: ADC Key IO Init fail\n", __FILE__, __func__,
              __LINE__);
    return IOT_FAILURE;
  }

  /* LzSaradcInit 接口只要初始化一次 */
  if(!init_adc_cnt) { 
    ret = LzSaradcInit();
    if (ret != LZ_HARDWARE_SUCCESS) {
      PRINT_ERR("%s, %s, %d: ADC Init fail\n", __FILE__, __func__, __LINE__);
      return IOT_FAILURE;
    }
  }

  /* 记录调用该接口次数 */
  init_adc_cnt++;

  /* 设置saradc的电压信号，选择AVDD */
  ulValue = *pGrfSocCon29;
  ulValue &= ~(0x1 << 4);
  ulValue |= ((0x1 << 4) << 16);
  *pGrfSocCon29 = ulValue;

  return IOT_SUCCESS;
}
```

### 取消初始化ADC设备：IoTAdcDeinit

```c
unsigned int IoTAdcDeinit(unsigned int id);
```

**描述：**

取消初始化ADC设备。


| 参数 | 类型         | 描述    |
| ---- | ------------ | ------- |
| id   | unsigned int | ADC通道 |

ADC通道有7个，对应以下7个引脚：


| id | GPIO      |
| -- | --------- |
| 0  | GPIO0_PC0 |
| 1  | GPIO0_PC1 |
| 2  | GPIO0_PC2 |
| 3  | GPIO0_PC3 |
| 4  | GPIO0_PC4 |
| 5  | GPIO0_PC5 |
| 6  | GPIO0_PC6 |
| 7  | GPIO0_PC7 |

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_adc.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
unsigned int IoTAdcDeinit(unsigned int id) {

  unsigned int ret = 0;

  if (id < 0 || id > 7) {
    PRINT_ERR("id(%d) > 7 or id(%d) < 0\n", id, id);
    return IOT_FAILURE;
  }

  m_adcKey.ctrl1.gpio = GPIO0_PC0 + id;

  LzGpioDeinit(m_adcKey.ctrl1.gpio);
  init_adc_cnt--;

  /* 当 init_adc_cnt 为 0 调用 LzSaradcDeinit 注销  */
  if(!init_adc_cnt) {
    ret = LzSaradcDeinit();
    if (ret != LZ_HARDWARE_SUCCESS) {
      PRINT_ERR("%s, %s, %d: ADC Deinit Fail\n", __FILE__, __func__, __LINE__);
      return IOT_FAILURE;
    }
  }

  return IOT_SUCCESS;
}
```

### 获取ADC设备的值：IoTAdcGetVal

```c
unsigned int IoTAdcGetVal(unsigned int id, unsigned int *val);
```

**描述：**

获取ADC设备的值。

**参数：**

| 参数 | 类型         | 描述    |
| ------------- | -------------- | -------- |
| id            | unsigned int   | ADC通道  |
| val           | unsigned int * | 数据指针 |

ADC通道有7个，对应以下7个引脚：


| id | GPIO      |
| -- | --------- |
| 0  | GPIO0_PC0 |
| 1  | GPIO0_PC1 |
| 2  | GPIO0_PC2 |
| 3  | GPIO0_PC3 |
| 4  | GPIO0_PC4 |
| 5  | GPIO0_PC5 |
| 6  | GPIO0_PC6 |
| 7  | GPIO0_PC7 |

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_adc.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
unsigned int IoTAdcGetVal(unsigned int id, unsigned int *val) {

  unsigned int ret = 0;

  if (id < 0 || id > 7) {
    PRINT_ERR("id(%d) > 7 or id(%d) < 0\n", id, id);
    return IOT_FAILURE;
  }

  ret = LzSaradcReadValue(id, val);

  if (ret != LZ_HARDWARE_SUCCESS) {
    PRINT_ERR("%s, %s, %d: ADC Read Fail\n", __FILE__, __func__, __LINE__);
    return IOT_FAILURE;
  }

  return IOT_SUCCESS;
}
```

### 软件设计

**主要代码分析**

在`adc_example`函数中，创建一个任务。

```c
void adc_example()
{
    unsigned int thread_id;
    TSK_INIT_PARAM_S task = {0};
    unsigned int ret      = LOS_OK;

    task.pfnTaskEntry = (TSK_ENTRY_FUNC)adc_thread;
    task.uwStackSize  = 2048;
    task.pcName       = "adc_thread";
    task.usTaskPrio   = 24;
    ret               = LOS_TaskCreate(&thread_id, &task);
    if (ret != LOS_OK) {
        printf("Falied to create adc_thread ret:0x%x\n", ret);
        return;
    }
}
```

`adc_thread`任务中调用IOT库的ADC接口控制ADC。

```c
void adc_thread()
{
    unsigned int data = 0;
    float voltage     = 0;
    unsigned int ret  = 0;

    /* 初始化adc设备 */
    ret = IoTAdcInit(ADC_CHANNEL);
    if (ret == IOT_FAILURE) {
        printf("%s, %s, %d: ADC Key IO Init fail\n", __FILE__, __func__, __LINE__);
    }

    while (1) {
        printf("***************Adc Example*************\r\n");
        /*获取电压值*/
        ret = IoTAdcGetVal(ADC_CHANNEL, &data);
        if (ret == IOT_FAILURE) {
            printf("%s, %s, %d: ADC Read Fail\n", __FILE__, __func__, __LINE__);
            return 0.0;
        }
        voltage = (float)(data * 3.3 / 1024.0);
        printf("vlt:%.3fV\n", voltage);

        /* 睡眠1秒 */
        LOS_Msleep(1000);
    }
}
```

ADC模块采用10位的ADC采集寄存器，可测试电压范围为0~3.3V，所以ADC采集数值换算为实际电压计算公司为：

```r
实际电压 = (ADC采集数值 / 1024) * 3.3V
```

注意：实际电压是 `float`类型，源代码计算要规范。具体源代码如下所示：

```c
return (float)(data * 3.3 / 1024.0)
```

## 编译调试

### 修改 BUILD.gn 文件

修改 `vendor/lockzhiner/rk2206/sample` 路径下 BUILD.gn 文件，指定 `iot_adc_example` 参与编译。

```r
"./b17_iot_adc:iot_adc_example",
```

修改 `device/lockzhiner/rk2206/sdk_liteos` 路径下 Makefile 文件，添加 `-liot_adc_example` 参与编译。

```r
hardware_LIBS = -lhal_iothardware -lhardware -lshellcmd -liot_adc_example
```

### 运行结果

示例代码编译烧录代码后，按下开发板的RESET按键，通过串口助手查看日志，显示如下：

```r
***************Adc Example*************
vlt:3.297V
***************Adc Example*************
vlt:3.297V
***************Adc Example*************
vlt:3.297V
***************Adc Example*************
vlt:3.297V
***************Adc Example*************
vlt:3.297V
***************Adc Example*************
vlt:3.297V
```
