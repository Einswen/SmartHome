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
#ifndef _CONFIG_WORK_H_
#define _CONFIG_WORK_H_

#include "wifi_device.h"
#include "wifi_hotspot.h"
#include "lwip/inet.h"
#include "stdbool.h"
#include "lz_hardware.h"

#ifdef __cplusplus
#if __cplusplus
extern "C" {
#endif /* __cpluscplus */
#endif /* __cpluscplus */

#define WIFI_SCAN_ON 0

typedef enum RK_BUTTOON_STATUS {
    AP_BUTTON_UP = 0,  /** UP mode */
    AP_BUTTON_DOWN = 1    /** DOWN mode */
} RKButtonStatus;

typedef struct RK_WIFI_CONFIG{
    char ssid[WIFI_MAX_SSID_LEN];
    char psk[WIFI_MAX_KEY_LEN];
    unsigned char bssid[WIFI_MAC_LEN];
} RKWifiConfig;

typedef struct RK_BOARD_CONFIG {
    char rkbc_head[4];    // head
    char rkbc_led_status;      // led status
    char rkbc_key_status[2]; // key status
    char rkbc_buzzer_status; // buzzer status
    char rkbc_light_status; // light status
    char rkbc_human_body_sensor_status; //human body sensor status
    char rkbc_gas_status; // gas status
    char rkbc_temperature_value[2]; // temperature value
    char rkbc_humidity_value[2]; // humidity value
    char rkbc_expand_data[16]; // expand data
} RKBoardConfig;

typedef struct RK_NETWORK_CONFIG {
    char rknc_head[4];    // head
    char rknc_ssid_length;      // ssid len
    char  rknc_psk_length; // password len
    char  rknc_data[]; // ssid data + password data
} RKNetworkConfig;

#define WIFI_MAX_SN_LEN             (VENDOR_ID_SIZE)
#define WIFI_MAX_LEN_SN             (VENDOR_ID_SIZE)
#define WIFI_MAX_LEN_PRODUCT        (VENDOR_ID_SIZE)
#define WIFI_MAX_LEN_FACTORY        (VENDOR_ID_SIZE)
#define WIFI_MAX_LEN_MODE           4
#define WIFI_MAX_LEN_MAC            6
#define WIFI_MAX_LEN_IP             4
#define WIFI_MAX_LEN_GATEWAY        4
#define WIFI_MAX_LEN_MASK           4
#define WIFI_MAX_LEN_AP_SSID        (WIFI_MAX_SSID_LEN)
#define WIFI_MAX_LEN_AP_PASSWD      (WIFI_MAX_KEY_LEN)
#define WIFI_MAX_LEN_ROUTE_SSID     (WIFI_MAX_SSID_LEN)
#define WIFI_MAX_LEN_ROUTE_PASSWD   (WIFI_MAX_KEY_LEN)

typedef struct 
{
    uint8_t sn[WIFI_MAX_LEN_SN];
    uint8_t product[WIFI_MAX_LEN_PRODUCT];
    uint8_t factory[WIFI_MAX_LEN_FACTORY];
    uint8_t mode[WIFI_MAX_LEN_MODE];
    uint8_t hwaddr[WIFI_MAX_LEN_MAC];
    uint8_t ip[WIFI_MAX_LEN_IP];
    uint8_t gateway[WIFI_MAX_LEN_GATEWAY];
    uint8_t mask[WIFI_MAX_LEN_MASK];
    uint8_t ssid[WIFI_MAX_LEN_AP_SSID];
    uint8_t password[WIFI_MAX_LEN_AP_PASSWD];
    uint8_t route_ssid[WIFI_MAX_LEN_ROUTE_SSID];
    uint8_t route_password[WIFI_MAX_LEN_ROUTE_PASSWD];
}wifi_config_t;
typedef int (*printf_fn)(const char *fmt, ...);
#define WIFI_CONFIG_KEY_SN              "sn"
#define WIFI_CONFIG_KEY_PRODUCT         "product"
#define WIFI_CONFIG_KEY_FACTORY         "factory"
#define WIFI_CONFIG_KEY_MODE            "mode"
#define WIFI_CONFIG_KEY_MAC             "mac"
#define WIFI_CONFIG_KEY_IP              "ip"
#define WIFI_CONFIG_KEY_GATEWAY         "gateway"
#define WIFI_CONFIG_KEY_MASK            "mask"
#define WIFI_CONFIG_KEY_AP_SSID         "ap_ssid"
#define WIFI_CONFIG_KEY_AP_PASSWD       "ap_passwd"
#define WIFI_CONFIG_KEY_ROUTE_SSID      "route_ssid"
#define WIFI_CONFIG_KEY_ROUTE_PASSWD    "route_passwd"

#define WIFI_CONFIG_KEY_MODE_AP         "AP"
#define WIFI_CONFIG_KEY_MODE_STA        "STA"

void set_default_wifi_config(void);
void set_wifi_config(wifi_config_t wifi_config);
void get_wifi_config(printf_fn pfn, wifi_config_t *wifi_config);
void set_wifi_config_mode(printf_fn pfn, uint8_t *md);
void set_wifi_config_mac(printf_fn pfn, uint8_t *mac);
void set_wifi_config_ip(printf_fn pfn, uint8_t *ip);
void set_wifi_config_gw(printf_fn pfn, uint8_t *gw);
void set_wifi_config_mask(printf_fn pfn, uint8_t *m);
void set_wifi_config_ssid(printf_fn pfn, uint8_t *s);
void set_wifi_config_passwd(printf_fn pfn, uint8_t *p);
void set_wifi_config_route_ssid(printf_fn pfn, uint8_t *s);
void set_wifi_config_route_passwd(printf_fn pfn, uint8_t *p);

WifiErrorCode SetApModeOn();
WifiErrorCode SetApModeOff();
WifiErrorCode SetWifiModeOff();
WifiErrorCode SetWifiModeOn();

UINT32 ExternalTaskConfigNetwork(VOID);
int ExternalSyncBCState(RKBoardConfig BCstate);
void ExternalSetButtonStatus(bool isdown);

#ifdef __cplusplus
#if __cplusplus
}
#endif /* __cpluscplus */
#endif /* __cpluscplus */
#endif // _CONFIG_WORK_H_
