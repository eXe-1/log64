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
    logger_init(FILE_LOGGER, "logger1.txt");
    //from now on message will be printed to the file and no longer to the console
    logger_warning("msg5"); //this message will be printed in logger1.txt
    return 0;
}
```




  

