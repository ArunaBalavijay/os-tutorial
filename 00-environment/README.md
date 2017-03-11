*Concepts you may want to Google beforehand: linux, mac, terminal, compiler, emulator, nasm, qemu*

**Goal: Install the software required to run this tutorial**

I'm working on a Mac, though Linux is better because it will have all the standard tools already
available for you.

On a mac, [install Homebrew](http://brew.sh) and then `brew install qemu nasm`

Don't use the Xcode developer tools `nasm` if you have them installed, they won't work for the most cases. Always use `/usr/local/bin/nasm`

Furthermore, on a mac, qemu is split into multiple binaries. You will want
to call `qemu-system-x86_64 binfile`

*For Windows,*

[Install QEMU](https://qemu.weilnetz.de/w64/)

[Install NASM](http://www.nasm.us/pub/nasm/releasebuilds/2.13rc8/)
