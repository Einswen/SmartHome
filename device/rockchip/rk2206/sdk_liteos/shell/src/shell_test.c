#include <stdio.h>

#if (LOGCFG_SHELL == 1)
#include "shcmd.h"
#include "shell.h"
#endif // LOGCFG_SHELL

int shell_test(int argc, const char *argv[])
{
    printf("Hello World\n");
    return 0;
}
