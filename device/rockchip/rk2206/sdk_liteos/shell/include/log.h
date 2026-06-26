#include <stdio.h>
#include <string.h>

// 日志总开关 - 取消注释关闭所有日志
#define ENABLE_LOGGING

#define __FILENAME__ (strrchr(__FILE__, '/') ? strrchr(__FILE__, '/') + 1 : (strrchr(__FILE__, '\\') ? strrchr(__FILE__, '\\') + 1 : __FILE__))

#ifdef ENABLE_LOGGING
#define LOG(level, format, ...)            \
    printf("[%s:%d][%s]: " format "\n", \
           __FILENAME__, __LINE__, level, ##__VA_ARGS__)
#else
#define LOG(level, format, ...)
#endif

#define LOG_DEBUG(format, ...) LOG("DEBUG", format, ##__VA_ARGS__)
#define LOG_INFO(format, ...)  LOG("INFO", format, ##__VA_ARGS__)
#define LOG_WARN(format, ...)  LOG("WARN", format, ##__VA_ARGS__)
#define LOG_ERROR(format, ...) LOG("ERROR", format, ##__VA_ARGS__)