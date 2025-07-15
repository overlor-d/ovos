; boot.asm
[org 0x7C00]
[bits 16]

start:
    cli

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    lgdt [gdt_descriptor]

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp 0x08:protected_mode_start

; GDT (Global Descriptor Table)

gdt_start:
    dd 0x00000000
    dd 0x00000000

    dd 0x0000FFFF
    dd 0x00CF9A00

    dd 0x0000FFFF
    dd 0x00CF9200

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

; Mode protégé (32 bits)

[bits 32]
protected_mode_start:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x9000

    mov eax, 0xCAFEBABE
    mov [0x10000], eax

.hang:
    jmp .hang

; Padding jusqu’à 512 octets + signature

times 510 - ($ - $$) db 0
dw 0xAA55
