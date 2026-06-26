# ADC概述

## 简介

- 逐次逼近寄存器型模数转换器（Successive-Approximation Analog to Digital Converter），是一种常用的A/D转换结构，其较低的功耗表现，还不错的转换速率，在有低功耗要求（可穿戴设备、物联网）的数据采集场景下广泛应用。

## 接口说明

### 包含头文件： 

```c
#include "iot_adc.h
```

#### 1. IoTAdcInit

```c
unsigned int IoTAdcInit(unsigned int id);
```

> IoTAdcInit初始化ADC设备。成功返回IOT_SUCCESS，否则返回IOT_FAILURE。

| Parameters(T) | Data Type       | Description    |
| ------------- | --------------- | -------------- |
| id            | unsigned int    | adc id号       |

#### 2. IoTAdcDeinit

```c
unsigned int IoTAdcDeinit(unsigned int id);
```

> IoTAdcDeinit释放ADC设备。成功返回IOT_SUCCESS，否则返回IOT_FAILURE。

| Parameters(T) | Data Type       | Description    |
| ------------- | --------------- | -------------- |
| id            | unsigned int    | adc id号       |

#### 3. IoTAdcGetVal

```c
unsigned int IoTAdcGetVal(unsigned int id, unsigned int *val);
```

> IoTAdcGetVal读取ADC设备值。成功返回IOT_SUCCESS，否则返回IOT_FAILURE。

| Parameters(T) | Data Type       | Description    |
| ------------- | --------------- | -------------- |
| id            | unsigned int    | adc id号       |
| val           | unsigned int *  | adc值          |
