# 小凌派-RK2206开发板基础外设开发：WiFi-AP通信

## 实验内容

本示例将演示如何在小凌派-RK2206开发板上使用WiFi-AP模式（即将RK2206作为WiFi路由器），实现与PC端进行TCP通信。

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

#### VendorSet()

**头文件：**

```
//device/rockchip/rk2206/adapter/include/lz_hadware.h
```

实际定义在：

```
//device/rockchip/rk2206/adapter/include/lz_hardware/vendor.h
```

**函数描述：**

```c
unsigned int VendorSet(VendorID id, unsigned char *buf, int len);
```

**作用描述：**

在Flash区域中设置WiFi相关参数。

**参数描述：**

| 名字 | 描述                                                         |
| :--- | :----------------------------------------------------------- |
| id   | 配置的参数，例如：<br>VENDOR_ID_WIFI_SSID：设备作为终端，连接WiFi路由器的SSID，32字节 + '\0'<br>VENDOR_ID_WIFI_PASSWD：设备作为终端，连接WiFi路由器的密钥，64字节 + '\0'<br>VENDOR_ID_WIFI_ROUTE_SSID：设备作为WiFi路由器，配置SSID，32字节 + '\0'<br>VENDOR_ID_WIFI_ROUTE_PASSWD：设备作为WiFi路由器，配置密钥，64字节 + '\0'<br>VENDOR_ID_WIFI_MODE：配置设备作为终端或WiFi路由器，3字节 + '\0' |
| buf  | 配置内容字符串                                               |
| len  | 配置内容字符串长度                                           |

**返回值：**

LZ_HARDWARE_SUCCESS为成功，反之为失败。

#### SetApModeOff()

**头文件：**

```
/device/rockchip/rk2206/sdk_liteos/board/include/config_network.h
```

**函数描述：**

```c
WifiErrorCode SetApModeOff();
```

**作用描述：**

关闭WiFi-AP模式。

**参数描述：**

无

**返回值：**

0为成功，反之为失败。

#### SetApModeOn()

**头文件：**

```
/device/rockchip/rk2206/sdk_liteos/board/include/config_network.h
```

**函数描述：**

```c
WifiErrorCode SetApModeOn();
```

**作用描述：**

开启WiFi-AP模式。

**参数描述：**

无

**返回值：**

0为成功，反之为失败。

### 软件设计

整个例程主要分为2个部分：

- 配置RK2206为WiFi-AP模式
- 创建TCP服务端，监听并等待TCP客户端

#### 配置WiFi-AP模式

该任务主要分为如下几个步骤：

（1）配置WiFi相关参数

首先，定义几个WiFi相关参数，并予以赋值。

```c
void wifi_process(void *args)
{
    unsigned int threadID_client, threadID_server;
    unsigned int ret = LOS_OK;
    WifiLinkedInfo info;
    uint8_t wifi_mode[4];                           // 注意：wifi_mode字符串长度为4, 不能超过4
    uint8_t mac_address[6];                         // 注意：mac_address字符串长度为6, 不能超过6
    uint8_t route_ssid[WIFI_MAX_SSID_LEN];          // config_network.h有定义该宏定义
    uint8_t route_passwd[WIFI_MAX_KEY_LEN];         // config_network.h有定义该宏定义

    // 配置WiFi模式字符串
    memset(wifi_mode, 0, sizeof(wifi_mode));
    snprintf(wifi_mode, sizeof(wifi_mode), "AP");
    // 配置MAC地址字符串
    memset(mac_address, 0, sizeof(mac_address));
    mac_address[0] = 0x00;
    mac_address[1] = 0xdc;
    mac_address[2] = 0xb6;
    mac_address[3] = 0x90;
    mac_address[4] = 0x11;
    mac_address[5] = 0x00;
    // 配置route_ssid和route_passwd
    memset(route_ssid, 0, WIFI_MAX_SSID_LEN);
    snprintf(route_ssid, sizeof(route_ssid), WIFI_SSID);
    memset(route_passwd, 0, WIFI_MAX_KEY_LEN);
    snprintf(route_passwd, sizeof(route_passwd), WIFI_PASSWORD);
    ......
}
```

