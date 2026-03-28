ENTRY(reset_handler)

/* stack starting address, this is equal to end of the RAM memory (0x20000000 + 64K) */
_estack = ORIGIN(RAM) + LENGTH(RAM);

/* giving linker memory locations of RAM and Flash */
MEMORY
{
    /* RAM (permissions) start address, length */
    /* FLASH (permissions: write is not given) start addr, length */
    RAM (xrw)   : ORIGIN = 0x20000000,   LENGTH = 64K
    FLASH (rx)  : ORIGIN = 0x08000000,   LENGTH = 256K
}

/* Minimum free memory that should be left */
_Min_Heap_Size = 0x200; /* 512 bytes */
_Min_Stack_Size = 0x400; /* 1024 bytes */

/* Sections, this defines how the program's different sections are placed in memory*/
SECTIONS
{
    /* interrupt vector table placed at start of FLASH, and 4 byte aligned*/
    .isr_vector :
    {
        . = ALIGN(4);
        KEEP (*(.isr_vector)) /*  */
        . = ALIGN(4);
    } > FLASH

    /* The text section of program written to FLASH memory*/
    .text :
    {
        . = ALIGN(4);
        *(.text)
        *(.text*)
        . = ALIGN(4);
    } > FLASH

    /* constant data */
    .rodata :
    {
        . = ALIGN(4);
        *(.rodata)
        *(.rodata*)
        . = ALIGN(4);
    } > FLASH

    /* used by startup code to copy from flash to RAM .data*/
    _sidata = LOADADDR(.data);

    /* data section, initialised with values */
    .data :
    {
        . = ALIGN(4);
        _sdata = .;
        *(.data)
        *(.data*)
        . = ALIGN(4);
        _edata = .;
    } > RAM AT > FLASH

    /* data section, uninitialised (zeroed) */
    .bss :
    {
        . = ALIGN(4);
        _sbss = .;
        *(.bss)
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;
    } > RAM

    /* to check if enough space is left in ram for stack and heap */
    ._user_heap_stack :
    {
        . = ALIGN(8);
        PROVIDE ( end = . );
        PROVIDE ( _end = . );
        . = . + _Min_Heap_Size;
        . = . + _Min_Stack_Size;
        . = ALIGN(8);
    }
}