/*----------------------------------------------------------------------------*/
/*                                                                            */
/*    Copyright (c) Innovation First 2017, All rights reserved.               */
/*                                                                            */
/*    Module:     lscript.ld                                                  */
/*    Author:     James Pearman                                               */
/*    Created:    21 March 2019                                               */
/*                                                                            */
/*    Revised linker script for VexIQ that allows program start address to be */
/*    in using the PROGRAM_OFFSET symbol                                      */
/*                                                                            */
/*    Revisions:                                                              */
/*                V1.00     TBD - Initial release                             */
/*                                                                            */
/*----------------------------------------------------------------------------*/

MEMORY
{
    FLASH (RX) : ORIGIN = 0x00020000, LENGTH = 0x00020000
    SRAM  (WX) : ORIGIN = 0x20005000, LENGTH = 0x00002FF0
    SRAMS (WX) : ORIGIN = 0x20007FF0, LENGTH = 0x00000010
}

REGION_ALIAS("REGION_TEXT", FLASH);
REGION_ALIAS("REGION_BSS", SRAM);
REGION_ALIAS("REGION_DATA", SRAM);
REGION_ALIAS("REGION_STACK", SRAMS);
REGION_ALIAS("REGION_HEAP", SRAM);
REGION_ALIAS("REGION_ARM_EXIDX", FLASH);
REGION_ALIAS("REGION_ARM_EXTAB", FLASH);

/* Configuration for VexIQ
 * order is mode, slot, type, version
 */
_iqProgramConfig = DEFINED(_iqProgramConfig)  ? _iqProgramConfig  : 0x13010001;

/* start address of program 
 */
PROGRAM_ADDRESS  = DEFINED(_iqProgramAddress) ? _iqProgramAddress : 0x00020000;

/* maximum program size is 32K 
 */
PROVIDE(__program_size__ = 0x8000);

SECTIONS {    
    .jump PROGRAM_ADDRESS : {
        CREATE_OBJECT_SYMBOLS
        PROVIDE(__jump_start__ = .);
        KEEP (*(.jump))
        *(.jump.*)
        . = ALIGN(0x4);
    } > REGION_TEXT

    .text : ALIGN(0x100) {
        CREATE_OBJECT_SYMBOLS
        __text_start__ = .;
        KEEP (*(.text))
        *(.text.*)
        . = ALIGN(0x4);
        KEEP (*(.ctors))
        . = ALIGN(0x4);
        KEEP (*(.dtors))
        . = ALIGN(0x4);
        __init_array_start = .;
        KEEP (*(.init_array*))
        __init_array_end = .;
        *(.init)
        *(.fini*)
    } > REGION_TEXT

    PROVIDE (__etext = .);
    PROVIDE (_etext = .);
    PROVIDE (etext = .);

    .rodata : {
        *(.rodata)
        *(.rodata*)
    } > REGION_TEXT

    .data : ALIGN (4) {
        __data_load__ = LOADADDR (.data);
        __data_start__ = .;
        KEEP (*(.data))
        KEEP (*(.data*))
        . = ALIGN (4);
        __data_end__ = .;
    } > REGION_DATA AT> REGION_TEXT

    .ARM.exidx : {
        __exidx_start = .;
        *(.ARM.exidx* .gnu.linkonce.armexidx.*)
        __exidx_end = .;
    } > REGION_ARM_EXIDX

    .ARM.extab : {
        *(.ARM.extab* .gnu.linkonce.armextab.*)
        ASSERT ((. < (__jump_start__ + __program_size__)), "Error: program too large");
    } > REGION_ARM_EXTAB

    PROVIDE (_end_flash = .);

    .bss : {
        __bss_start__ = .;
        *(.shbss)
        KEEP (*(.bss))
        *(.bss.*)
        *(COMMON)
        . = ALIGN (4);
        __bss_end__ = .;
    } > REGION_BSS

    .heap : {
        __heap_start__ = .;
        KEEP(*(.heap))
        . += 32;
        __heap_end__ = .;
        __HeapLimit = __heap_end__;
    } > REGION_HEAP

    .stack : ALIGN(0x8) {
        _stack = .;
        __stack = .;
        KEEP(*(.stack))
    } > REGION_STACK
}
