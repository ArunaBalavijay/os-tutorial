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
`0xAA55` (beware of indianness, `x86` is little-endian). 

The first three bytes, in hexadecimal as `0xe9`, `0xfd` and `0xff`, are actually
machine code instructions, as defined by the CPU manufacturer, to perform an
endless (infinite) jump.

An important note on endianness. You might be wondering why the magic BIOS
number was earlier described as the 16-bit value `0xaa55` but in our boot sector was
written as the consecutive bytes `0x55` and `0xaa`. This is because the `x86` architecture
handles multi-byte values in little-endian format, whereby less significant bytes proceed
more significant bytes, which is contrary to our familiar numbering system.

Compilers and assemblers can hide many issues of endianness from us by allowing
us to define the types of data, such that, say, a 16-bit value is serialised automatically
into machine code with its bytes in the correct order. However, it is sometimes useful,
especially when looking for bugs, to know exactly where an individual byte will be stored
on a storage device or in memory, so endianness is very important.

Note:

A computer represent a number as a sequence of `bits` (binary digits),
since fundamentally its circuitry can distinguish between only two electrical states: `0` and
`1`. So, to represent a number larger than 1, the computer can bunch together a series of bits.

Names have been adopted for bit series of certain lengths to make it easier to talk
about and agree upon the size of numbers we are dealing with. The instructions of
most computers deal with a minimum of `8 bit` values, which are named `bytes`. Other
groupings are `short`, `int`, and `long`, which usually represent `16`-bit, `32`-bit, and `64`-bit
values, respectively. We also see the term `word`, that is used to describe the size of the
maximum processing unit of the current mode of the `CPU`: so in 16-bit `real mode`, a
word refers to a 16-bit value; in 32-bit `protected mode`, a word refers to a 32-bit value;
and so on.

Each `4-bit` segments of the binary number is converted into a shorthand hexadecimal
notation as below.

```
1 1 1 0                 Hence, the hexadecimal value of `0xe` represents a `4-bit` value of `1 1 1 0`.
| | | |                 And, `0xe9` above represents a `8-bit` value (`1 byte` each).
| | | x 1 = 0
| | x 2   = 2
| x 4     = 4
x 8       = 8

Total     =14 (0xe)
```

Thus, above binary boot sector file has 16 bytes in each row with 32 rows in total to accomodate `512 bytes` (16 * 32).


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

*For Windows,*

To combile assembler code into machine (binary) code:

`"C:\Program Files (x86)\NASM\nasm" -f bin boot_sector.asm -o boot_sector.bin`

To boot from the binary file:

`"C:\Program Files\qemu\qemu-system-i386.exe" boot_sector.bin`