注意：上述wifi_mode、mac_address、route_ssid和route_passwd都有严格的字符串长度定义。

（2）写入Flash

将之前定义好的WiFi相关参数写入到Flash。

```c
void wifi_process(void *args)
{
	........
    // Flash初始化
    FlashInit();
    // 配置RK2206为WiFi-AP模式，并设置WiFi路由器的SSID和密码
    VendorSet(VENDOR_ID_WIFI_MODE, wifi_mode, sizeof(wifi_mode));           // 配置为Wifi AP模式
    VendorSet(VENDOR_ID_MAC, mac_address, sizeof(mac_address));             // 配置MAC地址
    VendorSet(VENDOR_ID_WIFI_SSID, route_ssid, sizeof(route_ssid));         // 配置WiFi路由器的SSID
    VendorSet(VENDOR_ID_WIFI_PASSWD, route_passwd, sizeof(route_passwd));   // 配置WiFi路由器的密码
    ......
}
```

注意：

- 在调用VendorSet()之前必须调用FlashInit()，初始化Flash相关操作，否则VendorSet()无效。
- VendorSet()第1个参数在vendor.h有定义。

（3）重启WiFi-AP模式

```c
void wifi_process(void *args)
{
    ........
    // 开启WiFi-AP模式
    SetApModeOff();
    SetApModeOn();
	......
}
```

#### TCP服务端

首先，在wifi_process()调用CreateThread()创建1个线程，运行wifi_tcp_server()

```c
void wifi_process(void *args)
{
	........
    // 创建TCP服务端线程
    CreateThread(&threadID_server, wifi_tcp_server, NULL, "tcp_server");
}
```

其次，运行TCP服务端，绑定IP地址和端口号，监听端口，等待TCP客户端连接

```c
int wifi_tcp_server(void *arg)
{
    int server_fd, ret;

    while (1)
    {
        server_fd = socket(AF_INET, SOCK_STREAM, 0); // AF_INET:IPV4;SOCK_STREAM:TCP
        // server_fd = lwip_socket(AF_INET, SOCK_STREAM, 0); //AF_INET:IPV4;SOCK_STREAM:TCP
        if (server_fd < 0)
        {
            printf("create socket fail!\n");
            return -1;
        }

        /*设置调用close(socket)后,仍可继续重用该socket。调用close(socket)一般不会立即关闭socket，而经历TIME_WAIT的过程。*/
        int flag = 1;
        ret = setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &flag, sizeof(int));
        if (ret != 0)
        {
            printf("[CommInitTcpServer]setsockopt fail, ret[%d]!\n", ret);
        }

        struct sockaddr_in serv_addr = {0};
        serv_addr.sin_family = AF_INET;
        serv_addr.sin_addr.s_addr = htonl(INADDR_ANY); // IP地址，需要进行网络序转换，INADDR_ANY：本地地址
        // serv_addr.sin_addr.s_addr = inet_addr(OC_SERVER_IP); //IP地址，需要进行网络序转换，INADDR_ANY：本地地址
        serv_addr.sin_port = htons(SERVER_PORT); // 端口号，需要网络序转换
        /* 绑定服务器地址结构 */
        ret = bind(server_fd, (struct sockaddr *)&serv_addr, sizeof(serv_addr));
        // ret = lwip_bind(server_fd, (struct sockaddr*)&serv_addr, sizeof(serv_addr));
        if (ret < 0)
        {
            printf("socket bind fail!\n");
            lwip_close(server_fd);
            return -1;
        }
        /* 监听socket 此处不阻塞 */
        ret = listen(server_fd, 64);
        // ret = lwip_listen(server_fd, 64);
        if (ret != 0)
        {
            printf("socket listen fail!\n");
            lwip_close(server_fd);
            return -1;
        }
        printf("[tcp server] listen:%d<%s:%d>\n", server_fd, inet_ntoa(serv_addr.sin_addr), ntohs(serv_addr.sin_port));
        tcp_server_msg_handle(server_fd); // 处理接收到的数据
        LOS_Msleep(1000);
    }
}
```

