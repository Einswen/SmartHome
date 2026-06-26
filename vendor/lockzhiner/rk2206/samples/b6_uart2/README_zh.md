# 小凌派-RK2206开发板基础外设开发——串口2收发数据

本示例将演示如何在小凌派-RK2206开发板上使用UART2收发数据。

注意：本样例专门创建任务，使用FiFo接收串口数据，是为了保证UART2接收到完整数据。

![小凌派-RK2206开发板](/vendor/lockzhiner/rk2206/docs/figures/lockzhiner-rk2206.jpg)

## 硬件接口说明

引脚名称开发者可在硬件资源图中查看。

| 引脚名称 | 功能描述 |
| :--- | :------- |
| GPIO0_PB2 | UART2_RX_M1 串口RX |
| GPIO0_PB3 | UART2_TX_M1 串口TX |
| GND | 电源地引脚 |


### 硬件连接

安装图如下所示：
![串口模块硬件连接图](/vendor/lockzhiner/rk2206/docs/figures/uart/20220505104232-串口连接2.jpg)

注意：
（1）串口GND引脚一定要连接到开发板的GND引脚上。

## 程序设计

### API分析

#### 头文件

```c
#include "lz_hardware.h"
```

注意：实际头文件可参考[uart.h](/device/rockchip/rk2206/adapter/include/lz_hardware/uart.h)

#### LzUartInit()

```c
unsigned int LzUartInit(unsigned int id, const UartAttribute *param);
```

**描述：**

初始化uart设备。

**参数：**

| 名字          | 描述           |
| :------------ | :------------- |
| id            | 串口ID         |
| param         | 串口配置参数，详情可参考[uart.h](/device/rockchip/rk2206/adapter/include/lz_hardware/uart.h) |

**返回值：**

返回LZ_HARDWARE_SUCCESS为成功，反之为失败

#### LzUartDeinit()

```c
unsigned int LzUartDeinit(unsigned int id);
```

**描述：**

释放uart设备。

**参数：**

| 名字          | 描述           |
| :------------ | :------------- |
| id            | 串口ID         |

**返回值：**

返回LZ_HARDWARE_SUCCESS为成功，反之为失败

#### LzUartRead()

```c
unsigned int LzUartRead(unsigned int id, unsigned char *data, unsigned int dataLen);
```

**描述：**

串口读操作。

**参数：**

| 名字          | 描述                      |
| :------------ | :------------------------ |
| id            | 串口ID                    |
| data          | 串口读取数据后存放的地址    |
| dataLen       | 串口读取数据的个数         |

**返回值：**

成功返回读取数据长度

#### LzUartWrite()

```c
unsigned int LzUartWrite(unsigned int id, const unsigned char *data, unsigned int dataLen);
```

**描述：**

串口写操作。

**参数：**

| 名字          | 描述                      |
| :------------ | :------------------------ |
| id            | 串口ID                    |
| data          | 串口写入数据的地址         |
| dataLen       | 串口写入数据的个数         |

**返回值：**

成功返回发送数据长度


### 主要代码分析

#### 初始化串口

这部分代码为uart初始化的代码。首先用 `LzUartDeinit()` 函数将串口释放掉；其次用`PinctrlSet()`将GPIO0_PB2复用为UART2_RX_M1，GPIO0_PB3复用为UART2_TX_M1。最后调用 `LzUartInit()`函数初始化uart。

```c
// 串口注销
LzUartDeinit(UART_ID);
// 串口配置
attr.baudRate = 115200;
attr.dataBits = UART_DATA_BIT_8;
attr.pad = FLOW_CTRL_NONE;
attr.parity = UART_PARITY_NONE;
attr.rxBlock = UART_BLOCK_STATE_NONE_BLOCK;
attr.stopBits = UART_STOP_BIT_1;
attr.txBlock = UART_BLOCK_STATE_NONE_BLOCK;
// 引脚复用
PinctrlSet(GPIO0_PB3, MUX_FUNC3, PULL_KEEP, DRIVE_LEVEL2);
PinctrlSet(GPIO0_PB2, MUX_FUNC3, PULL_KEEP, DRIVE_LEVEL2);
// 申请串口
ret = LzUartInit(UART_ID, &attr);
if (ret != LZ_HARDWARE_SUCCESS)
{
    printf("%s, %d: LzUartInit(%d) failed!\n", __FILE__, __LINE__, ret);
    return;
}
```

