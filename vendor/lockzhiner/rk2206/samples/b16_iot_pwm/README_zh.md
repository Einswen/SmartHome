# 小凌派-RK2206开发板基础外设开发-PWM控制

## 实验内容

本例程演示如何在小凌派-RK2206开发板上使用IOT库的PWM接口，进行PWM编程开发。例程将创建一个任务，每隔5秒将PWM0~10依次启用，输出1000Hz。

![小凌派-RK2206开发板](/vendor/lockzhiner/rk2206/docs/figures/lockzhiner-rk2206.jpg)

## 程序设计

PWM在日常设备中非常常见，以下我们将演示IOT库的PWM接口如何进行PWM控制。

### API分析

#### 头文件

```c
base/iot_hardware/peripheral/interfaces/kits/iot_pwm.h
```

#### 初始化PWM设备：IoTPwmInit

```c
unsigned int IoTPwmInit(unsigned int port);
```

**描述：**

初始化PWM设备。

**参数：**


| 参数 | 类型         | 描述      |
| ---- | ------------ | --------- |
| port | unsigned int | PWM端口号 |

其中，port对应于如下表所示：


| port | GPIO     |
| ---- | -------- |
| 0    | GPIO_PB4 |
| 1    | GPIO_PB5 |
| 2    | GPIO_PB6 |
| 3    | GPIO_PC0 |
| 4    | GPIO_PC1 |
| 5    | GPIO_PC2 |
| 6    | GPIO_PC3 |
| 7    | GPIO_PC4 |
| 8    | GPIO_PC5 |
| 9    | GPIO_PC6 |
| 10   | GPIO_PC7 |

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_pwm.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
unsigned int IoTPwmInit(unsigned int port)
{
    unsigned int ret = 0;

    if (port >= EPWMDEV_MAX) {
        PRINT_ERR("port(%d) >= EPWMDEV_MAX(%d)\n", port, EPWMDEV_MAX);
        return IOT_FAILURE;
    }

    PinctrlSet(m_pwm_bus_info[port].pwm_bus.pwm.gpio,
        m_pwm_bus_info[port].pwm_bus.pwm.func,
        m_pwm_bus_info[port].pwm_bus.pwm.type,
        m_pwm_bus_info[port].pwm_bus.pwm.drv);
    PwmIoInit(m_pwm_bus_info[port].pwm_bus);
    LzPwmInit(m_pwm_bus_info[port].port);

    return IOT_SUCCESS;
}
```

#### 取消初始化PWM设备：IoTPwmDeinit

```c
unsigned int IoTPwmDeinit(unsigned int port);
```

**描述：**

取消初始化PWM设备。

**参数：**


| 参数 | 类型         | 描述      |
| ---- | ------------ | --------- |
| port | unsigned int | PWM端口号 |

其中，port对应于如下表所示：


| port | GPIO     |
| ---- | -------- |
| 0    | GPIO_PB4 |
| 1    | GPIO_PB5 |
| 2    | GPIO_PB6 |
| 3    | GPIO_PC0 |
| 4    | GPIO_PC1 |
| 5    | GPIO_PC2 |
| 6    | GPIO_PC3 |
| 7    | GPIO_PC4 |
| 8    | GPIO_PC5 |
| 9    | GPIO_PC6 |
| 10   | GPIO_PC7 |

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_pwm.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
unsigned int IoTPwmDeinit(unsigned int port)
{
    if (port >= EPWMDEV_MAX) {
        PRINT_ERR("port(%d) >= EPWMDEV_MAX(%d)\n", port, EPWMDEV_MAX);
        return IOT_FAILURE;
    }

    LzGpioDeinit(m_pwm_bus_info[port].pwm_bus.pwm.gpio);

    LzPwmDeinit(m_pwm_bus_info[port].port);
  
    return IOT_SUCCESS;
}
```

#### 开始PWM信号输出：IoTPwmStart

```c
unsigned int IoTPwmStart(unsigned int port, unsigned short duty, unsigned int freq);
```

**描述：**

开始PWM信号输出。

**参数：**


| 参数 | 类型           | 描述                       |
| ---- | -------------- | -------------------------- |
| port | unsigned int   | PWM端口号                  |
| duty | unsigned short | 高电平的占空比，范围为1~99 |
| freq | unsigned int   | 频率                       |

其中，port对应于如下表所示：


