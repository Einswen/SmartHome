#include "shell_tcp.h"

#include <arpa/inet.h>

#include "log.h"
#include "kv_store.h"

#define TCP_CLIENT_IP_KEY   "tcp_client_ip"
#define TCP_CLIENT_PORT_KEY "tcp_client_port"

static bool is_valid_ip_format(const char *ip)
{
    int dots        = 0;
    const char *ptr = ip;

    // 检查是否包含3个点号
    while (*ptr) {
        if (*ptr == '.') dots++;
        ptr++;
    }
    if (dots != 3) {
        return false;
    }

    // 检查每个部分是否为数字且没有前导零（除了0本身）
    char copy[16];
    strncpy(copy, ip, sizeof(copy) - 1);
    copy[sizeof(copy) - 1] = '\0';

    char *part = strtok(copy, ".");
    while (part != NULL) {
        // 空部分
        if (*part == '\0') return false;

        // 检查是否为纯数字
        for (char *p = part; *p; p++) {
            if (!isdigit((unsigned char)*p)) return false;
        }

        // 检查前导零
        if (strlen(part) > 1 && part[0] == '0') return false;

        // 检查数值范围
        int num = atoi(part);
        if (num < 0 || num > 255) return false;

        part = strtok(NULL, ".");
    }

    return true;
}

static bool ip_check(const uint8_t *ip)
{
    if (!is_valid_ip_format(ip)) {
        LOG_ERROR("Incorrect ip address format! Ip: %s.", ip);
        return false;
    }

    struct in_addr addr;
    if (!(inet_pton(AF_INET, ip, &addr) == 1)) {
        LOG_ERROR("Incorrect ip address! Ip: %s.");
        return false;
    }

    return true;
}

static bool port_check(uint32_t port)
{
    if (port < 0 || port > 65535) {
        LOG_ERROR("Incorrect port! Port: %d.", port);
        return false;
    }

    return true;
}

static void shell_tcp_help()
{
    printf("Example:\r\n \
    tcp help\r\n \
    tcp client ip <ip>\r\n \
    tcp client port <port>\r\n \
    tcp client ip <ip> port <port>\r\n \
    \r\n");
}

static void shell_two_argc(const uint8_t **argv)
{
    if (strcmp(argv[0], "help") == 0) {
        shell_tcp_help();
    } else {
        shell_tcp_help();
    }
}

static void shell_four_argc(const uint8_t **argv)
{
    if (strcmp(argv[0], "client") == 0) {
        if (strcmp(argv[1], "ip") == 0) {
            if (!ip_check(argv[2])) {
                return;
            }
            uint32_t ret = UtilsSetValue(TCP_CLIENT_IP_KEY, argv[2]);
            if (ret < 0) {
                LOG_ERROR("Client config failed! Ip: %s.", argv[2]);
            } else {
                LOG_INFO("Client config success! Ip: %s. Restart the device to take effect!", argv[2]);
            }
        } else if (strcmp(argv[1], "port") == 0) {
            if (!port_check(atoi(argv[2]))) {
                return;
            }
            uint32_t ret = UtilsSetValue(TCP_CLIENT_PORT_KEY, argv[2]);
            if (ret < 0) {
                LOG_ERROR("Client config failed! Port: %s.", argv[2]);
            } else {
                LOG_INFO("Client config success! Port: %s. Restart the device to take effect!", argv[2]);
            }
        } else {
            shell_tcp_help();
        }
    } else {
        shell_tcp_help();
    }
}

static void shell_six_argc(const uint8_t **argv)
{
    if (strcmp(argv[0], "client") == 0) {
        if ((strcmp(argv[1], "ip") == 0) && (strcmp(argv[3], "port") == 0)) {
            if (!ip_check(argv[2]) || !port_check(atoi(argv[4]))) {
                return;
            }
            uint32_t ret = UtilsSetValue(TCP_CLIENT_IP_KEY, argv[2]);
            if (ret < 0) {
                LOG_ERROR("Client config failed! Ip: %s Port: %s.", argv[2], argv[4]);
                return;
            }
            ret = UtilsSetValue(TCP_CLIENT_PORT_KEY, argv[4]);
            if (ret < 0) {
                LOG_ERROR("Client config failed! Ip: %s Port: %s.", argv[2], argv[4]);
                return;
            }
            LOG_INFO("Client config success! Ip: %s Port: %s. Restart the device to take effect!", argv[2], argv[4]);
        } else {
            shell_tcp_help();
        }
    } else {
        shell_tcp_help();
    }
}

uint32_t shell_tcp(uint32_t argc, const uint8_t **argv)
{
    switch (argc) {
        case 2:
            shell_two_argc(&argv[1]);
            break;
        case 4:
            shell_four_argc(&argv[1]);
            break;
        case 6:
            shell_six_argc(&argv[1]);
            break;
        default:
            shell_tcp_help();
            break;
    }
}