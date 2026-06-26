/*
 * Copyright (c) 2020 Huawei Device Co., Ltd.
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

/**
 * @addtogroup IotHardware
 * @{
 *
 * @brief Provides APIs for operating devices,
 * including flash, GPIO, I2C, PWM, UART, and watchdog APIs.
 *
 *
 *
 * @since 2.2
 * @version 2.2
 */

/**
 * @file iot_i2c.h
 *
 * @brief Declares functions for operating I2C devices.
 *
 * These functions are used to initialize or deinitialize an I2C device,
 * and read data from or write data to an I2C device. \n
 *
 * @since 2.2
 * @version 2.2
 */

#ifndef IOT_I2C_H
#define IOT_I2C_H


/* 定义I2C速率 */
enum EnumI2cFre {
  EI2C_FRE_100K = 0,
  EI2C_FRE_400K,
  EI2C_FRE_1000K,
  EI2C_FRE_MAX,
};

/* 定义I2C设备数量 */
enum EnumI2cId {
  EI2C0_M2 = 0, /* SDA GPIO0_PA0 SCL GPIO0_PA1 */
  EI2C1_M2,     /* SDA GPIO0_PA2 SCL GPIO0_PA3 */
  EI2C0_M0,     /* SDA GPIO0_PB4 SCL GPIO0_PB5 */
  EI2C1_M0,     /* SDA GPIO0_PB6 SCL GPIO0_PB7 */
  EI2C1_M1,     /* SDA GPIO0_PC1 SCL GPIO0_PC2 */
  EI2C0_M1,     /* SDA GPIO0_PC6 SCL GPIO0_PC7 */
  EI2C2_M0,     /* SDA GPIO0_PD5 SCL GPIO0_PD6 */
  EI2CDEV_MAX
};

/**
 * @brief Initializes an I2C device with a specified baud rate.
 *
 *
 *
 * @param id Indicates the I2C device ID.
 * @param baudrate Indicates the I2C baud rate.
 * @return Returns {@link IOT_SUCCESS} if the I2C device is initialized;
 * returns {@link IOT_FAILURE} otherwise. For details about other return values, see the chip description.
 * @since 2.2
 * @version 2.2
 */
unsigned int IoTI2cInit(unsigned int id, unsigned int baudrate);

/**
 * @brief Deinitializes an I2C device.
 *
 * @param id Indicates the I2C device ID.
 * @return Returns {@link IOT_SUCCESS} if the I2C device is deinitialized;
 * returns {@link IOT_FAILURE} otherwise. For details about other return values, see the chip description.
 * @since 2.2
 * @version 2.2
 */
unsigned int IoTI2cDeinit(unsigned int id);

/**
 * @brief Writes data to an I2C device.
 *
 *
 *
 * @param id Indicates the I2C device ID.
 * @param deviceAddr Indicates the I2C device address.
 * @param data Indicates the pointer to the data to write.
 * @param dataLen Indicates the length of the data to write.
 * @return Returns {@link IOT_SUCCESS} if the data is written to the I2C device successfully;
 * returns {@link IOT_FAILURE} otherwise. For details about other return values, see the chip description.
 * @since 2.2
 * @version 2.2
 */
unsigned int IoTI2cWrite(unsigned int id, unsigned short deviceAddr, const unsigned char *data, unsigned int dataLen);

/**
 * @brief Reads data from an I2C device.
 *
 * The data read will be saved to the address specified by <b>i2cData</b>.
 *
 * @param id Indicates the I2C device ID.
 * @param deviceAddr Indicates the I2C device address.
 * @param data Indicates the pointer to the data to read.
 * @param dataLen Indicates the length of the data to read.
 * @return Returns {@link IOT_SUCCESS} if the data is read from the I2C device successfully;
 * returns {@link IOT_FAILURE} otherwise. For details about other return values, see the chip description.
 * @since 2.2
 * @version 2.2
 */
unsigned int IoTI2cRead(unsigned int id, unsigned short deviceAddr, unsigned char *data, unsigned int dataLen);

/**
 * @brief Sets the baud rate for an I2C device.
 *
 * @param id Indicates the I2C device ID.
 * @param baudrate Indicates the baud rate to set.
 * @return Returns {@link IOT_SUCCESS} if the baud rate is set;
 * returns {@link IOT_FAILURE} otherwise. For details about other return values, see the chip description.
 * @since 2.2
 * @version 2.2
 */
unsigned int IoTI2cSetBaudrate(unsigned int id, unsigned int baudrate);

/**
 * @brief Scan I2C device.
 *
 * @param id Indicates the I2C device ID.
 * @param slaveAddr Slave address.
 * @param slaveAddrLen Slave address length.
 * @return Return the number of slave addresses.
 * @since 2.2
 * @version 2.2
 */
unsigned int IoTI2cScan(unsigned int id, unsigned short *slaveAddr, unsigned int slaveAddrLen);

/**
 * @brief Write + Read I2C device.
 *
 * @param id Indicates the I2C device ID.
 * @param slaveAddr Slave address.
 * @param write data buffer.
 * @param twrite data buffer length
 * @param read data buffer.
 * @param read data buffer length
 * @return Return the length of read data buffer.
 * @since 2.2
 * @version 2.2
 */
unsigned int IoTI2cWriteRead(unsigned int id, unsigned short deviceAddr,
                             unsigned char *writeData, unsigned int writeDataLen,
                             unsigned char *readData, unsigned int readDataLen);

#endif
/** @} */
