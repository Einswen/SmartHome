/*
 * Copyright (c) 2021 LOCKZHINER Electronic Co., Ltd.
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
#include "iot_spi.h"

#include "lcd.h"
#include "lcd_font.h"

#include <stdarg.h>
#include <stdio.h>

lcd_size_t g_lcd_size = {
    .w = LCD_W,
    .h = LCD_H,
};

/* 是否启用SPI通信
 * 0 => 禁用SPI，使用gpio模拟SPI通信
 * 1 => 启用SPI
 */
#define LCD_ENABLE_SPI 1
#define LCD_SPI_BUS    ESPI0_M1

#define LCD_PIN_CS     GPIO0_PC0
#define LCD_PIN_CLK    GPIO0_PC1
#define LCD_PIN_MOSI   GPIO0_PC2
#define LCD_PIN_RES    GPIO0_PC3
#define LCD_PIN_DC     GPIO0_PC6

#define LCD_CS_Clr()   IoTGpioSetOutputVal(LCD_PIN_CS, IOT_GPIO_VALUE0)
#define LCD_CS_Set()   IoTGpioSetOutputVal(LCD_PIN_CS, IOT_GPIO_VALUE1)

#define LCD_CLK_Clr()  IoTGpioSetOutputVal(LCD_PIN_CLK, IOT_GPIO_VALUE0)
#define LCD_CLK_Set()  IoTGpioSetOutputVal(LCD_PIN_CLK, IOT_GPIO_VALUE1)

#define LCD_MOSI_Clr() IoTGpioSetOutputVal(LCD_PIN_MOSI, IOT_GPIO_VALUE0)
#define LCD_MOSI_Set() IoTGpioSetOutputVal(LCD_PIN_MOSI, IOT_GPIO_VALUE1)

#define LCD_RES_Clr()  IoTGpioSetOutputVal(LCD_PIN_RES, IOT_GPIO_VALUE0)
#define LCD_RES_Set()  IoTGpioSetOutputVal(LCD_PIN_RES, IOT_GPIO_VALUE1)

#define LCD_DC_Clr()   IoTGpioSetOutputVal(LCD_PIN_DC, IOT_GPIO_VALUE0)
#define LCD_DC_Set()   IoTGpioSetOutputVal(LCD_PIN_DC, IOT_GPIO_VALUE1)

#if LCD_ENABLE_SPI
#define sw16(x)                                              \
    ((uint16_t)((((uint16_t)(x) & (uint16_t)0x00ffU) << 8) | \
                (((uint16_t)(x) & (uint16_t)0xff00U) >> 8)))

#define SPI_TEMP_LEN 2048
uint16_t m_spibuf[SPI_TEMP_LEN];

IoT_SPI_InitTypeDef iot_spi = {
    .Mode              = SPI_MODE_MASTER,
    .Direction         = SPI_DIRECTION_1LINE_TX,
    .DataSize          = SPI_DATASIZE_8BIT,
    .CLKPolarity       = SPI_POLARITY_HIGH,
    .CLKPhase          = SPI_PHASE_2EDGE,
    .BaudRatePrescaler = SPI_BAUDRATEPRESCALER_1,
    .FirstBit          = SPI_FIRSTBIT_MSB,
};

static void lcd_writes(uint8_t *dat, uint32_t len)
{
    IoTSpiWrite(LCD_SPI_BUS, dat, len);
}
#endif
uint8_t get_utf8_byte_cnt(uint8_t *src);

/////////////////////////////////////////////////////////////////

static void lcd_write_bus(uint8_t dat)
{
#if LCD_ENABLE_SPI
    IoTSpiWrite(LCD_SPI_BUS, &dat, 1);
#else
    uint8_t i;

    LCD_CS_Clr();
    for (i = 0; i < 8; i++) {
        LCD_CLK_Clr();
        if (dat & 0x80) {
            LCD_MOSI_Set();
        } else {
            LCD_MOSI_Clr();
        }
        LCD_CLK_Set();
        dat <<= 1;
    }
    LCD_CS_Set();
#endif
}

static void lcd_wr_data8(uint8_t dat)
{
    lcd_write_bus(dat);
}

static void lcd_wr_data(uint16_t dat)
{
#if LCD_ENABLE_SPI
    uint8_t t[2];
    t[0] = dat >> 8;
    t[1] = dat;
    IoTSpiWrite(LCD_SPI_BUS, t, 2);
#else
    lcd_write_bus(dat >> 8);
    lcd_write_bus(dat);
#endif
}

static void lcd_wr_reg(uint8_t dat)
{
    LCD_DC_Clr();
    lcd_write_bus(dat);
    LCD_DC_Set();
}

static void lcd_address_set(uint16_t x1, uint16_t y1, uint16_t x2, uint16_t y2)
{
    /* 列地址设置 */
    lcd_wr_reg(0x2a);
#if LCD_ENABLE_SPI
    m_spibuf[0] = sw16(x1);
    m_spibuf[1] = sw16(x2);
    lcd_writes((uint8_t *)m_spibuf, 4);
    lcd_wr_reg(0x2b);
    m_spibuf[0] = sw16(y1);
    m_spibuf[1] = sw16(y2);
    lcd_writes((uint8_t *)m_spibuf, 4);
#else
    lcd_wr_data(x1);
    lcd_wr_data(x2);
    /* 行地址设置 */
    lcd_wr_reg(0x2b);
    lcd_wr_data(y1);
    lcd_wr_data(y2);
    /* 储存器写 */
#endif
    lcd_wr_reg(0x2c);
}

