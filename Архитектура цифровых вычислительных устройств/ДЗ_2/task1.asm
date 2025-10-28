global _start           ;делаем метку видимой извне

section .data                       ; секция с данными
    input_msg db "Enter sting: ", 0    ; сообщение для ввода
    len_in_msg equ $ - input_msg    ; длина сообщения
    out_msg db "Reversed string: ", 0  ; сообщение для вывода
    len_out_msg equ $ - out_msg     ; длина сообщения
    len_read dq 0                   ; количество считанных байт

section .bss                       ; секция bss для неинициализированных данных
    buffer resb 128                ; буфер для считывания из стандартного ввода

section .text                       ; объявление секции кода
_start:                             ; точка входа в программу
    mov rax, 1                      ; 1 - номер системного вызова функции write
    mov rdi, 1                      ; 1 - дескриптор файла стандартного вызова stdout
    mov rsi, input_msg              ; адрес строки для вывода
    mov rdx, len_in_msg             ; кол-во байт которое нужно записать
    syscall                         ; выполняем системный вызов write

    cmp rax, -1                     ; сравниваем значение которое вернул write
    jz err                          ; если rax = -1 то переход на метку err

    mov rax, 0                      ; номер системного вызова read
    mov rsi, buffer                 ; сообщение для записи
    mov rdi, 0                      ; дескриптор STDIN
    mov rdx, 128                    ; длина считываемого сообщения
    syscall

    mov [len_read], rax              ; количество байтов которые были прочитаны
    cmp rax, -1                      ; сравниваем значение которое вернул read
    jz err                           ; если rax = -1 то переход на метку err

    mov rax, 1                      ; 1 - номер системного вызова функции write
    mov rdi, 1                      ; 1 - дескриптор файла стандартного вызова stdout
    mov rsi, out_msg                ; адрес строки для вывода
    mov rdx, len_out_msg            ; кол-во байт которое нужно записать
    syscall                         ; выполняем системный вызов write

    cmp rax, -1                     ; сравниваем значение которое вернул write
    jz err                          ; если rax = -1 то переход на метку err

    mov rax, 1                     ; 1 - номер системного вызова функции write
    mov rdi, 1                     ; 1 - дескриптор файла стандартного вызова stdout
    mov rsi, buffer                ; адрес строки для вывода
    mov rdx, [len_read]            ; кол-во байт которое нужно записать
    syscall                        ; выполняем системный вызов write

    cmp rax, 8                     ; сравниваем значение которое вернул write
    jz success                     ; если rax = length то переход на метку success
    jmp err                        ; иначе на метку err

success:   
    mov rax, 60                    ; 60 - номер системного вызова exit         
    mov rdi, 0
    syscall                        ; выполняем системный вызов exit

err:
    mov rdi, rax
    mov rax, 60                    ; 60 - номер системного вызова exit
    syscall                        ; выполняем системный вызов exit
