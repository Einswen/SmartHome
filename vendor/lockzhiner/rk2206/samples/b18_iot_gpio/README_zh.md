# 小凌派-RK2206开发板基础外设开发——GPIO控制

## 实验内容

本示例将演示如何在小凌派-RK2206开发板上使用IOT库的GPIO接口，进行GPIO编程开发。例程将创建一个任务，通过配置GPIO引脚，实现GPIO读写操作。

![小凌派-RK2206开发板](/vendor/lockzhiner/rk2206/docs/figures/lockzhiner-rk2206.jpg)

## 程序设计

GPIO在日常设备中非常常见，以下我们将演示IOT库的GPIO接口如何进行GPIO口配置，以及GPIO口读写操作。

### API分析

#### 头文件

```c    
base/iot_hardware/peripheral/interfaces/kits/iot_gpio.h
```

#### 初始化GPIO设备：IoTGpioInit

```c
unsigned int IoTGpioInit(unsigned int id);
```

**描述：**

初始化GPIO设备。

**参数：**

| 参数 | 类型         | 描述       |
| ---- | ------------ | ---------- |
| id   | unsigned int | GPIOID编号 |

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_gpio.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
unsigned int IoTGpioInit(unsigned int id)
{
    unsigned int ret = 0;

    if (id > GPIO0_PC7 && id != GPIO1_PD0) {
        PRINT_ERR("id(%d) > %d || id(%d) != %d\n", id, GPIO0_PC7, GPIO1_PD0);
        return IOT_FAILURE;
    }

    ret = LzGpioInit(id);
    if (ret != LZ_HARDWARE_SUCCESS) {
        return IOT_FAILURE;
    }

    ret = PinctrlSet(id, MUX_FUNC0, PULL_KEEP, DRIVE_LEVEL0);
    if (ret != LZ_HARDWARE_SUCCESS) {
        return IOT_FAILURE;
    }

    return IOT_SUCCESS;
}
```

#### 取消初始化GPIO设备：IoTGpioDeinit

```c
unsigned int IoTGpioDeinit(unsigned int id);
```

**描述：**

取消初始化GPIO设备。

**参数：**

| 参数 | 类型         | 描述       |
| ---- | ------------ | ---------- |
| id   | unsigned int | GPIOID编号 |

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_gpio.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
unsigned int IoTGpioDeinit(unsigned int id)
{
    unsigned int ret = 0;

    if (id > GPIO0_PC7 && id != GPIO1_PD0) {
        PRINT_ERR("id(%d) > %d || id(%d) != %d\n", id, GPIO0_PC7, GPIO1_PD0);
        return IOT_FAILURE;
    }

    ret = LzGpioDeinit(id);
    if (ret != LZ_HARDWARE_SUCCESS) {
        return IOT_FAILURE;
    }

    return IOT_SUCCESS;
}
```

#### 设置GPIO引脚的方向：IoTGpioSetDir

```c
unsigned int IoTGpioSetDir(unsigned int id, IotGpioDir dir);
```

**描述：**

设置GPIO引脚的方向。

**参数：**

| 参数 | 类型         | 描述       |
| ---- | ------------ | ---------- |
| id   | unsigned int | GPIOID编号 |
| dir  | IotGpioDir   | GPIO方向   |

其中，dir对应于如下表所示：

| IotGpioDir       | 描述 |
| ---------------- | ---- |
| IOT_GPIO_DIR_IN  | 输入 |
| IOT_GPIO_DIR_OUT | 输出 |


