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

#include "iot_uart.h"
#include "iot_errno.h"

#include <stdio.h>

/* 串口0 */
#define UART_ID        EUART0_M0
#define STRING_MAXSIZE 128

/***************************************************************
 * 函数名称: uart_process
 * 说    明: 串口0任务
 * 参    数: 无
 * 返 回 值: 无
 ***************************************************************/
void uart_thread()
{
    unsigned int ret;
    IotUartAttribute attr;
    unsigned char str[]                       = "HelloWorld!";
    unsigned char recv_buffer[STRING_MAXSIZE] = {0};
    unsigned int recv_length                  = 0;

    IoTUartDeinit(UART_ID);

    attr.baudRate = 115200;
    attr.dataBits = IOT_UART_DATA_BIT_8;
    attr.pad      = IOT_FLOW_CTRL_NONE;
    attr.parity   = IOT_UART_PARITY_NONE;
    attr.rxBlock  = IOT_UART_BLOCK_STATE_NONE_BLOCK;
    attr.stopBits = IOT_UART_STOP_BIT_1;
    attr.txBlock  = IOT_UART_BLOCK_STATE_NONE_BLOCK;

    /* 初始化串口 */
    ret = IoTUartInit(UART_ID, &attr);
    if (ret != IOT_SUCCESS) {
        printf("%s, %d: IoTUartInit(%d) failed!\n", __FILE__, __LINE__, ret);
        return;
    }
    /* 休眠1秒 */
    LOS_Msleep(1000);

    while (1) {
        printf("%s, %d: uart write and str(%s), len(%d)!\n", __FILE__, __LINE__, str, strlen(str));
        // IoTUartWrite是异步发送，非阻塞发送
        IoTUartWrite(UART_ID, str, strlen(str));
        // 等待发送完毕
        LOS_Msleep(1000);

        recv_length = 0;
        memset(recv_buffer, 0, sizeof(recv_buffer));
        recv_length = IoTUartRead(UART_ID, recv_buffer, sizeof(recv_buffer));
        printf("%s, %d: uart recv and str(%s), len(%d)\n", __FILE__, __LINE__, recv_buffer, recv_length);

        /* 休眠1秒 */
        LOS_Msleep(1000);
    }
}

/***************************************************************
 * 函数名称: uart_example
 * 说    明: 开机自启动调用函数
 * 参    数: 无
 * 返 回 值: 无
 ***************************************************************/
void uart_example()
{
    unsigned int thread_id;
    TSK_INIT_PARAM_S task = {0};
    unsigned int ret      = LOS_OK;

    task.pfnTaskEntry = (TSK_ENTRY_FUNC)uart_thread;
    task.uwStackSize  = 2048;
    task.pcName       = "uart_thread";
    task.usTaskPrio   = 24;
    ret               = LOS_TaskCreate(&thread_id, &task);
    if (ret != LOS_OK) {
        printf("Falied to create uart_thread ret:0x%x\n", ret);
        return;
    }
}

APP_FEATURE_INIT(uart_example);
