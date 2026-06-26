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

#include "iot_errno.h"
#include "iot_uart.h"
#include "lz_hardware.h"

struct UartBusInfo
{
    unsigned int id;
    UartBusIo uart_bus;
};

static struct UartBusInfo m_uart_bus_info[EUARTDEV_MAX] = {
    [EUART1_M1] = {
        .id = 1,
        .uart_bus = {
            .rx = {.gpio = GPIO0_PA6, .func = MUX_FUNC3, .type = PULL_UP, .drv = DRIVE_KEEP, .dir = LZGPIO_DIR_KEEP, .val = LZGPIO_LEVEL_KEEP},
            .tx = {.gpio = GPIO0_PA7, .func = MUX_FUNC3, .type = PULL_UP, .drv = DRIVE_KEEP, .dir = LZGPIO_DIR_KEEP, .val = LZGPIO_LEVEL_KEEP},
            .ctsn = {.gpio = INVALID_GPIO, .func = MUX_FUNC3, .type = PULL_UP, .drv = DRIVE_KEEP, .dir = LZGPIO_DIR_KEEP, .val = LZGPIO_LEVEL_KEEP},
            .rtsn = {.gpio = INVALID_GPIO, .func = MUX_FUNC3, .type = PULL_UP, .drv = DRIVE_KEEP, .dir = LZGPIO_DIR_KEEP, .val = LZGPIO_LEVEL_KEEP},
            .id = FUNC_ID_UART1,
            .mode = FUNC_MODE_M1,
        },
    },
    [EUART2_M1] = {
        .id = 2,
        .uart_bus = {
            .rx = {.gpio = GPIO0_PB2, .func = MUX_FUNC3, .type = PULL_UP, .drv = DRIVE_KEEP, .dir = LZGPIO_DIR_KEEP, .val = LZGPIO_LEVEL_KEEP},
            .tx = {.gpio = GPIO0_PB3, .func = MUX_FUNC3, .type = PULL_UP, .drv = DRIVE_KEEP, .dir = LZGPIO_DIR_KEEP, .val = LZGPIO_LEVEL_KEEP},
            .ctsn = {.gpio = INVALID_GPIO, .func = MUX_FUNC3, .type = PULL_UP, .drv = DRIVE_KEEP, .dir = LZGPIO_DIR_KEEP, .val = LZGPIO_LEVEL_KEEP},
            .rtsn = {.gpio = INVALID_GPIO, .func = MUX_FUNC3, .type = PULL_UP, .drv = DRIVE_KEEP, .dir = LZGPIO_DIR_KEEP, .val = LZGPIO_LEVEL_KEEP},
            .id = FUNC_ID_UART2,
            .mode = FUNC_MODE_M1,
        },
    },
    [EUART0_M0] = {
        .id = 0,
        .uart_bus = {
            .rx = {.gpio = GPIO0_PB6, .func = MUX_FUNC2, .type = PULL_UP, .drv = DRIVE_KEEP, .dir = LZGPIO_DIR_KEEP, .val = LZGPIO_LEVEL_KEEP},
            .tx = {.gpio = GPIO0_PB7, .func = MUX_FUNC2, .type = PULL_UP, .drv = DRIVE_KEEP, .dir = LZGPIO_DIR_KEEP, .val = LZGPIO_LEVEL_KEEP},
            .ctsn = {.gpio = INVALID_GPIO, .func = MUX_FUNC2, .type = PULL_UP, .drv = DRIVE_KEEP, .dir = LZGPIO_DIR_KEEP, .val = LZGPIO_LEVEL_KEEP},
            .rtsn = {.gpio = INVALID_GPIO, .func = MUX_FUNC2, .type = PULL_UP, .drv = DRIVE_KEEP, .dir = LZGPIO_DIR_KEEP, .val = LZGPIO_LEVEL_KEEP},
            .id = FUNC_ID_UART0,
            .mode = FUNC_MODE_M0,
        },
    },
    [EUART1_M0] = {
        .id = 1,
        .uart_bus = {
            .rx = {.gpio = GPIO0_PC2, .func = MUX_FUNC3, .type = PULL_UP, .drv = DRIVE_KEEP, .dir = LZGPIO_DIR_KEEP, .val = LZGPIO_LEVEL_KEEP},
            .tx = {.gpio = GPIO0_PC3, .func = MUX_FUNC3, .type = PULL_UP, .drv = DRIVE_KEEP, .dir = LZGPIO_DIR_KEEP, .val = LZGPIO_LEVEL_KEEP},
            .ctsn = {.gpio = INVALID_GPIO, .func = MUX_FUNC3, .type = PULL_UP, .drv = DRIVE_KEEP, .dir = LZGPIO_DIR_KEEP, .val = LZGPIO_LEVEL_KEEP},
            .rtsn = {.gpio = INVALID_GPIO, .func = MUX_FUNC3, .type = PULL_UP, .drv = DRIVE_KEEP, .dir = LZGPIO_DIR_KEEP, .val = LZGPIO_LEVEL_KEEP},
            .id = FUNC_ID_UART1,
            .mode = FUNC_MODE_M0,
        },
    },
    [EUART0_M1] = {
        .id = 0,
        .uart_bus = {
            .rx = {.gpio = GPIO0_PC6, .func = MUX_FUNC3, .type = PULL_UP, .drv = DRIVE_KEEP, .dir = LZGPIO_DIR_KEEP, .val = LZGPIO_LEVEL_KEEP},
            .tx = {.gpio = GPIO0_PC7, .func = MUX_FUNC3, .type = PULL_UP, .drv = DRIVE_KEEP, .dir = LZGPIO_DIR_KEEP, .val = LZGPIO_LEVEL_KEEP},
            .ctsn = {.gpio = INVALID_GPIO, .func = MUX_FUNC3, .type = PULL_UP, .drv = DRIVE_KEEP, .dir = LZGPIO_DIR_KEEP, .val = LZGPIO_LEVEL_KEEP},
            .rtsn = {.gpio = INVALID_GPIO, .func = MUX_FUNC3, .type = PULL_UP, .drv = DRIVE_KEEP, .dir = LZGPIO_DIR_KEEP, .val = LZGPIO_LEVEL_KEEP},
            .id = FUNC_ID_UART0,
            .mode = FUNC_MODE_M1,
        },
    },
};

