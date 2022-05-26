IDEAL
P386N
MODEL FLAT
STACK 1000h
DATASEG

file_error      db 13,10,' ERROR: Could not open METROID.NES',13,10,'$'
size_error      db 13,10,' ERROR: METROID.NES must be 131,088 bytes',13,10,'$'

video_mem       dd 0B8000h

rom_file        db 'metroid.nes',0

file_data       db 131088 dup (?)

CODESEG

start:

mov     ax,0EE02h
int     31h
sub     [video_mem],ebx

mov     ax,3D00h
mov     edx,offset rom_file
int     21h
jnc     file_ok

mov     ah,09
mov     edx,offset file_error
int     21h
jmp     terminate

file_ok:
mov     bx,ax
mov     ah,3Fh
mov     edx,offset file_data
mov     ecx,131088
int     21h
cmp     eax,131088
je      size_ok

mov     ah,09
mov     edx,offset size_error
int     21h
jmp     terminate

size_ok:
mov     ah,3Eh
int     21h

mov     ax,3
int     10h

mov     edi,[video_mem]
mov     esi,offset file_data + 286Eh
mov     dh,16
loop_y:
mov     dl,32
loop_x:
mov     ebx,16
mov     cl,2
movzx   eax,[byte ptr esi]
call    NumToASCII
inc     esi
add     edi,4
dec     dl
jnz     loop_x
add     edi,160-128
dec     dh
jnz     loop_y

mov     ah,00
int     16h

terminate:
mov     ax,4c00h
int     21h

PROC    NumToASCII
pushad
mov     ch,cl
@@10:
xor     edx,edx
div     ebx
push    edx
dec     cl
jnz     short @@10
mov     ah,0Fh
@@20:
pop     edx
mov     al,dl
call    HexDigit
stosw
dec     ch
jnz     short @@20
popad
ret
ENDP    NumToASCII

PROC    HexDigit

; converts hex digit (range 0-F) to ASCII char

cmp     al,9
jbe     short @@10
add     al,7
@@10:
add     al,30h
ret
ENDP    HexDigit

end     start
