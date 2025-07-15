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

    dd 0x0000FFFF
    dd 0x00AD9A00
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

    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    mov eax, pml4
    mov cr3, eax

    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    jmp 0x18:long_mode_start

; Mode long (64 bits)

[bits 64]
long_mode_start;
    mov rax, 0xDEADBEEFCAFEBABE
    mov [0x100000], rax

.hang:
    jmp .hang

; Creation de la pgination

align 4096
pml4:
    dq pdpt | 0x03

align 4096
pdpt:
    dq pd | 0x03

align 4096
pd:
    dq 0x00000083

; Padding jusqu’à 512 octets + signature

times 510 - ($ - $$) db 0
dw 0xAA55
