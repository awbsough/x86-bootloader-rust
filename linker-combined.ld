ENTRY(_start)

SECTIONS
{
    /* Boot sector at 0x7C00 */
    . = 0x7C00;

    .boot :
    {
        *(.boot)
    }

    /* Rust code starts at 0x7E00 (right after 512-byte boot sector) */
    . = 0x7E00;

    .text :
    {
        *(.text .text.*)
    }

    .rodata :
    {
        *(.rodata .rodata.*)
    }

    .data :
    {
        *(.data .data.*)
    }

    .bss :
    {
        *(.bss .bss.*)
    }
}