static uint32_t mypow(uint8_t m, uint8_t n)
{
    uint32_t result = 1;

    while (n--) {
        result *= m;
    }

    return result;
}

/***************************************************************
 * 函数名称: lcd_show_chinese_12x12
 * 说    明: 显示单个12x12汉字
 * 参    数:
 *       @x：指定汉字串的起始位置X坐标
 *       @y：指定汉字串的起始位置X坐标
 *       @s：指定汉字串（该汉字串为ascii）
 *       @fc: 字的颜色
 *       @bc: 字的背景色
 *       @sizey: 字号，可选：12
 *       @mode: 0为非叠加模式；1为叠加模式
 * 返 回 值: 无
 ***************************************************************/
static void lcd_show_chinese_12x12(uint16_t x, uint16_t y, uint8_t *s, uint16_t fc, uint16_t bc, uint8_t sizey, uint8_t mode)
{
    uint8_t i, j, m = 0;
    uint16_t k;
    uint16_t HZnum;       // 汉字数目
    uint16_t TypefaceNum; // 一个字符所占字节大小
    uint16_t x0  = x;
    uint32_t cnt = 0;

    TypefaceNum = (sizey / 8 + ((sizey % 8) ? 1 : 0)) * sizey;

    /* 统计汉字数目 */
    HZnum = sizeof(tfont12) / sizeof(typFNT_GB12);

    for (k = 0; k < HZnum; k++) {
        if ((tfont12[k].Index[0] == *(s)) && (tfont12[k].Index[1] == *(s + 1)) && (tfont12[k].Index[2] == *(s + 2))) {
            lcd_address_set(x, y, x + sizey - 1, y + sizey - 1);
            for (i = 0; i < TypefaceNum; i++) {
                for (j = 0; j < 8; j++) {
                    if (!mode) {
                        /* 非叠加方式 */
                        if (tfont12[k].Msk[i] & (0x01 << j)) {
#if LCD_ENABLE_SPI
                            m_spibuf[cnt++] = sw16(fc);
#else
                            lcd_wr_data(fc);
#endif
                        } else {
#if LCD_ENABLE_SPI
                            m_spibuf[cnt++] = sw16(bc);
#else
                            lcd_wr_data(bc);
#endif
                        }
                        m++;
                        if ((m % sizey) == 0) {
                            m = 0;
                            break;
                        }
                    } else {
                        /* 叠加方式 */
                        if (tfont12[k].Msk[i] & (0x01 << j)) {
                            /* 画一个点 */
                            lcd_draw_point(x, y, fc);
                        }

                        x++;
                        if ((x - x0) == sizey) {
                            x = x0;
                            y++;
                            break;
                        }
                    }
                }
            }
#if LCD_ENABLE_SPI
            if (!mode) {
                lcd_writes((uint8_t *)m_spibuf, cnt * 2);
            }
#endif
            break; // 查找到对应点阵字库立即退出，防止多个汉字重复取模带来影响
        }
    }
}

/***************************************************************
 * 函数名称: lcd_show_chinese_16x16
 * 说    明: 显示单个16x16汉字
 * 参    数:
 *       @x：指定汉字串的起始位置X坐标
 *       @y：指定汉字串的起始位置X坐标
 *       @s：指定汉字串（该汉字串为ascii）
 *       @fc: 字的颜色
 *       @bc: 字的背景色
 *       @sizey: 字号，可选：16
 *       @mode: 0为非叠加模式；1为叠加模式
 * 返 回 值: 无
 ***************************************************************/
static void lcd_show_chinese_16x16(uint16_t x, uint16_t y, uint8_t *s, uint16_t fc, uint16_t bc, uint8_t sizey, uint8_t mode)
{
    uint8_t i, j, m = 0;
    uint16_t k;
    uint16_t HZnum;       // 汉字数目
    uint16_t TypefaceNum; // 一个字符所占字节大小
    uint16_t x0  = x;
    uint32_t cnt = 0;

    TypefaceNum = (sizey / 8 + ((sizey % 8) ? 1 : 0)) * sizey;
    /* 统计汉字数目 */
    HZnum = sizeof(tfont16) / sizeof(typFNT_GB16);

    for (k = 0; k < HZnum; k++) {
        if ((tfont16[k].Index[0] == *(s)) && (tfont16[k].Index[1] == *(s + 1)) && (tfont16[k].Index[2] == *(s + 2))) {
            lcd_address_set(x, y, x + sizey - 1, y + sizey - 1);
            for (i = 0; i < TypefaceNum; i++) {
                for (j = 0; j < 8; j++) {
                    if (!mode) {
                        /* 非叠加方式 */
                        if (tfont16[k].Msk[i] & (0x01 << j)) {
#if LCD_ENABLE_SPI
                            m_spibuf[cnt++] = sw16(fc);
#else
                            lcd_wr_data(fc);
#endif
                        } else {
#if LCD_ENABLE_SPI
                            m_spibuf[cnt++] = sw16(bc);
#else
                            lcd_wr_data(bc);
#endif
                        }
                        m++;
                        if (m % sizey == 0) {
                            m = 0;
                            break;
                        }
                    } else {
                        /* 叠加方式 */
                        if (tfont16[k].Msk[i] & (0x01 << j)) {
                            /* 画一个点 */
                            lcd_draw_point(x, y, fc);
                        }

                        x++;
                        if ((x - x0) == sizey) {
                            x = x0;
                            y++;
                            break;
                        }
                    }
                }
            }
#if LCD_ENABLE_SPI
            if (!mode) {
                lcd_writes((uint8_t *)m_spibuf, cnt * 2);
            }
#endif

            break; // 查找到对应点阵字库立即退出，防止多个汉字重复取模带来影响
        }
    }
}

