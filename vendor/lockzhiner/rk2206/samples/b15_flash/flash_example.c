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

#include "ohos_init.h"
#include "cmsis_os2.h"
#include "los_task.h"
#include "utils_file.h"
#include "hal_file.h"

#include "link.h"
#include "lz_hardware.h"

#define LOG_TAG                 "flash"                         // 模块名称

// 使用内部Flash范围： 7MB ~ 8MB
#define FLASH_ADDRESS_START     (0x700000)                      // 起始地址
#define FLASH_ADDRESS_LENGTH    (0x100000)                      // Flash可读写范围
#define FLASH_ERASE_BLOCK_SIZE  (4096)                          // 擦除块大小


void flash_process(void *args)
{
    uint32_t flash_base_address = FLASH_ADDRESS_START;
    uint8_t flash_erase_buffer[FLASH_ERASE_BLOCK_SIZE];
    uint32_t flash_erase_buffer_length;
    int ret;
    uint8_t ch = 0;

    // 初始化flash
    FlashInit();

    while (1)
    {
        for (uint32_t i = 0; i < 16; i += FLASH_ERASE_BLOCK_SIZE)
        {
            uint32_t flash_address = flash_base_address + i;
            uint32_t flash_length = FLASH_ERASE_BLOCK_SIZE;

            printf("Flash erase: address = 0x%x, length = 0x%x\n", flash_address, flash_length);
            // 擦除
            ret = FlashErase(flash_address, flash_length);
            if (ret != LZ_HARDWARE_SUCCESS)
            {
                printf("Flash erase failed\n");
                goto flash_out;
            }

            // 写入
            printf("Flash write: address = 0x%x, length = 0x%x, ch = %d\n", flash_address, flash_length, ch);
            memset(flash_erase_buffer, ch, sizeof(flash_erase_buffer));
            ret = FlashWrite(flash_address, sizeof(flash_erase_buffer), flash_erase_buffer, 0);
            if (ret != LZ_HARDWARE_SUCCESS)
            {
                printf("Flash write failed\n");
                goto flash_out;
            }
            ch++;

            // 读取
            printf("Flash read: address = 0x%x, length = 0x%x\n", flash_address, flash_length);
            memset(flash_erase_buffer, 0, sizeof(flash_erase_buffer));
            ret = FlashRead(flash_address, sizeof(flash_erase_buffer), flash_erase_buffer);
            if (ret != LZ_HARDWARE_SUCCESS)
            {
                printf("Flash read failed\n");
                goto flash_out;
            }
            for (uint32_t offset = 0; offset < 16; offset++)
            {
                printf("    [%d] = %d\n", offset, flash_erase_buffer[offset]);
            }
            printf("\n\n");

flash_out:
            LOS_Msleep(1000);
        }
    }
}


void flash_example(void)
{
    unsigned int ret = LOS_OK;
    unsigned int thread_id;
    TSK_INIT_PARAM_S task = {0};

    task.pfnTaskEntry = (TSK_ENTRY_FUNC)flash_process;
    task.uwStackSize = 1024 * 512;
    task.pcName = "flash_process";
    task.usTaskPrio = 24;
    ret = LOS_TaskCreate(&thread_id, &task);
    if (ret != LOS_OK)
    {
        printf("Falied to create flash_process ret:0x%x\n", ret);
        return;
    }
}

APP_FEATURE_INIT(flash_example);