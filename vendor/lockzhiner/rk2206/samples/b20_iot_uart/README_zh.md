# 小凌派-RK2206开发板基础外设开发——UART控制

## 实验内容

本示例将演示如何在小凌派-RK2206开发板上使用IOT库的UART接口，进行UART编程开发。例程将创建一个任务，通过配置UART引脚，实现UART读写操作。

![小凌派-RK2206开发板](/vendor/lockzhiner/rk2206/docs/figures/lockzhiner-rk2206.jpg)

## 程序设计

UART在日常设备中非常常见，以下我们将演示IOT库的UART接口如何进行UART口配置，以及UART口读写操作。

### API分析

#### 头文件

```c    
base/iot_hardware/peripheral/interfaces/kits/iot_uart.h
```

#### UART设备初始化：IoTUartInit

```c
unsigned int IoTUartInit(unsigned int id, const IotUartAttribute *param);
```

**描述：**

UART设备初始化。

**参数：**

| 参数  | 类型                     | 描述         |
| ----- | ------------------------ | ------------ |
| id    | unsigned int             | UART ID      |
| param | const IotUartAttribute * | UART配置参数 |

UART ID配置和IO复用如下表：

| 串口  | id        | TX        | RX        |
| ----- | --------- | --------- | --------- |
| UART0 | EUART0_M0 | GPIO0_PB7 | GPIO0_PB6 |
| UART0 | EUART0_M1 | GPIO0_PC7 | GPIO0_PC6 |
| UART1 | EUART1_M0 | GPIO0_PC3 | GPIO0_PC2 |
| UART1 | EUART1_M1 | GPIO0_PA7 | GPIO0_PA6 |
| UART2 | EUART2_M1 | GPIO0_PB3 | GPIO0_PB2 |

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_uart.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
unsigned int IoTUartInit(unsigned int id, const IotUartAttribute *param)
{
    unsigned int ret = 0;
    UartAttribute *temp_prt = (const UartAttribute *)param;

    if (id >= EUARTDEV_MAX)
    {
        PRINT_ERR("id(%d) >= EUARTDEV_MAX(%d)\n", id, EUARTDEV_MAX);
        return IOT_FAILURE;
    }

    PinctrlSet(m_uart_bus_info[id].uart_bus.rx.gpio, m_uart_bus_info[id].uart_bus.rx.func, m_uart_bus_info[id].uart_bus.rx.type, m_uart_bus_info[id].uart_bus.rx.drv);
    PinctrlSet(m_uart_bus_info[id].uart_bus.tx.gpio, m_uart_bus_info[id].uart_bus.tx.func, m_uart_bus_info[id].uart_bus.tx.type, m_uart_bus_info[id].uart_bus.tx.drv);

    if (param->parity == IOT_UART_PARITY_NONE)
    {
        temp_prt->parity = UART_PARITY_NONE;
    }
    else if (param->parity == IOT_UART_PARITY_EVEN)
    {
        temp_prt->parity = UART_PARITY_EVEN;
    }
    else if (param->parity == IOT_UART_PARITY_ODD)
    {
        temp_prt->parity = UART_PARITY_ODD;
    }

    if (m_uart_bus_info[id].id == 0)
    {
        LzUartDeinit(m_uart_bus_info[id].id);
        uint32_t *pUart0 = (uint32_t *)(0x40070000U);
        HAL_UART_DeInit(pUart0);
    }

    ret = LzUartInit(m_uart_bus_info[id].id, temp_prt);
    if (ret != LZ_HARDWARE_SUCCESS)
    {
        return IOT_FAILURE;
    }

    return IOT_SUCCESS;
}
```

#### 取消初始化UART设备：IoTUartDeinit

```c
unsigned int IoTUartDeinit(unsigned int id);
```

**描述：**

取消初始化UART设备。

**参数：**

| 参数 | 类型         | 描述    |
| ---- | ------------ | ------- |
| id   | unsigned int | UART ID |

UART ID配置和IO复用如下表：

| 串口  | id        | TX        | RX        |
| ----- | --------- | --------- | --------- |
| UART0 | EUART0_M0 | GPIO0_PB7 | GPIO0_PB6 |
| UART0 | EUART0_M1 | GPIO0_PC7 | GPIO0_PC6 |
| UART1 | EUART1_M0 | GPIO0_PC3 | GPIO0_PC2 |
| UART1 | EUART1_M1 | GPIO0_PA7 | GPIO0_PA6 |
| UART2 | EUART2_M1 | GPIO0_PB3 | GPIO0_PB2 |

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_uart.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
unsigned int IoTUartDeinit(unsigned int id)
{
    unsigned int ret = 0;

    if (id >= EUARTDEV_MAX)
    {
        PRINT_ERR("id(%d) >= EUARTDEV_MAX(%d)\n", id, EUARTDEV_MAX);
        return IOT_FAILURE;
    }

    ret = LzUartDeinit(m_uart_bus_info[id].id);
    if (ret != LZ_HARDWARE_SUCCESS)
    {
        return IOT_FAILURE;
    }

    return IOT_SUCCESS;
}
```

