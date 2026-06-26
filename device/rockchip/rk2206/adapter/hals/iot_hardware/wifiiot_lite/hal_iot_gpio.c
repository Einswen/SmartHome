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
#include "iot_gpio.h"
#include "lz_hardware.h"

unsigned int IoTGpioInit(unsigned int id)
{
    unsigned int ret = 0;

    if (id > GPIO0_PC7 && id != GPIO1_PD0) {
        PRINT_ERR("id(%d) > %d || id(%d) != %d\n", id, GPIO0_PC7, GPIO1_PD0);
        return IOT_FAILURE;
    }

    ret = LzGpioInit(id);
    if (ret != LZ_HARDWARE_SUCCESS) {
        return IOT_FAILURE;
    }

    ret = PinctrlSet(id, MUX_FUNC0, PULL_KEEP, DRIVE_LEVEL0);
    if (ret != LZ_HARDWARE_SUCCESS) {
        return IOT_FAILURE;
    }

    return IOT_SUCCESS;
}

unsigned int IoTGpioDeinit(unsigned int id)
{
    unsigned int ret = 0;

    if (id > GPIO0_PC7 && id != GPIO1_PD0) {
        PRINT_ERR("id(%d) > %d || id(%d) != %d\n", id, GPIO0_PC7, GPIO1_PD0);
        return IOT_FAILURE;
    }

    ret = LzGpioDeinit(id);
    if (ret != LZ_HARDWARE_SUCCESS) {
        return IOT_FAILURE;
    }

    return IOT_SUCCESS;
}

unsigned int IoTGpioSetDir(unsigned int id, IotGpioDir dir)
{
    unsigned int ret = 0;

    if (id > GPIO0_PC7 && id != GPIO1_PD0) {
        PRINT_ERR("id(%d) > %d || id(%d) != %d\n", id, GPIO0_PC7, GPIO1_PD0);
        return IOT_FAILURE;
    }

    ret = LzGpioSetDir(id, (LzGpioDir)dir);
    if (ret != LZ_HARDWARE_SUCCESS) {
        return IOT_FAILURE;
    }   

    return IOT_SUCCESS;
}

unsigned int IoTGpioGetDir(unsigned int id, IotGpioDir *dir)
{
    unsigned int ret = 0;

    if (id > GPIO0_PC7 && id != GPIO1_PD0) {
        PRINT_ERR("id(%d) > %d || id(%d) != %d\n", id, GPIO0_PC7, GPIO1_PD0);
        return IOT_FAILURE;
    }

    ret = LzGpioGetDir(id, (LzGpioDir *)dir);
    if (ret != LZ_HARDWARE_SUCCESS) {
        return IOT_FAILURE;
    }   

    return IOT_SUCCESS;
}

unsigned int IoTGpioSetOutputVal(unsigned int id, IotGpioValue val)
{
    unsigned int ret = 0;

    if (id > GPIO0_PC7 && id != GPIO1_PD0) {
        PRINT_ERR("id(%d) > %d || id(%d) != %d\n", id, GPIO0_PC7, GPIO1_PD0);
        return IOT_FAILURE;
    }

    ret = LzGpioSetVal(id, (LzGpioValue)val);
    if (ret != LZ_HARDWARE_SUCCESS) {
        return IOT_FAILURE;
    }   

    return IOT_SUCCESS;
}

unsigned int IoTGpioGetOutputVal(unsigned int id, IotGpioValue *val)
{
    unsigned int ret = 0;

    if (id > GPIO0_PC7 && id != GPIO1_PD0) {
        PRINT_ERR("id(%d) > %d || id(%d) != %d\n", id, GPIO0_PC7, GPIO1_PD0);
        return IOT_FAILURE;
    }

    ret = LzGpioGetVal(id, (LzGpioValue *)val);
    if (ret != LZ_HARDWARE_SUCCESS) {
        return IOT_FAILURE;
    }   

    return IOT_SUCCESS;
}

