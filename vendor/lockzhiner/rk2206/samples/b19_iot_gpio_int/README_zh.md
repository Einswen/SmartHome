# 小凌派-RK2206开发板基础外设开发——GPIO中断控制

## 实验内容

本示例将演示如何在小凌派-RK2206开发板上使用IOT库的GPIO接口，进行GPIO编程开发。例程将创建一个任务，通过配置GPIO引脚为中断模式，实现GPIO中断操作。

![小凌派-RK2206开发板](/vendor/lockzhiner/rk2206/docs/figures/lockzhiner-rk2206.jpg)

## 程序设计

GPIO在日常设备中非常常见，以下我们将演示IOT库的GPIO接口如何进行GPIO配置。

### API分析

#### 头文件

```c    
base/iot_hardware/peripheral/interfaces/kits/iot_gpio.h
```

#### 启用GPIO引脚的中断功能：IoTGpioRegisterIsrFunc

```c
unsigned int IoTGpioRegisterIsrFunc(unsigned int id, IotGpioIntType intType, IotGpioIntPolarity intPolarity, GpioIsrCallbackFunc func, char *arg);
```

**描述：**

启用GPIO引脚的中断功能。

**参数：**

| 参数        | 类型                | 描述             |
| ----------- | ------------------- | ---------------- |
| id          | unsigned int        | GPIOID编号       |
| intType     | IotGpioIntType      | 中断模式         |
| intPolarity | IotGpioIntPolarity  | 中断极性         |
| func        | GpioIsrCallbackFunc | 中断回调函数     |
| arg         | char *              | 中断回调函数参数 |

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_gpio.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
unsigned int IoTGpioRegisterIsrFunc(unsigned int id, IotGpioIntType intType, IotGpioIntPolarity intPolarity, GpioIsrCallbackFunc func, char *arg)
{
    unsigned int ret = 0;
    LzGpioIntType type;
    
    if (id > GPIO0_PC7 && id != GPIO1_PD0) {
        PRINT_ERR("id(%d) > %d || id(%d) != %d\n", id, GPIO0_PC7, GPIO1_PD0);
        return IOT_FAILURE;
    }

    if (intType == IOT_INT_TYPE_LEVEL && intPolarity == IOT_GPIO_EDGE_FALL_LEVEL_LOW)
        type = LZGPIO_INT_LEVEL_LOW;
    else if (intType == IOT_INT_TYPE_LEVEL && intPolarity == IOT_GPIO_EDGE_RISE_LEVEL_HIGH)
        type = LZGPIO_INT_LEVEL_HIGH;
    else if (intType == IOT_INT_TYPE_EDGE && intPolarity == IOT_GPIO_EDGE_FALL_LEVEL_LOW)
        type = LZGPIO_INT_EDGE_FALLING;
    else if (intType == IOT_INT_TYPE_EDGE && intPolarity == IOT_GPIO_EDGE_RISE_LEVEL_HIGH)
        type = LZGPIO_INT_EDGE_RISING;
    else if (intType == IOT_INT_TYPE_EDGE && intPolarity == IOT_GPIO_EDGE_BOTH_TYPE)
        type = LZGPIO_INT_EDGE_BOTH;
    else
        return IOT_FAILURE;

    ret = LzGpioRegisterIsrFunc(id, type, (GpioIsrFunc)func, arg);
    if (ret != LZ_HARDWARE_SUCCESS) {
        return IOT_FAILURE;
    }  

    return IOT_SUCCESS;
}
```

#### 禁用GPIO引脚的中断功能：IoTGpioUnregisterIsrFunc

```c
unsigned int IoTGpioUnregisterIsrFunc(unsigned int id);
```

**描述：**

禁用GPIO引脚的中断功能。

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
unsigned int IoTGpioUnregisterIsrFunc(unsigned int id)
{
    unsigned int ret = 0;

    if (id > GPIO0_PC7 && id != GPIO1_PD0) {
        PRINT_ERR("id(%d) > %d || id(%d) != %d\n", id, GPIO0_PC7, GPIO1_PD0);
        return IOT_FAILURE;
    }

    ret = LzGpioUnregisterIsrFunc(id);
    if (ret != LZ_HARDWARE_SUCCESS) {
        return IOT_FAILURE;
    }   

    return IOT_SUCCESS;
}
```

#### 屏蔽GPIO引脚的中断功能：IoTGpioSetIsrMask

