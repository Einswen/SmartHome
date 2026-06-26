#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <getopt.h>

#include <string.h>
#include <securec.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <sys/stat.h>
#include "cJSON.h"
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

#define TAG                 "hwinfo"

#define ARGV_GET            "get"
#define ARGV_SET            "set"
#define ARGV_INIT           "init"

enum enum_hwinfo_operator
{
    E_HWINFO_GET = 0,
    E_HWINFO_SET,
    E_HWINFO_INIT,
    E_HWINFO_MAX
};
static int m_hwinfo_op = E_HWINFO_GET;
static char *m_str_key = NULL;
static char *m_str_value = NULL;

static void hwinfo_usage(const char *cmd)
{
    printf("%s: set/get/init hardware information\n", cmd);
    printf("%s [options]...\n", cmd);
    printf("%s                     => show all hardware information\n", cmd);
    printf("%s get                 => show hardware information by key\n", cmd);
    printf("%s set key value       => set hardware information by key\n", cmd);
    printf("             sn        => device sn\n");
    printf("             product   => device product id\n");
    printf("             ......\n");
    printf("\n");
}

static int parse_opt(int argc, const char *argv[])
{
    if (argc == 1)
    {
        m_hwinfo_op = E_HWINFO_GET;
        return 0;
    }
    else if ((argc == 2) && strncmp(argv[1], ARGV_GET, strlen(ARGV_GET)) == 0)
    {
        m_hwinfo_op = E_HWINFO_GET;
        return 0;
    }
    else if ((argc == 2) && (strncmp(argv[1], ARGV_INIT, strlen(ARGV_INIT)) == 0))
    {
        m_hwinfo_op = E_HWINFO_INIT;
        return 0;
    }
    else if ((argc == 4) && (strncmp(argv[1], ARGV_SET, strlen(ARGV_SET)) == 0))
    {
        m_hwinfo_op = E_HWINFO_SET;
        m_str_key = argv[2];
        m_str_value = argv[3];
        return 0;
    }
    else
    {
        hwinfo_usage(argv[0]);
        return -1;
    }

    return 0;
}