#### UART设备读取指定长度的数据：IoTUartRead

```c
int IoTUartRead(unsigned int id, unsigned char *data, unsigned int dataLen);
```

**描述：**

UART设备读取指定长度的数据。

**参数：**

| 参数    | 类型            | 描述     |
| ------- | --------------- | -------- |
| id      | unsigned int    | UART ID  |
| data    | unsigned char * | 数据指针 |
| dataLen | unsigned int    | 数据长度 |

UART ID配置和IO复用如下表：

| 串口  | id        | TX        | RX        |
| ----- | --------- | --------- | --------- |
| UART0 | EUART0_M0 | GPIO0_PB7 | GPIO0_PB6 |
| UART0 | EUART0_M1 | GPIO0_PC7 | GPIO0_PC6 |
| UART1 | EUART1_M0 | GPIO0_PC3 | GPIO0_PC2 |
| UART1 | EUART1_M1 | GPIO0_PA7 | GPIO0_PA6 |
| UART2 | EUART2_M1 | GPIO0_PB3 | GPIO0_PB2 |

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_uart.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
int IoTUartRead(unsigned int id, unsigned char *data, unsigned int dataLen)
{
    unsigned int ret = 0;

    if (id >= EUARTDEV_MAX)
    {
        PRINT_ERR("id(%d) >= EUARTDEV_MAX(%d)\n", id, EUARTDEV_MAX);
        return IOT_FAILURE;
    }

    ret = LzUartRead(m_uart_bus_info[id].id, data, dataLen);

    return ret;
}
```

#### UART设备写指定长度的数据：IoTUartWrite

```c
int IoTUartWrite(unsigned int id, const unsigned char *data, unsigned int dataLen);
```

**描述：**

UART设备读取指定长度的数据。

**参数：**

| 参数    | 类型                  | 描述     |
| ------- | --------------------- | -------- |
| id      | unsigned int          | UART ID  |
| data    | const unsigned char * | 数据指针 |
| dataLen | unsigned int          | 数据长度 |

UART ID配置和IO复用如下表：

| 串口  | id        | TX        | RX        |
| ----- | --------- | --------- | --------- |
| UART0 | EUART0_M0 | GPIO0_PB7 | GPIO0_PB6 |
| UART0 | EUART0_M1 | GPIO0_PC7 | GPIO0_PC6 |
| UART1 | EUART1_M0 | GPIO0_PC3 | GPIO0_PC2 |
| UART1 | EUART1_M1 | GPIO0_PA7 | GPIO0_PA6 |
| UART2 | EUART2_M1 | GPIO0_PB3 | GPIO0_PB2 |

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_uart.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
int IoTUartWrite(unsigned int id, const unsigned char *data, unsigned int dataLen)
{
    unsigned int ret = 0;

    if (id >= EUARTDEV_MAX)
    {
        PRINT_ERR("id(%d) >= EUARTDEV_MAX(%d)\n", id, EUARTDEV_MAX);
        return IOT_FAILURE;
    }

    ret = LzUartWrite(m_uart_bus_info[id].id, data, dataLen);
    if (ret != LZ_HARDWARE_SUCCESS)
    {
        return IOT_FAILURE;
    }

    return IOT_SUCCESS;
}
```

### 软件设计

**主要代码分析**

在`uart_example`函数中，创建一个任务。

```c
void uart_example()
{
    unsigned int thread_id;
    TSK_INIT_PARAM_S task = {0};
    unsigned int ret      = LOS_OK;

    task.pfnTaskEntry = (TSK_ENTRY_FUNC)uart_thread;
    task.uwStackSize  = 2048;
    task.pcName       = "uart_thread";
    task.usTaskPrio   = 24;
    ret               = LOS_TaskCreate(&thread_id, &task);
    if (ret != LOS_OK) {
        printf("Falied to create uart_thread ret:0x%x\n", ret);
        return;
    }
}
```

