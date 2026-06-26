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

#include "iot_adc.h"
#include "iot_errno.h"

#include <stdio.h>

/* 定义ADC的通道号 */
#define ADC_CHANNEL 5

/***************************************************************
 * 函数名称: adc_thread
 * 说    明: ADC采集循环任务
 * 参    数: 无
 * 返 回 值: 无
 ***************************************************************/
void adc_thread()
{
    unsigned int data = 0;
    float voltage     = 0;
    unsigned int ret  = 0;

    /* 初始化adc设备 */
    ret = IoTAdcInit(ADC_CHANNEL);
    if (ret == IOT_FAILURE) {
        printf("%s, %s, %d: ADC Key IO Init fail\n", __FILE__, __func__, __LINE__);
    }

    while (1) {
        printf("***************Adc Example*************\r\n");
        /*获取电压值*/
        ret = IoTAdcGetVal(ADC_CHANNEL, &data);
        if (ret == IOT_FAILURE) {
            printf("%s, %s, %d: ADC Read Fail\n", __FILE__, __func__, __LINE__);
            return 0.0;
        }
        voltage = (float)(data * 3.3 / 1024.0);
        printf("vlt:%.3fV\n", voltage);

        /* 睡眠1秒 */
        LOS_Msleep(1000);
    }
}

/***************************************************************
 * 函数名称: adc_example
 * 说    明: 开机自启动调用函数
 * 参    数: 无
 * 返 回 值: 无
 ***************************************************************/
void adc_example()
{
    unsigned int thread_id;
    TSK_INIT_PARAM_S task = {0};
    unsigned int ret      = LOS_OK;

    task.pfnTaskEntry = (TSK_ENTRY_FUNC)adc_thread;
    task.uwStackSize  = 2048;
    task.pcName       = "adc_thread";
    task.usTaskPrio   = 24;
    ret               = LOS_TaskCreate(&thread_id, &task);
    if (ret != LOS_OK) {
        printf("Falied to create adc_thread ret:0x%x\n", ret);
        return;
    }
}

APP_FEATURE_INIT(adc_example);