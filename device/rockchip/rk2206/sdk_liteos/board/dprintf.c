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

#include <stdarg.h>
#include <stdio.h>
#include "lz_hardware.h"

#define DEBUG_PORT              1
#define BUFFER_MAXSIZE          256

int printf(char const  *fmt, ...)
{
    va_list ap;
    unsigned char buffer[BUFFER_MAXSIZE];
    
    va_start(ap, fmt);
    vsnprintf(buffer, BUFFER_MAXSIZE, fmt, ap);
    // DebugWrite(DEBUG_PORT, (const unsigned char *)buffer, strlen(buffer));
    // DebugWrite(DEBUG_PORT, '\n', 1);
    for (int i = 0; i < strlen(buffer); i++)
    {
        // 当发现换行符，则自动添加回车,注意当下标为0直接添加回车
        if (buffer[i] == '\n' && (( i > 0 && buffer[i - 1] != '\r') || (i == 0)))
        {
            DebugPutc(DEBUG_PORT, '\r');
        }
        DebugPutc(DEBUG_PORT, buffer[i]);
    }
    va_end(ap);
    return 0;
}

