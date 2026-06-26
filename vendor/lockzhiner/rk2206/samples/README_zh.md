# 小凌派-RK2206开发板 案例开发

小凌派-RK2206开发板提供多个案例，案例以A、B、C、D进行不同类别进行分级，方便初学者由浅入深逐步学习。您拿到工程后经过简单的编程和下载即可看到实验现象。下面依次对A/B/C/D类进行介绍：

* `A1 - A99`：内核类
* `B1 - B99`：基础外设类
* `C1 - C99`：E53传感器类
* `D1 - D99`：物联网类

例程列表如下所示：

| 编号 | 类别      | 例程名                       | 说明                                                         |
| ---- | --------- | ---------------------------- | ------------------------------------------------------------ |
| A0   | 内核      | Hello World                  | [Hello World](./a0_hello_world/README_zh.md)                 |
| A1   | 内核      | thread                       | [任务](./a1_kernal_task/README_zh.md)                        |
| A2   | 内核      | semaphore                    | [信号量](./a2_kernel_semaphore/README_zh.md)                 |
| A3   | 内核      | timer                        | [定时器](./a3_kernel_timer/README_zh.md)                     |
| A4   | 内核      | mutex                        | [互斥锁](./a4_kernel_mutex/README_zh.md)                     |
| A5   | 内核      | queue                        | [消息队列](./a5_kernel_queue/README_zh.md)                   |
| A6   | 内核      | event                        | [事件](./a6_kernel_event/README_zh.md)                       |
| A7   | 内核      | hal_file                     | [标准文件读写](./a7_hal_file/README_zh.md)                   |
| A8   | 内核      | hal_pwm                      | [标准PWM控制](./a8_hal_pwm/README_zh.md)                     |
| A9   | 内核      | hal_dir                      | [标准目录操作](./a9_hal_dir/README_zh.md)                    |
| A10  | 内核      | kv_strore                    | [分布式数据管理](./a10_kv_store/README_zh.md)                |
| B1   | 基础      | adc                          | [ADC按键检测](./b1_adc/README_zh.md)                         |
| B2   | 基础      | nfc                          | [NFC标签](./b2_nfc/README_zh.md)                             |
| B3   | 基础      | eeprom                       | [EEPROM测试](./b3_eeprom/README_zh.md)                       |
| B4   | 基础      | lcd                          | [LCD显示](./b4_lcd/README_zh.md)                             |
| B5   | 基础      | oled                         | [OLED显示](./b5_oled/README_zh.md)                           |
| B6   | 基础      | uart0                        | [UART0打印](./b6_uart0/README_zh.md)                         |
| B6   | 基础      | uart2                        | [UART2收发数据](./b6_uart2/README_zh.md)                     |
| B7   | 基础      | wifi_tcp                     | [TCP通信](./b7_wifi_tcp/README_zh.md)                        |
| B8   | 基础      | wifi_udp                     | [UDP通信](./b8_wifi_udp/README_zh.md)                        |
| B9   | 基础      | gpio                         | [GPIO控制](./b9_gpio/README_zh.md)                           |
| B10  | 基础      | gpio_interrupt               | [GPIO中断控制](./b10_gpio_interrupt/README_zh.md)            |
| B11  | 基础      | i2c_scan                     | [i2c扫描从设备](./b11_i2c_scan/README_zh.md)                 |
| B12  | 基础      | watchdog                     | [看门狗控制](./b12_watchdog/README_zh.md)                    |
| B13  | 基础      | reboot                       | [重启控制](./b13_reboot/README_zh.md)                        |
| B14  | 基础      | wifi_ap                      | [WiFi-AP模式](./b14_wifi_ap/README_zh.md)                    |
| B15  | 基础      | flash                        | [Flash读写](./b15_flash/README_zh.md)                        |
| B16  | 基础      | iot_pwm                      | [基于IoT标准接口的PWM控制](./b16_iot_pwm/README_zh.md)             |
| B17  | 基础      | iot_adc                      | [基于IoT标准接口的ADC读取](./b17_iot_adc/README_zh.md)             |
| B18  | 基础      | iot_gpio                     | [基于IoT标准接口的GPIO控制](./b18_iot_gpio/README_zh.md)            |
| B19  | 基础      | iot_gpio_int                 | [基于IoT标准接口的GPIO中断](./b19_iot_gpio_int/README_zh.md)            |
| B20  | 基础      | iot_uart                     | [基于IoT标准接口的UART通信](./b20_iot_uart/README_zh.md)            |
| B21  | 基础      | iot_flash                    | [基于IoT标准接口的Flash存储读写](./b21_iot_flash/README_zh.md)       |
| B22  | 基础      | iot_watchdog                 | [基于IoT标准接口的看门狗控制](./b22_iot_watchdog/README_zh.md)          |
| B23  | 基础      | iot_lcd                      | [基于IoT标准接口的液晶屏显示](./b23_iot_lcd/README_zh.md)          |
| C1   | E53传感器 | e53_ia_example               | [智慧农业](./c1_e53_intelligent_agriculture/README_zh.md)    |
| C2   | E53传感器 | e53_sc_example               | [智慧井盖](./c2_e53_smart_covers/README_zh.md)               |
| C3   | E53传感器 | e53_isl_example              | [智慧路灯](./c3_e53_intelligent_street_lamp/README_zh.md)    |
| C4   | E53传感器 | e53_iv01_example             | [智慧车载](./c4_e53_intelligent_vehicle_01/README_zh.md)     |
| C5   | E53传感器 | e53_bi_example               | [人体感应](./c5_e53_body_induction/README_zh.md)             |
| C6   | E53传感器 | e53_gs_example               | [智能手势](./c6_e53_gesture_sensor/README_zh.md)             |
| C7   | E53传感器 | e53_intelligent_smoke_sensor | [智慧烟感](./c7_e53_intelligent_smoke_sensor/README_zh.md)   |
| C8   | E53传感器 | e53_temperature_measurement  | [红外温控](./c8_e53_temperature_measurement/README_zh.md)    |
| D2   | 物联网    | iot_cloud_sc_example         | [基于华为IoT平台的智慧井盖](./d2_iot_cloud_smart_covers/README_zh.md) |
| D3   | 物联网    | iot_cloud_isl_example        | [基于华为IoT平台的智慧路灯](./d3_iot_cloud_intelligent_street_lamp/README_zh.md) |
| D4   | 物联网    | iot_cloud_iv_example         | [基于华为IoT平台的智慧车载](./d4_iot_cloud_intelligent_vehicle/README_zh.md) |
| D5   | 物联网    | iot_cloud_bi_example         | [基于华为IoT平台的人体感应](./d5_iot_cloud_body_induction/README_zh.md) |
| D6   | 物联网    | iot_cloud_gs_example         | [基于华为IoT平台的智能手势](./d6_iot_cloud_gesture_sensor/README_zh.md) |
| D7   | 物联网    | iot_cloud_ia_example         | [基于华为IoT平台的智慧农业](./d7_iot_cloud_intelligent_agriculture/README_zh.md) |
| D8   | 物联网    | iot_cloud_TH                 | [基于通鸿IoT平台的数据通信](./d8_iot_cloud_TH/README_zh.md)  |

