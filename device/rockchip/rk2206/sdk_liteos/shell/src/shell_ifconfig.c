#include <stddef.h>
#include <string.h>
#include <securec.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

#include "lwip/if_api.h"
#include "lwip/netifapi.h"
#include "wifi_device.h"
#include "wifi_hotspot_config.h"

#include "los_tick.h"
#include "los_task.h"
#include "los_config.h"
#include "los_interrupt.h"
#include "los_debug.h"
#include "los_compiler.h"

#include "config_network.h"
#include "lz_hardware.h"

#if (LOGCFG_SHELL == 1)
#include "shcmd.h"
#include "shell.h"
#endif // LOGCFG_SHELL

#define DEBUG_PRINT 0

static void shell_ifconfig_wlan0_up(void)
{
    uint8_t mac_address[] = {0x10, 0x25, 0x5A, 0x92, 0x11, 0xEA};
    uint8_t id_buf[6] = {0};

    /* 获取 rk2206 id */
    uint8_t r = LzEfuseRead(21, 5, id_buf);
    if (r == 5)
    {
        /* 以芯片的唯一 id 作为 mac 地址 */
        /* 注意：同一个网路下不能有多个一致的 mac 地址 */
        memcpy(&mac_address[1], id_buf, 5);
    }
    set_wifi_config_mode(NULL, (uint8_t *)"STA");
    set_wifi_config_mac(NULL, mac_address);
    SetWifiModeOff();
    SetWifiModeOn();
}

static void shell_ifconfig_wlan0_down(void)
{
    SetWifiModeOff();
}

static void shell_ifconfig_wlan0_info(void)
{
    WifiLinkedInfo wifi_info = {0};
    int gw, netmask;

    // 获取WiFi连接信息
    if ((GetLinkedInfo(&wifi_info) == WIFI_SUCCESS) && (wifi_info.connState == WIFI_CONNECTED) && (wifi_info.ipAddress != 0))
    {
        printf("wlan0: ");
        printf("inet %s", inet_ntoa(wifi_info.ipAddress));
        if (GetLocalWifiNetmask(&netmask) == WIFI_SUCCESS)
        {
            printf("  netmask %s", inet_ntoa(netmask));
        }
        if (GetLocalWifiGw(&gw) == WIFI_SUCCESS)
        {
            printf("  gateway %s", inet_ntoa(gw));
        }
        printf("\r\n");
    }
    else
    {
        printf("wlan0 is no connected\r\n");
    }
}

static void shell_ifconfig_help(void)
{
    printf("Usage: ifconfig <interface> [up|down]\r\n   \
    [ssid <ssid>] [password <password>]\r\n  \
    \r\nExample:\r\n  \
    ifconfig wlan0 up\r\n  \
    ifconfig wlan0 down\r\n  \
    ifconfig wlan0 ssid <ssid> password <password>\r\n  \
    ifconfig -h\r\n  \
    ifconfig help\r\n");
}

// 查看IP地址
int shell_ifconfig(int argc, const char *argv[])
{
#if DEBUG_PRINT
    printf("argc = %d\r\n", argc);
    for (uint8_t i = 0; i < argc; i++)
    {
        printf("argv[%d] = %s\r\n", i, argv[i]);
    }
#endif

    if (argc == 1)
    {
        shell_ifconfig_wlan0_info();
    }
    else if (argc == 2)
    {
        if (strcmp(argv[1], "wlan0") == 0)
        {
            shell_ifconfig_wlan0_info();
        }
        else if ((strcmp(argv[1], "-h") == 0) || (strcmp(argv[1], "help") == 0))
        {
            shell_ifconfig_help();
        }
        else
        {
            shell_ifconfig_help();
        }
    }
    else if (argc == 3)
    {
        if (strcmp(argv[1], "wlan0") == 0)
        {
            if (strcmp(argv[2], "up") == 0)
            {
                shell_ifconfig_wlan0_up();
            }
            else if (strcmp(argv[2], "down") == 0)
            {
                shell_ifconfig_wlan0_down();
            }
        }
        else
        {
            shell_ifconfig_help();
        }
    }
    else if (argc == 6)
    {
        if (strcmp(argv[1], "wlan0") == 0)
        {
            if ((strcmp(argv[2], "ssid") == 0) && (strcmp(argv[4], "password") == 0))
            {
                set_wifi_config_route_ssid(NULL, (uint8_t *)argv[3]);
                set_wifi_config_route_passwd(NULL, (uint8_t *)argv[5]);
                printf("wlan0 config success\r\n");
            }
        }
        else
        {
            shell_ifconfig_help();
        }
    }

    return 0;
}
