; --------------------------
; SIMPLE x64 ASSEMBLY LOGGER 
;   WIN64, INTEL SYNTAX
; --------------------------
%define SYSTEMTIME_wYear        0
%define SYSTEMTIME_wMonth       2
%define SYSTEMTIME_wDay         6
%define SYSTEMTIME_wHour        8
%define SYSTEMTIME_wMinute     10
%define SYSTEMTIME_wSecond     12
%define SYSTEMTIME_SIZE        16

global logger_init
global logger_log
global logger_setLevel
global logger_error
global logger_warning
global logger_info
global logger_debug
global logger_trace

extern GetStdHandle
extern WriteFile
extern WriteConsoleA
extern CreateFileA
extern GetSystemTime
extern ExitProcess

section .data
    loggerHandle dq 0
    loggerLevel dq 0
    loggerType dq 0

    LOG_ERROR db " [ERROR] ", 0
    LOG_WARN  db " [WARN]  ", 0
    LOG_INFO  db " [INFO]  ", 0
    LOG_DEBUG db " [DEBUG] ", 0
    LOG_TRACE db " [TRACE] ", 0

    NEW_LINE: db "", 0x0D, 0x0A, 0

    ERROR_INIT db "[LOGGER INIT ERROR]", 0x0A, 0
    TEST1 db "TEST", 0x0A, 0

    system_time times SYSTEMTIME_SIZE db 0
    utc_time_template db "[0000-00-00T00:00:00Z]", 0 ;ISO 8601
    dec_buffer times 6 db 0

section .text

logger_init:
    push rbp
    mov rbp, rsp
    
    cmp rcx, 1
    je .type_console
    cmp rcx, 2
    je .type_file
    jmp .error

.type_console:
    sub rsp, 32
    mov [loggerType], rcx
    mov qword [loggerLevel], 4

    mov rcx, -11
    call GetStdHandle
    mov [loggerHandle], rax

    mov rax, 3001 
    add rsp,32
    pop rbp
    ret

.type_file:
    sub rsp, 64
    mov [loggerType], rcx
    mov qword [loggerLevel], 4

    mov rcx, rdx
    mov rdx, 0x10000000
    mov r8, 0x00000007
    xor r9, r9
    mov qword [rsp + 32], 2
    mov qword [rsp + 40], 128
    mov qword [rsp + 48], 0
    call CreateFileA

    cmp rax, -1
    je .error

    mov [loggerHandle], rax

    mov rax, 3002
    add rsp, 64
    pop rbp
    ret
    
.error:
    sub rsp, 32
    lea rcx, [ERROR_INIT]
    call _writeStdConsole
    mov rcx, -1111
    call ExitProcess

logger_setLevel:
    push rbp
    mov rbp, rsp

    cmp rcx, 1
    je .level_update
    cmp rcx, 2
    je .level_update
    cmp rcx, 3
    je .level_update
    cmp rcx, 4
    je .level_update
    cmp rcx, 5
    je .level_update
    jmp .error

.level_update:
    mov [loggerLevel], rcx
    mov rax, 3101
    pop rbp
    ret
.error:
    mov rax, 5101
    pop rbp
    ret

logger_log:
    push rbp
    push r12
    push r13
    push r14
    push r15
    mov rbp, rsp

    mov r12, rdx
    mov r14, rcx

    cmp rcx, [loggerLevel]
    jg .level_error

    cmp rcx, 1
    je .a
    cmp rcx, 2
    je .a
    cmp rcx, 3
    je .a
    cmp rcx, 4
    je .a
    cmp rcx, 5
    je .a
    jmp .error

.a:
    sub rsp, 32
    call _update_utc_time
    add rsp, 32
    mov r13, [loggerType]
    cmp r13, 1
    je .log_console
    cmp r13, 2
    je .log_file
    jmp .error1