**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_gpio.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
unsigned int IoTGpioSetDir(unsigned int id, IotGpioDir dir)
{
    unsigned int ret = 0;

    if (id > GPIO0_PC7 && id != GPIO1_PD0) {
        PRINT_ERR("id(%d) > %d || id(%d) != %d\n", id, GPIO0_PC7, GPIO1_PD0);
        return IOT_FAILURE;
    }

    ret = LzGpioSetDir(id, (LzGpioDir)dir);
    if (ret != LZ_HARDWARE_SUCCESS) {
        return IOT_FAILURE;
    }   

    return IOT_SUCCESS;
}
```

#### 获取GPIO引脚的方向：IoTGpioGetDir

```c
unsigned int IoTGpioGetDir(unsigned int id, IotGpioDir *dir);
```

**描述：**

获取GPIO引脚的方向。

**参数：**

| 参数 | 类型         | 描述         |
| ---- | ------------ | ------------ |
| id   | unsigned int | GPIOID编号   |
| dir  | IotGpioDir * | GPIO方向指针 |

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_gpio.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
unsigned int IoTGpioGetDir(unsigned int id, IotGpioDir *dir)
{
    unsigned int ret = 0;

    if (id > GPIO0_PC7 && id != GPIO1_PD0) {
        PRINT_ERR("id(%d) > %d || id(%d) != %d\n", id, GPIO0_PC7, GPIO1_PD0);
        return IOT_FAILURE;
    }

    ret = LzGpioGetDir(id, (LzGpioDir *)dir);
    if (ret != LZ_HARDWARE_SUCCESS) {
        return IOT_FAILURE;
    }   

    return IOT_SUCCESS;
}
```

#### 设置GPIO引脚的输出电平值：IoTGpioSetOutputVal

```c
unsigned int IoTGpioSetOutputVal(unsigned int id, IotGpioValue val);
```

**描述：**

设置GPIO引脚的输出电平值。

**参数：**

| 参数 | 类型         | 描述       |
| ---- | ------------ | ---------- |
| id   | unsigned int | GPIOID编号 |
| val  | IotGpioValue | 电平       |

其中，val对应于如下表所示：

| IotGpioValue    | 描述   |
| --------------- | ------ |
| IOT_GPIO_VALUE0 | 低电平 |
| IOT_GPIO_VALUE1 | 高电平 |

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_gpio.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
unsigned int IoTGpioSetOutputVal(unsigned int id, IotGpioValue val)
{
    unsigned int ret = 0;

    if (id > GPIO0_PC7 && id != GPIO1_PD0) {
        PRINT_ERR("id(%d) > %d || id(%d) != %d\n", id, GPIO0_PC7, GPIO1_PD0);
        return IOT_FAILURE;
    }

    ret = LzGpioSetVal(id, (LzGpioValue)val);
    if (ret != LZ_HARDWARE_SUCCESS) {
        return IOT_FAILURE;
    }   

    return IOT_SUCCESS;
}
```

#### 获取GPIO引脚的输出电平值：IoTGpioGetOutputVal

```c
unsigned int IoTGpioGetOutputVal(unsigned int id, IotGpioValue *val);
```

**描述：**

获取GPIO引脚的输出电平值。

**参数：**

| 参数 | 类型           | 描述       |
| ---- | -------------- | ---------- |
| id   | unsigned int   | GPIOID编号 |
| val  | IotGpioValue * | 电平指针   |

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_gpio.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
unsigned int IoTGpioGetOutputVal(unsigned int id, IotGpioValue *val)
{
    unsigned int ret = 0;

    if (id > GPIO0_PC7 && id != GPIO1_PD0) {
        PRINT_ERR("id(%d) > %d || id(%d) != %d\n", id, GPIO0_PC7, GPIO1_PD0);
        return IOT_FAILURE;
    }

    ret = LzGpioGetVal(id, (LzGpioValue *)val);
    if (ret != LZ_HARDWARE_SUCCESS) {
        return IOT_FAILURE;
    }   

    return IOT_SUCCESS;
}
```

#### 获取GPIO引脚的输入电平值：IoTGpioGetInputVal

```c
unsigned int IoTGpioGetInputVal(unsigned int id, IotGpioValue *val);
```

**描述：**

