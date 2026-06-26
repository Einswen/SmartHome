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
#include "iot_i2c.h"
#include "lz_hardware.h"

struct I2cBusInfo
{
  unsigned int id;
  I2cBusIo i2c_bus;
};

static struct I2cBusInfo
    m_i2c_bus_info[EI2CDEV_MAX] =
        {
            [EI2C0_M2] =
                {
                    .id = 0,
                    .i2c_bus =
                        {
                            .scl = {.gpio = GPIO0_PA1,
                                    .func = MUX_FUNC3,
                                    .type = PULL_NONE,
                                    .drv = DRIVE_KEEP,
                                    .dir = LZGPIO_DIR_KEEP,
                                    .val = LZGPIO_LEVEL_KEEP},
                            .sda = {.gpio = GPIO0_PA0,
                                    .func = MUX_FUNC3,
                                    .type = PULL_NONE,
                                    .drv = DRIVE_KEEP,
                                    .dir = LZGPIO_DIR_KEEP,
                                    .val = LZGPIO_LEVEL_KEEP},
                            .id = FUNC_ID_I2C0,
                            .mode = FUNC_MODE_M2,
                        },
                },
            [EI2C1_M2] =
                {
                    .id = 1,
                    .i2c_bus =
                        {
                            .scl = {.gpio = GPIO0_PA3,
                                    .func = MUX_FUNC3,
                                    .type = PULL_NONE,
                                    .drv = DRIVE_KEEP,
                                    .dir = LZGPIO_DIR_KEEP,
                                    .val = LZGPIO_LEVEL_KEEP},
                            .sda = {.gpio = GPIO0_PA2,
                                    .func = MUX_FUNC3,
                                    .type = PULL_NONE,
                                    .drv = DRIVE_KEEP,
                                    .dir = LZGPIO_DIR_KEEP,
                                    .val = LZGPIO_LEVEL_KEEP},
                            .id = FUNC_ID_I2C1,
                            .mode = FUNC_MODE_M2,
                        },
                },
            [EI2C0_M0] =
                {
                    .id = 0,
                    .i2c_bus =
                        {
                            .scl =
                                {
                                    .gpio = GPIO0_PB5,
                                    .func = MUX_FUNC4,
                                    .type = PULL_NONE,
                                    .drv = DRIVE_KEEP,
                                    .dir = LZGPIO_DIR_KEEP,
                                    .val = LZGPIO_LEVEL_KEEP,
                                },
                            .sda =
                                {
                                    .gpio = GPIO0_PB4,
                                    .func = MUX_FUNC4,
                                    .type = PULL_NONE,
                                    .drv = DRIVE_KEEP,
                                    .dir = LZGPIO_DIR_KEEP,
                                    .val = LZGPIO_LEVEL_KEEP,
                                },
                            .id = FUNC_ID_I2C0,
                            .mode = FUNC_MODE_M0,
                        },
                },
            [EI2C1_M0] =
                {
                    .id = 1,
                    .i2c_bus =
                        {
                            .scl = {.gpio = GPIO0_PB7,
                                    .func = MUX_FUNC4,
                                    .type = PULL_NONE,
                                    .drv = DRIVE_KEEP,
                                    .dir = LZGPIO_DIR_KEEP,
                                    .val = LZGPIO_LEVEL_KEEP},
                            .sda = {.gpio = GPIO0_PB6,
                                    .func = MUX_FUNC4,
                                    .type = PULL_NONE,
                                    .drv = DRIVE_KEEP,
                                    .dir = LZGPIO_DIR_KEEP,
                                    .val = LZGPIO_LEVEL_KEEP},
                            .id = FUNC_ID_I2C1,
                            .mode = FUNC_MODE_M0,
                        },
                },
            [EI2C1_M1] =
                {
                    .id = 1,
                    .i2c_bus =
                        {
                            .scl = {.gpio = GPIO0_PC2,
                                    .func = MUX_FUNC5,
                                    .type = PULL_NONE,
                                    .drv = DRIVE_KEEP,
                                    .dir = LZGPIO_DIR_KEEP,
                                    .val = LZGPIO_LEVEL_KEEP},
                            .sda = {.gpio = GPIO0_PC1,
                                    .func = MUX_FUNC5,
                                    .type = PULL_NONE,
                                    .drv = DRIVE_KEEP,
                                    .dir = LZGPIO_DIR_KEEP,
                                    .val = LZGPIO_LEVEL_KEEP},
                            .id = FUNC_ID_I2C1,
                            .mode = FUNC_MODE_M1,
                        },
                },
            [EI2C0_M1] =
                {
                    .id = 0,
                    .i2c_bus =
                        {
                            .scl = {.gpio = GPIO0_PC7,
                                    .func = MUX_FUNC5,
                                    .type = PULL_NONE,
                                    .drv = DRIVE_KEEP,
                                    .dir = LZGPIO_DIR_KEEP,
                                    .val = LZGPIO_LEVEL_KEEP},
                            .sda = {.gpio = GPIO0_PC6,
                                    .func = MUX_FUNC5,
                                    .type = PULL_NONE,
                                    .drv = DRIVE_KEEP,
                                    .dir = LZGPIO_DIR_KEEP,
                                    .val = LZGPIO_LEVEL_KEEP},
                            .id = FUNC_ID_I2C0,
                            .mode = FUNC_MODE_M1,
                        },
                },
            [EI2C2_M0] =
                {
                    .id = 2,
                    .i2c_bus =
                        {
                            .scl = {.gpio = GPIO0_PD6,
                                    .func = MUX_FUNC1,
                                    .type = PULL_NONE,
                                    .drv = DRIVE_KEEP,
                                    .dir = LZGPIO_DIR_KEEP,
                                    .val = LZGPIO_LEVEL_KEEP},
                            .sda = {.gpio = GPIO0_PD5,
                                    .func = MUX_FUNC1,
                                    .type = PULL_NONE,
                                    .drv = DRIVE_KEEP,
                                    .dir = LZGPIO_DIR_KEEP,
                                    .val = LZGPIO_LEVEL_KEEP},
                            .id = FUNC_ID_I2C2,
                            .mode = FUNC_MODE_M0,
                        },
                },
};