int shell_hwinfo(int argc, const char *argv[])
{
    wifi_config_t config;
    
    m_hwinfo_op = E_HWINFO_GET;
    m_str_key = NULL;
    m_str_value = NULL;
    if (parse_opt(argc, argv) != 0)
    {
        return __LINE__;
    }
    
    switch (m_hwinfo_op)
    {
    case E_HWINFO_SET:
        if (m_str_key == NULL || m_str_value == NULL)
        {
            hwinfo_usage(argv[0]);
            return __LINE__;
        }
        memset(&config, 0, sizeof(config));
        get_wifi_config(NULL, &config);
        if (strncmp(m_str_key, WIFI_CONFIG_KEY_SN, strlen(WIFI_CONFIG_KEY_SN)) == 0)
        {
            printf("%s, %d: 1\n", __func__, __LINE__);
            memset(config.sn, 0, sizeof(config.sn));
            snprintf(config.sn, sizeof(config.sn), "%s", m_str_value);
        }
        else if (strncmp(m_str_key, WIFI_CONFIG_KEY_PRODUCT, strlen(WIFI_CONFIG_KEY_PRODUCT)) == 0)
        {
            memset(config.product, 0, sizeof(config.product));
            snprintf(config.product, sizeof(config.product), "%s", m_str_value);
        }
        else if (strncmp(m_str_key, WIFI_CONFIG_KEY_FACTORY, strlen(WIFI_CONFIG_KEY_FACTORY)) == 0)
        {
            memset(config.factory, 0, sizeof(config.factory));
            snprintf(config.factory, sizeof(config.factory), "%s", m_str_value);
        }
        else if (strncmp(m_str_key, WIFI_CONFIG_KEY_MODE, strlen(WIFI_CONFIG_KEY_MODE)) == 0)
        {
            if (strncmp(m_str_value, WIFI_CONFIG_KEY_MODE_AP, strlen(WIFI_CONFIG_KEY_MODE_AP)) == 0
                    && strncmp(config.mode, WIFI_CONFIG_KEY_MODE_STA, strlen(WIFI_CONFIG_KEY_MODE_STA)) == 0)
            {
                hwinfo_usage(argv[0]);
                return __LINE__;
            }
            else
            {
                memset(config.mode, 0, sizeof(config.mode));
                snprintf(config.mode, sizeof(config.mode), "%s", m_str_value);
            }
        }
        else if (strncmp(m_str_key, WIFI_CONFIG_KEY_MAC, strlen(WIFI_CONFIG_KEY_MAC)) == 0)
        {
            uint8_t mac[WIFI_MAX_LEN_MAC] = { 0 };
            int ret = sscanf(m_str_value, "%02x:%02x:%02x:%02x:%02x:%02x",
                             &mac[0], &mac[1], &mac[2], &mac[3], &mac[4], &mac[5]);
            if (ret != WIFI_MAX_LEN_MAC)
            {
                LZ_HARDWARE_LOGE(TAG, "%s, %d, mac format error, ret = %d, mac(%s)\n", __func__, __LINE__, ret, m_str_value);
                return __LINE__;
            }
            memset(config.hwaddr, 0, sizeof(config.hwaddr));
            memcpy(config.hwaddr, mac, sizeof(config.hwaddr));
        }
        else if (strncmp(m_str_key, WIFI_CONFIG_KEY_IP, strlen(WIFI_CONFIG_KEY_IP)) == 0)
        {
            uint8_t ip[WIFI_MAX_LEN_IP] = { 0 };
            int ret = sscanf(m_str_value, "%d.%d.%d.%d", &ip[0], &ip[1], &ip[2], &ip[3]);
            if (ret != WIFI_MAX_LEN_IP)
            {
                LZ_HARDWARE_LOGE(TAG, "%s, %d, ip format error, ret = %d, ip(%s)\n", __func__, __LINE__, ret, m_str_value);
                return __LINE__;
            }
            memset(config.ip, 0, sizeof(config.ip));
            memcpy(config.ip, ip, sizeof(config.ip));
        }
        else if (strncmp(m_str_key, WIFI_CONFIG_KEY_GATEWAY, strlen(WIFI_CONFIG_KEY_GATEWAY)) == 0)
        {
            uint8_t gateway[WIFI_MAX_LEN_GATEWAY] = { 0 };
            int ret = sscanf(m_str_value, "%d.%d.%d.%d", &gateway[0], &gateway[1], &gateway[2], &gateway[3]);
            if (ret != WIFI_MAX_LEN_GATEWAY)
            {
                LZ_HARDWARE_LOGE(TAG, "%s, %d, gateway format error\n", __func__, __LINE__);
                return __LINE__;
            }
            memset(config.gateway, 0, sizeof(config.gateway));
            memcpy(config.gateway, gateway, sizeof(config.gateway));
        }
        else if (strncmp(m_str_key, WIFI_CONFIG_KEY_MASK, strlen(WIFI_CONFIG_KEY_MASK)) == 0)
        {
            uint8_t mask[WIFI_MAX_LEN_MASK] = { 0 };
            int ret = sscanf(m_str_value, "%d.%d.%d.%d", &mask[0], &mask[1], &mask[2], &mask[3]);
            if (ret != WIFI_MAX_LEN_MASK)
            {
                LZ_HARDWARE_LOGE(TAG, "%s, %d, mask format error\n", __func__, __LINE__);
                return __LINE__;
            }
            memset(config.mask, 0, sizeof(config.mask));
            memcpy(config.mask, mask, sizeof(config.mask));
        }
        else if (strncmp(m_str_key, WIFI_CONFIG_KEY_AP_SSID, strlen(WIFI_CONFIG_KEY_AP_SSID)) == 0)
        {
            memset(config.ssid, 0, sizeof(config.ssid));
            snprintf(config.ssid, sizeof(config.ssid), "%s", m_str_value);
        }
        else if (strncmp(m_str_key, WIFI_CONFIG_KEY_AP_PASSWD, strlen(WIFI_CONFIG_KEY_AP_PASSWD)) == 0)
        {
            memset(config.password, 0, sizeof(config.password));
            snprintf(config.password, sizeof(config.password), "%s", m_str_value);
        }
        else if (strncmp(m_str_key, WIFI_CONFIG_KEY_ROUTE_SSID, strlen(WIFI_CONFIG_KEY_ROUTE_SSID)) == 0)
        {
            memset(config.route_ssid, 0, sizeof(config.route_ssid));
            snprintf(config.route_ssid, sizeof(config.route_ssid), "%s", m_str_value);
        }
        else if (strncmp(m_str_key, WIFI_CONFIG_KEY_ROUTE_PASSWD, strlen(WIFI_CONFIG_KEY_ROUTE_PASSWD)) == 0)
        {
            memset(config.route_password, 0, sizeof(config.route_password));
            snprintf(config.route_password, sizeof(config.route_password), "%s", m_str_value);
        }
        else
        {
            LZ_HARDWARE_LOGE(TAG, "%s, %d, key(%s) error\n", __func__, __LINE__, m_str_key);
            return __LINE__;
        }
        set_wifi_config(config);
        memset(&config, 0, sizeof(config));
        get_wifi_config(printf, &config);
        break;
        
    case E_HWINFO_INIT:
        set_default_wifi_config();
        memset(&config, 0, sizeof(config));
        get_wifi_config(printf, &config);
        break;
        
    default:
        memset(&config, 0, sizeof(config));
        get_wifi_config(printf, &config);
        break;
    }
    
    return 0;
}