/***************************************************************
 * 函数名称: lcd_show_chinese_24x24
 * 说    明: 显示单个24x24汉字
 * 参    数:
 *       @x：指定汉字串的起始位置X坐标
 *       @y：指定汉字串的起始位置X坐标
 *       @s：指定汉字串（该汉字串为ascii）
 *       @fc: 字的颜色
 *       @bc: 字的背景色
 *       @sizey: 字号，可选：24
 *       @mode: 0为非叠加模式；1为叠加模式
 * 返 回 值: 无
 ***************************************************************/
static void lcd_show_chinese_24x24(uint16_t x, uint16_t y, uint8_t *s, uint16_t fc, uint16_t bc, uint8_t sizey, uint8_t mode)
{
    uint8_t i, j, m = 0;
    uint16_t k;
    uint16_t HZnum;       // 汉字数目
    uint16_t TypefaceNum; // 一个字符所占字节大小
    uint16_t x0  = x;
    uint32_t cnt = 0;

    TypefaceNum = (sizey / 8 + ((sizey % 8) ? 1 : 0)) * sizey;
    /* 统计汉字数目 */
    HZnum = sizeof(tfont24) / sizeof(typFNT_GB24);

    for (k = 0; k < HZnum; k++) {
        if ((tfont24[k].Index[0] == *(s)) && (tfont24[k].Index[1] == *(s + 1)) && (tfont24[k].Index[2] == *(s + 2))) {
            lcd_address_set(x, y, x + sizey - 1, y + sizey - 1);
            for (i = 0; i < TypefaceNum; i++) {
                for (j = 0; j < 8; j++) {
                    if (!mode) {
                        /* 非叠加方式 */
                        if (tfont24[k].Msk[i] & (0x01 << j)) {
#if LCD_ENABLE_SPI
                            m_spibuf[cnt++] = sw16(fc);
#else
                            lcd_wr_data(fc);

#endif
                        } else {
#if LCD_ENABLE_SPI
                            m_spibuf[cnt++] = sw16(bc);
#else
                            lcd_wr_data(bc);
#endif
                        }

                        m++;
                        if (m % sizey == 0) {
                            m = 0;
                            break;
                        }
                    } else {
                        /* 叠加方式 */
                        if (tfont24[k].Msk[i] & (0x01 << j)) {
                            /* 画一个点 */
                            lcd_draw_point(x, y, fc);
                        }

                        x++;
                        if ((x - x0) == sizey) {
                            x = x0;
                            y++;
                            break;
                        }
                    }
                }
            }
#if LCD_ENABLE_SPI
            if (!mode) {
                lcd_writes((uint8_t *)m_spibuf, cnt * 2);
            }
#endif

            continue; // 查找到对应点阵字库立即退出，防止多个汉字重复取模带来影响
        }
    }
}

/***************************************************************
 * 函数名称: lcd_show_chinese_32x32
 * 说    明: 显示单个32x32汉字
 * 参    数:
 *       @x：指定汉字串的起始位置X坐标
 *       @y：指定汉字串的起始位置X坐标
 *       @s：指定汉字串（该汉字串为ascii）
 *       @fc: 字的颜色
 *       @bc: 字的背景色
 *       @sizey: 字号，可选：32
 *       @mode: 0为非叠加模式；1为叠加模式
 * 返 回 值: 无
 ***************************************************************/
static void lcd_show_chinese_32x32(uint16_t x, uint16_t y, uint8_t *s, uint16_t fc, uint16_t bc, uint8_t sizey, uint8_t mode)
{
    uint8_t i, j, m = 0;
    uint16_t k;
    uint16_t HZnum;       // 汉字数目
    uint16_t TypefaceNum; // 一个字符所占字节大小
    uint16_t x0  = x;
    uint32_t cnt = 0;

    TypefaceNum = (sizey / 8 + ((sizey % 8) ? 1 : 0)) * sizey;
    /* 统计汉字数目 */
    HZnum = sizeof(tfont32) / sizeof(typFNT_GB32);

    for (k = 0; k < HZnum; k++) {
        if ((tfont32[k].Index[0] == *(s)) && (tfont32[k].Index[1] == *(s + 1)) && (tfont32[k].Index[2] == *(s + 2))) {
            lcd_address_set(x, y, x + sizey - 1, y + sizey - 1);
            for (i = 0; i < TypefaceNum; i++) {
                for (j = 0; j < 8; j++) {
                    if (!mode) {
                        /* 非叠加方式 */
                        if (tfont32[k].Msk[i] & (0x01 << j)) {
#if LCD_ENABLE_SPI
                            m_spibuf[cnt++] = sw16(fc);
#else
                            lcd_wr_data(fc);
#endif
                        } else {
#if LCD_ENABLE_SPI
                            m_spibuf[cnt++] = sw16(bc);
#else
                            lcd_wr_data(bc);
#endif
                        }

                        m++;
                        if (m % sizey == 0) {
                            m = 0;
                            break;
                        }
                    } else {
                        /* 叠加方式 */
                        if (tfont32[k].Msk[i] & (0x01 << j)) {
                            lcd_draw_point(x, y, fc); // 画一个点
                        }

                        x++;
                        if ((x - x0) == sizey) {
                            x = x0;
                            y++;
                            break;
                        }
                    }
                }
            }
#if LCD_ENABLE_SPI
            if (!mode) {
                lcd_writes((uint8_t *)m_spibuf, cnt * 2);
            }
#endif

            continue;
            ; // 查找到对应点阵字库立即退出，防止多个汉字重复取模带来影响
        }
    }
}

