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

/* GPIO0_PC5与按键相连 按下K1引脚电压0.06V左右 可作为下降沿触发 */
#define GPIO_TEST GPIO0_PC5

/* 按键按下次数 */
static uint16_t m_gpio_interrupt_count;

/***************************************************************
 * 函数名称: gpio_int_func
 * 说    明: gpio中断响应处理函数
 * 参    数: 无
 * 返 回 值: 无
 ***************************************************************/
void gpio_int_func()
{
    m_gpio_interrupt_count++;
}

/***************************************************************
 * 函数名称: gpio_int_thread
 * 说    明: gpio_int任务
 * 参    数: 无
 * 返 回 值: 无
 ***************************************************************/
void gpio_int_thread()
{
    unsigned int ret;

    /* 初始化引脚为GPIO */
    IoTGpioInit(GPIO_TEST);
    /* 引脚配置为输入 */
    IoTGpioSetDir(GPIO_TEST, IOT_GPIO_DIR_IN);
    /* 设置中断触发方式为下降沿和中断处理函数 */
    ret = IoTGpioRegisterIsrFunc(GPIO_TEST, IOT_INT_TYPE_EDGE, IOT_GPIO_EDGE_FALL_LEVEL_LOW, gpio_int_func, NULL);
    if (ret != IOT_SUCCESS) {
        printf("IoTGpioRegisterIsrFunc failed(%d)\n", ret);
        return;
    }
    /* 关闭中断屏蔽 */
    IoTGpioSetIsrMask(GPIO_TEST, FALSE);

    while (1) {
        printf("***************GPIO Interrupt Example*************\n");
        printf("gpio interrupt count = %d\n", m_gpio_interrupt_count);
        printf("\n");
        /* 睡眠1秒 */
        LOS_Msleep(1000);
    }
}

/***************************************************************
 * 函数名称: gpio_int_example
 * 说    明: 开机自启动调用函数
 * 参    数: 无
 * 返 回 值: 无
 ***************************************************************/
void gpio_int_example()
{
    unsigned int thread_id;
    TSK_INIT_PARAM_S task = {0};
    unsigned int ret      = LOS_OK;

    task.pfnTaskEntry = (TSK_ENTRY_FUNC)gpio_int_thread;
    task.uwStackSize  = 2048;
    task.pcName       = "gpio_int_thread";
    task.usTaskPrio   = 20;
    ret               = LOS_TaskCreate(&thread_id, &task);
    if (ret != LOS_OK) {
        printf("Falied to create gpio_int_thread ret:0x%x\n", ret);
        return;
    }
}

APP_FEATURE_INIT(gpio_int_example);