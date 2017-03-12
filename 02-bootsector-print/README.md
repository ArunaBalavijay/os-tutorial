*Concepts you may want to Google beforehand: interrupts, CPU
registers*

**Goal: Make our previously silent boot sector print some text**

We will improve a bit on our infinite-loop boot sector and print
something on the screen. We will raise an interrupt for this.

Theory
------

For backward compatibility, it is important that CPUs boot initially in `16-bit
real mode`, requiring modern operating systems explicitly to switch up into the more
advanced `32-bit` (or `64-bit`) `protected mode`, but allowing older operating systems to
carry on, blissfully unaware that they are running on a modern CPU. Later on, we will
look at this important step from 16-bit real mode into 32-bit protected mode in detail.

Generally, when we say that a CPU is 16-bit, we mean that its instructions can work
with a maximum of 16-bits at once, for example: a 16-bit CPU will have a particular
instruction that can add two 16-bit (2 bytes) numbers together in one CPU cycle; if it was necessary
for a process to add together two 32-bit numbers, then it would take more cycles,
that make use of 16-bit addition.

First we will explore this 16-bit real mode environment, since all operating systems
must begin here, then later we will see how to switch into 32-bit protected mode and the
main benefits of doing so.

**CPU clock speed**, or clock rate, is measured in Hertz — generally in gigahertz, or `GHz`. 
A CPU's clock speed rate is a measure of how many clock cycles a CPU can perform per second. 
For example, a CPU with a clock rate of `1.8 GHz` can perform `1,800,000,000` clock cycles per second.

Some processors execute only one instruction per clock cycle. More advanced processors, described as superscalar, 
can perform more than one instruction per clock cycle. The latter type of processor gets more work done 
at a given clock speed than the former type. 

**On this example**, we are going to write a seemingly simple boot sector program that prints a short
message on the screen. To do this we will have to learn some fundamentals of how the
CPU works and how we can use BIOS to help us to manipulate the screen device.

We'd like to print a character on the screen but we do not know exactly how to communicate with the screen device,
since there may be many different kinds of screen devices and they may have different
interfaces. This is why we need to use BIOS, since BIOS has already done some auto
detection of the hardware and, evidently by the fact that BIOS earlier printed information
on the screen about self-testing and so on, so can offer us a hand.

We can be sure, however, that somewhere in the memory of the computer there
will be some BIOS machine code that knows how to write to the screen. The truth is
that we could possibly find the BIOS code in memory and execute it somehow, but this
is more trouble than it is worth and will be prone to errors when there are differences
between BIOS routine internals on different machines.

Here we can make use of a fundamental mechanism of the computer: *interrupts*.

**Interrupts** are a mechanism that allow the CPU temporarily to halt what it is doing and
run some other, higher-priority instructions before returning to the original task. An
interrupt could be raised either by a software instruction (e.g. `int 0x10`) or by some
hardware device that requires high-priority action (e.g. to read some incoming data from
a network device).

Each interrupt is represented by a unique number that is an index to the interrupt
vector, a table initially set up by BIOS at the start of memory (i.e. at physical address
`0x0`) that contains address pointers to *interrupt service routines (ISRs)*. An `ISR` is simply
a sequence of machine instructions, much like our boot sector code, that deals with a
specific interrupt (e.g. perhaps to read new data from a disk drive or from a network
card).

So, in a nutshell, BIOS adds some of its own ISRs to the interrupt vector that
specialise in certain aspects of the computer, for example: interrupt `0x10` causes the
screen-related ISR to be invoked; and interrupt `0x13`, the disk-related I/O ISR.

However, it would be wasteful to allocate an interrupt per BIOS routine, so BIOS
multiplexes the ISRs by what we could imagine as a big switch statement, based usually
on the value set in one of the CPUs *general purpose registers*, `ax`, prior to raising the
interrupt.

**CPU Registers**: Just as we use variables in a higher level languages, 
it is useful if we can store data tem-porarily during a particular routine. 
All x86 CPUs have four general purpose registers, ax, bx, cx, and dx, 
for exactly that purpose. Also, these registers, which can each hold
a word (two bytes, 16 bits) of data, can be read and written by the CPU with negligible
delay as compared with accessing main memory. In assembly programs, one of the most
common operations is moving (or more accurately, copying) data between these registers:

On this example we are going to write each character of the "Hello"
word into the register `al` (lower part of `ax`), the bytes `0x0e`
into `ah` (the higher part of `ax`) and raise interrupt `0x10` which
is a general interrupt for video services.

`0x0e` on `ah` tells the video interrupt that the actual function
we want to run is to 'write the contents of `al` in tty mode'.

We will set tty mode only once though in the real world we 
cannot be sure that the contents of `ah` are constant. Some other
process may run on the CPU while we are sleeping, not clean
up properly and leave garbage data on `ah`.

For this example we don't need to take care of that since we are
the only thing running on the CPU.

Our new boot sector looks like this:
```nasm
mov ah, 0x0e ; tty mode
mov al, 'H'
int 0x10
mov al, 'e'
int 0x10
mov al, 'l'
int 0x10
int 0x10 ; 'l' is still on al, remember?
mov al, 'o'
int 0x10

jmp $ ; jump to current address = infinite loop

; padding and magic number
times 510 - ($-$$) db 0
dw 0xaa55 
```

You can examine the binary data with `xxd file.bin`

Anyway, you know the drill:

`nasm -fbin boot_sect_hello.asm -o boot_sect_hello.bin`

`qemu boot_sect_hello.bin`

Your boot sector will say 'Hello' and hang on an infinite loop