/////////////////////////////////////////////////////////////////

/***************************************************************
 * 函数名称: lcd_init
 * 说    明: Lcd初始化
 * 参    数: 无
 * 返 回 值: 返回0为成功，反之为失败
 ***************************************************************/
unsigned int lcd_init(uint8_t dir)
{
    unsigned int ret = 0;

#if LCD_ENABLE_SPI
    ret = IoTSpiInit(LCD_SPI_BUS, &iot_spi);
    if (ret != IOT_SUCCESS) {
        printf("%s, %s, %d: Spi init failed!\n", __FILE__, __func__, __LINE__);
        return IOT_FAILURE;
    }
#else
    /* 初始化GPIO0_C0 */
    IoTGpioInit(LCD_PIN_CS);
    IoTGpioSetDir(LCD_PIN_CS, IOT_GPIO_DIR_OUT);
    IoTGpioSetOutputVal(LCD_PIN_CS, IOT_GPIO_VALUE1);
    /* 初始化GPIO0_C1 */
    IoTGpioInit(LCD_PIN_CLK);
    IoTGpioSetDir(LCD_PIN_CLK, IOT_GPIO_DIR_OUT);
    IoTGpioSetOutputVal(LCD_PIN_CLK, IOT_GPIO_VALUE0);
    /* 初始化GPIO0_C2 */
    IoTGpioInit(LCD_PIN_MOSI);
    IoTGpioSetDir(LCD_PIN_MOSI, IOT_GPIO_DIR_OUT);
    IoTGpioSetOutputVal(LCD_PIN_MOSI, IOT_GPIO_VALUE0);
#endif
    /* 初始化GPIO0_C3 */
    IoTGpioInit(LCD_PIN_RES);
    IoTGpioSetDir(LCD_PIN_RES, IOT_GPIO_DIR_OUT);
    IoTGpioSetOutputVal(LCD_PIN_RES, IOT_GPIO_VALUE1);

    /* 初始化GPIO0_C6 */
    IoTGpioInit(LCD_PIN_DC);
    IoTGpioSetDir(LCD_PIN_DC, IOT_GPIO_DIR_OUT);
    IoTGpioSetOutputVal(LCD_PIN_DC, IOT_GPIO_VALUE0);

    /* 重启lcd */
    LCD_RES_Clr();
    LOS_Msleep(100);
    LCD_RES_Set();
    LOS_Msleep(100);
    LOS_Msleep(500);
    lcd_wr_reg(0x11);
    /* 等待LCD 100ms */
    LOS_Msleep(100);
    /* 启动LCD配置，设置显示和颜色配置 */
    lcd_wr_reg(0X36);

    switch (dir) {
        case 0:
            g_lcd_size.w = LCD_W;
            g_lcd_size.h = LCD_H;
            lcd_wr_data8(0x00);
            break;
        case 1:
            g_lcd_size.w = LCD_W;
            g_lcd_size.h = LCD_H;
            lcd_wr_data8(0xC0);
            break;
        case 2:
            g_lcd_size.w = LCD_H;
            g_lcd_size.h = LCD_W;
            lcd_wr_data8(0x70);
            break;
        default:
            g_lcd_size.w = LCD_H;
            g_lcd_size.h = LCD_W;
            lcd_wr_data8(0xA0);
            break;
    }

    lcd_wr_reg(0X3A);
    lcd_wr_data8(0X05);
    /* ST7789S帧刷屏率设置 */
    lcd_wr_reg(0xb2);
    lcd_wr_data8(0x0c);
    lcd_wr_data8(0x0c);
    lcd_wr_data8(0x00);
    lcd_wr_data8(0x33);
    lcd_wr_data8(0x33);
    lcd_wr_reg(0xb7);
    lcd_wr_data8(0x35);
    /* ST7789S电源设置 */
    lcd_wr_reg(0xbb);
    lcd_wr_data8(0x35);
    lcd_wr_reg(0xc0);
    lcd_wr_data8(0x2c);
    lcd_wr_reg(0xc2);
    lcd_wr_data8(0x01);
    lcd_wr_reg(0xc3);
    lcd_wr_data8(0x13);
    lcd_wr_reg(0xc4);
    lcd_wr_data8(0x20);
    lcd_wr_reg(0xc6);
    lcd_wr_data8(0x0f);
    lcd_wr_reg(0xca);
    lcd_wr_data8(0x0f);
    lcd_wr_reg(0xc8);
    lcd_wr_data8(0x08);
    lcd_wr_reg(0x55);
    lcd_wr_data8(0x90);
    lcd_wr_reg(0xd0);
    lcd_wr_data8(0xa4);
    lcd_wr_data8(0xa1);
    /* ST7789S gamma设置 */
    lcd_wr_reg(0xe0);
    lcd_wr_data8(0xd0);
    lcd_wr_data8(0x00);
    lcd_wr_data8(0x06);
    lcd_wr_data8(0x09);
    lcd_wr_data8(0x0b);
    lcd_wr_data8(0x2a);
    lcd_wr_data8(0x3c);
    lcd_wr_data8(0x55);
    lcd_wr_data8(0x4b);
    lcd_wr_data8(0x08);
    lcd_wr_data8(0x16);
    lcd_wr_data8(0x14);
    lcd_wr_data8(0x19);
    lcd_wr_data8(0x20);
    lcd_wr_reg(0xe1);
    lcd_wr_data8(0xd0);
    lcd_wr_data8(0x00);
    lcd_wr_data8(0x06);
    lcd_wr_data8(0x09);
    lcd_wr_data8(0x0b);
    lcd_wr_data8(0x29);
    lcd_wr_data8(0x36);
    lcd_wr_data8(0x54);
    lcd_wr_data8(0x4b);
    lcd_wr_data8(0x0d);
    lcd_wr_data8(0x16);
    lcd_wr_data8(0x14);
    lcd_wr_data8(0x21);
    lcd_wr_data8(0x20);
    lcd_wr_reg(0x29);

    return 0;
}