```c
unsigned int IoTGpioSetIsrMask(unsigned int id, unsigned char mask);
```

**描述：**

屏蔽GPIO引脚的中断功能。

**参数：**

| 参数 | 类型          | 描述                             |
| ---- | ------------- | -------------------------------- |
| id   | unsigned int  | GPIOID编号                       |
| mask | unsigned char | 中断掩码 1：屏蔽开启 0：屏蔽关闭 |

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_gpio.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
unsigned int IoTGpioSetIsrMask(unsigned int id, unsigned char mask)
{
    unsigned int ret = 0;

    if (id > GPIO0_PC7 && id != GPIO1_PD0) {
        PRINT_ERR("id(%d) > %d || id(%d) != %d\n", id, GPIO0_PC7, GPIO1_PD0);
        return IOT_FAILURE;
    }

    if (!mask)
    {
        ret = LzGpioEnableIsr(id);
        if (ret != LZ_HARDWARE_SUCCESS) {
            return IOT_FAILURE;
        } 
    }
    else
    {
        ret = LzGpioDisableIsr(id);
        if (ret != LZ_HARDWARE_SUCCESS) {
            return IOT_FAILURE;
        } 
    }
    
    return IOT_SUCCESS;
}
```

### 软件设计

**主要代码分析**

`gpio_int_example`函数中，创建一个任务。

```c
void gpio_int_example()
{
    unsigned int thread_id;
    TSK_INIT_PARAM_S task = {0};
    unsigned int ret      = LOS_OK;

    task.pfnTaskEntry = (TSK_ENTRY_FUNC)gpio_int_thread;
    task.uwStackSize  = 2048;
    task.pcName       = "gpio_int_thread";
    task.usTaskPrio   = 20;
    ret               = LOS_TaskCreate(&thread_id, &task);
    if (ret != LOS_OK) {
        printf("Falied to create gpio_int_thread ret:0x%x\n", ret);
        return;
    }
}
```

`gpio_int_thread`任务中调用IOT库的GPIO接口初始化、配置，并打印`m_gpio_interrupt_count`的值。

```c
void gpio_int_thread()
{
    unsigned int ret;

    /* 初始化引脚为GPIO */
    IoTGpioInit(GPIO_TEST);
    /* 引脚配置为输入 */
    IoTGpioSetDir(GPIO_TEST, IOT_GPIO_DIR_IN);
    /* 设置中断触发方式为下降沿和中断处理函数 */
    ret = IoTGpioRegisterIsrFunc(GPIO_TEST, IOT_INT_TYPE_EDGE, IOT_GPIO_EDGE_FALL_LEVEL_LOW, gpio_int_func, NULL);
    if (ret != IOT_SUCCESS) {
        printf("IoTGpioRegisterIsrFunc failed(%d)\n", ret);
        return;
    }
    /* 关闭中断屏蔽 */
    IoTGpioSetIsrMask(GPIO_TEST, FALSE);

    while (1) {
        printf("***************GPIO Interrupt Example*************\n");
        printf("gpio interrupt count = %d\n", m_gpio_interrupt_count);
        printf("\n");
        /* 睡眠1秒 */
        LOS_Msleep(1000);
    }
}
```

`gpio_int_func`回调函数中`m_gpio_interrupt_count`自增。

```c
void gpio_int_func()
{
    m_gpio_interrupt_count++;
}
```

## 编译调试

### 修改 BUILD.gn 文件

修改 `vendor/lockzhiner/rk2206/sample` 路径下 BUILD.gn 文件，指定 `iot_gpio_int_example` 参与编译。

```r
"./b19_iot_gpio_int:iot_gpio_int_example",
```

修改 `device/lockzhiner/rk2206/sdk_liteos` 路径下 Makefile 文件，添加 `-liot_gpio_int_example` 参与编译。

```r
hardware_LIBS = -lhal_iothardware -lhardware -lshellcmd -liot_gpio_int_example
```

### 运行结果

示例代码编译烧录代码后，按下开发板的RESET按键，按下按键，通过串口助手查看日志，显示如下：

```r
***************GPIO Interrupt Example*************
gpio interrupt count = 0

***************GPIO Interrupt Example*************
gpio interrupt count = 1

***************GPIO Interrupt Example*************
gpio interrupt count = 2

***************GPIO Interrupt Example*************
gpio interrupt count = 3
```