unsigned int IoTGpioGetInputVal(unsigned int id, IotGpioValue *val)
{
    unsigned int ret = 0;

    if (id > GPIO0_PC7 && id != GPIO1_PD0) {
        PRINT_ERR("id(%d) > %d || id(%d) != %d\n", id, GPIO0_PC7, GPIO1_PD0);
        return IOT_FAILURE;
    }

    ret = LzGpioGetVal(id, (LzGpioValue *)val);
    if (ret != LZ_HARDWARE_SUCCESS) {
        return IOT_FAILURE;
    }   

    return IOT_SUCCESS;
}

unsigned int IoTGpioRegisterIsrFunc(unsigned int id, IotGpioIntType intType, IotGpioIntPolarity intPolarity,
                                    GpioIsrCallbackFunc func, char *arg)
{
    unsigned int ret = 0;
    LzGpioIntType type;
    
    if (id > GPIO0_PC7 && id != GPIO1_PD0) {
        PRINT_ERR("id(%d) > %d || id(%d) != %d\n", id, GPIO0_PC7, GPIO1_PD0);
        return IOT_FAILURE;
    }

    if (intType == IOT_INT_TYPE_LEVEL && intPolarity == IOT_GPIO_EDGE_FALL_LEVEL_LOW)
        type = LZGPIO_INT_LEVEL_LOW;
    else if (intType == IOT_INT_TYPE_LEVEL && intPolarity == IOT_GPIO_EDGE_RISE_LEVEL_HIGH)
        type = LZGPIO_INT_LEVEL_HIGH;
    else if (intType == IOT_INT_TYPE_EDGE && intPolarity == IOT_GPIO_EDGE_FALL_LEVEL_LOW)
        type = LZGPIO_INT_EDGE_FALLING;
    else if (intType == IOT_INT_TYPE_EDGE && intPolarity == IOT_GPIO_EDGE_RISE_LEVEL_HIGH)
        type = LZGPIO_INT_EDGE_RISING;
    else if (intType == IOT_INT_TYPE_EDGE && intPolarity == IOT_GPIO_EDGE_BOTH_TYPE)
        type = LZGPIO_INT_EDGE_BOTH;
    else
        return IOT_FAILURE;

    ret = LzGpioRegisterIsrFunc(id, type, (GpioIsrFunc)func, arg);
    if (ret != LZ_HARDWARE_SUCCESS) {
        return IOT_FAILURE;
    }  

    return IOT_SUCCESS;
}

unsigned int IoTGpioUnregisterIsrFunc(unsigned int id)
{
    unsigned int ret = 0;

    if (id > GPIO0_PC7 && id != GPIO1_PD0) {
        PRINT_ERR("id(%d) > %d || id(%d) != %d\n", id, GPIO0_PC7, GPIO1_PD0);
        return IOT_FAILURE;
    }

    ret = LzGpioUnregisterIsrFunc(id);
    if (ret != LZ_HARDWARE_SUCCESS) {
        return IOT_FAILURE;
    }   

    return IOT_SUCCESS;
}

unsigned int IoTGpioSetIsrMask(unsigned int id, unsigned char mask)
{
    unsigned int ret = 0;

    if (id > GPIO0_PC7 && id != GPIO1_PD0) {
        PRINT_ERR("id(%d) > %d || id(%d) != %d\n", id, GPIO0_PC7, GPIO1_PD0);
        return IOT_FAILURE;
    }

    if (!mask)
    {
        ret = LzGpioEnableIsr(id);
        if (ret != LZ_HARDWARE_SUCCESS) {
            return IOT_FAILURE;
        } 
    }
    else
    {
        ret = LzGpioDisableIsr(id);
        if (ret != LZ_HARDWARE_SUCCESS) {
            return IOT_FAILURE;
        } 
    }
    
    return IOT_SUCCESS;
}

unsigned int IoTGpioSetIsrMode(unsigned int id, IotGpioIntType intType, IotGpioIntPolarity intPolarity)
{
    return LZ_HARDWARE_SUCCESS;
}