/***************************************************************
 * 函数名称: lcd_deinit
 * 说    明: Lcd注销
 * 参    数: 无
 * 返 回 值: 返回0为成功，反之为失败
 ***************************************************************/
unsigned int lcd_deinit()
{
#if LCD_ENABLE_SPI
    IoTSpiDeinit(LCD_SPI_BUS);
#else
    IoTGpioDeinit(LCD_PIN_CS);
    IoTGpioDeinit(LCD_PIN_CLK);
    IoTGpioDeinit(LCD_PIN_MOSI);
#endif
    IoTGpioDeinit(LCD_PIN_RES);
    IoTGpioDeinit(LCD_PIN_DC);

    return 0;
}

/***************************************************************
 * 函数名称: lcd_fill
 * 说    明: 指定区域填充颜色
 * 参    数:
 *       @xsta：指定区域的起始点X坐标
 *       @ysta：指定区域的起始点Y坐标
 *       @xend：指定区域的结束点X坐标
 *       @yend：指定区域的结束点Y坐标
 *       @color：指定区域的颜色
 * 返 回 值: 无
 ***************************************************************/
void lcd_fill(uint16_t xsta, uint16_t ysta, uint16_t xend, uint16_t yend, uint16_t color)
{
    uint16_t i, j;

    /* 设置显示范围 */
    lcd_address_set(xsta, ysta, xend - 1, yend - 1);
    /* 填充颜色 */
#if LCD_ENABLE_SPI
    int cnt = (xend - xsta) * (yend - ysta);
    do {
        for (i = 0; i < SPI_TEMP_LEN && i < cnt; i++) {
            m_spibuf[i] = sw16(color);
        }
        cnt = (cnt > SPI_TEMP_LEN) ? cnt - SPI_TEMP_LEN : 0;
        lcd_writes((uint8_t *)m_spibuf, i * 2);
    } while (cnt);
#else
    for (i = ysta; i < yend; i++) {
        for (j = xsta; j < xend; j++) {
            lcd_wr_data(color);
        }
    }
#endif
}

/***************************************************************
 * 函数名称: lcd_draw_point
 * 说    明: 指定位置画一个点
 * 参    数:
 *       @x：指定点的X坐标
 *       @y：指定点的Y坐标
 *       @color：指定点的颜色
 * 返 回 值: 无
 ***************************************************************/
void lcd_draw_point(uint16_t x, uint16_t y, uint16_t color)
{
    /* 设置光标位置 */
    lcd_address_set(x, y, x, y);
    lcd_wr_data(color);
}

/***************************************************************
 * 函数名称: lcd_draw_line
 * 说    明: 指定位置画一条线
 * 参    数:
 *       @x1：指定线的起始点X坐标
 *       @y1：指定线的起始点Y坐标
 *       @x2：指定线的结束点X坐标
 *       @y2：指定线的结束点Y坐标
 *       @color：指定点的颜色
 * 返 回 值: 无
 ***************************************************************/
void lcd_draw_line(uint16_t x1, uint16_t y1, uint16_t x2, uint16_t y2, uint16_t color)
{
    uint16_t t;
    int xerr = 0, yerr = 0, delta_x, delta_y, distance;
    int incx, incy, uRow, uCol;

    /* 计算坐标增量 */
    delta_x = x2 - x1;
    delta_y = y2 - y1;
    /* 画线起点坐标 */
    uRow = x1;
    uCol = y1;

    if (delta_x > 0) {
        /* 设置单步方向 */
        incx = 1;
    } else if (delta_x == 0) {
        /* 垂直线 */
        incx = 0;
    } else {
        incx    = -1;
        delta_x = -delta_x;
    }

    if (delta_y > 0) {
        incy = 1;
    } else if (delta_y == 0) {
        /* 水平线 */
        incy = 0;
    } else {
        incy    = -1;
        delta_y = -delta_y;
    }

    if (delta_x > delta_y) {
        /* 选取基本增量坐标轴 */
        distance = delta_x;
    } else {
        distance = delta_y;
    }

    for (t = 0; t < distance + 1; t++) {
        /* 画点 */
        lcd_draw_point(uRow, uCol, color);
        xerr += delta_x;
        yerr += delta_y;
        if (xerr > distance) {
            xerr -= distance;
            uRow += incx;
        }
        if (yerr > distance) {
            yerr -= distance;
            uCol += incy;
        }
    }
}

