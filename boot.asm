[BITS 16]           ; Start in 16-bit real mode

section .boot
global start

start:
    ; Disable interrupts during mode switch
    cli

    ; Clear segment registers
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00      ; Stack grows downward from boot sector

    ; Clear screen (fill VGA buffer with spaces)
    mov ax, 0xB800
    mov es, ax
    xor di, di
    mov cx, 2000        ; 80x25 = 2000 characters
    mov ax, 0x0F20      ; Space character with white on black
    rep stosw           ; Repeat store word

    ; Reset segment for disk loading
    xor ax, ax
    mov es, ax

    ; Load Stage 2 (Rust code) from disk into memory at 0x7E00
    ; TODO(human): Set the number of sectors to load
    ; Each sector is 512 bytes. Calculate: (Rust code size / 512) + 1
    mov ah, 0x02        ; BIOS read sector function
    mov al, 1          ; Number of sectors to read (TEMPORARY - you'll adjust this)
    mov ch, 0           ; Cylinder 0
    mov cl, 2           ; Start at sector 2 (sector 1 is boot sector)
    mov dh, 0           ; Head 0
    mov dl, 0x80        ; Drive number (0x80 = first hard disk)
    mov bx, 0x7E00      ; Load to memory address 0x7E00 (right after boot sector)
    int 0x13            ; Call BIOS disk interrupt

    jc disk_error       ; If carry flag set, disk read failed

    ; Load GDT
    lgdt [gdt_descriptor]

    ; Enable protected mode by setting bit 0 of CR0
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; Far jump to flush CPU pipeline and load CS with 32-bit code selector
    jmp 0x08:protected_mode

[BITS 32]           ; Now in 32-bit protected mode
protected_mode:
    ; Set up segment registers for 32-bit data segment
    mov ax, 0x10        ; 0x10 is the offset to data descriptor in GDT
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000    ; Set up stack at 576KB (safe location)

    ; Debug: Write "32" to show we're in protected mode
    mov edi, 0xB8000
    mov byte [edi], '3'
    mov byte [edi+1], 0x0A  ; Green on black
    mov byte [edi+2], '2'
    mov byte [edi+3], 0x0A

    ; Call Rust code!
    extern _start
    call _start

    ; If _start returns (it shouldn't), halt
    hlt
    jmp $               ; Infinite loop

; Global Descriptor Table
align 4
gdt_start:
    ; Null descriptor (required)
    dq 0x0000000000000000

    ; Code segment descriptor
    ; 32-bit code segment covering all 4GB of memory
    ; Access: 0x9A (present, ring 0, executable)
    ; Flags: 0xCF (4KB granularity, 32-bit)
    dq 0x00CF9A000000FFFF

    ; Data segment descriptor
    ; 32-bit data segment covering all 4GB of memory
    ; Access: 0x92 (present, ring 0, writable)
    ; Flags: 0xCF (4KB granularity, 32-bit)
    dq 0x00CF92000000FFFF

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; GDT size
    dd gdt_start                 ; GDT address

disk_error:
    ; Display "E" for error in red
    mov ax, 0xB800
    mov es, ax
    mov word [es:0], 0x0C45    ; 'E' in red (0x0C)
    hlt
    jmp $

; Note: Boot signature will be added by build script at byte 510-511
