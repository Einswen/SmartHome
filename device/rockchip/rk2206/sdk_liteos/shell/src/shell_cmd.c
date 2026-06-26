#include <stddef.h>
#include <string.h>
#include <securec.h>
#include <stdlib.h>
#include <stdio.h>

#include "los_tick.h"
#include "los_task.h"
#include "los_config.h"
#include "los_interrupt.h"
#include "los_debug.h"
#include "los_compiler.h"

#include "lz_hardware.h"
#include "shell_cmd.h"
#include "shell_test.h"
#include "shell_uname.h"
#include "shell_hwinfo.h"
#include "shell_flash.h"
#include "shell_ifconfig.h"
#include "shell_tcp.h"

#if (LOGCFG_SHELL == 1)
#include "shcmd.h"
#include "shell.h"
#endif // LOGCFG_SHELL

void shell_cmd_init()
{
#if (LOGCFG_SHELL == 1)
    osCmdReg(CMD_TYPE_STD, "test", 0, (CMD_CBK_FUNC)shell_test);
    osCmdReg(CMD_TYPE_STD, "uname", 0, (CMD_CBK_FUNC)shell_uname);
    osCmdReg(CMD_TYPE_STD, "hwinfo", XARGS, (CMD_CBK_FUNC)shell_hwinfo);
    osCmdReg(CMD_TYPE_STD, "flash", XARGS, (CMD_CBK_FUNC)shell_flash);
    osCmdReg(CMD_TYPE_STD, "ifconfig", XARGS, (CMD_CBK_FUNC)shell_ifconfig);
    osCmdReg(CMD_TYPE_STD, "tcp", XARGS, (CMD_CBK_FUNC)shell_tcp);
#endif // // LOGCFG_SHELL
}

