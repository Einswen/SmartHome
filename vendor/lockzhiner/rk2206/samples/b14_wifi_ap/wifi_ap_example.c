/*
 * Copyright (c) 2022 FuZhou Lockzhiner Electronic Co., Ltd. All rights reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "ohos_init.h"
#include "cmsis_os2.h"
#include "los_task.h"
#include "config_network.h"
#include "lwip/tcp.h"
#include "lwip/ip_addr.h"
#include "lwip/priv/tcp_priv.h"
#include "lwip/stats.h"
#include "lwip/inet_chksum.h"

#define LOG_TAG         "tcp"               // 模块名称

#define OC_SERVER_IP    "192.168.2.10"      // 服务器IP地址
#define SERVER_PORT     6666                // 服务器端口号

#define BUFF_LEN        256                 // 接收缓冲区大小

#define WIFI_SSID       "rk2206_nano"       // wifi路由器名称
#define WIFI_PASSWORD   "88888888"          // wifi路由器密码

/***************************************************************
 * 函数名称: tcp_server_msg_handle
 * 说    明: TCP服务端针对某个客户端的服务线程
 * 参    数:
 *       @fd     ：socket描述符
 * 返 回 值: 无
 ***************************************************************/
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

/***************************************************************
 * 函数名称: wifi_tcp_server
 * 说    明: TCP服务端线程，负责绑定IP地址和端口号，并监听连接客户端
 * 参    数:
 *       @fd     ：socket描述符
 * 返 回 值: 0：成功，-1：失败
 ***************************************************************/
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

/***************************************************************
 * 函数名称: wifi_process
 * 说    明: 
 *      配置WiFi-AP模式，并开启WiFi-AP模式
 *      创建TCP服务端线程，监听客户端连接
 * 参    数: 无
 * 返 回 值: 无
 ***************************************************************/
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

    // Flash初始化
    FlashInit();
    // 配置RK2206为WiFi-AP模式，并设置WiFi路由器的SSID和密码
    VendorSet(VENDOR_ID_WIFI_MODE, wifi_mode, sizeof(wifi_mode));           // 配置为Wifi AP模式
    VendorSet(VENDOR_ID_MAC, mac_address, sizeof(mac_address));             // 配置MAC地址
    VendorSet(VENDOR_ID_WIFI_SSID, route_ssid, sizeof(route_ssid));         // 配置WiFi路由器的SSID
    VendorSet(VENDOR_ID_WIFI_PASSWD, route_passwd, sizeof(route_passwd));   // 配置WiFi路由器的密码
    // 开启WiFi-AP模式
    SetApModeOff();
    SetApModeOn();

    // 创建TCP服务端线程
    CreateThread(&threadID_server, wifi_tcp_server, NULL, "tcp_server");
}

/***************************************************************
 * 函数名称: wifi_ap_example
 * 说    明: 开机自动调用该函数，创建wifi_process线程
 * 参    数: 无
 * 返 回 值: 无
 ***************************************************************/
void wifi_ap_example(void)
{
    unsigned int ret = LOS_OK;
    unsigned int thread_id;
    TSK_INIT_PARAM_S task = {0};
    printf("%s start ....\n", __FUNCTION__);

    task.pfnTaskEntry = (TSK_ENTRY_FUNC)wifi_process;
    task.uwStackSize = 1024 * 128;
    task.pcName = "wifi_process";
    task.usTaskPrio = 24;
    ret = LOS_TaskCreate(&thread_id, &task);
    if (ret != LOS_OK)
    {
        printf("Falied to create wifi_process ret:0x%x\n", ret);
        return;
    }
}

APP_FEATURE_INIT(wifi_ap_example);