`uart_thread`任务中调用IOT库的UART接口配置、读写UART。

```c
void uart_thread()
{
    unsigned int ret;
    IotUartAttribute attr;
    unsigned char str[]                       = "HelloWorld!";
    unsigned char recv_buffer[STRING_MAXSIZE] = {0};
    unsigned int recv_length                  = 0;

    IoTUartDeinit(UART_ID);

    attr.baudRate = 115200;
    attr.dataBits = IOT_UART_DATA_BIT_8;
    attr.pad      = IOT_FLOW_CTRL_NONE;
    attr.parity   = IOT_UART_PARITY_NONE;
    attr.rxBlock  = IOT_UART_BLOCK_STATE_NONE_BLOCK;
    attr.stopBits = IOT_UART_STOP_BIT_1;
    attr.txBlock  = IOT_UART_BLOCK_STATE_NONE_BLOCK;

    /* 初始化串口 */
    ret = IoTUartInit(UART_ID, &attr);
    if (ret != IOT_SUCCESS) {
        printf("%s, %d: IoTUartInit(%d) failed!\n", __FILE__, __LINE__, ret);
        return;
    }
    /* 休眠1秒 */
    LOS_Msleep(1000);

    while (1) {
        printf("%s, %d: uart write and str(%s), len(%d)!\n", __FILE__, __LINE__, str, strlen(str));
        // IoTUartWrite是异步发送，非阻塞发送
        IoTUartWrite(UART_ID, str, strlen(str));
        // 等待发送完毕
        LOS_Msleep(1000);

        recv_length = 0;
        memset(recv_buffer, 0, sizeof(recv_buffer));
        recv_length = IoTUartRead(UART_ID, recv_buffer, sizeof(recv_buffer));
        printf("%s, %d: uart recv and str(%s), len(%d)\n", __FILE__, __LINE__, recv_buffer, recv_length);

        /* 休眠1秒 */
        LOS_Msleep(1000);
    }
}
```

## 编译调试

### 修改 BUILD.gn 文件

修改 `vendor/lockzhiner/rk2206/sample` 路径下 BUILD.gn 文件，指定 `iot_uart_example` 参与编译。

```r
"./b20_iot_uart:iot_uart_example",
```

修改 `device/lockzhiner/rk2206/sdk_liteos` 路径下 Makefile 文件，添加 `-liot_uart_example` 参与编译。

```r
hardware_LIBS = -lhal_iothardware -lhardware -lshellcmd -liot_uart_example
```

### 运行结果

示例代码编译烧录代码后，按下开发板的RESET按键，使用杜邦线连接TX和RX，通过串口助手查看日志，显示如下：

```r
entering kernel init...
hilog will init.
[MAIN:D]Main: LOS_Start ...
Entering scheduler
OHOS # hiview init success.[UART:E]LzUartDeinit: id 0, controller has NOT been initialized
[UART:E]LzUartDeinit: id 0, controller has NOT been initialized
../../../vendor/lockzhiner/rk2206/samples/b20_iot_uart/iot_uart_example.c, 63: uart write and str(HelloWorld!), len(11)!
../../../vendor/lockzhiner/rk2206/samples/b20_iot_uart/iot_uart_example.c, 72: uart recv and str(HelloWorld!), len(11)
../../../vendor/lockzhiner/rk2206/samples/b20_iot_uart/iot_uart_example.c, 63: uart write and str(HelloWorld!), len(11)!
../../../vendor/lockzhiner/rk2206/samples/b20_iot_uart/iot_uart_example.c, 72: uart recv and str(HelloWorld!), len(11)
../../../vendor/lockzhiner/rk2206/samples/b20_iot_uart/iot_uart_example.c, 63: uart write and str(HelloWorld!), len(11)!
../../../vendor/lockzhiner/rk2206/samples/b20_iot_uart/iot_uart_example.c, 72: uart recv and str(HelloWorld!), len(11)
../../../vendor/lockzhiner/rk2206/samples/b20_iot_uart/iot_uart_example.c, 63: uart write and str(HelloWorld!), len(11)!
../../../vendor/lockzhiner/rk2206/samples/b20_iot_uart/iot_uart_example.c, 72: uart recv and str(HelloWorld!), len(11)

```