#### 串口写操作

具体uart写操作如下：

```c
printf("uart write and send_buffer_len = %d\n", STRING_MAXSIZE);
// LzUartWrite是异步发送，非阻塞发送
LzUartWrite(UART_ID, send_buffer, STRING_MAXSIZE);
// 等待发送完毕
LOS_Msleep(1000);
```

串口读操作

uart读操作实际上是从Fifo中读取数据，并非直接从uart读。

```c
printf("uart recv: \n");
for (int i = 0; i < 100; i++)
{
    recv_length = 0;
    memset(recv_buffer, 0, sizeof(recv_buffer));
    ret = fifo_read(&m_uart_recv_fifo, recv_buffer, sizeof(recv_buffer), &recv_length);
    if (ret > 0)
    {
        printf("	uart recv and i(%d), len(%d)\n", i, recv_length);
        for (int x = 0; x < recv_length; x++)
        {
            printf("		[%d] = 0x%x\n", x, recv_buffer[x]);
        }
        printf("");
    }
    else
    {
        printf("	uart recv and str is null\n");
        printf("");
        break;
    }
}
```

#### 创建串口接收任务

在主任务中创建串口接收任务，具体代码如下：

```c
// 创建接收任务
task.pfnTaskEntry = (TSK_ENTRY_FUNC)uart2_recv_process;
task.uwStackSize = 1024 * 1024;
task.pcName = "uart2 recv process";
task.usTaskPrio = 20;
ret = LOS_TaskCreate(&thread_id, &task);
if (ret != LOS_OK)
{
    printf("Falied to create task(uart2_recv_process) and ret: 0x%x\n", ret);
    return;
}
```

串口接收任务专门负责串口读操作，并将数据存入Fifo中，具体代码如下：

```c
void uart2_recv_process()
{
    unsigned char recv_buffer[STRING_MAXSIZE];
    int recv_length = 0;
    
    while (1)
    {
        recv_length = 0;
        memset(recv_buffer, 0, sizeof(recv_buffer));
        recv_length = LzUartRead(UART_ID, recv_buffer, sizeof(recv_buffer));
        if (recv_length > 0)
        {
            // 写入到FiFo
            fifo_write(&m_uart_recv_fifo, recv_buffer, recv_length);
        }
        else
        {
            // 没有收到数据，则睡眠
            LOS_Msleep(1);
        }
    }
}
```

注意：串口接收任务不能有多余的延时操作，否则会导致串口接收不到某部分字符串。
## 编译调试

### 修改 BUILD.gn 文件

修改 `vendor\lockzhiner\rk2206\sample` 路径下 BUILD.gn 文件，指定 `uart2_example` 参与编译。

```r
"./b6_uart2:uart2_example",
```

修改 `device/lockzhiner/rk2206/sdk_liteos` 路径下 Makefile 文件，添加 `-luart2_example` 参与编译。

```r
hardware_LIBS = -lhal_iothardware -lhardware -lm -luart2_example
```

### 运行结果

示例代码编译烧录代码后，按下开发板的RESET按键，通过串口助手查看日志，串口2显示如下：

```c
uart recv: 
        uart recv and str is null
uart write and send_buffer_len = 128
uart recv: 
        uart recv and str is null
uart write and send_buffer_len = 128
uart recv: 
        uart recv and str is null
uart write and send_buffer_len = 128
......
```

注意：如果你使用MobaXterm，并且发现串口0能打印，但是换行有问题，则：
（1）在MobaXterm界面中按住右边的Ctrl按键 + 右击鼠标，弹出菜单，选择`Change terminal settings...`，如下图所示：

![右击菜单图](/vendor/lockzhiner/rk2206/docs/figures/uart/MobaXterm_右击菜单.png)

（2）将2个选项勾选上即可。如下图所示：

![勾选图](/vendor/lockzhiner/rk2206/docs/figures/uart/MobaXterm_勾选.png)
