[BITS 16]
ORG 0x7C00

start:
    ; suppression du curseur blanc en bas
    mov ah, 0x01
    mov ch, 0x20
    mov cl, 0x00
    int 0x10

    cli
    xor ax, ax
    mov ds, ax
    mov es, ax

    mov [boot_drive], dl

    mov ah, 0x02
    mov al, 127
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, [boot_drive]
    mov bx, 0x8000
    int 0x13
    jc .disk_error

    jmp 0x0000:0x8000

.disk_error:
    hlt
    jmp .disk_error

boot_drive db 0

; padding + signature BIOS
times 510 - ( $ - $$ ) db 0
dw 0xAA55
