[BITS 16]
ORG 0x8000

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax

    call enable_a20

    lgdt [gdtr]

    mov eax, cr0
    or  eax, 1
    mov cr0, eax
    jmp 0x08:prot_entry

enable_a20:
    in   al, 0x64
.wait_in:
    test al, 2
    jnz  .wait_in
    mov  al, 0xD1
    out  0x64, al
.wait_out:
    in   al, 0x64
    test al, 2
    jnz  .wait_out
    mov  al, 0xDF
    out  0x60, al
.wait_done:
    in   al, 0x64
    test al, 2
    jnz  .wait_done
    ret

[BITS 32]
prot_entry:
    ;— Segments plats
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000

    mov  eax, cr4
    or   eax, (1 << 5)
    mov  cr4, eax

    mov  eax, pml4
    mov  cr3, eax

    mov  ecx, 0xC0000080
    rdmsr
    or   eax, (1 << 8)
    wrmsr

    mov  eax, cr0
    or   eax, (1 << 31)
    mov  cr0, eax

    jmp  0x18:long_entry

[BITS 64]
long_entry:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov   edi, 0x000B8000
    mov   ecx, 80*25
    mov   ax, ' ' | (0x07 << 8)
    cld
    rep   stosw

    mov   ax, 'O' | (0x02 << 8)
    mov   [0xB8000], ax
    mov   ax, 'K' | (0x02 << 8)
    mov   [0xB8000+2], ax

.hang:
    hlt
    jmp .hang

; GDT (null, code32, data32, code64, data64)
align 8
gdt_start:
    dq 0x0000000000000000
    dq 0x00CF9A000000FFFF
    dq 0x00CF92000000FFFF
    dq 0x00AF9A000000FFFF
    dq 0x00AF92000000FFFF
gdt_end:
gdtr:
    dw gdt_end - gdt_start - 1
    dd gdt_start

align 4096
pml4:
    dq pml4_pdpt + 3
    times 511 dq 0

align 4096
pml4_pdpt:
    dq pd_table + 3
    times 511 dq 0

align 4096
pd_table:
    dq 0x0000000000000083
    dq 0x0000000000200083
    dq 0x0000000000400083
    dq 0x0000000000600083
    dq 0x0000000000800083
    dq 0x0000000000A00083
    dq 0x0000000000C00083
    dq 0x0000000000E00083
    times 504 dq 0

times 16384 - ($ - $$) dq 0