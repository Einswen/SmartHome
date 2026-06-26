# 小凌派-RK2206开发板基础外设开发——看门狗操作

## 实验内容

本示例将演示如何在小凌派-RK2206开发板上使用IOT库的看门狗接口，进行看门狗编程开发。例程将创建一个任务，实现看门狗配置、喂狗、复位操作。

![小凌派-RK2206开发板](/vendor/lockzhiner/rk2206/docs/figures/lockzhiner-rk2206.jpg)

## 程序设计

看门狗在日常设备中非常常见，以下我们将演示IOT库的看门狗接口如何配置、喂狗、复位操作。

### API分析

#### 头文件

```c    
base/iot_hardware/peripheral/interfaces/kits/iot_watchdog.h
```

#### 使能看门狗：IoTWatchDogEnable

```c
void IoTWatchDogEnable(unsigned int sec);
```

**描述：**

使能看门狗。

**参数：**

| 参数        | 类型            | 描述      |
| ----------- | --------------- | --------- |
| sec | unsigned int    | 超时时间 |

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_watchdog.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
void IoTWatchDogEnable(unsigned int sec)
{
    LzWatchdogInit();
    LzWatchdogSetTimeout(sec);
    LzWatchdogStart(LZ_WATCHDOG_REBOOT_MODE_FIRST);
}
```

#### 看门狗喂狗：IoTWatchDogKick

```c
void IoTWatchDogKick(void);
```

**描述：**

看门狗喂狗。

**参数：**

无

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_watchdog.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
void IoTWatchDogKick(void)
{
    LzWatchdogKeepAlive();
}
```

### 软件设计

**主要代码分析**

在`watchdog_example`函数中，创建一个任务。

```c
void watchdog_example()
{
    unsigned int thread_id;
    TSK_INIT_PARAM_S task = {0};
    unsigned int ret      = LOS_OK;

    task.pfnTaskEntry = (TSK_ENTRY_FUNC)watchdog_thread;
    task.uwStackSize  = 20480;
    task.pcName       = "watchdog_thread";
    task.usTaskPrio   = 24;
    ret               = LOS_TaskCreate(&thread_id, &task);
    if (ret != LOS_OK) {
        printf("Falied to create watchdog_thread ret:0x%x\n", ret);
        return;
    }
}
```

`watchdog_thread`任务中调用IOT库的看门狗接口配置、喂狗、复位操作。

```c
void watchdog_thread()
{
    uint32_t current = 0;

    printf("%s: start\n", __func__);
    IoTWatchDogEnable(10);

    while (1) {
        printf("Wathdog: current(%d)\n", current++);
        if (current < 5) {
            printf("freedog\n");
            IoTWatchDogKick();
        } else {
            printf("not freedog\n");
        }

        LOS_Msleep(1000);
    }
}
```

## 编译调试

### 修改 BUILD.gn 文件

修改 `vendor/lockzhiner/rk2206/sample` 路径下 BUILD.gn 文件，指定 `iot_watchdog_example` 参与编译。

```r
"./b22_iot_watchdog:iot_watchdog_example",
```

修改 `device/lockzhiner/rk2206/sdk_liteos` 路径下 Makefile 文件，添加 `-liot_watchdog_example` 参与编译。

```r
hardware_LIBS = -lhal_iothardware -lhardware -lshellcmd -liot_watchdog_example
```

### 运行结果

示例代码编译烧录代码后，按下开发板的RESET按键，通过串口助手查看日志，显示如下：

可以看到前5秒看门狗会喂狗，然后停止喂狗，10秒后看门狗会复位。

```r
entering kernel init...
hilog will init.
[MAIN:D]Main: LOS_Start ...
Entering scheduler
OHOS # hiview init success.watchdog_thread: start
Wathdog: current(0)
freedog
Wathdog: current(1)
freedog
Wathdog: current(2)
freedog
Wathdog: current(3)
freedog
Wathdog: current(4)
not freedog
Wathdog: current(5)
not freedog
Wathdog: current(6)
not freedog
Wathdog: current(7)
not freedog
Wathdog: current(8)
not freedog
Wathdog: current(9)
not freedog
Wathdog: current(10)
not freedog
Wathdog: current(11)
not freedog
Wathdog: current(12)
not freedog
Wathdog: current(13)
not freedog
Wathdog: current(14)
not freedog
```