/***************************************************************
 * 函数名称: lcd_draw_rectangle
 * 说    明: 指定位置画矩形
 * 参    数:
 *       @x1：指定矩形的起始点X坐标
 *       @y1：指定矩形的起始点Y坐标
 *       @x2：指定矩形的结束点X坐标
 *       @y2：指定矩形的结束点Y坐标
 *       @color：指定点的颜色
 * 返 回 值: 无
 ***************************************************************/
void lcd_draw_rectangle(uint16_t x1, uint16_t y1, uint16_t x2, uint16_t y2, uint16_t color)
{
    lcd_draw_line(x1, y1, x2, y1, color);
    lcd_draw_line(x1, y1, x1, y2, color);
    lcd_draw_line(x1, y2, x2, y2, color);
    lcd_draw_line(x2, y1, x2, y2, color);
}

/***************************************************************
 * 函数名称: lcd_draw_circle
 * 说    明: 指定位置画圆
 * 参    数:
 *       @x0：指定圆的中心点X坐标
 *       @y0：指定圆的中心点Y坐标
 *       @r：指定圆的半径
 *       @color：指定点的颜色
 * 返 回 值: 无
 ***************************************************************/
void lcd_draw_circle(uint16_t x0, uint16_t y0, uint8_t r, uint16_t color)
{
    int a, b;

    a = 0;
    b = r;

    while (a <= b) {
        lcd_draw_point(x0 - b, y0 - a, color);
        lcd_draw_point(x0 + b, y0 - a, color);
        lcd_draw_point(x0 - a, y0 + b, color);
        lcd_draw_point(x0 - a, y0 - b, color);
        lcd_draw_point(x0 + b, y0 + a, color);
        lcd_draw_point(x0 + a, y0 - b, color);
        lcd_draw_point(x0 + a, y0 + b, color);
        lcd_draw_point(x0 - b, y0 + a, color);
        a++;
        /* 判断要画的点是否过远 */
        if ((a * a + b * b) > (r * r)) {
            b--;
        }
    }
}

/***************************************************************
 * 函数名称: lcd_show_chinese
 * 说    明: 显示汉字串
 * 参    数:
 *       @x：指定汉字串的起始位置X坐标
 *       @y：指定汉字串的起始位置X坐标
 *       @s：指定汉字串（该汉字串为utf-8）
 *       @fc: 字的颜色
 *       @bc: 字的背景色
 *       @sizey: 字号，可选：12、16、24、32
 *       @mode: 0为非叠加模式；1为叠加模式
 * 返 回 值: 无
 ***************************************************************/
void lcd_show_chinese(uint16_t x, uint16_t y, uint8_t *s, uint16_t fc, uint16_t bc, uint8_t sizey, uint8_t mode)
{
#if 1
    uint8_t buffer[128];
    uint32_t buffer_len = 0;
    uint32_t len        = strlen(s);
    memset(buffer, 0, sizeof(buffer));
    /* utf8格式汉字转化为ascii格式 */
    chinese_utf8_to_ascii(s, strlen(s), buffer, &buffer_len);

    for (uint32_t i = 0; i < buffer_len; i += 3, x += sizey) {
        if (sizey == 12) {
            lcd_show_chinese_12x12(x, y, &buffer[i], fc, bc, sizey, mode);
        } else if (sizey == 16) {
            lcd_show_chinese_16x16(x, y, &buffer[i], fc, bc, sizey, mode);
        } else if (sizey == 24) {
            lcd_show_chinese_24x24(x, y, &buffer[i], fc, bc, sizey, mode);
        } else if (sizey == 32) {
            lcd_show_chinese_32x32(x, y, &buffer[i], fc, bc, sizey, mode);
        } else {
            return;
        }
    }
#endif

#if 0
    while (*s != 0)
    {
        if (sizey == 12)
        {
            lcd_show_chinese_12x12(x, y, s, fc, bc, sizey, mode);
        }
        else if (sizey == 16)
        {
            lcd_show_chinese_16x16(x, y, s, fc, bc, sizey, mode);
        }
        else if (sizey == 24)
        {
            lcd_show_chinese_24x24(x, y, s, fc, bc, sizey, mode);
        }
        else if (sizey == 32)
        {
            lcd_show_chinese_32x32(x, y, s, fc, bc, sizey, mode);
        }
        else
        {
            return;
        }
        s += 2;
        x += sizey;
    }
#endif
}

/***************************************************************
 * 函数名称: lcd_show_char
 * 说    明: 显示一个字符
 * 参    数:
 *       @x：指定字符的起始位置X坐标
 *       @y：指定字串的起始位置X坐标
 *       @s：指定字串
 *       @fc: 字的颜色
 *       @bc: 字的背景色
 *       @sizey: 字号，可选：16、24、32
 *       @mode: 0为非叠加模式；1为叠加模式
 * 返 回 值: 无
 ***************************************************************/
