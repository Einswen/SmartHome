#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

#include "los_tick.h"
#include "los_task.h"
#include "los_config.h"

#include "lz_hardware.h"

#if (LOGCFG_SHELL == 1)
#include "shcmd.h"
#include "shell.h"
#endif // LOGCFG_SHELL

#define TAG                 "hwinfo"

enum enum_flash_operator
{
    E_FLASH_OPER_READ = 0,
    E_FLASH_OPER_WRITE,
    E_FLASH_OPER_ERASE,
    E_FLASH_OPER_MAX,
};
#define STR_FLASH_OPER_READ     "read"
#define STR_FLASH_OPER_WRITE    "write"
#define STR_FLASH_OPER_ERASE    "erase"

#define FLASH_MAXSIZE           (4096)

static unsigned int m_flash_operator = E_FLASH_OPER_READ;
static unsigned int m_flash_address = 0;
static unsigned int m_flash_size = 0;
static unsigned char m_flash_value = 0;
static unsigned char m_flash_data[FLASH_MAXSIZE];

static unsigned int address_to_offset(unsigned int address)
{
    unsigned int offset = (address / FLASH_MAXSIZE) * FLASH_MAXSIZE;
    return offset;
}

static unsigned int size_to_count(unsigned int size)
{
    unsigned int count = (size / FLASH_MAXSIZE);
    if ((size % FLASH_MAXSIZE) != 0)
    {
        count++;
    }
    return (count * FLASH_MAXSIZE);
}

static void usage(const char *cmd)
{
    printf("Usage: %s <oper> <addr> [size/value]\n", cmd);
    printf("        oper: read/write/erase\n");
    printf("        addr: flash address\n");
    printf("        size: flash size\n");
    printf("        value: flash value\n");
    printf("\n");
}

static int parse_opt(int argc, const char *argv[])
{
    if ((argc == 4) && (strncmp(argv[1], STR_FLASH_OPER_READ, strlen(STR_FLASH_OPER_READ)) == 0))
    {
        m_flash_operator = E_FLASH_OPER_READ;
        m_flash_address = strtol(argv[2], NULL, 16);
        m_flash_size = strtol(argv[3], NULL, 16);
    }
    else if ((argc == 4) && (strncmp(argv[1], STR_FLASH_OPER_WRITE, strlen(STR_FLASH_OPER_WRITE)) == 0))
    {
        m_flash_operator = E_FLASH_OPER_WRITE;
        m_flash_address = strtol(argv[2], NULL, 16);
        m_flash_value = strtol(argv[3], NULL, 16);
    }
    else if ((argc == 4) && (strncmp(argv[1], STR_FLASH_OPER_ERASE, strlen(STR_FLASH_OPER_ERASE)) == 0))
    {
        m_flash_operator = E_FLASH_OPER_ERASE;
        m_flash_address = strtol(argv[2], NULL, 16);
        m_flash_size = strtol(argv[3], NULL, 16);
    }
    else
    {
        usage(argv[0]);
        return __LINE__;
    }
    
    return 0;
}

int shell_flash(int argc, const char *argv[])
{
    m_flash_operator = E_FLASH_OPER_READ;
    m_flash_address = 0;
    m_flash_size = FLASH_MAXSIZE;
    memset(m_flash_data, 0, sizeof(m_flash_data));
    
    if (parse_opt(argc, argv) != 0)
    {
        return __LINE__;
    }
    
    switch (m_flash_operator)
    {
    case E_FLASH_OPER_READ:
        {
            unsigned int offset = address_to_offset(m_flash_address);
            unsigned int count = size_to_count(m_flash_size);
            
            FlashInit();
            for (unsigned int i = offset; i < (offset + count); i += FLASH_MAXSIZE)
            {
                memset(m_flash_data, 0, sizeof(m_flash_data));
                FlashRead(i, FLASH_MAXSIZE, m_flash_data);
                for (unsigned int j = 0; j < FLASH_MAXSIZE; j += 16)
                {
                    printf("[%08x]: ", i + j);
                    printf("%02x ", m_flash_data[j + 0]);
                    printf("%02x ", m_flash_data[j + 1]);
                    printf("%02x ", m_flash_data[j + 2]);
                    printf("%02x ", m_flash_data[j + 3]);
                    printf("%02x ", m_flash_data[j + 4]);
                    printf("%02x ", m_flash_data[j + 5]);
                    printf("%02x ", m_flash_data[j + 6]);
                    printf("%02x ", m_flash_data[j + 7]);
                    printf("  ");
                    printf("%02x ", m_flash_data[j + 8]);
                    printf("%02x ", m_flash_data[j + 9]);
                    printf("%02x ", m_flash_data[j + 10]);
                    printf("%02x ", m_flash_data[j + 11]);
                    printf("%02x ", m_flash_data[j + 12]);
                    printf("%02x ", m_flash_data[j + 13]);
                    printf("%02x ", m_flash_data[j + 14]);
                    printf("%02x ", m_flash_data[j + 15]);
                    printf("\n");
                }
            }
        }
        break;
        
    case E_FLASH_OPER_WRITE:
        {
            unsigned int offset = address_to_offset(m_flash_address);
            unsigned int count = size_to_count(m_flash_size);
            
            FlashInit();
            memset(m_flash_data, 0, sizeof(m_flash_data));
            FlashRead(offset, FLASH_MAXSIZE, m_flash_data);
            m_flash_data[m_flash_address - offset] = (m_flash_value) & 0xff;
            FlashErase(offset, FLASH_MAXSIZE);
            FlashWrite(offset, FLASH_MAXSIZE, m_flash_data, 0);
        }
        break;
        
    case E_FLASH_OPER_ERASE:
        {
            unsigned int offset = address_to_offset(m_flash_address);
            unsigned int count = size_to_count(m_flash_size);
            
            FlashInit();
            for (unsigned int i = offset; i < (offset + count); i += FLASH_MAXSIZE)
            {
                FlashErase(i, FLASH_MAXSIZE);
                printf("Erase %08x\n", i);
            }
        }
        break;
        
    default:
        printf("Error: flash operator(%d) is not supported!\n", m_flash_operator);
        break;
    }
    
    return 0;
}
