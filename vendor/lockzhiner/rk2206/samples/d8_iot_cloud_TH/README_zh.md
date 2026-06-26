# 小凌派-RK2206开发板OpenHarmonyOS开发-通鸿IoT平台的数据通讯

## 实验内容

本例程演示如何在小凌派-RK2206开发板上，对接通通鸿联网平台。

通鸿联网平台：http://117.78.16.25

![小凌派-RK2206开发板](/vendor/lockzhiner/rk2206/docs/figures/lockzhiner-rk2206.jpg)

## 程序设计

### 主要代码分析

在TH_iot_cloud_example函数中，通过LOS_TaskCreate创建mqttTask线程，线程主要上报状态到云平台和处理云平台下发命令。

```c
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
```

在mqttTask线程中，首先通过WIFI连接网络，进行网络初始化；网络初始化完成后，初始化MQTT服务，对接MQTT云平台；对接云平台成功后，周期向云平台上报设备的状态值。

```c
static void mqttTask(void)
{
    int rc = 0;

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
```

在mqttInit函数中，初始化MQTT服务，通过设备ID和设备密匙连接MQTT云平台；云平台连接成功后，注册消息解析函数。

```c
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
```

在messageArrived函数中，当接收到云平台下发的命令时，解析命令体，如果命令体正确，打印解析出的命令和命名内容。

```c
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
```

## 编译调试

### 登录云平台

设备连接云平台前，需要做一些准备工作，请获取云平台用户账号。

![登录云平台](/vendor/lockzhiner/rk2206/docs/figures/TH_cloud/login.png)

### 创建产品

选择侧边栏产品管理页面，点击右上角创建产品，在弹出的页面中创建产品，选择默认资源空间，填入产品名称、厂商名称和设备类型。

![创建产品](/vendor/lockzhiner/rk2206/docs/figures/TH_cloud/create_product.png)

点击进入新创建的产品详情页，点击添加服务，在弹出的页面中添加服务，填入服务ID。

服务ID：server(必须与代码一致)

![添加服务](/vendor/lockzhiner/rk2206/docs/figures/TH_cloud/add_server.png)

选择新添加的服务，点击添加属性，填入属性名称：状态值；选择枚举类型：ON，OFF。

![新增属性](/vendor/lockzhiner/rk2206/docs/figures/TH_cloud/add_properties.png)


选择服务，点击添加命令，添加控制命令，填入命令名称：下发参数。

![添加命令](/vendor/lockzhiner/rk2206/docs/figures/TH_cloud/add_cmd.png)

点击新增输入参数，填入参数名称：参数值。

![添加参数](/vendor/lockzhiner/rk2206/docs/figures/TH_cloud/add_param.png)

服务添加完成，产品详情页面可以查看到添加的属性和命令。

![添加服务完成](/vendor/lockzhiner/rk2206/docs/figures/TH_cloud/add_server_complete.png)

### 注册设备

选择侧边栏设备管理-我的设备页面，点击右上角注册设备，进入单设备注册页面，勾选对应所属资源空间并选中刚创建的产品，注意设备认证类型选择“密钥”，并按要求填写密钥，其中密钥必须与代码中的MQTT_DEVICES_PWD一致。

```c
#define MQTT_DEVICES_PWD    "12345678"
```

![注册设备](/vendor/lockzhiner/rk2206/docs/figures/TH_cloud/device.png)

注册完成后，点击进入设备详情页面，可以查看设备的详细信息；其中，设备ID用于区分不同设备，需要对应修改代码中的DEVICE_ID。

```c
#define DEVICE_ID "kxcr3cahv44a-1763753349879955511_rk2206"
```

![设备ID](/vendor/lockzhiner/rk2206/docs/figures/TH_cloud/device_id.png)


### WIFI连接

修改例程/device/rockchip/rk2206/sdk_liteos/board/main.c代码中，注释网络连接函数。

```c
LITE_OS_SEC_TEXT_INIT int Main(void)
{
    int ret;
    LZ_HARDWARE_LOGD(MAIN_TAG, "%s: enter ...", __func__);
    
    HalInit();

    ret = LOS_KernelInit();
    if (ret == LOS_OK) {
        OHOS_SystemInit();
        IotInit();
        /* 开启驱动管理服务 */
        //DeviceManagerStart();
        //ExternalTaskConfigNetwork();      // 注释该行。正常情况下，该行是注释，但请确认
        LZ_HARDWARE_LOGD(MAIN_TAG, "%s: LOS_Start ...", __func__);
        LOS_Start();
    }

    while (1) {
        __asm volatile("wfi");
    }
}
```

修改本案例的的ROUTE_SSID和ROUTE_PASSWORD为使用WIFI的SSID和密匙，用于连接网络，设备通过WIFI访问华为云。

```c
#define ROUTE_SSID                       "lzdz"
#define ROUTE_PASSWORD                   "12345678"
```

另外，如果同一个地方、同一个时间内有多人正在做开发板网络相关案例，请修改`mqttTask`的WiFi MAC地址，以免MAC地址冲突无法联网。

```c
{
    uint8_t hwaddr[6]  = {0x10, 0xdc, 0xb6, 0x90, 0x00, 0x00};	// 请修改该MAC地址
    ......
    FlashInit(); 
    VendorSet(VENDOR_ID_MAC,               hwaddr,         6);  // 多人同时做该实验，请修改各自不同的WiFi MAC地址
    VendorSet(VENDOR_ID_WIFI_ROUTE_SSID,   ROUTE_SSID,     sizeof(ROUTE_SSID));
    VendorSet(VENDOR_ID_WIFI_ROUTE_PASSWD, ROUTE_PASSWORD, sizeof(ROUTE_PASSWORD));
    SetWifiModeOn();
}
```

### 修改 BUILD.gn 文件

修改 `vendor/lockzhiner/rk2206/sample` 路径下 BUILD.gn 文件，指定 `d8_iot_cloud_TH` 参与编译。

```r
"./d8_iot_cloud_TH:iot_cloud_TH_example",
```

修改 `device/lockzhiner/rk2206/sdk_liteos` 路径下 Makefile 文件，添加 `-liot_cloud_TH_example` 参与编译。

```r
hardware_LIBS = -lhal_iothardware -lhardware -liot_cloud_TH_example
```

### 运行结果

例程代码编译烧写到开发板后，按下开发板的RESET按键，通过串口软件查看日志，串口打印如下信息，通过网络向平台发送设备状态值。

```
NetworkConnect  ...
MQTTClientInit  ...
MQTTConnect  ...
mqtt publish success:{"services":[{"service_id":"server","properties":{"状态值":"ON"}}]}
```

登录平台，选择侧边栏设备管理-我的设备页面，点击进入rk2206设备页面，查看设备上报状态。

![TH IOT](/vendor/lockzhiner/rk2206/docs/figures/TH_cloud/TH_iot.png)

设备详情页面，点击选择命令界面，选择命令下发，选择命令：server：下发参数，填入参数值，点击确定。

![命令下发](/vendor/lockzhiner/rk2206/docs/figures/TH_cloud/TH_iot_cmd.png)

串口打印如下信息，说明成功接收平台下发命令。

```
Message arrived on topic $oc/devices/o2vcxvqvtcxs-1763515131473428504_rk2206_d1/sys/commands/request_id=1763746754794094618: {"command_name":"下发参数","paras":{"参数值":"123"},"service_id":"server"}
request_id = 1763746754794094618
rsptopic = $oc/devices/o2vcxvqvtcxs-1763515131473428504_rk2206_d1/sys/commands/response/request_id=1763746754794094618

参数值: 123
```