void lcd_show_char(uint16_t x, uint16_t y, uint8_t num, uint16_t fc, uint16_t bc, uint8_t sizey, uint8_t mode)
{
    uint8_t temp, sizex, t, m = 0;
    uint16_t i;
    uint16_t TypefaceNum; // 一个字符所占字节大小
    uint16_t x0  = x;
    uint32_t cnt = 0;

    sizex       = sizey / 2;
    TypefaceNum = (sizex / 8 + ((sizex % 8) ? 1 : 0)) * sizey;

    /* 得到偏移后的值 */
    num = num - ' ';
    /* 设置光标位置 */
    lcd_address_set(x, y, x + sizex - 1, y + sizey - 1);

    for (i = 0; i < TypefaceNum; i++) {
        if (sizey == 12) {
            /* 调用6x12字体 */
            temp = ascii_1206[num][i];
        } else if (sizey == 16) {
            /* 调用8x16字体 */
            temp = ascii_1608[num][i];
        } else if (sizey == 24) {
            /* 调用12x24字体 */
            temp = ascii_2412[num][i];
        } else if (sizey == 32) {
            /* 调用16x32字体 */
            temp = ascii_3216[num][i];
        } else {
            return;
        }

        for (t = 0; t < 8; t++) {
            if (!mode) {
                /* 非叠加模式 */
                if (temp & (0x01 << t)) {
#if LCD_ENABLE_SPI
                    m_spibuf[cnt++] = sw16(fc);
#else
                    lcd_wr_data(fc);
#endif
                } else {
#if LCD_ENABLE_SPI
                    m_spibuf[cnt++] = sw16(bc);
#else
                    lcd_wr_data(bc);
#endif
                }

                m++;
                if (m % sizex == 0) {
                    m = 0;
                    break;
                }
            } else {
                /* 叠加模式 */
                if (temp & (0x01 << t)) {
                    /* 画一个点 */
                    lcd_draw_point(x, y, fc);
                }

                x++;
                if ((x - x0) == sizex) {
                    x = x0;
                    y++;
                    break;
                }
            }
        }
    }
#if LCD_ENABLE_SPI
    if (!mode) {
        lcd_writes((uint8_t *)m_spibuf, cnt * 2);
    }
#endif
}

// 获取utf8字节数
uint8_t get_utf8_byte_cnt(uint8_t *src)
{
    uint8_t byte_num = 0;
    uint8_t valuebit = 0x80;

    for (int i = 0; i < 4; i++) {
        if (*src & valuebit) {
            byte_num++;
            valuebit >>= 1;
        } else {
            if (i == 0)
                byte_num++;
            break;
        }
    }

    return byte_num;
}

// 获取字符串点阵宽度
//  sizey 字号
uint32_t get_str_size(uint8_t *s, uint8_t sizey)
{
    if (s == NULL)
        return 0;
    uint32_t len = 0;

    while (*s) {
        if (*s < 0x7f) {
            len += sizey / 2;
            s++;
        } else {
            s += get_utf8_byte_cnt(s);
            len += sizey;
        }
    }
    return len;
}

// lcd 文字显示
void lcd_show(uint16_t x, uint16_t y, const uint8_t *p, uint16_t fc, uint16_t bc, uint8_t sizey)
{
    if (p == NULL)
        return;
    uint8_t *s = (uint8_t *)p;

    while (*s) {
        if (*s < 0x7f) {
            if (x + (sizey / 2) > g_lcd_size.w)
                break;
            lcd_show_char(x, y, *s, fc, bc, sizey, 0);
            s++;
            x += (sizey / 2);
        } else {
            if (x + sizey > g_lcd_size.w)
                break;
            if (sizey == 12) {
                lcd_show_chinese_12x12(x, y, s, fc, bc, sizey, 0);
            } else if (sizey == 16) {
                lcd_show_chinese_16x16(x, y, s, fc, bc, sizey, 0);
            } else if (sizey == 24) {
                lcd_show_chinese_24x24(x, y, s, fc, bc, sizey, 0);
            } else if (sizey == 32) {
                lcd_show_chinese_32x32(x, y, s, fc, bc, sizey, 0);
            } else {
                return;
            }
            s += get_utf8_byte_cnt(s);
            x += sizey;
        }
    }
}

/* MODE=0不特殊处理，=1中间对齐，=2中间对齐清空空余，=3左对齐, =4左对齐清空空余，=5右对齐，=6右对齐清空空余 */
int Printf_Lcd(uint16_t x, uint16_t y, uint16_t fc, uint16_t bc, uint8_t sizey, lcd_screen_align_type_e mode, const char *fmt, ...)
{
    int rc; // return code
    char buf[1024] = {0};
    va_list ap; // for variable args

    va_start(ap, fmt); // init specifying last non-var arg
    rc = vsnprintf(buf, 1024, fmt, ap);
    va_end(ap); // end var args

    int word_len = get_str_size(buf, sizey);
    uint16_t xs  = 0;

    switch (mode) {
        case E_LCD_SCREEN_ALIGN_NONE:
            /* code */
            break;
        case E_LCD_SCREEN_ALIGN_MID:
            x = (g_lcd_size.w > word_len) ? (g_lcd_size.w - word_len) / 2 : 0;
            break;
        case E_LCD_SCREEN_ALIGN_MID_NOP:
            if (g_lcd_size.w > x + word_len + 2) {
                x = (g_lcd_size.w - word_len) / 2;
                lcd_fill(0, y, x, y + sizey, bc);
                xs = x + word_len;
                lcd_fill(xs, y, g_lcd_size.w, y + sizey, bc);
            }
            break;
        case E_LCD_SCREEN_ALIGN_LEFT:
            x = 0;
            break;
        case E_LCD_SCREEN_ALIGN_LEFT_NOP:
            if (g_lcd_size.w > x + word_len + 2) {
                lcd_fill(word_len, y, g_lcd_size.w, y + sizey, bc);
            }
            break;
        case E_LCD_SCREEN_ALIGN_RIGHT:
            x = g_lcd_size.w - word_len;
            break;
        case E_LCD_SCREEN_ALIGN_RIGHT_NOP:
            if (g_lcd_size.w > x + word_len + 2) {
                lcd_fill(0, y, g_lcd_size.w - word_len, y + sizey, bc);
            }
            break;

        default:
            break;
    }
    // printf("lcdprintf:%d,%d,%d-%d,%s\n", x, y, word_len, g_lcd_size.w, buf);
    lcd_show(x, y, buf, fc, bc, sizey);
    return rc;
}

