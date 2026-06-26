# 小凌派-RK2206开发板E53模块开发——红外测温

## 实验内容

本示例将演示如何在小凌派-RK2206开发板上实现红外测温的应用案例。

![小凌派-RK2206](/vendor/lockzhiner/rk2206/docs/figures/lockzhiner-rk2206.jpg)

硬件资源图如下所示：
![红外测温模块硬件资源](/vendor/lockzhiner/rk2206/docs/figures/e53_wm02/e53_wm02_resource_map.jpg)

EEPROM 24C02的设备地址为：0x1010001* ；
红外测温传感器 MLX90614 的设备地址为：0101101*

## 硬件接口说明

引脚名称开发者可在硬件资源图中查看，也可在智慧井盖模块背面查看。

| 引脚名称 | 功能描述 |
| :--- | :------- | 
| LED_WARNING | LED控制线，低电平有效 | 
| I2C_SCL  |I2C时钟信号线 | 
| I2C-SDA | I2C数据信号线 | 
| GND | 电源地引脚 | 
| 3V3 |3.3V电源输入引脚 | 
| GND | 电源地引脚 |

## 硬件设计

硬件电路如下图所示：
![红外测温模块硬件电路图](/vendor/lockzhiner/rk2206/docs/figures/e53_wm02/lz_e53_wm02_sch.jpg)

模块整体硬件电路如上图所示，电路中包含了E53接口连接器，EEPROM存储器、MLX90614传感器，LED指示灯电路，其中EEPROM存储器、传感器为数字接口芯片，直接使用I2C总线控制，电路简单，本文不再过多说明。下面稍微介绍测温原理。
物体红外辐射能量的大小和波长的分布与其表面温度关系密切。因此，通过对物体自身
红外辐射的测量，能准确地确定其表面温度，红外测温就是利用这一原理测量温度的。红外测温器由光学系统、光电探测器、信号放大器和信号处理及输出等部分组成。 光学系统汇聚其视场内的目标红外辐射能量，视场的大小由测温仪的光学零件及其位置确定。红外能量聚焦在光电探测器上并转变为相应的电信号。该信号经过放大器和信号处理电路，并按照仪器内的算法和目标发射率校正后转变为被测目标的温度值。

### 硬件连接

小凌派开发板与模块均带有防呆设计，故很容易区分安装方向，直接将模块插入到开发板的E53母座接口上即可，安装图如下所示：
![红外测温模块硬件连接图](/vendor/lockzhiner/rk2206/docs/figures/e53_wm02/e53_wm02_connection_diagram.jpg)

## 程序设计

### API分析

**头文件：**
/vendor/lockzhiner/rk2206/samples/c8_e53_temperature_measurement/include/e53_temperature_measurement.h

#### e53_tm_init()

```c
void e53_tm_init(void);
```

**描述说明：**

E53红外测温模块初始化函数，初始化I2C0用于操作红外测温传感器。

**参数说明：**

无

**返回值说明：**

无

#### e53_tm_read_data()

```c
unsigned int e53_tm_read_data(float *temperature);
```

**描述说明：**

E53红外测温模块读取红外测温传感器温度数据。

**参数说明：**

temperature：读取到的温度值指针

**返回值说明：**

成功：SUCCESS
失败：FAIL

#### calculate_temperature()

```c
float calculate_temperature(float ta, float to);
```

**描述说明：**

E53红外测温模块温度计算函数。

**参数说明：**

ta：红外传感器获取参数值
to：红外传感器获取参数值

**返回值说明：**

计算得到的温度值。

### 主要代码分析

在e53_tm_thread函数中，首先初始化红外测温模块，初始化成功后，每秒读取一次红外测温模块的温度值，并将温度值打印到串口中。

```c
void e53_tm_thread()
{
    unsigned int ret = LZ_HARDWARE_SUCCESS;
    float temperature = 0;

    e53_tm_init();

    while (1)
    {
        if (SUCCESS == e53_tm_read_data(&temperature)) {
            printf("temperature:%0.1f\n", temperature);
            LOS_Msleep(1000);
        } else {
            LOS_Msleep(10);
        }
    }
}
```

## 编译调试

### 修改 BUILD.gn 文件

修改 `vendor\lockzhiner\rk2206\sample` 路径下 BUILD.gn 文件，指定 `c8_e53_temperature_measurement` 参与编译。

```r
"./c8_e53_temperature_measurement:e53_tm_example",
```

修改 `device/rockchip/rk2206/sdk_liteos` 路径下 Makefile 文件，添加 `-le53_tm_example` 参与编译。

```r
hardware_LIBS = -lhal_iothardware -lhardware -leeprom_example -le53_tm_example,
```

### 运行结果

示例代码编译烧录代码后，按下开发板的RESET按键，通过串口助手查看日志，手靠近红外传感器，串口显示如下日志。

```c
temperature:36.3
```