.log_console:
    sub rsp, 48

    lea rcx, [utc_time_template]
    call _strlen
    mov rcx, [loggerHandle]
    lea rdx, [utc_time_template]
    mov r8, rax
    xor r9, r9
    mov qword [rsp + 32], 0
    call WriteConsoleA

    mov rcx, r14
    call _getLevelString
    mov r13, rax
    mov rcx, rax
    call _strlen
    mov rcx, [loggerHandle]
    mov rdx, r13
    mov r8, rax
    xor r9, r9
    mov qword [rsp + 32], 0
    call WriteConsoleA

    mov rcx, r12
    call _strlen
    mov rcx, [loggerHandle]
    mov rdx, r12
    mov r8, rax
    xor r9, r9
    mov qword [rsp + 32], 0
    call WriteConsoleA

    lea rcx, [NEW_LINE]
    call _strlen
    mov rcx, [loggerHandle]
    lea rdx, [NEW_LINE]
    mov r8, rax
    xor r9, r9
    mov qword [rsp + 32], 0
    call WriteConsoleA

    add rsp, 48
   
    mov rax, 3201
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

.log_file:
    sub rsp, 48

    lea rcx, [utc_time_template]
    call _strlen
    mov rcx, [loggerHandle]
    lea rdx, [utc_time_template]
    mov r8, rax
    xor r9, r9
    mov qword [rsp + 32], 0
    call WriteFile

    mov rcx, r14
    call _getLevelString
    mov r13, rax
    mov rcx, rax
    call _strlen
    mov rcx, [loggerHandle]
    mov rdx, r13
    mov r8, rax
    xor r9, r9
    mov qword [rsp + 32], 0
    call WriteFile

    mov rcx, r12
    call _strlen
    mov rcx, [loggerHandle]
    mov rdx, r12
    mov r8, rax
    xor r9, r9
    mov qword [rsp + 32], 0
    call WriteFile

    lea rcx, [NEW_LINE]
    call _strlen
    mov rcx, [loggerHandle]
    lea rdx, [NEW_LINE]
    mov r8, rax
    xor r9, r9
    mov qword [rsp + 32], 0
    call WriteFile

    add rsp, 48

    mov rax, 3202
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

.error:
    mov rax, 5201
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

.error1:
    mov rax, 5202
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

.level_error:
    mov rax, 5203
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

logger_error:
    push rbp
    mov rbp, rsp
    mov rdx, rcx
    mov rcx, 1
    call logger_log
    pop rbp
    ret

logger_warning:
    push rbp
    mov rbp, rsp
    mov rdx, rcx
    mov rcx, 2
    call logger_log
    pop rbp
    ret

logger_info:
    push rbp
    mov rbp, rsp
    mov rdx, rcx
    mov rcx, 3
    call logger_log
    pop rbp
    ret

logger_debug:
    push rbp
    mov rbp, rsp
    mov rdx, rcx
    mov rcx, 4
    call logger_log
    pop rbp
    ret

logger_trace:
    push rbp
    mov rbp, rsp
    mov rdx, rcx
    mov rcx, 5
    call logger_log
    pop rbp
    ret

_getLevelString:
    cmp rcx, 1
    je .log_error
    cmp rcx, 2
    je .log_warning
    cmp rcx, 3
    je .log_info
    cmp rcx, 4
    je .log_debug
    cmp rcx, 5
    je .log_trace
    jmp .error
.log_error:
    lea rax, [LOG_ERROR]
    ret
.log_warning:
    lea rax, [LOG_WARN]
    ret
.log_info:
    lea rax, [LOG_INFO]
    ret
.log_debug:
    lea rax, [LOG_DEBUG]
    ret
.log_trace:
    lea rax, [LOG_TRACE]
    ret
.error:
    lea rax, [LOG_DEBUG]
    ret

