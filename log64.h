#pragma once
#define LEVEL_ERROR 1
#define LEVEL_WARNING 2
#define LEVEL_INFO 3
#define LEVEL_DEBUG 4
#define LEVEL_TRACE 5
#define CONSOLE_LOGGER 1
#define FILE_LOGGER 2
extern int logger_init(int i, char* str);
extern int logger_setLevel(int level);
extern int logger_log(int level, char* str);
extern int logger_error(char* str);
extern int logger_warning(char* str);
extern int logger_info(char* str);
extern int logger_debug(char* str);
extern int logger_trace(char* str);
