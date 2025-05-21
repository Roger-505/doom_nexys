OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY {
    WAD (rwx)    : ORIGIN = 0x00000000, LENGTH = 5M     /* doom1.wad */
    RAM (wxa!ri) : ORIGIN = 0x00420000, LENGTH = 64M
}

SECTIONS {
    /* Place WAD at 0x00000000 */
    .wad : {
        _binary_doom1_wad_start = .;
        KEEP(*(.wad))
        _binary_doom1_wad_end = .;
    } > WAD

    /* Top of stack is at the end of RAM */
    __stacktop = ORIGIN(RAM) + LENGTH(RAM);

    /* TEXT SECTION: code and read-only data */
    .text ORIGIN(RAM) :
    {
        . = ALIGN(4);
        *(.text.start)
        *(.text)
        *(.text*)
        *(.init)
        *(.gnu.linkonce.t.*)
        *(.rodata)
        *(.rodata*)
        *(.srodata)
        *(.srodata*)
        *(.gnu.linkonce.r.*)
        . = ALIGN(4);
        _etext = .;
        _sidata = _etext; /* Start of initialized data in ROM */
    } > RAM


    /* DATA SECTION: initialized variables (copied from ROM) */
    .data : AT(_sidata)
    {
        . = ALIGN(4);
        _sdata = .;
        _ram_start = .;
        *(.data)
        *(.data*)
        *(.sdata)
        *(.sdata*)
        *(.gnu.linkonce.d.*)
        *(.gnu.linkonce.s.*)
        . = ALIGN(4);
        _edata = .;
    } > RAM

    /* BSS SECTION: zero-initialized variables */
    .bss :
    {
        . = ALIGN(4);
        _sbss = .;
        *(.bss)
        *(.bss*)
        *(.sbss)
        *(.sbss*)
        *(.scommon)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;
    } > RAM

    /* HEAP SECTION: optional dynamic memory start */
    .heap :
    {
        . = ALIGN(4);
        _heap_start = .;
    } > RAM

    /* STACK SECTION: grows down from __stacktop */
    .stack (NOLOAD) :
    {
        _heap_end = .;
        . = . + (__stack_size);
        _sp = .;
    } > RAM

    /* Fallback default stack size */
    /* __stack_size = DEFINED(__stack_size) ? __stack_size : 4K; */
    __stack_size = 128K;
}
