# shell命令

## 1、shell简介

LiteOS提供shell命令行，它能够以命令行交互的方式访问操作系统的功能或服务：它接收并解析用户输入的命令，并处理操作系统的输出结果。

## 2、基础知识

LiteOS提供的Shell作为在线调试工具，可以通过串口工具输入输出，支持常用的基本调试功能。同时用户可以新增定制的命令，新增命令需重新编译烧录后才能执行。

### 2.1、新增Shell命令

有静态注册命令和系统运行时动态注册命令两种注册方式。

- 静态注册命令：

  ```c
  #include "shcmd.h"
  SHELLCMD_ENTRY(ls_shellcmd, CMD_TYPE_EX, "ls", XARGS, (CMD_CBK_FUNC)osShellCmdLs);
  ```

- 动态注册命令：

  ```c
  #include "shell.h"
  osCmdReg(CMD_TYPE_EX, "ls", XARGS, (CMD_CBK_FUNC)osShellCmdLs);
  ```

### 2.2、动态注册shell

**步骤01：定义命令所要调用的命令处理函数cmd_test**

```
#include "shell.h"
#include "shcmd.h"

int cmd_test(void)
{
    printf("hello everybody!\n");
    return 0;
}
```

**步骤02：添加新增命令项**

```
#include "shell.h"
osCmdReg(CMD_TYPE_STD, "test", XARGS, (CMD_CBK_FUNC)cmd_test);
```

## 3、动态注册test命令

### 3.1、创建文件

在//device/rockchip/rk2206/sdk_liteos/shell创建文件，具体如下：

```
//device/rockchip/rk2206/sdk_liteos/shell
├── include
|   └── shell_test.h		# ifconfig头文件
├── src                       
|   └── shell_test.c		# ifconfig实现的源代码
├── BUILD.gn
```

其中，shell_test.h具体如下：

```c
#ifndef _SHELL_TEST_H_
#define _SHELL_TEST_H_

int shell_test(int argc, const char *argv[]);

#endif // _SHELL_TEST_H_
```

shell_test.c具体如下：

```c
#include <stdio.h>

#if (LOGCFG_SHELL == 1)
#include "shcmd.h"
#include "shell.h"
#endif // LOGCFG_SHELL

int shell_test(int argc, const char *argv[])
{
    printf("Hello World\n");
    return 0;
}
```

### 3.2、注册shell

在//device/rockchip/rk2206/sdk_liteos/shell/shell_cmd.c添加如下代码：

```c
#if (LOGCFG_SHELL == 1)
#include "shcmd.h"
#include "shell.h"
#endif // LOGCFG_SHELL

void shell_cmd_init()
{
#if (LOGCFG_SHELL == 1)
    osCmdReg(CMD_TYPE_STD, "test", 0, (CMD_CBK_FUNC)shell_test);			# 添加该行
    osCmdReg(CMD_TYPE_STD, "uname", 0, (CMD_CBK_FUNC)shell_uname);
    osCmdReg(CMD_TYPE_STD, "hwinfo", XARGS, (CMD_CBK_FUNC)shell_hwinfo);
    osCmdReg(CMD_TYPE_STD, "flash", XARGS, (CMD_CBK_FUNC)shell_flash);
    osCmdReg(CMD_TYPE_STD, "ifconfig", XARGS, (CMD_CBK_FUNC)shell_ifconfig);
#endif // // LOGCFG_SHELL
}
```

### 3.3、参与编译

在//device/rockchip/rk2206/sdk_liteos/shell/BUILD.gn添加如下代码：

```
import("//device/rockchip/rk2206/sdk_liteos/board.gni")
import("//drivers/adapter/khdf/liteos_m/hdf.gni")

static_library("shellcmd") {
  sources = [
    "src/shell_cmd.c",
    "src/shell_test.c",			# 添加该行
    "src/shell_uname.c",
    "src/shell_hwinfo.c",
    "src/shell_flash.c",
    "src/shell_ifconfig.c",
  ]

  include_dirs = [
    "$kernel_path/kernel/include",
    "$kernel_path/kernel/arch/include",
    "$kernel_path/utils",
    "$kernel_path/kal/cmsis",
    "$kernel_path/kal",
    "$kernel_path/components/shell/include",
    "$hilog_path/interfaces/native/kits",
    "$adapter_path/include",
    "include",
    "../board/include",
    "//third_party/cJSON",
    "//third_party/lwip/src/include",
    "//third_party/musl/porting/liteos_m/kernel/include",
    "$rk_third_party_dir/simple_gui/inc",
    "$hdf_fwk_path/include/platform",
    "$hdf_fwk_path/include/utils",
    "$hdf_fwk_path/include/osal",
    "$khdf_path/osal/include",
  ]

  deps = []
}
```

