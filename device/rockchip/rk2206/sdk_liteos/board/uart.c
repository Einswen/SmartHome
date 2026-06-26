/*
 * Copyright (c) 2020-2021 Huawei Device Co., Ltd.
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

#include <stdio.h>

#include "los_config.h"
#include "los_reg.h"
#include "los_interrupt.h"
#include "los_event.h"
#include "los_task.h"
#include "ohos_init.h"

#include "uart.h"
#include "lz_hardware.h"

#ifdef __cplusplus
#if __cplusplus
extern "C" {
#endif
#endif

#define UART_DEBUG_PORT     1       // 串口调试口，uart1
#define FIFO_MAXSIZE        1024    // 接收缓冲区大小
typedef struct tag_fifo {
    UINT32 write;
    UINT32 read;
    UINT32 size;
    UINT8 data[FIFO_MAXSIZE];
} fifo_t;

static fifo_t m_uart_recv_fifo;

static void task_uart_debug_recv_process()
{
    UINT8 data = 0;
    int ret = 0;
    int current = 0;
    int read_size = 0;

    while (1)
    {
        current++;
        if (current >= 1000)
        {
            //printf("UartDebugRecvProcess: current = %d, read_size = %d\n", current, read_size);
            current = 0;
        }

        ret = LzUartRead(UART_DEBUG_PORT, &data, 1);
        if (ret == 1)
        {
            read_size++;
            m_uart_recv_fifo.data[m_uart_recv_fifo.write] = data;
            m_uart_recv_fifo.write = (m_uart_recv_fifo.write + 1) % m_uart_recv_fifo.size;
#if (LOSCFG_USE_SHELL == 1)
            (VOID)LOS_EventWrite(&g_shellInputEvent, 0x1);
#endif
            //LzUartWrite(UART_DEBUG_PORT, &data, 1);
            continue;
        }

        LOS_Msleep(1);

    }
}

VOID UartDebugInit(VOID)
{
    unsigned int thread_id;
    TSK_INIT_PARAM_S task = {0};
    unsigned int ret = LOS_OK;

    m_uart_recv_fifo.size = FIFO_MAXSIZE;
    m_uart_recv_fifo.write = m_uart_recv_fifo.read = 0;

    task.pfnTaskEntry = (TSK_ENTRY_FUNC)task_uart_debug_recv_process;
    task.uwStackSize = 1024 * 128;
    task.pcName = "UartDebugRecvProcess";
    task.usTaskPrio = 3;
    ret = LOS_TaskCreate(&thread_id, &task);
    if (ret != LOS_OK)
    {
        printf("Falied to create Task_One ret:0x%x\n", ret);
        return;
    }
}

INT32 UartGetc(VOID)
{
    UINT8 data = 0;

    if (m_uart_recv_fifo.write == m_uart_recv_fifo.read) {
        return 0;
    }

    data = m_uart_recv_fifo.data[m_uart_recv_fifo.read];
    m_uart_recv_fifo.read = (m_uart_recv_fifo.read + 1) % m_uart_recv_fifo.size;

    return data;
}



#ifdef __cplusplus
#if __cplusplus
}
#endif // __cplusplus
#endif // __cplusplus