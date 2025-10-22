global _start

section .data
    msg db 'Hello, world', 0xa   ; сообщение с переводом строки
    len equ $ - msg              ; длина сообщения
    filename db 'task2.txt', 0    ; имя файла с нулевым байтом
    lenfilename equ $ - filename ; длина имени файла
    fd dq 0                      ; переменная для хранения дескриптора файла

section .text
_start:
    mov rdi, filename
    mov rsi, 0102o     ; флаги: O_CREAT и O_RDWR (создать файл если не существует, открыть для чтения и записи)
    mov rdx, 0666o     ; права доступа: rw-rw-rw- (чтение и запись для всех)
    mov rax, 2         ; номер системного вызова open
    syscall

    mov [fd], rax      ; сохраняем дескриптор файла
    mov rdx, len       ; длина сообщения
    mov rsi, msg       ; сообщение для записи
    mov rdi, [fd]      ; дескриптор файла
    mov rax, 1         ; номер системного вызова write
    syscall

    mov rdi, [fd]      ; дескриптор файла для закрытия
    mov rax, 3         ; номер системного вызова close
    syscall

    mov rax, 60        ; номер системного вызова exit
    syscall
