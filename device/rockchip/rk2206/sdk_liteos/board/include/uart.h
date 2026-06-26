#ifndef _LITEOS_UART_H
#define _LITEOS_UART_H
#ifdef __cplusplus
#if __cplusplus
extern "C" {
#endif
#endif

#include "los_event.h"
#include "los_compiler.h"

extern VOID UartDebugInit(VOID);
extern INT32 UartGetc(VOID);


#if (LOSCFG_USE_SHELL == 1)
extern EVENT_CB_S g_shellInputEvent;
#endif

#ifdef __cplusplus
#if __cplusplus
}
#endif // __cplusplus
#endif // __cplusplus
#endif // _LITEOS_UART_H