unsigned int IoTUartInit(unsigned int id, const IotUartAttribute *param)
{
    unsigned int ret = 0;
    UartAttribute *temp_prt = (const UartAttribute *)param;

    if (id >= EUARTDEV_MAX)
    {
        PRINT_ERR("id(%d) >= EUARTDEV_MAX(%d)\n", id, EUARTDEV_MAX);
        return IOT_FAILURE;
    }

    PinctrlSet(m_uart_bus_info[id].uart_bus.rx.gpio, m_uart_bus_info[id].uart_bus.rx.func, m_uart_bus_info[id].uart_bus.rx.type, m_uart_bus_info[id].uart_bus.rx.drv);
    PinctrlSet(m_uart_bus_info[id].uart_bus.tx.gpio, m_uart_bus_info[id].uart_bus.tx.func, m_uart_bus_info[id].uart_bus.tx.type, m_uart_bus_info[id].uart_bus.tx.drv);

    if (param->parity == IOT_UART_PARITY_NONE)
    {
        temp_prt->parity = UART_PARITY_NONE;
    }
    else if (param->parity == IOT_UART_PARITY_EVEN)
    {
        temp_prt->parity = UART_PARITY_EVEN;
    }
    else if (param->parity == IOT_UART_PARITY_ODD)
    {
        temp_prt->parity = UART_PARITY_ODD;
    }

    if (m_uart_bus_info[id].id == 0)
    {
        LzUartDeinit(m_uart_bus_info[id].id);
        uint32_t *pUart0 = (uint32_t *)(0x40070000U);
        HAL_UART_DeInit(pUart0);
    }

    ret = LzUartInit(m_uart_bus_info[id].id, temp_prt);
    if (ret != LZ_HARDWARE_SUCCESS)
    {
        return IOT_FAILURE;
    }

    return IOT_SUCCESS;
}

int IoTUartRead(unsigned int id, unsigned char *data, unsigned int dataLen)
{
    unsigned int ret = 0;

    if (id >= EUARTDEV_MAX)
    {
        PRINT_ERR("id(%d) >= EUARTDEV_MAX(%d)\n", id, EUARTDEV_MAX);
        return IOT_FAILURE;
    }

    ret = LzUartRead(m_uart_bus_info[id].id, data, dataLen);

    return ret;
}

int IoTUartWrite(unsigned int id, const unsigned char *data, unsigned int dataLen)
{
    unsigned int ret = 0;

    if (id >= EUARTDEV_MAX)
    {
        PRINT_ERR("id(%d) >= EUARTDEV_MAX(%d)\n", id, EUARTDEV_MAX);
        return IOT_FAILURE;
    }

    ret = LzUartWrite(m_uart_bus_info[id].id, data, dataLen);
    if (ret != LZ_HARDWARE_SUCCESS)
    {
        return IOT_FAILURE;
    }

    return IOT_SUCCESS;
}

unsigned int IoTUartDeinit(unsigned int id)
{
    unsigned int ret = 0;

    if (id >= EUARTDEV_MAX)
    {
        PRINT_ERR("id(%d) >= EUARTDEV_MAX(%d)\n", id, EUARTDEV_MAX);
        return IOT_FAILURE;
    }

    ret = LzUartDeinit(m_uart_bus_info[id].id);
    if (ret != LZ_HARDWARE_SUCCESS)
    {
        return IOT_FAILURE;
    }

    return IOT_SUCCESS;
}

unsigned int IoTUartSetFlowCtrl(unsigned int id, IotFlowCtrl flowCtrl)
{
    unsigned int ret = 0;

    if (id >= EUARTDEV_MAX)
    {
        PRINT_ERR("id(%d) >= EUARTDEV_MAX(%d)\n", id, EUARTDEV_MAX);
        return IOT_FAILURE;
    }

    ret = LzUartSetFlowCtrl(m_uart_bus_info[id].id, (FlowCtrl)flowCtrl);
    if (ret != LZ_HARDWARE_SUCCESS)
    {
        return IOT_FAILURE;
    }

    return IOT_SUCCESS;
}
