*Concepts you may want to Google beforehand: assembler, BIOS*

**Goal: Create a file which the BIOS interprets as a bootable disk**

This is very exciting, we're going to create our own boot sector!

Theory
------

The Basic Input/Output Software (`BIOS`) is a collection of software routines that are
initially loaded from a chip into memory and initialised when the computer is switched
on. BIOS provides auto-detection and basic control of the computer’s essential devices,
such as the screen, keyboard, and hard disks.

After BIOS completes some low-level tests of the hardware, particularly whether or
not the installed memory is working correctly, it must boot the operating system stored
on one of the devices but the BIOS doesn't know how to load the OS. 

So, the easiest place for BIOS to find the OS is in the first sector of one of the disks
(i.e. Cylinder 0, Head 0, Sector 0), known as the `boot sector` (usually `512 bytes` in size). 
Since some of our disks may not contain an operating systems (they may simply be connected for additional storage),
then it is important that BIOS can determine whether the boot sector of a particular
disk is boot code that is intended for execution or simply data. Note that the CPU does
not differentiate between code and data: both can be interpreted as CPU instructions,
where code is simply instructions that have been crafted by a programmer into some
useful algorithm.

To make sure that the "disk is bootable", the BIOS checks the last two
bytes (bytes 511 and 512) of an intended boot sector must be set to the 
magic number (bytes) `0xAA55`.

So, BIOS loops through each storage device (e.g. floppy drive, hard disk, CD drive, etc.), 
reads the boot sector into memory, and instructs the CPU to begin executing the first boot
sector it finds that ends with the magic number. This is where we seize control of the computer.

This is the simplest boot sector ever (A machine code boot sector, with each byte displayed in
hexadecimal):

```
e9 fd ff 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[ 29 more lines with sixteen zero-bytes each ]
00 00 00 00 00 00 00 00 00 00 00 00 00 00 55 aa
```

It is basically all zeros, ending with the 16-bit value
`0xAA55` (beware of indianness, x86 is little-endian). 
The first three bytes, in hexadecimal as `0xe9`, `0xfd` and `0xff`, are actually
machine code instructions, as defined by the CPU manufacturer, to perform an
endless (infinite) jump.

Simplest boot sector ever
-------------------------

You can either write the above 512 bytes
with a binary editor such as TextPad/GHex/Visual Studio, or just write a very
simple assembler code:

```nasm
; Infinite loop (e9 fd ff)
loop:
    jmp loop 

; Fill with 510 zeros minus the size of the previous code
times 510-($-$$) db 0
; Magic number
dw 0xaa55 
```

To compile:
`nasm -f bin boot_sect_simple.asm -o boot_sect_simple.bin`

> OSX warning: if this drops an error, read chapter 00 again

I know you're anxious to try it out (I am!), so let's do it:

`qemu boot_sect_simple.bin`

You will see a window open which says "Booting from Hard Disk..." and
nothing else. When was the last time you were so excited to see an infinite
loop? ;-)