## 4、常用命令

OpenHarmony常用命令如下：

### 4.1、系统级命令

#### 4.1.1、help命令

帮助命令，将所有命令打印出来。

```sh
OHOS # help
*******************shell commands:*************************

cat           cd            cp            date          flash         free          help          hwinfo
ifconfig      ls            mkdir         pwd           rm            rmdir         task          test
touch         uname
```

注意：cat、cd等命令暂不支持。

#### 4.1.2、free命令

free命令可显示系统内存的使用情况。

命令格式：free [-k/-m]

其中，参数定义如下：

| 参数   | 参数说明           | 取值范围 |
| :----- | :----------------- | :------- |
| 无参数 | 以Byte为单位显示。 | N/A      |
| -k     | 以KB为单位显示。   | N/A      |
| -m     | 以MB为单位显示。   | N/A      |

具体命令使用如下：

```sh
OHOS # free

        total        used          free
Mem:    7340032      227964        7112068
OHOS # 
```

#### 4.1.3、task命令

task命令用于查询进程及线程信息。

命令格式：task

具体命令使用如下：

```sh
OHOS # task
Name                   TaskEntryAddr       TID    Priority   Status       StackSize       StackPoint   TopOfStack
----                   -------------       ---    --------   --------     ---------       ----------   ----------
Swt_Task               0x8dbcd             0x0    0          Pend         0x1000          0x3810e33c   0x3810d418
IdleCore000            0x8e069             0x1    31         Ready        0x1000          0x3810f3ac   0x3810e438
Bootstrap              0x100976ed          0x2    9          Pend         0x800           0x38110a54   0x38110388
Broadcast              0x100976ed          0x3    2          Pend         0x800           0x3811126c   0x38110ba0
hiview                 0x100976ed          0x4    10         Pend         0x800           0x38111a8c   0x381113c0
UartDebugRecvProcess   0x8a369             0x5    3          Ready        0x20000         0x38131b54   0x38111bd8
ShellTaskEntry         0x10098b45          0x6    3          Running      0x4000          0x38135e4c   0x38131f28
taskConfigWifiModeEntry0x89fc5             0x7    15         Delay        0x4000          0x3813ad64   0x38136de0
BcoreDevTask           0x8511d             0x8    6          Pend         0x1000          0x3813c5bc   0x3813b658
tcpip_thread           0x10094d01          0x9    5          PendTime     0x1000          0x3813e5b4   0x3813d690
WifiRxThread           0x87265             0xa    6          Pend         0x1000          0x3813f5dc   0x3813e6f0
OHOS # 
```

### 4.2、自定义命令

#### 4.2.1、ifconfig命令

ifconfig命令用于查看当前wifi网络连接状态信息。

具体命令使用如下：

```sh
OHOS # ifconfig
inet 192.168.1.67
netmask 255.255.255.0
gateway 192.168.1.3
OHOS # 
```

其中，打印信息定义如下所示：

| 序号 | 名称    | 描述                 |
| ---- | ------- | -------------------- |
| 1    | inet    | 开发板WiFi的IP地址   |
| 2    | netmask | 开发板WiFi的子网掩码 |
| 3    | gateway | 开发板WiFi的网关地址 |

#### 4.2.2、hwinfo命令

hwinfo命令用于读写开发板一些硬件信息。

命令格式：

```sh
# 查看所有配置信息
hwinfo 
# 获取某一个硬件信息的内容
hwinfo get xxxxx
# 设置某一个硬件信息的内容
hwinfo set key value
```

具体命令使用如下：

（1）查看所有配置信息

```sh
OHOS # hwinfo
[FLASH:E]FlashInit: id 0, controller has already been initialized
sn:           LZ01
product:      小凌派
factory:      凌睿智捷
mode:         STA
ap_ssid:      rk2206_nano
ap_passwd:    88888888
route_ssid:   凌智电子_2
route_passwd: 88888888
mac:          10:dc:b6:91:01:00
ip:           192.168.2.10
gateway:      192.168.2.1
mask:         255.255.255.0
OHOS # 
```

其中，打印信息定义如下所示：

