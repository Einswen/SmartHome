# 小凌派-RK2206开发板基础外设开发——FLASH读写

## 实验内容

本示例将演示如何在小凌派-RK2206开发板上使用IOT库的FLASH接口，进行FLASH编程开发。例程将创建一个任务，实现FLASH读写操作。

![小凌派-RK2206开发板](/vendor/lockzhiner/rk2206/docs/figures/lockzhiner-rk2206.jpg)

## 程序设计

FLASH在日常设备中非常常见，以下我们将演示IOT库的FLASH接口如何进行FLASH读写操作。

### API分析

#### 头文件

```c    
base/iot_hardware/peripheral/interfaces/kits/iot_flash.h
```

#### FLASH设备初始化：IoTFlashInit

```c
unsigned int IoTFlashInit(void);
```

**描述：**

FLASH设备初始化。

**参数：**

无

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_flash.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
unsigned int IoTFlashInit(void)
{
    return (FlashInit() == LZ_HARDWARE_SUCCESS) ? IOT_SUCCESS : IOT_FAILURE;
}
```

#### 取消初始化FLASH设备：IoTFlashDeinit

```c
unsigned int IoTFlashDeinit(void);
```

**描述：**

取消初始化FLASH设备。

**参数：**

无

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_flash.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
unsigned int IoTFlashDeinit(void)
{
    return (FlashDeinit() == LZ_HARDWARE_SUCCESS) ? IOT_SUCCESS : IOT_FAILURE;
}
```

#### FLASH读操作：IoTFlashRead

```c
unsigned int IoTFlashRead(unsigned int flashOffset, unsigned int size, unsigned char *ramData);
```

**描述：**

FLASH读操作。

**参数：**

| 参数        | 类型            | 描述      |
| ----------- | --------------- | --------- |
| flashOffset | unsigned int    | flash地址 |
| size        | unsigned int    | 长度      |
| ramData     | unsigned char * | 数据指针  |

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_flash.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
unsigned int IoTFlashRead(unsigned int flashOffset, unsigned int size, unsigned char *ramData)
{
    return (FlashRead(flashOffset, size, ramData) == LZ_HARDWARE_SUCCESS) ? IOT_SUCCESS : IOT_FAILURE;
}
```

#### FLASH写操作：IoTFlashWrite

```c
unsigned int IoTFlashWrite(unsigned int flashOffset, unsigned int size, const unsigned char *ramData, unsigned char doErase);
```

**描述：**

FLASH写操作。

**参数：**

| 参数        | 类型            | 描述      |
| ----------- | --------------- | --------- |
| flashOffset | unsigned int    | flash地址 |
| size        | unsigned int    | 长度      |
| ramData     | unsigned char * | 数据指针  |
| doErase     | unsigned char   | 无效位    |

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_flash.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
unsigned int IoTFlashWrite(unsigned int flashOffset, unsigned int size, const unsigned char *ramData, unsigned char doErase)
{
    return (FlashWrite(flashOffset, size, ramData, doErase) == LZ_HARDWARE_SUCCESS) ? IOT_SUCCESS : IOT_FAILURE;
}
```

#### FLASH擦除操作：IoTFlashErase

```c
unsigned int IoTFlashErase(unsigned int flashOffset, unsigned int size);
```

**描述：**

FLASH擦除操作。

**参数：**