/***************************************************************
 * 函数名称: lcd_show_string
 * 说    明: 显示字符串
 * 参    数:
 *       @x：指定字符的起始位置X坐标
 *       @y：指定字串的起始位置X坐标
 *       @s：指定字串
 *       @fc: 字的颜色
 *       @bc: 字的背景色
 *       @sizey: 字号，可选：16、24、32
 *       @mode: 0为非叠加模式；1为叠加模式
 * 返 回 值: 无
 ***************************************************************/
void lcd_show_string(uint16_t x, uint16_t y, const uint8_t *p, uint16_t fc, uint16_t bc, uint8_t sizey, uint8_t mode)
{
    while (*p != '\0') {
        lcd_show_char(x, y, *p, fc, bc, sizey, mode);
        x += (sizey / 2);
        p++;
    }
}

/***************************************************************
 * 函数名称: lcd_show_int_num
 * 说    明: 显示整数变量
 * 参    数:
 *       @x：指定整数变量的起始位置X坐标
 *       @y：指定整数变量的起始位置X坐标
 *       @num：指定整数变量
 *       @fc: 整数变量的颜色
 *       @bc: 整数变量的背景色
 *       @sizey: 字号，可选：16、24、32
 * 返 回 值: 无
 ***************************************************************/
void lcd_show_int_num(uint16_t x, uint16_t y, uint16_t num, uint8_t len, uint16_t fc, uint16_t bc, uint8_t sizey)
{
    uint8_t t, temp;
    uint8_t enshow = 0;
    uint8_t sizex  = sizey / 2;

    for (t = 0; t < len; t++) {
        temp = (num / mypow(10, len - t - 1)) % 10;
        if (enshow == 0 && t < (len - 1)) {
            if (temp == 0) {
                lcd_show_char(x + t * sizex, y, ' ', fc, bc, sizey, 0);
                continue;
            } else {
                enshow = 1;
            }
        }
        lcd_show_char(x + t * sizex, y, temp + 48, fc, bc, sizey, 0);
    }
}

/***************************************************************
 * 函数名称: lcd_show_float_num1
 * 说    明: 显示两位小数变量
 * 参    数:
 *       @x：指定浮点变量的起始位置X坐标
 *       @y：指定浮点变量的起始位置X坐标
 *       @num：指定浮点变量
 *       @fc: 浮点变量的颜色
 *       @bc: 浮点变量的背景色
 *       @sizey: 字号，可选：16、24、32
 * 返 回 值: 无
 ***************************************************************/
void lcd_show_float_num1(uint16_t x, uint16_t y, float num, uint8_t len, uint16_t fc, uint16_t bc, uint8_t sizey)
{
    uint8_t t, temp, sizex;
    uint16_t num1;

    sizex = sizey / 2;
    num1  = num * 100;
    for (t = 0; t < len; t++) {
        temp = (num1 / mypow(10, len - t - 1)) % 10;
        if (t == (len - 2)) {
            lcd_show_char(x + (len - 2) * sizex, y, '.', fc, bc, sizey, 0);
            t++;
            len += 1;
        }
        lcd_show_char(x + t * sizex, y, temp + 48, fc, bc, sizey, 0);
    }
}

/***************************************************************
 * 函数名称: lcd_show_picture
 * 说    明: 显示图片
 * 参    数:
 *       @x：指定图片的起始位置X坐标
 *       @y：指定图片的起始位置X坐标
 *       @length：指定图片的长度
 *       @width：指定图片的宽度
 *       @pic：指定图片的内容
 * 返 回 值: 无
 ***************************************************************/
void lcd_show_picture(uint16_t x, uint16_t y, uint16_t length, uint16_t width, const uint8_t *pic)
{
    uint16_t i, j;
    uint32_t k = 0;

    lcd_address_set(x, y, x + length - 1, y + width - 1);
#if LCD_ENABLE_SPI
    uint16_t *p = (uint16_t *)pic;

    int cnt = length * width;
    do {
        for (i = 0; i < SPI_TEMP_LEN && i < cnt; i++) {
            uint16_t temp_data = *p++;
            m_spibuf[i]        = temp_data;
        }
        cnt = (cnt > SPI_TEMP_LEN) ? cnt - SPI_TEMP_LEN : 0;
        lcd_writes((uint8_t *)m_spibuf, i * 2);
    } while (cnt);
#else
    for (i = 0; i < length; i++) {
        for (j = 0; j < width; j++) {
            lcd_wr_data8(pic[k * 2]);
            lcd_wr_data8(pic[k * 2 + 1]);
            k++;
        }
    }
#endif
}