获取GPIO引脚的输入电平值。

**参数：**

| 参数 | 类型           | 描述       |
| ---- | -------------- | ---------- |
| id   | unsigned int   | GPIOID编号 |
| val  | IotGpioValue * | 电平指针   |

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_gpio.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
unsigned int IoTGpioGetInputVal(unsigned int id, IotGpioValue *val)
{
    unsigned int ret = 0;

    if (id > GPIO0_PC7 && id != GPIO1_PD0) {
        PRINT_ERR("id(%d) > %d || id(%d) != %d\n", id, GPIO0_PC7, GPIO1_PD0);
        return IOT_FAILURE;
    }

    ret = LzGpioGetVal(id, (LzGpioValue *)val);
    if (ret != LZ_HARDWARE_SUCCESS) {
        return IOT_FAILURE;
    }   

    return IOT_SUCCESS;
}
```

### 软件设计

**主要代码分析**

`gpio_example`函数中，创建一个任务。

```c
void gpio_example()
{
    unsigned int thread_id;
    TSK_INIT_PARAM_S task = {0};
    unsigned int ret      = LOS_OK;

    task.pfnTaskEntry = (TSK_ENTRY_FUNC)gpio_thread;
    task.uwStackSize  = 2048;
    task.pcName       = "gpio_thread";
    task.usTaskPrio   = 24;
    ret               = LOS_TaskCreate(&thread_id, &task);
    if (ret != LOS_OK) {
        printf("Falied to create gpio_thread ret:0x%x\n", ret);
        return;
    }
}
```

`gpio_thread`任务中调用IOT库的GPIO接口初始化、配置、读写GPIO。

```c
void gpio_thread()
{
    unsigned int cur   = 0;
    IotGpioValue value = IOT_GPIO_VALUE0;

    IoTGpioInit(GPIO_TEST);

    while (1) {
        printf("***************GPIO Example*************\r\n");
        printf("Write GPIO\n");
        IoTGpioSetDir(GPIO_TEST, IOT_GPIO_DIR_OUT);
        if (cur == 0) {
            IoTGpioSetOutputVal(GPIO_TEST, cur);
            IoTGpioGetOutputVal(GPIO_TEST, &value);
            printf("\tgpio set %d => gpio get %d\n", cur, value);
            cur = 1;
        } else {
            IoTGpioSetOutputVal(GPIO_TEST, cur);
            IoTGpioGetOutputVal(GPIO_TEST, &value);
            printf("\tgpio set %d => gpio get %d\n", cur, value);
            cur = 0;
        }
        /* 睡眠1秒 */
        LOS_Msleep(1000);

        printf("Read GPIO\n");
        IoTGpioSetDir(GPIO_TEST, IOT_GPIO_DIR_IN);
        IoTGpioGetInputVal(GPIO_TEST, &value);
        printf("\tgpio get %d\n", value);
        /* 睡眠1秒 */
        LOS_Msleep(1000);

        printf("\n");
    }
}
```

## 编译调试

### 修改 BUILD.gn 文件

修改 `vendor/lockzhiner/rk2206/sample` 路径下 BUILD.gn 文件，指定 `iot_gpio_example` 参与编译。

```r
"./b18_iot_gpio:iot_gpio_example",
```

修改 `device/lockzhiner/rk2206/sdk_liteos` 路径下 Makefile 文件，添加 `-liot_gpio_example` 参与编译。

```r
hardware_LIBS = -lhal_iothardware -lhardware -lshellcmd -liot_gpio_example
```

### 运行结果

示例代码编译烧录代码后，按下开发板的RESET按键，通过串口助手查看日志，显示如下：

```r
***************GPIO Example*************
Write GPIO
        gpio set 0 => gpio get 0
Read GPIO
        gpio get 0

***************GPIO Example*************
Write GPIO
        gpio set 1 => gpio get 1
Read GPIO
        gpio get 1
```