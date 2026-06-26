# WatchDog概述

## 简介

- 看门狗定时器（Watchdog Timer），是一种用于监控系统运行状态的安全机制。它具有简洁高效的特点，能在检测到系统故障或无响应状态时，迅速触发系统复位或其他预设措施。在低功耗需求（如可穿戴设备、物联网）以及关键任务应用（如工业控制、汽车电子）中，广泛应用于确保系统的稳定性和可靠性。看门狗定时器以其低功耗、实时响应的特性，有效提高了系统的容错能力，成为保障系统正常运行的重要组成部分。

## 接口说明

### 包含头文件：

```c
#include "iot_watchdog.h"
```

#### 1. IoTWatchDogEnable

```c
unsigned int IoTWatchDogEnable(unsigned int sec);
```

> IoTWatchDogEnable使能看门狗。成功返回IOT_SUCCESS，否则返回IOT_FAILURE。

| Parameters(T) | Data Type       | Description    |
| ------------- | --------------- | -------------- |
| sec           | unsigned int    | 看门狗定时器秒 |

#### 2. IoTWatchDogKick

```c
unsigned int IoTWatchDogKick(void);
```

> IoTWatchDogKick喂看门狗。成功返回IOT_SUCCESS，否则返回IOT_FAILURE。
