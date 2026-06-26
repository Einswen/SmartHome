/*******************************************************************************
 * Copyright (c) 2014 IBM Corp.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * and Eclipse Distribution License v1.0 which accompany this distribution.
 *
 * The Eclipse Public License is available at
 *    http://www.eclipse.org/legal/epl-v10.html
 * and the Eclipse Distribution License is available at
 *   http://www.eclipse.org/org/documents/edl-v10.php.
 *
 * Contributors:
 *    Ian Craggs - initial API and implementation and/or initial documentation
 *    Sergio R. Caprile - clarifications and/or documentation extension
 *******************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "los_task.h"

#include "cmsis_os2.h"
#include "ohos_init.h"

#include "MQTTClient.h"

#include "cJSON.h"

#include "lz_hardware.h"
#include "config_network.h"

#define ROUTE_SSID                      "lzdz"
#define ROUTE_PASSWORD                  "12345678"

static unsigned char sendBuf[1000];
static unsigned char readBuf[1000];

#define MQTT_DEVICES_PWD                    "12345678"

#define HOST_ADDR                           "117.78.16.25"

#define DEVICE_ID                           "kxcr3cahv44a-1763753349879955511_rk2206"

#define PUBLISH_TOPIC                       "$oc/devices/"DEVICE_ID"/sys/properties/report"
#define SUBCRIB_TOPIC                       "$oc/devices/"DEVICE_ID"/sys/commands/+" ///request_id={request_id}"
#define RESPONSE_TOPIC                      "$oc/devices/"DEVICE_ID"/sys/commands/response" ///request_id={request_id}"

Network network;
MQTTClient client;

void messageArrived(MessageData* data)
{
    int rc;
    printf("Message arrived on topic %.*s: %.*s\n", data->topicName->lenstring.len, data->topicName->lenstring.data,
           data->message->payloadlen, data->message->payload);

    //get request id
    char *request_id_idx=NULL;
    char request_id[20]={0};
    request_id_idx = strstr(data->topicName->lenstring.data,"request_id=");
    strncpy(request_id,request_id_idx+11,19);
    printf("request_id = %s\n",request_id);

    //create response topic
    char rsptopic[128]={0};
    sprintf(rsptopic,"%s/request_id=%s",RESPONSE_TOPIC,request_id);
    printf("rsptopic = %s\n",rsptopic);

    //response message
    MQTTMessage message;
    char payload[300];
    message.qos = 0;
    message.retained = 0;
    message.payload = payload;
    sprintf(payload, "{ \
    \"result_code\": 0, \
    \"response_name\": \"COMMAND_RESPONSE\", \
    \"paras\": { \
        \"result\": \"success\" \
    } \
    }" );
    message.payloadlen = strlen(payload);

    //publish the msg to responese topic
    if ((rc = MQTTPublish(&client, rsptopic, &message)) != 0) {
        printf("Return code from MQTT publish is %d\n", rc);
        NetworkDisconnect(&network);
        MQTTDisconnect(&client);
        
    }
    /*{"command_name":"cmd","paras":{"cmd_value":"1"},"service_id":"server"}*/
    cJSON *root = cJSON_ParseWithLength(data->message->payload, data->message->payloadlen);
    if (root != NULL) {
        cJSON *cmd_name = cJSON_GetObjectItem(root,"command_name");
        if (cmd_name != NULL) {
            char *cmd_name_str = cJSON_GetStringValue(cmd_name);

            if (strcmp(cmd_name_str,"下发参数") == 0) {
                 cJSON *para_obj = cJSON_GetObjectItem(root,"paras");
                 int speed;
                 if (para_obj) {
                    cJSON *level_obj = cJSON_GetObjectItem(para_obj,"参数值");
                    if (level_obj != NULL) {
                        speed = atoi(cJSON_GetStringValue(level_obj));
                        printf("参数值: %d\n",speed);
                    }
                }
            }
        }
    }

    cJSON_Delete(root);   
}

