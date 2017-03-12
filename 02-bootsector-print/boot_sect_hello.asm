;
; A simple boot sector that prints a message to the screen using a BIOS routine.
;

mov ah, 0x0e    ; int 10/ ah = 0eh -> scrolling teletype BIOS routine

mov al, 'H'
int 0x10
mov al, 'e'
int 0x10
mov al, 'l'
int 0x10
int 0x10        ; 'l' is still on al, remember?
mov al, 'o'
int 0x10

jmp $           ; jump to current address ( i.e. forever ) = infinite loop

;
; Padding and magic BIOS number.
;

times 510 - ($-$$) db 0   ; Pad the boot sector out with zeros
dw 0xaa55                 ; Last two bytes form the magic number ,
                          ; so BIOS knows we are a boot sector.
