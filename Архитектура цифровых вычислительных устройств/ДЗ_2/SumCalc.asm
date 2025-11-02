global _start           ;делаем метку видимой извне

section .data                         ; секция с данными
    input_a db "Enter a: ", 0         ; сообщение для ввода
    len_in_a equ $ - input_a          ; длина сообщения
    input_b db "Enter b: ", 0         ; сообщение для ввода
    len_in_b equ $ - input_b          ; длина сообщения
    out_msg db "a + b = ", 0          ; сообщение для вывода
    len_out_msg equ $ - out_msg       ; длина сообщения
    len_read dq 0                     ; количество считанных байт
    a dq 0                            ; первое число
    b dq 0                            ; второе число

section .bss                       ; секция bss для неинициализированных данных
    buffer resb 128                ; буфер для считывания из стандартного ввода

section .text                       ; объявление секции кода
_start:                             ; точка входа в программу
    mov rax, 1                      ; 1 - номер системного вызова функции write
    mov rdi, 1                      ; 1 - дескриптор файла стандартного вызова stdout
    mov rsi, input_a                ; адрес строки для вывода
    mov rdx, len_in_a               ; кол-во байт которое нужно записать
    syscall                         ; выполняем системный вызов write

    cmp rax, -1                     ; сравниваем значение которое вернул write
    jz err                          ; если rax = -1 то переход на метку err

    mov rax, 0                      ; номер системного вызова read
    mov rsi, buffer                 ; сообщение для записи
    mov rdi, 0                      ; дескриптор STDIN
    mov rdx, 128                    ; длина считываемого сообщения
    syscall                         ; выполняем системный вызов read

    mov [len_read], rax              ; количество байтов которые были прочитаны
    cmp rax, -1                      ; сравниваем значение которое вернул read
    jz err                           ; если rax = -1 то переход на метку err

    call str_to_num                  ; вызов функции перевода строки в число
    mov [a], rax

    mov rax, 1                      ; 1 - номер системного вызова функции write
    mov rdi, 1                      ; 1 - дескриптор файла стандартного вызова stdout
    mov rsi, out_msg                ; адрес строки для вывода
    mov rdx, len_out_msg            ; кол-во байт которое нужно записать
    syscall                         ; выполняем системный вызов write

    cmp rax, -1                     ; сравниваем значение которое вернул write
    jz err                          ; если rax = -1 то переход на метку err

    mov rax, 1                      ; 1 - номер системного вызова функции write
    mov rdi, 1                      ; 1 - дескриптор файла стандартного вызова stdout
    mov rsi, a               ; адрес строки для вывода
    mov rdx, 8             ; кол-во байт которое нужно записать
    ;add rdx, 2                      ; перевод строки и нуль-терминатор
    syscall                         ; выполняем системный вызов write

    cmp rax, -1                     ; сравниваем значение которое вернул write
    jz err                          ; если rax = length то переход на метку success
    jmp success                     ; иначе на метку err

; функция для перевода строки в число
str_to_num:
    mov rcx, [len_read]       ; инициализируем счетчик длиной строки
    mov rsi, buffer           ; начало исходной строки
    mov rax, 0                ; инициализируем rax нулем

    strloop:                      ; цикл прохода по строке
        mov dl, [rsi]             ; считываем символ из буфера
        imul rax, 10              ; умножение значения в rax на 10 и присваивание результата rax

        cmp dl, '-'
        jz minus

        sub dl, '0'               ; перевод символа в число
        movsx rdx, dl
        add rax, rdx               ; rax = rax + al
        inc rsi                   ; переход к следующему символу
        loop strloop              ; уменьшаем счетчик rcx и переходим на метку strloop, если rcx != 0
    ret
        minus:
            inc rsi                   ; переход к следующему символу
            mov dl, [rsi]             ; считываем символ из буфера
            sub dl, '0'               ; перевод символа в число
            movsx rdx, dl
            sub rax, rdx
            inc rsi                   ; переход к следующему символу
            dec rcx
            loop strloop              ; уменьшаем счетчик rcx и переходим на метку strloop, если rcx != 0
    ret


; успешное завершение программы
success:   
    mov rax, 60                    ; 60 - номер системного вызова exit         
    mov rdi, 123
    syscall                        ; выполняем системный вызов exit

; завершение программы с ошибкой
err:
    mov rax, 60                    ; 60 - номер системного вызова exit
    mov rdi, -1
    syscall                        ; выполняем системный вызов exit
