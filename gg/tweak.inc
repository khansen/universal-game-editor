_320x240        dw 05F00h
                dw 04F01h
                dw 05002h
                dw 08203h
                dw 05404h
                dw 08005h
                dw 00D06h
                dw 03E07h
                dw 00008h
                dw 04109h
                dw 0EA10h
                dw 0AC11h
                dw 0DF12h
                dw 02813h
                dw 00014h
                dw 0E715h
                dw 00616h
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
        mov     esi,offset _320x240 ;point to CRT parameter table
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
        mov     ecx,8000h ;# of words in display memory
        rep     stosw   ;clear all of display memory

        mov     dx,3c8h
        mov     al,32
        out     dx,al
        inc     dx
        mov     al,63
        out     dx,al
        out     dx,al
        out     dx,al

        ret
endp    _Set320x240Mode
