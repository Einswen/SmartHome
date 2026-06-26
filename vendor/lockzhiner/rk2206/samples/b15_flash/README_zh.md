# 小凌派-RK2206开发板基础外设开发：Flash读写

## 实验内容

本示例将演示如何在小凌派-RK2206开发板上使用内部Flash进行读写操作。

![小凌派-RK2206开发板](/vendor/lockzhiner/rk2206/docs/figures/lockzhiner-rk2206.jpg)

## 程序设计

### API设计

#### FlashInit()

**头文件：**

```
//device/rockchip/rk2206/adapter/include/lz_hadware.h
```

**函数描述：**

```c
unsigned int FlashInit(void);
```

**作用描述：**

初始化RK2206的Flash。

**参数描述：**

无

**返回值：**

LZ_HARDWARE_SUCCESS为成功，反之为失败。

#### FlashDeinit()

**头文件：**

```
//device/rockchip/rk2206/adapter/include/lz_hadware.h
```

**函数描述：**

```c
unsigned int FlashDeinit(void);
```

**作用描述：**

销毁RK2206的Flash。

**参数描述：**

无

**返回值：**

LZ_HARDWARE_SUCCESS为成功，反之为失败。

#### FlashErase()

**头文件：**

```
//device/rockchip/rk2206/adapter/include/lz_hadware.h
```

**函数描述：**

```c
unsigned int FlashErase(unsigned int flashOffset, unsigned int size)
```

**作用描述：**

擦除Flash某一块区域。

**参数描述：**

| 名字        | 描述                                                         |
| :---------- | :----------------------------------------------------------- |
| flashOffset | 起始位置<br>范围：0x0000_0000 ~ 0x0080_0000                  |
| size        | 擦除长度<br>必须是4KB的倍数（即Flash的擦除块，也是最小擦除单元） |

**返回值：**

LZ_HARDWARE_SUCCESS为成功，反之为失败。

#### FlashRead()

**头文件：**

```
//device/rockchip/rk2206/adapter/include/lz_hadware.h
```

**函数描述：**

```c
unsigned int FlashRead(unsigned int flashOffset, unsigned int size, unsigned char *ramData)
```

**作用描述：**

读取Flash数据。

**参数描述：**

| 名字        | 描述                                        |
| :---------- | :------------------------------------------ |
| flashOffset | 起始位置<br>范围：0x0000_0000 ~ 0x0080_0000 |
| size        | 读取长度                                    |
| ramData     | 存放读取Flahs的数据缓冲区                   |

**返回值：**

LZ_HARDWARE_SUCCESS为成功，反之为失败。

#### FlashWrite()

**头文件：**

```
//device/rockchip/rk2206/adapter/include/lz_hadware.h
```

**函数描述：**

```c
unsigned int FlashWrite(unsigned int flashOffset, 
                        unsigned int size,
                        const unsigned char *ramData, 
                        unsigned char doErase)
```

**作用描述：**

将数据写入到Flash。

**参数描述：**

| 名字        | 描述                                        |
| :---------- | :------------------------------------------ |
| flashOffset | 起始位置<br>范围：0x0000_0000 ~ 0x0080_0000 |
| size        | 读取长度                                    |
| ramData     | 存放读取Flahs的数据缓冲区                   |
| doErase     | 是否要擦除操作。一般为0                     |

**返回值：**

LZ_HARDWARE_SUCCESS为成功，反之为失败。

### 软件设计

整个例程主要分为2个部分：

- Flash读写操作
- 修改LittleFS配置

#### Flash读写操作

该任务主要分为如下几个步骤：

**（1）定义Flash读写范围**

内部Flash的容量为8MB，具体分为如下所示：

- 0 ~ 4MB：固件库
- 4~8MB：文件系统

本案例Flash读写操作对象设定为Flash的7~8MB空间。

```c
// 使用内部Flash范围： 7MB ~ 8MB
#define FLASH_ADDRESS_START     (0x700000)                      // 起始地址
#define FLASH_ADDRESS_LENGTH    (0x100000)                      // Flash可读写范围
#define FLASH_ERASE_BLOCK_SIZE  (4096)                          // 擦除块大小
```

注意：内部Flash的最小擦除块单元为4KB。

**（2）初始化Flash**

使用FlashInit()初始化Flash。

```c
void flash_process(void *args)
{
    ......
    // 初始化flash
    FlashInit();
    ......
}
```

**（3）擦除Flash**

使用FlashErase()来擦除Flash某一段区域。

