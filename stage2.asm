[org 0x8000]
[bits 16]

stage2_start:
    mov ah, 0x0E
    mov al, 'O'
    int 0x10

    mov al, 'K'
    int 0x10

    cli
    xor ax, 0x8000
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x9000

    lgdt [gdt_descriptor]

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp 0x08:protected_mode

[bits 32]
protected_mode:
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

    jmp 0x18:long_mode

[bits 64]
long_mode:
    mov rax, 0xDEADBEEFCAFEBABE
    mov [0x100000], rax
    
.hang:
    hlt
    jmp .hang

align 8
gdt_start:
    dq 0
    dq 0x00CF9A000000FFFF
    dq 0x00CF92000000FFFF
    dq 0x00AF9A000000FFFF
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

align 4096
pml4:
    dq pdpt + 0x03
align 4096
pdpt:
    dq pd + 0x03
align 4096
pd:
    dq 0x00000083

; Pad stage2 to 25 sectors (12800 bytes)
times 12800 - ($ - $$) db 0
