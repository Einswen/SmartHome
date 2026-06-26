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

#ifndef __IOT_SPI__
#define __IOT_SPI__

/* 定义SPI设备数量 */
enum EnumSpiId 
{
  ESPI1_M1 = 0, /* CS GPIO0_PB0 CLK GPIO0_PB1 MOSI GPIO0_PB2 MISO GPIO0_PB3 */
  ESPI0_M0,     /* CS GPIO0_PB4 CLK GPIO0_PB5 MOSI GPIO0_PB6 MISO GPIO0_PB7 */
  ESPI0_M1,     /* CS GPIO0_PC0 CLK GPIO0_PC1 MOSI GPIO0_PC2 MISO GPIO0_PC3 */
  ESPI1_M0,     /* CS GPIO0_PC4 CLK GPIO0_PC5 MOSI GPIO0_PC6 MISO GPIO0_PC7 */
  ESPIDEV_MAX
};

/** @defgroup SPI_Mode SPI Mode
  * 
  */
typedef enum 
{
    SPI_MODE_SLAVE = 0,
    SPI_MODE_MASTER
} IoT_SPI_Mode;

/** @defgroup SPI_Mode SPI Data Size
  * 
  */
typedef enum 
{
    SPI_DATASIZE_8BIT = 0,
    SPI_DATASIZE_16BIT
} IoT_SPI_DataSize;

/** @defgroup SPI_Clock_Polarity SPI Clock Polarity
  * 
  */
typedef enum 
{
    SPI_POLARITY_LOW = 0,
    SPI_POLARITY_HIGH
} IoT_SPI_Polarity;

/** @defgroup SPI_Clock_Phase SPI Clock Phase
  * 
  */
typedef enum 
{
    SPI_PHASE_1EDGE = 0,
    SPI_PHASE_2EDGE
} IoT_SPI_Phase; 

/** @defgroup SPI_MSB_LSB_transmission SPI MSB LSB Transmission
  * 
  */
typedef enum 
{
    SPI_FIRSTBIT_MSB = 0,
    SPI_FIRSTBIT_LSB
} IoT_SPI_FirstBit; 

/** @defgroup SPI_BaudRate_Prescaler SPI BaudRate Prescaler
  * 
  */
typedef enum 
{
    SPI_BAUDRATEPRESCALER_1 = 0,
    SPI_BAUDRATEPRESCALER_2,
    SPI_BAUDRATEPRESCALER_4,
    SPI_BAUDRATEPRESCALER_8,
    SPI_BAUDRATEPRESCALER_16,
    SPI_BAUDRATEPRESCALER_32,
    SPI_BAUDRATEPRESCALER_64,
    SPI_BAUDRATEPRESCALER_128,
} IoT_SPI_BaudRate; 

/** @defgroup SPI_Direction SPI Direction Mode
  * 
  */
typedef enum 
{
    SPI_DIRECTION_2LINES = 0,
    SPI_DIRECTION_2LINES_RXONLY,
    SPI_DIRECTION_1LINE_TX,
} IoT_SPI_Direction; 

/** @defgroup SPI_NSS SPI NSS Mode
  * 
  */
typedef enum
{
    SPI_NSS_HARD = 0,
    SPI_NSS_SOFT,
} IoT_SPI_NSS; 

typedef struct
{
  unsigned int Mode;       
  unsigned int Direction;       
  unsigned int DataSize;           
  unsigned int CLKPolarity;       
  unsigned int CLKPhase;            
  unsigned int BaudRatePrescaler;  
  unsigned int FirstBit;   
  unsigned int NSS;     
} IoT_SPI_InitTypeDef;

/**
 * @brief Initializes an SPI device.
 *
 * @param id Indicates the SPI device ID.
 * @param IoT_SPI_InitTypeDef SPI Config.
 * @return Returns {@link IOT_SUCCESS} if the SPI device is initialized;
 * returns {@link IOT_FAILURE} otherwise. For details about other return values, see the chip description.
 */
unsigned int IoTSpiInit(unsigned int id, IoT_SPI_InitTypeDef *iot_spi);

/**
 * @brief Deinitializes an SPI device.
 * 
 * @param id Indicates the SPI device ID.
 * @return Returns {@link IOT_SUCCESS} if the SPI device is initialized;
 * returns {@link IOT_FAILURE} otherwise. For details about other return values, see the chip description.
 */
unsigned int IoTSpiDeinit(unsigned int id);

/**
 * @brief Writes data to an SPI device.
 * 
 * @param id Indicates the SPI device ID. 
 * @param buf Indicates the pointer to the data to write.
 * @param len Indicates the length of the data to write.
 * @return Returns {@link IOT_SUCCESS} if the data is written to the I2C device successfully;
 * returns {@link IOT_FAILURE} otherwise. For details about other return values, see the chip description.
 */
unsigned int IoTSpiWrite(unsigned int id, unsigned char *buf, unsigned int len);

/**
 * @brief Reads data from an SPI device.
 * 
 * @param id Indicates the SPI device ID. 
 * @param buf Indicates the pointer to the data to write.
 * @param len Indicates the length of the data to write.
 * @return Returns {@link IOT_SUCCESS} if the data is written to the I2C device successfully;
 * returns {@link IOT_FAILURE} otherwise. For details about other return values, see the chip description.
 */
unsigned int IoTSpiRead(unsigned int id, unsigned char *buf, unsigned int len);

/**
 * @brief Write Then Read data from an SPI device.
 * 
 * @param id Indicates the SPI device ID. 
 * @param write_buf Indicates the pointer to the data to write.
 * @param write_len Indicates the length of the data to write.
 * @param read_buf Indicates the pointer to the data to read.
 * @param read_len Indicates the length of the data to read.
 * @return Returns {@link IOT_SUCCESS} if the data is written to the I2C device successfully;
 * returns {@link IOT_FAILURE} otherwise. For details about other return values, see the chip description.
 */
unsigned int IoTSpiWriteRead(unsigned int id, unsigned char *write_buf, unsigned int write_len, unsigned char *read_buf, unsigned int read_len);

#endif