| port | GPIO     |
| ---- | -------- |
| 0    | GPIO_PB4 |
| 1    | GPIO_PB5 |
| 2    | GPIO_PB6 |
| 3    | GPIO_PC0 |
| 4    | GPIO_PC1 |
| 5    | GPIO_PC2 |
| 6    | GPIO_PC3 |
| 7    | GPIO_PC4 |
| 8    | GPIO_PC5 |
| 9    | GPIO_PC6 |
| 10   | GPIO_PC7 |

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_pwm.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
unsigned int IoTPwmStart(unsigned int port, unsigned short duty, unsigned int freq)
{
#define DUTY_MIN        1
#define DUTY_MAX        99
#define SEC_TO_NSEC     (1000000000UL)
    unsigned int duty_ns;
    unsigned int cycle_ns;
  
    if (port >= EPWMDEV_MAX) {
        PRINT_ERR("port(%d) >= EPWMDEV_MAX(%d)\n", port, EPWMDEV_MAX);
        return IOT_FAILURE;
    }
    if ((duty < DUTY_MIN) || (DUTY_MAX < duty)) {
        PRINT_ERR("duty(%d) out of the range(%d ~ %d)\n", duty, DUTY_MIN, DUTY_MAX);
        return IOT_FAILURE;
    }
    if (freq == 0) {
        PRINT_ERR("freq(%d) is invalid!\n", freq);
        return IOT_FAILURE;
    }
    if (freq > SEC_TO_NSEC) {
        PRINT_ERR("freq(%d) > SEC_TO_NSEC(%d)\n", freq, SEC_TO_NSEC);
        return IOT_FAILURE;
    }

    cycle_ns = SEC_TO_NSEC / freq;
    duty_ns = cycle_ns * duty / 100;

    LzPwmStart(m_pwm_bus_info[port].port, duty_ns, cycle_ns);

    return IOT_SUCCESS;
}
```

#### 停止PWM信号输出：IoTPwmStop

```c
unsigned int IoTPwmStop(unsigned int port);
```

**描述：**

停止PWM信号输出。

**参数：**


| 参数 | 类型         | 描述      |
| ---- | ------------ | --------- |
| port | unsigned int | PWM端口号 |

其中，port对应于如下表所示：


| port | GPIO     |
| ---- | -------- |
| 0    | GPIO_PB4 |
| 1    | GPIO_PB5 |
| 2    | GPIO_PB6 |
| 3    | GPIO_PC0 |
| 4    | GPIO_PC1 |
| 5    | GPIO_PC2 |
| 6    | GPIO_PC3 |
| 7    | GPIO_PC4 |
| 8    | GPIO_PC5 |
| 9    | GPIO_PC6 |
| 10   | GPIO_PC7 |

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_pwm.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
unsigned int IoTPwmStop(unsigned int port)
{
    if (port >= EPWMDEV_MAX) {
        PRINT_ERR("port(%d) >= EPWMDEV_MAX(%d)\n", port, EPWMDEV_MAX);
        return IOT_FAILURE;
    }

    LzPwmStart(m_pwm_bus_info[port].port, 0, 0);

    return IOT_SUCCESS;
}
```

### 软件设计

**主要代码分析**

在`pwm_example`函数中，创建一个任务。

```c
void pwm_example()
{
    unsigned int thread_id;
    TSK_INIT_PARAM_S task = {0};
    unsigned int ret      = LOS_OK;

    task.pfnTaskEntry = (TSK_ENTRY_FUNC)pwm_thread;
    task.uwStackSize  = 2048;
    task.pcName       = "pwm_thread";
    task.usTaskPrio   = 20;
    ret               = LOS_TaskCreate(&thread_id, &task);
    if (ret != LOS_OK) {
        printf("Falied to create pwm_thread ret:0x%x\n", ret);
        return;
    }
}
```

`pwm_thread`任务中调用IOT库的PWM接口控制PWM。

```c
void pwm_thread()
{
    unsigned int ret;
    /* PWM端口号对应于参考文件：
     * device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite/hal_iot_pwm.c
     */
    unsigned int port = 0;

    while (1) {
        printf("===========================\n");
        printf("PWM(%d) Init\n", port);
        ret = IoTPwmInit(port);
        if (ret != 0) {
            printf("IoTPwmInit failed(%d)\n");
            continue;
        }

        printf("PWM(%d) Start\n", port);
        ret = IoTPwmStart(port, 50, 1000);
        if (ret != 0) {
            printf("IoTPwmStart failed(%d)\n");
            continue;
        }

        LOS_Msleep(5000);

        printf("PWM(%d) end\n", port);
        ret = IoTPwmStop(port);
        if (ret != 0) {
            printf("IoTPwmStop failed(%d)\n");
            continue;
        }

        ret = IoTPwmDeinit(port);
        if (ret != 0) {
            printf("IoTPwmInit failed(%d)\n");
            continue;
        }

        printf("\n");

        port++;
        if (port >= 11) {
            port = 0;
        }
    }
}
```

## 编译调试

### 修改 BUILD.gn 文件

修改 `vendor/lockzhiner/rk2206/sample` 路径下 BUILD.gn 文件，指定 `iot_pwm_example` 参与编译。

```r
"./b16_iot_pwm:iot_pwm_example",
```

修改 `device/lockzhiner/rk2206/sdk_liteos` 路径下 Makefile 文件，添加 `-liot_pwm_example` 参与编译。

```r
hardware_LIBS = -lhal_iothardware -lhardware -lshellcmd -liot_pwm_example
```

### 运行结果

示例代码编译烧录代码后，按下开发板的RESET按键，通过串口助手查看日志，任务每隔5s控制不同PWM输出。

```r
entering kernel init...
hilog will init.
[MAIN:D]Main: LOS_Start ...
Entering scheduler
OHOS # hiview init success.===========================
PWM(0) Init
[GPIO:D]LzGpioInit: id 12 is initialized successfully
PWM(0) Start
PWM(0) end
[GPIO:D]LzGpioDeinit: id 12 is released successfully

===========================
PWM(1) Init
[GPIO:D]LzGpioInit: id 13 is initialized successfully
PWM(1) Start
PWM(1) end
[GPIO:D]LzGpioDeinit: id 13 is released successfully
...
```