unsigned int IoTI2cWrite(unsigned int id, unsigned short deviceAddr,
                         const unsigned char *data, unsigned int dataLen)
{

  unsigned int ret = 0;

  if (id >= EI2CDEV_MAX)
  {
    PRINT_ERR("id(%d) >= EI2CDEV_MAX(%d)\n", id, EI2CDEV_MAX);
    return IOT_FAILURE;
  }

  ret = LzI2cWrite(m_i2c_bus_info[id].id, deviceAddr, data, dataLen);
  if (ret != LZ_HARDWARE_SUCCESS)
  {
    return IOT_FAILURE;
  }

  return IOT_SUCCESS;
}

unsigned int IoTI2cRead(unsigned int id, unsigned short deviceAddr,
                        unsigned char *data, unsigned int dataLen)
{

  unsigned int ret = 0;

  if (id >= EI2CDEV_MAX)
  {
    PRINT_ERR("id(%d) >= EI2CDEV_MAX(%d)\n", id, EI2CDEV_MAX);
    return IOT_FAILURE;
  }

  ret = LzI2cRead(m_i2c_bus_info[id].id, deviceAddr, data, dataLen);
  if (ret != LZ_HARDWARE_SUCCESS)
  {
    return IOT_FAILURE;
  }

  return IOT_SUCCESS;
}

unsigned int IoTI2cWriteRead(unsigned int id, unsigned short deviceAddr,
                             unsigned char *writeData, unsigned int writeDataLen,
                             unsigned char *readData, unsigned int readDataLen)
{
  unsigned int ret = 0;

  if (id >= EI2CDEV_MAX)
  {
    PRINT_ERR("id(%d) >= EI2CDEV_MAX(%d)\n", id, EI2CDEV_MAX);
    return IOT_FAILURE;
  }

  LzI2cMsg msgs[2];
  msgs[0].addr  = deviceAddr;
  msgs[0].flags = 0;
  msgs[0].buf   = writeData;
  msgs[0].len   = writeDataLen;

  msgs[1].addr  = deviceAddr;
  msgs[1].flags = I2C_M_RD;
  msgs[1].buf   = readData;
  msgs[1].len   = readDataLen;

  ret = LzI2cTransfer(0, msgs, (writeDataLen > readDataLen) ? writeDataLen : readDataLen);
  if (ret != LZ_HARDWARE_SUCCESS)
  {
    return IOT_FAILURE;
  }

  return IOT_SUCCESS;
}

