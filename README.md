# log64
Simple minimal logger written in assembler. <br>

**I'm not a professional programmer. This is just a simple project I made to learn and understand assembly.** <br>
**It is neither efficient nor safe.** <br>

## Basic Information

Intel Syntax, win64 <br>
Uses WinAPI only: 
```
GetStdHandle
WriteFile
WriteConsoleA
CreateFileA
GetSystemTime
ExitProcess
```
All functions are in kernel32 <br>

## Assemble
Example:
```
nasm -f win64 logger.asm
```

## C Implementation
```c
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
```
link with logger.obj

## Functions

### init
```c
extern int logger_init(int i, char* str);
```
i = 1 -> console logger <br>
i = 2 -> file logger <br>
str -> filename (gets ignored if i==1)
if file exists it gets overwritten <br>
return: <br>
3001 created console logger <br>
3002 created file logger <br>
5001 error 

### setLevel
```c
extern int logger_setLevel(int level);
```
level -> logger level <br>
return: <br>
3101 updated logger level <br>
5101 error

### log
```c
extern int logger_log(int level, char* str);
```
level -> level of message <br>
str -> message <br>
return: <br>
3201 logged to console <br>
3202 logged to file <br>
5201 unknown level <br>
5202 loggerType error (shouldn't be possible) <br>
5203 level greater than logger level (from setLevel) <br>

```c
extern int logger_error(char* str);
extern int logger_warning(char* str);
extern int logger_info(char* str);
extern int logger_debug(char* str);
extern int logger_trace(char* str);
```
str -> message <br>
calls logger_log with specific level <br>
return: <br>
same as logger_log

## Example

```c
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

int main() {
    logger_init(CONSOLE_LOGGER, "argument gets ignored");
    logger_setLevel(LEVEL_INFO);
    logger_info("msg1"); //will be printed
    logger_debug("msg2"); //wont be printed
    logger_log(LEVEL_TRACE, "msg3"); //wont be printed
    logger_log(LEVEL_ERROR, "msg4"); //will be printed
    return 0;
}
```




  

