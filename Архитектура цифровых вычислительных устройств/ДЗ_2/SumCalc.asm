global _start           ;делаем метку видимой извне

section .data                         ; секция с данными
    input_a db "Enter a: ", 0         ; сообщение для ввода
    len_in_a equ $ - input_a          ; длина сообщения
    input_b db "Enter b: ", 0         ; сообщение для ввода
    len_in_b equ $ - input_b          ; длина сообщения
    out_msg db "a + b = ", 0          ; сообщение для вывода
    len_out_msg equ $ - out_msg       ; длина сообщения
    len_read dq 0                     ; количество считанных байт
    a dq 0                            ; первое число 2 байта
    b dq 0                            ; второе число 2 байта
    sign dq 1                         ; знак числа для функции num_to_str
    divisor dq 10                     ; делитель для функции num_to_str

section .bss                       ; секция bss для неинициализированных данных
    buffer resb 128                ; буфер для считывания из стандартного ввода
    result resb 128

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
    call num_to_str
    mov [len_read], rdx

    mov rax, 1                      ; 1 - номер системного вызова функции write
    mov rdi, 1                      ; 1 - дескриптор файла стандартного вызова stdout
    mov rsi, out_msg                ; адрес строки для вывода
    mov rdx, len_out_msg            ; кол-во байт которое нужно записать
    syscall                         ; выполняем системный вызов write

    cmp rax, -1                     ; сравниваем значение которое вернул write
    jz err                          ; если rax = -1 то переход на метку err

    mov rax, 1                      ; 1 - номер системного вызова функции write
    mov rdi, 1                      ; 1 - дескриптор файла стандартного вызова stdout
    mov rsi, buffer               ; адрес строки для вывода
    mov rdx, len_read             ; кол-во байт которое нужно записать
    ;add rdx, 2                      ; перевод строки и нуль-терминатор
    syscall                         ; выполняем системный вызов write

    cmp rax, -1                     ; сравниваем значение которое вернул write
    jz err                          ; если rax = length то переход на метку success
    jmp success                     ; иначе на метку err


; функция для перевода строки в число
; Вход: строка из buffer
; Выход: число в rax
str_to_num:
    mov rcx, [len_read]       ; инициализируем счетчик длиной строки
    dec rcx
    mov rsi, buffer           ; начало исходной строки
    mov rax, 0                ; инициализируем rax нулем
    mov rbx, 1                ; инициализируем rbx единицей(обозначает знак числа)

    mov dl, [rsi]             ; считываем символ из буфера
    cmp dl, '-'               ; сравнение со знаком "-"
    jne strloop               ; если считанный символ это не минус то переход к метке strloop
    inc rsi                   ; переход к следующему символу
    dec rcx                   ; увеличиваем счетчик цикла
    mov rbx, -1               ; число будет отрицательным

    strloop:                      ; цикл прохода по строке
        mov dl, [rsi]             ; считываем символ из буфера
        imul rax, 10              ; умножение значения в rax на 10 и присваивание результата rax

        sub dl, '0'               ; перевод символа в число
        movzx rdx, dl             ; расширяем до 64 бит
        add rax, rdx              ; rax = rax + al
        inc rsi                   ; переход к следующему символу
        loop strloop              ; уменьшаем счетчик rcx и переходим на метку strloop, если rcx != 0
    imul rax, rbx
    ret


; функция для перевода числа в строку
; Вход: число в rax
; Выход: строка в result
;        длина строки в rdx
num_to_str:
    mov rsi, buffer             ; начало строки с числом
    mov rbx, 1                  ; инициализируем rbx единицей(обозначает знак числа)
    mov rcx, 0                  ; длина строки с числом

    cmp rax, 0                  ; сравнение переводимого числа с нулем
    ;je zero                     ; если ноль
    jg positive                 ; если больше нуля

    negative:                   ; иначе метка negative
        mov rbx, -1
        imul rax, -1
        inc rcx

    positive:
        cqo                     ;расширяем регистр RDX знаковым битом из RAX
        idiv qword [divisor]
        add rdx, '0'            ; преобразование в символ
        mov byte [rsi], dl
        inc rsi
        inc rcx
        
        cmp rax, 0
        jne positive

    mov rdi, result
    mov rdx, rcx
    make_str:
        cmp rbx, 1
        je digits
        mov byte [rdi], '-'
        inc rdi
        mov rbx, 1

        digits:
            mov al, [rsi]
            mov [rdi], al
            dec rsi
            inc rdi
            dec rcx
            test rcx, rcx
            jnz make_str
    mov byte [rdi], 0
    inc rdx

    ret


; успешное завершение программы
success:   
    mov rax, 60                    ; 60 - номер системного вызова exit         
    mov rdi, [a]
    syscall                        ; выполняем системный вызов exit

; завершение программы с ошибкой
err:
    mov rax, 60                    ; 60 - номер системного вызова exit
    mov rdi, [a]
    syscall                        ; выполняем системный вызов exit
