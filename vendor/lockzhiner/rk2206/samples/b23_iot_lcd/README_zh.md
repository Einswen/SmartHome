# 小凌派-RK2206开发板基础外设开发——SPI操作

## 实验内容

本示例将演示如何在小凌派-RK2206开发板上使用IOT库的SPI接口，进行2.4寸LCD屏编程开发。例程将创建一个任务，使用SPI接口对2.4寸LCD屏进行配置、显示操作。

![小凌派-RK2206开发板](/vendor/lockzhiner/rk2206/docs/figures/lockzhiner-rk2206.jpg)

## 程序设计

SPI在日常设备中非常常见，以下我们将演示IOT库的SPI接口对2.4寸LCD屏进行配置、显示操作。

### API分析

#### 头文件

```c    
base/iot_hardware/peripheral/interfaces/kits/iot_spi.h
```

#### 初始化SPI器件：IoTSpiInit

```c
unsigned int IoTSpiInit(unsigned int id, IoT_SPI_InitTypeDef *iot_spi);
```

**描述：**

初始化SPI器件。

**参数：**


| 参数    | 类型                  | 描述          |
| ------- | --------------------- | ------------- |
| id      | unsigned int          | SPI ID        |
| iot_spi | IoT_SPI_InitTypeDef * | SPI初始化参数 |

其中，id对应于如下表所示：


| SPI  | id       | CS        | CLK       | MOSI      | MISO      |
| ---- | -------- | --------- | --------- | --------- | --------- |
| SPI0 | ESPI0_M0 | GPIO0_PB4 | GPIO0_PB5 | GPIO0_PB6 | GPIO0_PB7 |
| SPI0 | ESPI0_M1 | GPIO0_PC0 | GPIO0_PC1 | GPIO0_PC2 | GPIO0_PC3 |
| SPI1 | ESPI1_M0 | GPIO0_PC4 | GPIO0_PC5 | GPIO0_PC6 | GPIO0_PC7 |
| SPI1 | ESPI1_M1 | GPIO0_PB0 | GPIO0_PB1 | GPIO0_PB2 | GPIO0_PB3 |

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_spi.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
unsigned int IoTSpiInit(unsigned int id, IoT_SPI_InitTypeDef *iot_spi)
{
    unsigned int ret = 0;
    LzSpiConfig spi_config = {0};

    if (id >= ESPIDEV_MAX)
    {
        PRINT_ERR("id(%d) >= ESPIDEV_MAX(%d)\n", id, ESPIDEV_MAX);
        return IOT_FAILURE;
    }

    if (iot_spi->Mode == SPI_MODE_SLAVE)
    {
        spi_config.isSlave = false;
    }
    else if (iot_spi->Mode == SPI_MODE_SLAVE)
    {
        spi_config.isSlave = true;
    }

    if (iot_spi->Direction == SPI_DIRECTION_1LINE_TX)
    {
        m_spi_bus_info[id].spi_bus.miso.gpio = INVALID_GPIO;
        m_spi_bus_info[id].spi_bus.miso.func = MUX_FUNC0;
    }

    if (iot_spi->NSS == SPI_NSS_SOFT)
    {
        m_spi_bus_info[id].spi_bus.cs.gpio = INVALID_GPIO;
        m_spi_bus_info[id].spi_bus.cs.func = MUX_FUNC0;
    }

    if (iot_spi->DataSize == SPI_DATASIZE_8BIT)
    {
        spi_config.bitsPerWord = SPI_PERWORD_8BITS;
    }
    else if (iot_spi->DataSize == SPI_DATASIZE_16BIT)
    {
        spi_config.bitsPerWord = SPI_PERWORD_16BITS;
    }

    if (iot_spi->CLKPolarity == SPI_POLARITY_LOW)
    {
        if (iot_spi->CLKPhase == SPI_PHASE_1EDGE)
        {
            spi_config.mode = SPI_MODE_0;
        }
        else if (iot_spi->CLKPhase == SPI_PHASE_2EDGE)
        {
            spi_config.mode = SPI_MODE_1;
        }
    }
    else if (iot_spi->CLKPolarity == SPI_POLARITY_HIGH)
    {
        if (iot_spi->CLKPhase == SPI_PHASE_1EDGE)
        {
            spi_config.mode = SPI_MODE_2;
        }
        else if (iot_spi->CLKPhase == SPI_PHASE_2EDGE)
        {
            spi_config.mode = SPI_MODE_3;
        }
    }

    spi_config.speed = SPI_MAX_SPEED / (1 << iot_spi->BaudRatePrescaler);

    if (iot_spi->FirstBit == SPI_FIRSTBIT_MSB)
    {
        spi_config.firstBit = SPI_MSB;
    }
    else if (iot_spi->FirstBit == SPI_FIRSTBIT_LSB)
    {
        spi_config.firstBit = SPI_LSB;
    }

    spi_config.csm = SPI_CMS_ONE_CYCLES;

    if (SpiIoInit(m_spi_bus_info[id].spi_bus) != LZ_HARDWARE_SUCCESS)
    {
        printf("%s, %d: SpiIoInit failed!\n", __FILE__, __LINE__);
        return IOT_FAILURE;
    }

    if (LzSpiInit(m_spi_bus_info[id].id, spi_config) != LZ_HARDWARE_SUCCESS)
    {
        printf("%s, %d: LzSpiInit failed!\n", __FILE__, __LINE__);
        return IOT_FAILURE;
    }

    return IOT_SUCCESS;
}
```

#### 取消SPI器件的初始化：IoTSpiDeinit

```c
unsigned int IoTSpiDeinit(unsigned int id);
```

**描述：**

取消SPI器件的初始化。

**参数：**


| 参数 | 类型         | 描述   |
| ---- | ------------ | ------ |
| id   | unsigned int | SPI ID |

其中，id对应于如下表所示：


| SPI  | id       | CS        | CLK       | MOSI      | MISO      |
| ---- | -------- | --------- | --------- | --------- | --------- |
| SPI0 | ESPI0_M0 | GPIO0_PB4 | GPIO0_PB5 | GPIO0_PB6 | GPIO0_PB7 |
| SPI0 | ESPI0_M1 | GPIO0_PC0 | GPIO0_PC1 | GPIO0_PC2 | GPIO0_PC3 |
| SPI1 | ESPI1_M0 | GPIO0_PC4 | GPIO0_PC5 | GPIO0_PC6 | GPIO0_PC7 |
| SPI1 | ESPI1_M1 | GPIO0_PB0 | GPIO0_PB1 | GPIO0_PB2 | GPIO0_PB3 |

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_spi.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
unsigned int IoTSpiDeinit(unsigned int id)
{
    unsigned int ret = 0;

    if (id >= ESPIDEV_MAX)
    {
        PRINT_ERR("id(%d) >= ESPIDEV_MAX(%d)\n", id, ESPIDEV_MAX);
        return IOT_FAILURE;
    }

    LzGpioDeinit(m_spi_bus_info[id].spi_bus.clk.gpio);
    LzGpioDeinit(m_spi_bus_info[id].spi_bus.cs.gpio);
    LzGpioDeinit(m_spi_bus_info[id].spi_bus.miso.gpio);
    LzGpioDeinit(m_spi_bus_info[id].spi_bus.mosi.gpio);

    ret = LzSpiDeinit(m_spi_bus_info[id].id);
    if (ret != LZ_HARDWARE_SUCCESS)
    {
        return IOT_FAILURE;
    }

    return IOT_SUCCESS;
}
```

