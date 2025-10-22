global _start                      ; делаем метку метку _start видимой извне
 
section .data                      ; секция данных
    message db  "Hello world!",10  ; строка для вывода на консоль
    length  equ $ - message
 
section .text                      ; объявление секции кода
_start:                            ; точка входа в программу
    mov rax, 1                     ; 1 - номер системного вызова функции write
    mov rdi, 1                     ; 1 - дескриптор файла стандартного вызова stdout
    mov rsi, message               ; адрес строки для вывод
    mov rdx, length                ; количество байтов
    syscall                        ; выполняем системный вызов write

    cmp rax, length                ; сравниваем значение которое вернул write
    mov rax, 60                    ; 60 - номер системного вызова exit
    jz success                     ; если rax = length то переход на метку success
    jmp err                        ; иначе на метку err

success:            
    mov rdi, 0
    syscall                        ; выполняем системный вызов exit

err:
    mov rdi, rax
    syscall                        ; выполняем системный вызов exit
