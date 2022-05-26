_256x240        dw 05F00h
                dw 03F01h
                dw 04002h
                dw 08203h
                dw 04E04h
                dw 09605h
                dw 00D06h
                dw 03E07h
                dw 00008h
                dw 04109h
                dw 0EA10h
                dw 0AC11h
                dw 0DF12h
                dw 02013h
                dw 04014h
                dw 0E715h
                dw 00616h
                dw 0E317h

_320x400        dw 05F00h
                dw 04F01h
                dw 05002h
                dw 08203h
                dw 05404h
                dw 08005h
                dw 0BF06h
                dw 01F07h
                dw 00008h
                dw 04009h
                dw 09C10h
                dw 08E11h
                dw 08F12h
                dw 02813h
                dw 00014h
                dw 09615h
                dw 0B916h
                dw 0E317h

_360x360        dw 06B00h
                dw 05901h
                dw 05A02h
                dw 08E03h
                dw 05E04h
                dw 08A05h
                dw 0BF06h
                dw 01F07h
                dw 00008h
                dw 04009h
                dw 08810h
                dw 08511h
                dw 06712h
                dw 02D13h
                dw 00014h
                dw 06D15h
                dw 0BA16h
                dw 0E317h

proc    _Set320x240Mode near

        mov     ax,13h  ;let the BIOS set standard 256-color
        int     10h     ; mode (320x200 linear)

        mov     dx,SC_INDEX
        mov     ax,0604h
        out     dx,ax   ;disable chain4 mode
        mov     ax,0100h
        out     dx,ax   ;synchronous reset while switching clocks

        mov     dx,MISC_OUTPUT
        mov     al,067h
        out     dx,al

        mov     dx,SC_INDEX
        mov     ax,0300h
        out     dx,ax   ;undo reset (restart sequencer)

        mov     dx,CRTC_INDEX ;reprogram the CRT Controller
        mov     al,11h  ;VSync End reg contains register write
        out     dx,al   ; protect bit
        inc     dx      ;CRT Controller Data register
        in      al,dx   ;get current VSync End register setting
        and     al,7fh  ;remove write protect on various
        out     dx,al   ; CRTC registers
        dec     dx      ;CRT Controller Index
        cld
        mov     esi,offset _360x360 ;point to CRT parameter table
        mov     ecx,18 ;# of table entries
SetCRTParmsLoop:
        lodsw           ;get the next CRT Index/Data pair
        out     dx,ax   ;set the next CRT Index/Data pair
        loop    SetCRTParmsLoop

        mov     dx,SC_INDEX
        mov     ax,0f02h
        out     dx,ax   ;enable writes to all four planes
        mov     edi,[video_mem]
        sub     ax,ax   ;clear to zero-value pixels
        mov     cx,8000h ;# of words in display memory
        rep     stosw   ;clear all of display memory

        ret
endp    _Set320x240Mode

PROC    _Set256x240Mode near

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
mov     esi,offset _256x240
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
ENDP    _Set256x240Mode
