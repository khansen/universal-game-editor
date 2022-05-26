font_order      db 'ABCDEFGHIJKLMNOPQRSTUVWXYZ :-0123456789,()',0

font_data       db 01100b
                db 10010b
                db 11110b
                db 10010b
                db 10010b

                db 11100b
                db 10010b
                db 11100b
                db 10010b
                db 11100b

                db 01110b
                db 10000b
                db 10000b
                db 10000b
                db 01110b

                db 11100b
                db 10010b
                db 10010b
                db 10010b
                db 11100b

                db 11110b
                db 10000b
                db 11110b
                db 10000b
                db 11110b

                db 11110b
                db 10000b
                db 11110b
                db 10000b
                db 10000b

                db 01110b
                db 10000b
                db 10110b
                db 10010b
                db 01110b

                db 10010b
                db 10010b
                db 11110b
                db 10010b
                db 10010b

                db 00100b
                db 00100b
                db 00100b
                db 00100b
                db 00100b

                db 00010b
                db 00010b
                db 00010b
                db 10010b
                db 01100b

                db 10010b
                db 10100b
                db 11000b
                db 10100b
                db 10010b

                db 10000b
                db 10000b
                db 10000b
                db 10000b
                db 11110b

                db 11111b
                db 10101b
                db 10101b
                db 10001b
                db 10001b

                db 10010b
                db 11010b
                db 10110b
                db 10010b
                db 10010b

                db 01100b
                db 10010b
                db 10010b
                db 10010b
                db 01100b

                db 11100b
                db 10010b
                db 11100b
                db 10000b
                db 10000b

                db 01100b
                db 10010b
                db 10010b
                db 10110b
                db 01110b

                db 11100b
                db 10010b
                db 11100b
                db 10010b
                db 10010b

                db 01110b
                db 10000b
                db 01100b
                db 00010b
                db 11100b

                db 11110b
                db 01000b
                db 01000b
                db 01000b
                db 01000b

                db 10010b
                db 10010b
                db 10010b
                db 10010b
                db 01100b

                db 10001b
                db 10001b
                db 10001b
                db 01010b
                db 00100b

                db 10001b
                db 10001b
                db 10101b
                db 10101b
                db 11111b

                db 10010b
                db 10010b
                db 01100b
                db 10010b
                db 10010b

                db 10001b
                db 10001b
                db 01010b
                db 00100b
                db 00100b

                db 11110b
                db 00100b
                db 01000b
                db 10000b
                db 11110b

                db 00000b
                db 00000b
                db 00000b
                db 00000b
                db 00000b

                db 00000b
                db 01000b
                db 00000b
                db 01000b
                db 00000b

                db 00000b
                db 00000b
                db 11110b
                db 00000b
                db 00000b

                db 01100b
                db 10010b
                db 10010b
                db 10010b
                db 01100b

                db 00100b
                db 01100b
                db 00100b
                db 00100b
                db 00100b

                db 11100b
                db 00010b
                db 00100b
                db 01000b
                db 11110b

                db 11100b
                db 00010b
                db 11100b
                db 00010b
                db 11100b

                db 10010b
                db 10010b
                db 11110b
                db 00010b
                db 00010b

                db 11110b
                db 10000b
                db 11100b
                db 00010b
                db 11100b

                db 00100b
                db 01000b
                db 11100b
                db 10010b
                db 01100b

                db 11110b
                db 00010b
                db 00100b
                db 01000b
                db 01000b

                db 01100b
                db 10010b
                db 01100b
                db 10010b
                db 01100b

                db 01100b
                db 10010b
                db 01110b
                db 00100b
                db 01000b

                db 00000b
                db 00000b
                db 00000b
                db 00100b
                db 01000b

                db 00010b
                db 00100b
                db 00100b
                db 00100b
                db 00010b

                db 01000b
                db 00100b
                db 00100b
                db 00100b
                db 01000b

PROC    disp_string

pushad

; edi = where to store output string
; esi = pointer to ascii string

@@10:
lodsb
cmp     al,0
je      @@99
push    esi edi
mov     esi,offset font_order
xor     ebx,ebx
@@20:
cmp     al,[byte ptr esi]
je      @@30
inc     bl
inc     esi
jmp     @@20
@@30:
mov     eax,ebx
mov     edx,5
mul     edx
mov     esi,offset font_data
add     esi,eax
mov     ch,5
@@40:
lodsb
mov     ah,al
rol     ah,3
mov     cl,5
@@50:
rol     ah,1
mov     al,ah
and     al,1
shl     al,5
jz      @@60
mov     [byte ptr edi],al
@@60:
inc     edi
dec     cl
jnz     @@50
add     edi,512-5
dec     ch
jnz     @@40
pop     edi esi
add     edi,5
jmp     @@10
@@99:
popad
ret
ENDP    disp_string
