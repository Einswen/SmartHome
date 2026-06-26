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

#include "los_task.h"
#include "ohos_init.h"

#include "lcd.h"

/***************************************************************
 * 函数名称: lcd_thread
 * 说    明: lcd例程
 * 参    数: 无
 * 返 回 值: 无
 ***************************************************************/
void lcd_thread(void)
{
    uint8_t chinese_string[] = "小凌派";
    uint8_t cur_sizey        = 12;

    lcd_init(0);
    lcd_fill(0, 0, g_lcd_size.w, g_lcd_size.h, LCD_WHITE);

    while (1) {
        printf("************Lcd Example***********\n");
        lcd_fill(0, 0, LCD_W, LCD_H, LCD_WHITE);
        lcd_show_chinese(0, 0, chinese_string, LCD_RED, LCD_WHITE, cur_sizey, 0);
        if (cur_sizey == 12)
            cur_sizey = 16;
        else if (cur_sizey == 16)
            cur_sizey = 24;
        else if (cur_sizey == 24)
            cur_sizey = 32;
        else
            cur_sizey = 12;

        printf("\n");
        LOS_Msleep(1000);
    }
}

/***************************************************************
 * 函数名称: iot_lcd_example
 * 说    明: 开机自启动调用函数
 * 参    数: 无
 * 返 回 值: 无
 ***************************************************************/
void iot_lcd_example()
{
    unsigned int thread_id;
    TSK_INIT_PARAM_S task = {0};
    unsigned int ret      = LOS_OK;

    task.pfnTaskEntry = (TSK_ENTRY_FUNC)lcd_thread;
    task.uwStackSize  = 20480;
    task.pcName       = "lcd_thread";
    task.usTaskPrio   = 24;
    ret               = LOS_TaskCreate(&thread_id, &task);
    if (ret != LOS_OK) {
        printf("Falied to create lcd_thread ret:0x%x\n", ret);
        return;
    }
}

APP_FEATURE_INIT(iot_lcd_example);