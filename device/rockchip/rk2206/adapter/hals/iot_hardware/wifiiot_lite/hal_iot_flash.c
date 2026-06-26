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
#include "iot_flash.h"
#include "lz_hardware.h"

unsigned int IoTFlashRead(unsigned int flashOffset, unsigned int size, unsigned char *ramData)
{
    return (FlashRead(flashOffset, size, ramData) == LZ_HARDWARE_SUCCESS) ? IOT_SUCCESS : IOT_FAILURE;
}

unsigned int IoTFlashWrite(unsigned int flashOffset, unsigned int size,
                           const unsigned char *ramData, unsigned char doErase)
{
    return (FlashWrite(flashOffset, size, ramData, doErase) == LZ_HARDWARE_SUCCESS) ? IOT_SUCCESS : IOT_FAILURE;
}

unsigned int IoTFlashErase(unsigned int flashOffset, unsigned int size)
{
    return (FlashErase(flashOffset, size) == LZ_HARDWARE_SUCCESS) ? IOT_SUCCESS : IOT_FAILURE;
}

unsigned int IoTFlashInit(void)
{
    return (FlashInit() == LZ_HARDWARE_SUCCESS) ? IOT_SUCCESS : IOT_FAILURE;
}

unsigned int IoTFlashDeinit(void)
{
    return (FlashDeinit() == LZ_HARDWARE_SUCCESS) ? IOT_SUCCESS : IOT_FAILURE;
}