_update_utc_time:
    push rbp
    push rdi
    push r12
    mov rbp, rsp
    sub rsp, 32

    lea rcx, [system_time]
    call GetSystemTime

    xor rdi, rdi
    mov ax, word [system_time + SYSTEMTIME_wYear]
    call _hex_to_dec
    mov al, byte [rdi]
    mov byte [utc_time_template + 1], al
    mov al, byte [rdi + 1]
    mov byte [utc_time_template + 2], al
    mov al, byte [rdi + 2]
    mov byte [utc_time_template + 3], al
    mov al, byte [rdi + 3]
    mov byte [utc_time_template + 4], al

    xor rdi, rdi
    mov ax, word [system_time + SYSTEMTIME_wMonth]
    call _hex_to_dec
    mov al, byte [rdi]
    cmp byte [rdi + 1], 0
    jne .two_digits_month
    mov byte [utc_time_template + 6], '0'
    mov byte [utc_time_template + 7], al
    jmp .month_continue
    .two_digits_month:
    mov byte [utc_time_template + 6], al
    mov al, byte [rdi + 1]
    mov byte [utc_time_template + 7], al
    .month_continue:

    xor rdi, rdi
    mov ax, word [system_time + SYSTEMTIME_wDay]
    call _hex_to_dec
    mov al, byte [rdi]
    cmp byte [rdi + 1], 0
    jne .two_digits_day
    mov byte [utc_time_template + 9], '0'
    mov byte [utc_time_template + 10], al
    jmp .day_continue
    .two_digits_day:
    mov byte [utc_time_template + 9], al
    mov al, byte [rdi + 1]
    mov byte [utc_time_template + 10], al
    .day_continue:

    xor rdi, rdi
    mov ax, word [system_time + SYSTEMTIME_wHour]
    call _hex_to_dec
    mov al, byte [rdi]
    cmp byte [rdi + 1], 0
    jne .two_digits_hour
    mov byte [utc_time_template + 12], '0'
    mov byte [utc_time_template + 13], al
    jmp .hour_continue
    .two_digits_hour:
    mov byte [utc_time_template + 12], al
    mov al, byte [rdi + 1]
    mov byte [utc_time_template + 13], al
    .hour_continue:

    xor rdi, rdi
    mov ax, word [system_time + SYSTEMTIME_wMinute]
    call _hex_to_dec
    mov al, byte [rdi]
    cmp byte [rdi + 1], 0
    jne .two_digits_minute
    mov byte [utc_time_template + 15], '0'
    mov byte [utc_time_template + 16], al
    jmp .minute_continue
    .two_digits_minute:
    mov byte [utc_time_template + 15], al
    mov al, byte [rdi + 1]
    mov byte [utc_time_template + 16], al
    .minute_continue:

    xor rdi, rdi
    mov ax, word [system_time + SYSTEMTIME_wSecond]
    call _hex_to_dec
    mov al, byte [rdi]
    cmp byte [rdi + 1], 0
    jne .two_digits_second
    mov byte [utc_time_template + 18], '0'
    mov byte [utc_time_template + 19], al
    jmp .second_continue
    .two_digits_second:
    mov byte [utc_time_template + 18], al
    mov al, byte [rdi + 1]
    mov byte [utc_time_template + 19], al
    .second_continue:

    add rsp, 32
    xor rax, rax
    pop r12
    pop rdi
    pop rbp
    ret

_hex_to_dec:
    mov cx, 10
    mov rdi, dec_buffer + 5
    mov byte [rdi], 0

    test ax, ax
    jnz .convert_loop

    dec rdi
    mov byte [rdi], '0'
    ret

.convert_loop:
    xor dx, dx
    div cx       
    add dl, '0'
    dec rdi
    mov [rdi], dl
    test ax, ax
    jnz .convert_loop
    ret

_writeStdConsole:
    push rbp
    push r12
    push r13
    
    mov r12, rcx

    call _strlen
    mov r13, rax

    sub rsp, 48

    mov rcx, -11
    call GetStdHandle

    mov rcx, rax
    mov rdx, r12
    mov r8, r13
    xor r9, r9
    mov qword [rsp + 32], 0
    call WriteConsoleA

    add rsp, 48

    xor rax, rax
    pop r13
    pop r12
    pop rbp
    ret

_strlen:
    push rbp
    mov rbp, rsp
    push r12
    push r13           
    xor rax, rax
.loop:
    mov r12b, byte [rcx + rax]
    cmp r12b, 0
    je .done
    inc rax
    jmp .loop
.done:
    pop r13
    pop r12
    pop rbp
    ret