| 序号 | 名称         | 描述                                                         |
| ---- | ------------ | ------------------------------------------------------------ |
| 1    | sn           | 开发板的SN序列号                                             |
| 2    | product      | 开发板产品名称                                               |
| 3    | factory      | 开发板厂商名称                                               |
| 4    | mode         | WiFi模式：<br>（1）STA，Station，站点模式<br>（2）AP，Access Point，接入点模式 |
| 5    | ap_ssid      | WiFi AP模式的SSID                                            |
| 6    | ap_passwd    | WiFi AP模式的密码                                            |
| 7    | route_ssid   | WiFi STA模式，需要链接WiFi路由器的SSID                       |
| 8    | route_passwd | WiFi STA模式，需要链接WiFi路由器的密码                       |
| 9    | mac          | WiFi AP模式的MAC地址                                         |
| 10   | ip           | WiFi AP模式的IP地址                                          |
| 11   | gateway      | WiFi AP模式的网关IP地址                                      |
| 12   | mask         | WiFi AP模式的子网掩码                                        |

（2）配置WiFi STA模式的路由器SSID名称

```sh
OHOS # hwinfo set route_ssid 凌智电子
[FLASH:E]FlashInit: id 0, controller has already been initialized
[FLASH:E]FlashInit: id 0, controller has already been initialized
[FLASH:E]FlashInit: id 0, controller has already been initialized
sn:           LZ01
product:      小凌派
factory:      凌睿智捷
mode:         STA
ap_ssid:      rk2206_nano
ap_passwd:    88888888
route_ssid:   凌智电子
route_passwd: 88888888
mac:          10:dc:b6:91:01:00
ip:           192.168.2.10
gateway:      192.168.2.1
mask:         255.255.255.0
OHOS # 
```

注意：重启后生效。

（3）配置WiFi STA模式的路由器密码

```sh
OHOS # hwinfo set route_passwd 99999999
[FLASH:E]FlashInit: id 0, controller has already been initialized
[FLASH:E]FlashInit: id 0, controller has already been initialized
[FLASH:E]FlashInit: id 0, controller has already been initialized
sn:           LZ01
product:      小凌派
factory:      凌睿智捷
mode:         STA
ap_ssid:      rk2206_nano
ap_passwd:    88888888
route_ssid:   凌智电子_2
route_passwd: 99999999
mac:          10:dc:b6:91:01:00
ip:           192.168.2.10
gateway:      192.168.2.1
mask:         255.255.255.0
OHOS # 
```

注意：重启后生效。

#### 4.2.3、flash命令

flash命令用于读写擦除flash。

命令格式：

```sh
# 读取Flash的addr ~ (addr + size)区域信息
flash read addr size
# 写入Flash的addr区域，写入内容为value
flash write addr value
# 擦除Flash的addr ~ (addr + size)区域
flash erase addr size
```

注意：

- 该命令可擦除一些重要的flash区域信息，请慎用flash命令。
- flash的0~4MB区域建议不要随意修改或擦除，以免导致开发板出现问题。
- 读取或擦除时，size以4KB为一个单位。

（1）查看flash区域

查看0x100000 ~  0x101000区域的Flash内容

```sh
OHOS # flash read 100000 1
[FLASH:E]FlashInit: id 0, controller has already been initialized
[00100000]: 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00
[00100010]: 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00
[00100020]: 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00
[00100030]: 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00
[00100040]: 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00
......
```

#### 4.2.4、uname命令

uname命令用于查看OpenHarmony版本号。

命令格式：uname

具体命令使用如下：

```sh
OHOS # uname
OpenHarmony-v3.0LTS, Lockzhiner rk2206 v1.3
OHOS # 
```

其中，打印信息定义如下所示：

| 序号 | 名称                | 描述                               |
| ---- | ------------------- | ---------------------------------- |
| 1    | OpenHarmony-v3.0LTS | OpenHarmony主线版本号              |
| 2    | Lockzhiner          | 厂商名称，福州凌睿智捷电子有限公司 |
| 3    | rk2206              | 芯片名称，瑞芯微RK2206             |
| 4    | v1.3                | 厂商管理的OpenHarmony版本号        |

#### 4.2.5、tcp命令

tcp用于设置或查看tcp服务端IP地址和端口号。

命令格式：tcp client [ip/port] xxxxxx

具体命令使用如下：

```shell
# 配置TCP服务端的IP地址
OHOS # tcp client ip 192.168.1.32
# 配置TCP服务端的端口
OHOS # tcp client port 8000
```









