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

#include "iot_adc.h"
#include "iot_errno.h"
#include "lz_hardware.h"

/* 定义ADC初始化的结构体 */
static DevIo m_adcKey = {
    .isr = {.gpio = INVALID_GPIO},
    .rst = {.gpio = INVALID_GPIO},
    .ctrl1 = {.gpio = GPIO0_PC0,
              .func = MUX_FUNC1,
              .type = PULL_NONE,
              .drv = DRIVE_KEEP,
              .dir = LZGPIO_DIR_IN,
              .val = LZGPIO_LEVEL_KEEP},
    .ctrl2 = {.gpio = INVALID_GPIO},
};

/* 初始化 ADC 次数 */
static uint8_t init_adc_cnt = 0;

unsigned int IoTAdcInit(unsigned int id) {

  unsigned int ret = 0;
  uint32_t *pGrfSocCon29 = (uint32_t *)(0x41050000U + 0x274U);
  uint32_t ulValue;

  if (id < 0 || id > 7) {
    PRINT_ERR("id(%d) > 7 or id(%d) < 0\n", id, id);
    return IOT_FAILURE;
  }

  m_adcKey.ctrl1.gpio = GPIO0_PC0 + id;

  ret = DevIoInit(m_adcKey);
  if (ret != LZ_HARDWARE_SUCCESS) {
    PRINT_ERR("%s, %s, %d: ADC Key IO Init fail\n", __FILE__, __func__,
              __LINE__);
    return IOT_FAILURE;
  }

  /* LzSaradcInit 接口只要初始化一次 */
  if(!init_adc_cnt) { 
    ret = LzSaradcInit();
    if (ret != LZ_HARDWARE_SUCCESS) {
      PRINT_ERR("%s, %s, %d: ADC Init fail\n", __FILE__, __func__, __LINE__);
      return IOT_FAILURE;
    }
  }

  /* 记录调用该接口次数 */
  init_adc_cnt++;

  /* 设置saradc的电压信号，选择AVDD */
  ulValue = *pGrfSocCon29;
  ulValue &= ~(0x1 << 4);
  ulValue |= ((0x1 << 4) << 16);
  *pGrfSocCon29 = ulValue;

  return IOT_SUCCESS;
}

unsigned int IoTAdcDeinit(unsigned int id) {

  unsigned int ret = 0;

  if (id < 0 || id > 7) {
    PRINT_ERR("id(%d) > 7 or id(%d) < 0\n", id, id);
    return IOT_FAILURE;
  }

  m_adcKey.ctrl1.gpio = GPIO0_PC0 + id;

  LzGpioDeinit(m_adcKey.ctrl1.gpio);
  init_adc_cnt--;

  /* 当 init_adc_cnt 为 0 调用 LzSaradcDeinit 注销  */
  if(!init_adc_cnt) {
    ret = LzSaradcDeinit();
    if (ret != LZ_HARDWARE_SUCCESS) {
      PRINT_ERR("%s, %s, %d: ADC Deinit Fail\n", __FILE__, __func__, __LINE__);
      return IOT_FAILURE;
    }
  }

  return IOT_SUCCESS;
}

unsigned int IoTAdcGetVal(unsigned int id, unsigned int *val) {

  unsigned int ret = 0;

  if (id < 0 || id > 7) {
    PRINT_ERR("id(%d) > 7 or id(%d) < 0\n", id, id);
    return IOT_FAILURE;
  }

  ret = LzSaradcReadValue(id, val);

  if (ret != LZ_HARDWARE_SUCCESS) {
    PRINT_ERR("%s, %s, %d: ADC Read Fail\n", __FILE__, __func__, __LINE__);
    return IOT_FAILURE;
  }

  return IOT_SUCCESS;
}