void mqttInit()
{
    int rc;
begin:
    /* 连接网络*/
    printf("NetworkConnect  ...\n");
    NetworkConnect(&network, HOST_ADDR, 1883);
    printf("MQTTClientInit  ...\n");
    /*MQTT客户端初始化*/
    MQTTClientInit(&client, &network, 2000, sendBuf, sizeof(sendBuf), readBuf, sizeof(readBuf));

    MQTTString clientId = MQTTString_initializer;
    clientId.cstring = DEVICE_ID;

    MQTTString userName = MQTTString_initializer;
    userName.cstring = DEVICE_ID;

    MQTTString password = MQTTString_initializer;
    password.cstring = MQTT_DEVICES_PWD;

    MQTTPacket_connectData data = MQTTPacket_connectData_initializer;
    data.clientID = clientId;
    data.username = userName;
    data.password = password;
    data.willFlag = 0;
    data.MQTTVersion = 4;
    data.keepAliveInterval = 60;
    data.cleansession = 1;

    printf("MQTTConnect  ...\n");
    rc = MQTTConnect(&client, &data);
    if (rc != 0) {
        printf("MQTTConnect: %d\n", rc);
        NetworkDisconnect(&network);
        MQTTDisconnect(&client);
        osDelay(200);
        goto begin;
    }

    printf("MQTTSubscribe  ...\n");
    rc = MQTTSubscribe(&client, SUBCRIB_TOPIC, 0, messageArrived);
    if (rc != 0) {
        printf("MQTTSubscribe: %d\n", rc);
        osDelay(200);
        goto begin;
    }
}

static void mqttTask(void)
{
    uint8_t hwaddr[6]  = {0x10, 0xdc, 0xb6, 0x90, 0x00, 0x00};
    int rc = 0;

    printf(">> mqttTask Set mac, ssid and passwd\n");
    FlashInit(); 
    VendorSet(VENDOR_ID_MAC,               hwaddr,         6);  // 多人同时做该实验，请修改各自不同的WiFi MAC地址
    VendorSet(VENDOR_ID_WIFI_ROUTE_SSID,   ROUTE_SSID,     sizeof(ROUTE_SSID));
    VendorSet(VENDOR_ID_WIFI_ROUTE_PASSWD, ROUTE_PASSWORD, sizeof(ROUTE_PASSWORD));
    
    printf(">> mqttTask ...\n");
    /*连接wifi*/
    SetWifiModeOn();

    printf("Starting ...\n");
    /*网络初始化*/
    NetworkInit(&network);

begin:
    mqttInit();

    while (1) {
        MQTTMessage message;
        char *publishtopic = PUBLISH_TOPIC;
        char payload[300] = {0};
        cJSON *root = cJSON_CreateObject();
        if(root != NULL){
            cJSON *serv_arr = cJSON_AddArrayToObject(root, "services");
            cJSON *arr_item = cJSON_CreateObject();
            cJSON_AddStringToObject(arr_item, "service_id", "server");
            cJSON *pro_obj = cJSON_CreateObject();
            cJSON_AddItemToObject(arr_item, "properties", pro_obj);
            cJSON_AddStringToObject(pro_obj, "状态值", "ON");
            cJSON_AddItemToArray(serv_arr, arr_item);

            char *palyload_str = cJSON_PrintUnformatted(root);
            strcpy(payload, palyload_str);

            cJSON_free(palyload_str);
            cJSON_Delete(root);
        }
     
        message.qos = 0;
        message.retained = 0;
        message.payload = payload;
        message.payloadlen = strlen(payload);

        if ((rc = MQTTPublish(&client, publishtopic, &message)) != 0) {
            printf("Return code from MQTT publish is %d\n", rc);
            NetworkDisconnect(&network);
            MQTTDisconnect(&client);
            goto begin;
        } else {
            printf("mqtt publish success:%s\n", payload);
        }
        /*阻塞至多5000ms,有消息下发则退出阻塞*/
        MQTTYield(&client, 5000);
    }
}    

static void TH_iot_cloud_example(void)
{
    unsigned int ret = LOS_OK;
    unsigned int thread_id;
    TSK_INIT_PARAM_S task = {0};

    task.pfnTaskEntry = (TSK_ENTRY_FUNC)mqttTask;
    task.uwStackSize = 10240;
    task.pcName = "mqttTask";
    task.usTaskPrio = 24;
    ret = LOS_TaskCreate(&thread_id, &task);
    if (ret != LOS_OK) {
        printf("Falied to create mqttTask ret:0x%x\n", ret);
        return;
    }
}

APP_FEATURE_INIT(TH_iot_cloud_example);