注意：flash_length必须是4KB的倍数。

```c
printf("Flash erase: address = 0x%x, length = 0x%x\n", flash_address, flash_length);
ret = FlashErase(flash_address, flash_length);
if (ret != LZ_HARDWARE_SUCCESS)
{
    printf("Flash erase failed\n");
    goto flash_out;
}
```

**（4）写入Flash**

使用FlashWrite()将flash_erase_buffer数据写入到内部Flash中。

```c
 printf("Flash write: address = 0x%x, length = 0x%x, ch = %d\n", flash_address, flash_length, ch);
memset(flash_erase_buffer, ch, sizeof(flash_erase_buffer));
ret = FlashWrite(flash_address, sizeof(flash_erase_buffer), flash_erase_buffer, 0);
if (ret != LZ_HARDWARE_SUCCESS)
{
    printf("Flash write failed\n");
    goto flash_out;
}
ch++;
```

**（5）读取Flash**

使用FlashRead()将Flash内部数据读取到flash_erase_buffer。

```c
printf("Flash read: address = 0x%x, length = 0x%x\n", flash_address, flash_length);
memset(flash_erase_buffer, 0, sizeof(flash_erase_buffer));
ret = FlashRead(flash_address, sizeof(flash_erase_buffer), flash_erase_buffer);
if (ret != LZ_HARDWARE_SUCCESS)
{
    printf("Flash read failed\n");
    goto flash_out;
}
for (uint32_t offset = 0; offset < 16; offset++)
{
    printf("    [%d] = %d\n", offset, flash_erase_buffer[offset]);
}
```

#### 修改LittleFS配置

编辑//device/rockchip/rk2206/adapter/hals/utils/file/hal_file.c，修改如下内容

```c
static const struct lfs_config m_lfs_cfg =
{
    // block device operations
    .read  = lzflash_read,
    .prog  = lzflash_prog,
    .erase = lzflash_erase,
    .sync  = lzflash_sync,
    
    // block device configuration
    .read_size = 4,
    .prog_size = 4,
    .block_size = 4096,
    .block_count = 768,
    .cache_size = 256,
    .lookahead_size = 64,
    .block_cycles = 500,
    .file_max = LFS_FILE_MAX,
    .name_max = 32,
};
```

将`.block_count`改为768（即4~7MB空间给LittleFS），该定义为文件系统的block数量，其中block大小为4KB。

## 编译调试

### 修改BUILD.gn文件

修改 `vendor/lockzhiner/rk2206/sample` 路径下 BUILD.gn 文件，指定 `flash_example` 参与编译。

```r
"./b15_flash:flash_example",
```

修改 `device/lockzhiner/rk2206/sdk_liteos` 路径下 Makefile 文件，添加 `-lflash_example` 参与编译。

```r
app_LIBS = -lflash_example
```

### 运行结果

示例代码编译烧录代码后，按下开发板的RESET按键，通过串口助手查看日志，显示如下：

```r
Flash erase: address = 0x700000, length = 0x1000
Flash write: address = 0x700000, length = 0x1000, ch = 8
Flash read: address = 0x700000, length = 0x1000
    [0] = 8
    [1] = 8
    [2] = 8
    [3] = 8
    [4] = 8
    [5] = 8
    [6] = 8
    [7] = 8
    [8] = 8
    [9] = 8
    [10] = 8
    [11] = 8
    [12] = 8
    [13] = 8
    [14] = 8
    [15] = 8


Flash erase: address = 0x700000, length = 0x1000
Flash write: address = 0x700000, length = 0x1000, ch = 9
Flash read: address = 0x700000, length = 0x1000
    [0] = 9
    [1] = 9
    [2] = 9
    [3] = 9
    [4] = 9
    [5] = 9
    [6] = 9
    [7] = 9
    [8] = 9
    [9] = 9
    [10] = 9
    [11] = 9
    [12] = 9
    [13] = 9
    [14] = 9
    [15] = 9


Flash erase: address = 0x700000, length = 0x1000
Flash write: address = 0x700000, length = 0x1000, ch = 10
Flash read: address = 0x700000, length = 0x1000
    [0] = 10
    [1] = 10
    [2] = 10
    [3] = 10
    [4] = 10
    [5] = 10
    [6] = 10
    [7] = 10
    [8] = 10
    [9] = 10
    [10] = 10
    [11] = 10
    [12] = 10
    [13] = 10
    [14] = 10
    [15] = 10
```
