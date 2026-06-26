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

#ifndef __IOT_ADC_H__
#define __IOT_ADC_H__

/**
 * @brief Initializes a ADC device.
 * 
 * @param id Indicates the ADC device ID.
 * @return Returns {@link IOT_SUCCESS} if the ADC device is initialized;
 * returns {@link IOT_FAILURE} otherwise. For details about other return values, see the chip description. 
 */
unsigned int IoTAdcInit(unsigned int id);

/**
 * @brief Deinitializes a ADC device.
 * 
 * @param id Indicates the ADC device ID.
 * @return Returns {@link IOT_SUCCESS} if the ADC device is initialized;
 * returns {@link IOT_FAILURE} otherwise. For details about other return values, see the chip description. 
 */
unsigned int IoTAdcDeinit(unsigned int id);

/**
 * @brief Obtains the value of a ADC device.
 * 
 * @param id Indicates the ADC device ID.
 * @param val Indicates the pointer to the value.
 * @return Returns {@link IOT_SUCCESS} if the value is obtained;
 * returns {@link IOT_FAILURE} otherwise. For details about other return values, see the chip description. 
 */
unsigned int IoTAdcGetVal(unsigned int id, unsigned int *val);

#endif