最后，tcp_server_msg_handle()负责与TCP客户端进行实际通信。

```c

void tcp_server_msg_handle(int fd)
{
    char buf[BUFF_LEN];
    socklen_t client_addr_len;
    int cnt = 0, count;
    int client_fd;
    struct sockaddr_in client_addr = {0};

    printf("waitting for client connect...\n");
    /* 监听socket 此处会阻塞 */
    client_fd = accept(fd, (struct sockaddr *)&client_addr, &client_addr_len);
    // client_fd = lwip_accept(fd, (struct sockaddr*)&client_addr, &client_addr_len);
    printf("[tcp server] accept <%s:%d>\n", inet_ntoa(client_addr.sin_addr), ntohs(client_addr.sin_port));
    while (1)
    {
        memset(buf, 0, BUFF_LEN);
        printf("-------------------------------------------------------\n");
        printf("[tcp server] waitting client msg\n");
        count = recv(client_fd, buf, BUFF_LEN, 0);          // read是阻塞函数，没有数据就一直阻塞
        // count = lwip_read(client_fd, buf, BUFF_LEN);     //read是阻塞函数，没有数据就一直阻塞
        if (count == -1)
        {
            printf("[tcp server] recieve data fail!\n");
            LOS_Msleep(3000);
            break;
        }
        printf("[tcp server] rev client msg:%s\n", buf);
        memset(buf, 0, BUFF_LEN);
        sprintf(buf, "I have recieved %d bytes data! recieved cnt:%d", count, ++cnt);
        printf("[tcp server] send msg:%s\n", buf);
        send(client_fd, buf, strlen(buf), 0);           // 发送信息给client
        // lwip_write(client_fd, buf, strlen(buf));     //发送信息给client
    }
    lwip_close(client_fd);
    lwip_close(fd);
}
```

## 编译调试

### 修改BUILD.gn文件

修改 `vendor/lockzhiner/rk2206/sample` 路径下 BUILD.gn 文件，指定 `wifi_ap_example` 参与编译。

```r
"./b14_wifi_ap:wifi_ap_example",
```

修改 `device/lockzhiner/rk2206/sdk_liteos` 路径下 Makefile 文件，添加 `-lwifi_ap_example` 参与编译。

```r
app_LIBS = -lwifi_ap_example
```

### 运行结果

示例代码编译烧录代码后，按下开发板的RESET按键，通过串口助手查看日志，显示如下：

```r
entering kernel init...
hilog will init.
[IOT:D]IotInit: start ....
[MAIN:D]Main: LOS_Start ...
Entering scheduler
[IOT:D]IotProcess: start ....
wifi_ap_example start ....
[FLASH:I]FlashInit: blockSize 4096, blockStart 0, blockEnd 8388608
[config_network:D]rknetwork SetApModeOff start ...

[config_network:D]rknetwork AP is inactive

[config_network:D]rknetwork SetApModeOff end ...

[config_network:D]rknetwork SetApModeOn start ...

[FLASH:E]FlashInit: id 0, controller has already been initialized
[config_network:D]rknetwork EnableHotspot ...

[wifi_api:D]ip=192.168.2.10 gw=192.168.2.1 mask=255.255.255.0
[wifi_api:D]HWADDR (00:dc:b6:90:11:00)
[bcore_device:E]start bb ...
[bcore_device:E]start bb done
[wifi_api:D]netif setup ...
[wifi_api_internal:D]Start AP (SSID=rk2206_nano channel=1)
[wifi_api_internal:D]derive psk ...
[wifi_api_internal:D]derive psk done
[wifi_dhcp:D]lann_ipaddr:192.168.2.1
[wifi_dhcp:D]lann_mask:255.255.255.0
[config_network:D]rknetwork EnableHotspot done
[tcp server] listen:50<0.0.0.0:6666>
waitting for client connect...

```

注意：设备WiFi路由器IP地址为192.168.2.10。