| 参数        | 类型         | 描述      |
| ----------- | ------------ | --------- |
| flashOffset | unsigned int | flash地址 |
| size        | unsigned int | 长度      |

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_flash.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
unsigned int IoTFlashErase(unsigned int flashOffset, unsigned int size)
{
    return (FlashErase(flashOffset, size) == LZ_HARDWARE_SUCCESS) ? IOT_SUCCESS : IOT_FAILURE;
}
```

### 软件设计

**主要代码分析**

在`flash_example`函数中，创建一个任务。

```c
void flash_example(void)
{
    unsigned int ret = LOS_OK;
    unsigned int thread_id;
    TSK_INIT_PARAM_S task = {0};

    task.pfnTaskEntry = (TSK_ENTRY_FUNC)flash_thread;
    task.uwStackSize  = 1024 * 512;
    task.pcName       = "flash_thread";
    task.usTaskPrio   = 24;
    ret               = LOS_TaskCreate(&thread_id, &task);
    if (ret != LOS_OK) {
        printf("Falied to create flash_thread ret:0x%x\n", ret);
        return;
    }
}
```

`flash_thread`任务中调用IOT库的FLASH接口进行读写操作。

```c
void flash_thread(void *args)
{
    uint32_t flash_base_address = FLASH_ADDRESS_START;
    uint8_t flash_erase_buffer[FLASH_ERASE_BLOCK_SIZE];
    int ret;
    uint8_t ch = 'a';

    // 初始化flash
    IoTFlashDeinit();
    IoTFlashInit();

    while (1) {
        for (uint32_t i = 0; i < 16; i += FLASH_ERASE_BLOCK_SIZE) {
            uint32_t flash_address = flash_base_address + i;
            uint32_t flash_length  = FLASH_ERASE_BLOCK_SIZE;

            printf("Flash erase: address = 0x%x, length = 0x%x\n", flash_address, flash_length);
            // 擦除
            ret = IoTFlashErase(flash_address, flash_length);
            if (ret != IOT_SUCCESS) {
                printf("Flash erase failed\n");
                goto flash_out;
            }

            // 写入
            printf("Flash write: address = 0x%x, length = 0x%x, ch = %c\n", flash_address, flash_length, ch);
            memset(flash_erase_buffer, ch, sizeof(flash_erase_buffer));
            ret = IoTFlashWrite(flash_address, sizeof(flash_erase_buffer), flash_erase_buffer, 0);
            if (ret != IOT_SUCCESS) {
                printf("Flash write failed\n");
                goto flash_out;
            }
            ch++;

            printf("Flash read: address = 0x%x, length = 0x%x\n", flash_address, flash_length);
            memset(flash_erase_buffer, ch, sizeof(flash_erase_buffer));
            ret = IoTFlashRead(flash_address, sizeof(flash_erase_buffer), flash_erase_buffer);
            if (ret != IOT_SUCCESS) {
                printf("Flash read failed\n");
                goto flash_out;
            }
            for (uint32_t offset = 0; offset < 16; offset++) {
                printf("    [%d] = %c\n", offset, flash_erase_buffer[offset]);
            }

        flash_out:
            LOS_Msleep(1000);
        }
    }
}
```

## 编译调试

### 修改 BUILD.gn 文件

修改 `vendor/lockzhiner/rk2206/sample` 路径下 BUILD.gn 文件，指定 `iot_flash_example` 参与编译。

```r
"./b21_iot_flash:iot_flash_example",
```

修改 `device/lockzhiner/rk2206/sdk_liteos` 路径下 Makefile 文件，添加 `-iot_flash_example` 参与编译。

```r
hardware_LIBS = -lhal_iothardware -lhardware -lshellcmd -liot_flash_example
```

### 运行结果

示例代码编译烧录代码后，按下开发板的RESET按键，通过串口助手查看日志，显示如下：

```r
entering kernel init...
hilog will init.
[MAIN:D]Main: LOS_Start ...
Entering scheduler
OHOS # hiview init success.[FLASH:E]FlashDeinit: id 0, controller has NOT been initialized
[FLASH:I]FlashInit: blockSize 4096, blockStart 0, blockEnd 8388608
Flash erase: address = 0x700000, length = 0x1000
Flash write: address = 0x700000, length = 0x1000, ch = a
Flash read: address = 0x700000, length = 0x1000
    [0] = a
    [1] = a
    [2] = a
    [3] = a
    [4] = a
    [5] = a
    [6] = a
    [7] = a
    [8] = a
    [9] = a
    [10] = a
    [11] = a
    [12] = a
    [13] = a
    [14] = a
    [15] = a
Flash erase: address = 0x700000, length = 0x1000
Flash write: address = 0x700000, length = 0x1000, ch = b
Flash read: address = 0x700000, length = 0x1000
    [0] = b
    [1] = b
    [2] = b
    [3] = b
    [4] = b
    [5] = b
    [6] = b
    [7] = b
    [8] = b
    [9] = b
    [10] = b
    [11] = b
    [12] = b
    [13] = b
    [14] = b
    [15] = b
```