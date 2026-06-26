/*
 * Copyright (c) 2025 FuZhou Lockzhiner Electronic Co., Ltd. All rights reserved.
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

#include "los_task.h"
#include "ohos_init.h"

#include "iot_gpio.h"
#include "iot_errno.h"

#include <stdio.h>

#define GPIO_TEST GPIO0_PA0

/***************************************************************
 * 函数名称: gpio_thread
 * 说    明: gpio任务
 * 参    数: 无
 * 返 回 值: 无
 ***************************************************************/
void gpio_thread()
{
    unsigned int cur   = 0;
    IotGpioValue value = IOT_GPIO_VALUE0;

    IoTGpioInit(GPIO_TEST);

    while (1) {
        printf("***************GPIO Example*************\r\n");
        printf("Write GPIO\n");
        IoTGpioSetDir(GPIO_TEST, IOT_GPIO_DIR_OUT);
        if (cur == 0) {
            IoTGpioSetOutputVal(GPIO_TEST, cur);
            IoTGpioGetOutputVal(GPIO_TEST, &value);
            printf("\tgpio set %d => gpio get %d\n", cur, value);
            cur = 1;
        } else {
            IoTGpioSetOutputVal(GPIO_TEST, cur);
            IoTGpioGetOutputVal(GPIO_TEST, &value);
            printf("\tgpio set %d => gpio get %d\n", cur, value);
            cur = 0;
        }
        /* 睡眠1秒 */
        LOS_Msleep(1000);

        printf("Read GPIO\n");
        IoTGpioSetDir(GPIO_TEST, IOT_GPIO_DIR_IN);
        IoTGpioGetInputVal(GPIO_TEST, &value);
        printf("\tgpio get %d\n", value);
        /* 睡眠1秒 */
        LOS_Msleep(1000);

        printf("\n");
    }
}

/***************************************************************
 * 函数名称: gpio_example
 * 说    明: 开机自启动调用函数
 * 参    数: 无
 * 返 回 值: 无
 ***************************************************************/
void gpio_example()
{
    unsigned int thread_id;
    TSK_INIT_PARAM_S task = {0};
    unsigned int ret      = LOS_OK;

    task.pfnTaskEntry = (TSK_ENTRY_FUNC)gpio_thread;
    task.uwStackSize  = 2048;
    task.pcName       = "gpio_thread";
    task.usTaskPrio   = 24;
    ret               = LOS_TaskCreate(&thread_id, &task);
    if (ret != LOS_OK) {
        printf("Falied to create gpio_thread ret:0x%x\n", ret);
        return;
    }
}

APP_FEATURE_INIT(gpio_example);