unsigned int IoTI2cInit(unsigned int id, unsigned int baudrate)
{

  unsigned int ret = 0;
  unsigned int fre = 100000;

  if (id >= EI2CDEV_MAX)
  {
    PRINT_ERR("id(%d) >= EI2CDEV_MAX(%d)\n", id, EI2CDEV_MAX);
    return IOT_FAILURE;
  }

  if (baudrate >= EI2C_FRE_MAX)
  {
    PRINT_ERR("baudrate(%d) >= EI2C_FRE_MAX(%d)\n", baudrate, EI2C_FRE_MAX);
  }

  switch (baudrate)
  {
  case EI2C_FRE_100K:
    fre = 100000;
    break;
  case EI2C_FRE_400K:
    fre = 400000;
    break;
  case EI2C_FRE_1000K:
    fre = 1000000;
    break;
  default:
    fre = 100000;
    break;
  }

  ret = I2cIoInit(m_i2c_bus_info[id].i2c_bus);
  if (ret != LZ_HARDWARE_SUCCESS)
  {
    return IOT_FAILURE;
  }

  ret = LzI2cInit(m_i2c_bus_info[id].id, baudrate);
  if (ret != LZ_HARDWARE_SUCCESS)
  {
    return IOT_FAILURE;
  }

  return IOT_SUCCESS;
}

unsigned int IoTI2cDeinit(unsigned int id)
{

  unsigned int ret = 0;

  if (id >= EI2CDEV_MAX)
  {
    PRINT_ERR("id(%d) >= EI2CDEV_MAX(%d)\n", id, EI2CDEV_MAX);
    return IOT_FAILURE;
  }

  LzGpioDeinit(m_i2c_bus_info[id].i2c_bus.scl.gpio);
  LzGpioDeinit(m_i2c_bus_info[id].i2c_bus.sda.gpio);

  ret = LzI2cDeinit(m_i2c_bus_info[id].id);
  if (ret != LZ_HARDWARE_SUCCESS)
  {
    return IOT_FAILURE;
  }

  return IOT_SUCCESS;
}

unsigned int IoTI2cSetBaudrate(unsigned int id, unsigned int baudrate)
{

  unsigned int ret = 0;
  unsigned int fre = 100000;

  if (id >= EI2CDEV_MAX)
  {
    PRINT_ERR("id(%d) >= EI2CDEV_MAX(%d)\n", id, EI2CDEV_MAX);
    return IOT_FAILURE;
  }

  if (baudrate >= EI2C_FRE_MAX)
  {
    PRINT_ERR("baudrate(%d) >= EI2C_FRE_MAX(%d)\n", baudrate, EI2C_FRE_MAX);
    return IOT_FAILURE;
  }

  switch (baudrate)
  {
  case EI2C_FRE_100K:
    fre = 100000;
    break;
  case EI2C_FRE_400K:
    fre = 400000;
    break;
  case EI2C_FRE_1000K:
    fre = 1000000;
    break;
  }

  ret = LzI2cSetFreq(m_i2c_bus_info[id].id, baudrate);
  if (ret != LZ_HARDWARE_SUCCESS)
  {
    return IOT_FAILURE;
  }

  return IOT_SUCCESS;
}

unsigned int IoTI2cScan(unsigned int id, unsigned short *slaveAddr,
                        unsigned int slaveAddrLen)
{
  unsigned int i2c_dev_num = 0;

  if (id >= EI2CDEV_MAX)
  {
    PRINT_ERR("id(%d) >= EI2CDEV_MAX(%d)\n", id, EI2CDEV_MAX);
    return IOT_FAILURE;
  }

  i2c_dev_num = LzI2cScan(m_i2c_bus_info[id].id, slaveAddr, slaveAddrLen);

  return i2c_dev_num;
}