#### 将数据写入SPI器件：IoTSpiWrite

```c
unsigned int IoTSpiWrite(unsigned int id, unsigned char *buf, unsigned int len);
```

**描述：**

将数据写入SPI器件。

**参数：**


| 参数 | 类型            | 描述     |
| ---- | --------------- | -------- |
| id   | unsigned int    | SPI ID   |
| buf  | unsigned char * | 数据     |
| len  | unsigned int    | 数据长度 |

其中，id对应于如下表所示：


| SPI  | id       | CS        | CLK       | MOSI      | MISO      |
| ---- | -------- | --------- | --------- | --------- | --------- |
| SPI0 | ESPI0_M0 | GPIO0_PB4 | GPIO0_PB5 | GPIO0_PB6 | GPIO0_PB7 |
| SPI0 | ESPI0_M1 | GPIO0_PC0 | GPIO0_PC1 | GPIO0_PC2 | GPIO0_PC3 |
| SPI1 | ESPI1_M0 | GPIO0_PC4 | GPIO0_PC5 | GPIO0_PC6 | GPIO0_PC7 |
| SPI1 | ESPI1_M1 | GPIO0_PB0 | GPIO0_PB1 | GPIO0_PB2 | GPIO0_PB3 |

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_spi.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
unsigned int IoTSpiWrite(unsigned int id, unsigned char *buf, unsigned int len)
{
    unsigned int ret = 0;

    if (id >= ESPIDEV_MAX)
    {
        PRINT_ERR("id(%d) >= ESPIDEV_MAX(%d)\n", id, ESPIDEV_MAX);
        return IOT_FAILURE;
    }

    ret = LzSpiWrite(m_spi_bus_info[id].id, m_spi_bus_info[id].id, buf, len);
    if (ret != LZ_HARDWARE_SUCCESS)
    {
        return IOT_FAILURE;
    }

    return IOT_SUCCESS;
}
```

#### 从SPI器件读取数据：IoTSpiRead

```c
unsigned int IoTSpiWrite(unsigned int id, unsigned char *buf, unsigned int len);
```

**描述：**

从SPI器件读取数据。

**参数：**


| 参数 | 类型            | 描述     |
| ---- | --------------- | -------- |
| id   | unsigned int    | SPI ID   |
| buf  | unsigned char * | 数据     |
| len  | unsigned int    | 数据长度 |

其中，id对应于如下表所示：


| SPI  | id       | CS        | CLK       | MOSI      | MISO      |
| ---- | -------- | --------- | --------- | --------- | --------- |
| SPI0 | ESPI0_M0 | GPIO0_PB4 | GPIO0_PB5 | GPIO0_PB6 | GPIO0_PB7 |
| SPI0 | ESPI0_M1 | GPIO0_PC0 | GPIO0_PC1 | GPIO0_PC2 | GPIO0_PC3 |
| SPI1 | ESPI1_M0 | GPIO0_PC4 | GPIO0_PC5 | GPIO0_PC6 | GPIO0_PC7 |
| SPI1 | ESPI1_M1 | GPIO0_PB0 | GPIO0_PB1 | GPIO0_PB2 | GPIO0_PB3 |

**返回值：**


| 返回值      | 描述 |
| ----------- | ---- |
| IOT_SUCCESS | 成功 |
| IOT_FAILURE | 失败 |

**实现：**

`hal_iot_spi.c`文件在`device/rockchip/rk2206/adapter/hals/iot_hardware/wifiiot_lite`目录下。

```c
unsigned int IoTSpiWrite(unsigned int id, unsigned char *buf, unsigned int len)
{
    unsigned int ret = 0;

    if (id >= ESPIDEV_MAX)
    {
        PRINT_ERR("id(%d) >= ESPIDEV_MAX(%d)\n", id, ESPIDEV_MAX);
        return IOT_FAILURE;
    }

    ret = LzSpiWrite(m_spi_bus_info[id].id, m_spi_bus_info[id].id, buf, len);
    if (ret != LZ_HARDWARE_SUCCESS)
    {
        return IOT_FAILURE;
    }

    return IOT_SUCCESS;
}
```

### 软件设计

**主要代码分析**

在`lcd_example`函数中，创建一个任务。

```c
void iot_lcd_example()
{
    unsigned int thread_id;
    TSK_INIT_PARAM_S task = {0};
    unsigned int ret      = LOS_OK;

    task.pfnTaskEntry = (TSK_ENTRY_FUNC)lcd_thread;
    task.uwStackSize  = 20480;
    task.pcName       = "lcd_thread";
    task.usTaskPrio   = 24;
    ret               = LOS_TaskCreate(&thread_id, &task);
    if (ret != LOS_OK) {
        printf("Falied to create lcd_thread ret:0x%x\n", ret);
        return;
    }
}
```

`lcd_thread`任务中调用`lcd.c`文件中的接口对2.4寸屏初始化、显示。

```c
void lcd_thread(void)
{
    uint8_t chinese_string[] = "小凌派";
    uint8_t cur_sizey        = 12;

    lcd_init(0);
    lcd_fill(0, 0, g_lcd_size.w, g_lcd_size.h, LCD_WHITE);

    while (1) {
        printf("************Lcd Example***********\n");
        lcd_fill(0, 0, LCD_W, LCD_H, LCD_WHITE);
        lcd_show_chinese(0, 0, chinese_string, LCD_RED, LCD_WHITE, cur_sizey, 0);
        if (cur_sizey == 12)
            cur_sizey = 16;
        else if (cur_sizey == 16)
            cur_sizey = 24;
        else if (cur_sizey == 24)
            cur_sizey = 32;
        else
            cur_sizey = 12;

        printf("\n");
        LOS_Msleep(1000);
    }
}
```

在`lcd.c`文件中，可以看到调用IOT库的SPI接口。

```c
unsigned int lcd_init(uint8_t dir)
{
    unsigned int ret = 0;
    ret = IoTSpiInit(LCD_SPI_BUS, &iot_spi);
    if (ret != IOT_SUCCESS) {
        printf("%s, %s, %d: Spi init failed!\n", __FILE__, __func__, __LINE__);
        return IOT_FAILURE;
    }
    ...
}

unsigned int lcd_deinit()
{
    IoTSpiDeinit(LCD_SPI_BUS);
    ...
}
```

## 编译调试

### 修改 BUILD.gn 文件

修改 `vendor/lockzhiner/rk2206/sample` 路径下 BUILD.gn 文件，指定 `iot_lcd_example` 参与编译。

```r
"./b23_iot_lcd:iot_lcd_example",
```

修改 `device/lockzhiner/rk2206/sdk_liteos` 路径下 Makefile 文件，添加 `-liot_lcd_example` 参与编译。

```r
hardware_LIBS = -lhal_iothardware -lhardware -lshellcmd -liot_lcd_example
```

### 运行结果

示例代码编译烧录代码后，按下开发板的RESET按键，可以看到屏幕显示“小凌派”。
