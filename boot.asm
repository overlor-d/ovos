[org 0x7C00]
[bits 16]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; load stage2 after this sector
    mov ax, 0x8000
    mov es, ax
    xor bx, bx
    mov ah, 0x02
    mov al, STAGE2_SECTORS
    mov ch, 0
    mov cl, 1
    mov dh, 0
    ; drive number is already in DL
    int 0x13
    jc .disk_error

    jmp 0x8000:0

.disk_error:
    mov ah, 0x0E
    mov al, 'E'
    int 0x10
    jmp $

STAGE2_SECTORS equ 25

; padding and signature
 times 510 - ($ - $$) db 0
 dw 0xAA55
