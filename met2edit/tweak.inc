_256x256        dw 05F00h
                dw 03F01h
                dw 04002h
                dw 08203h
                dw 04A04h
                dw 09A05h
                dw 02306h
                dw 0B207h
                dw 00008h
                dw 06109h
                dw 00A10h
                dw 0AC11h
                dw 0FF12h
                dw 02013h
                dw 04014h
                dw 00715h
                dw 01A16h
                dw 0A317h

PROC    _Set256x256Mode near

pushad

mov     ax,13h
int     10h                     ; set graphics mode 13h (320x200)

    mov     dx,3C4h          ; Sequencer Address Register

; === Set dot clock & scanning rate ===
    mov     ax,0100h
    out     dx,ax            ; Stop sequencer while setting Misc Output

    mov     dx,3C2h
    mov     al,0e3h          ; 0e3h = 227d = 11100011b
    out     dx,al            ; Select 25 MHz dot clock & 60 Hz scanning rate

    mov     dx,3C4h
    mov     ax,0300h         ; Index 00h --- 03h = 3d = 00000011b
    out     dx,ax            ; Undo reset (restart sequencer)

; === Remove write protection ===
    mov     dx,3D4h
    mov     al,11h           ; VSync End contains write protect bit (bit 7)
    out     dx,al
    inc     dx               ; Crt Controller Data register
    in      al,dx
    and     al,01111111b     ; Remove write protect on various CrtC registers
    out     dx,al            ; (bit 7 is 0)

mov     dx,3C4h
mov     ax,0E04h
out     dx,ax
 
mov     dx,3D4h
mov     cl,18
mov     esi,offset _256x256
@@10:
lodsw
out     dx,ax
dec     cl
jnz     @@10

mov     dx,3DAh
in      al,dx
mov     dx,3C0h
mov     al,31h
out     dx,al
mov     al,0FFh
out     dx,al

mov     dx,3c8h
mov     al,0FFh
out     dx,al
inc     dx
xor     al,al
out     dx,al
out     dx,al
out     dx,al

mov     dx,3c8h
mov     al,32
out     dx,al
inc     dx
mov     al,63
out     dx,al
out     dx,al
out     dx,al

popad
ret
ENDP    _Set256x256Mode
