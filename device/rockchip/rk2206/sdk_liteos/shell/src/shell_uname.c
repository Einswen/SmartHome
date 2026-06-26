#include <stdio.h>

#if (LOGCFG_SHELL == 1)
#include "shcmd.h"
#include "shell.h"
#endif // LOGCFG_SHELL

// 打印软件系统版本号
int shell_uname(int argc, const char *argv[])
{
    printf("OpenHarmony-v3.0LTS, Lockzhiner rk2206 v1.3\n");
    return 0;
}

