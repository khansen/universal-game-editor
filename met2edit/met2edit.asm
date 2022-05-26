IDEAL
P386N
MODEL FLAT
STACK 1000h
DATASEG

ROM_file        db 'metroid2.gb',0

fopen_error     db ' ERROR: Could not open METROID2.GB!',13,10,'$'
fsize_error     db ' ERROR: File must be 262,144 bytes in size!',13,10,'$'

video_mem       dd 0A0000h

gb_pal          db 63,63,35,42,42,15,28,28,9

room_ofs        dd 3C500h

include "met.db"

name_table      db 32*32        dup (?)
PreCalcBuffer   db 10000h*8     dup (?)
file_data       db 262144       dup (?)
virtual_screen  db 256*256      dup (?)

CODESEG

MACRO   Draw8x8Tile
push    edi
rept    8
movzx   ebx,[byte ptr esi]
mov     bh,[byte ptr esi+1]
mov     eax,[dword ptr PreCalcBuffer + ebx*8]
mov     [dword ptr edi],eax
mov     eax,[dword ptr PreCalcBuffer + ebx*8+4]
mov     [dword ptr edi+4],eax
add     esi,2
add     edi,256
endm
pop     edi
ENDM

include "tweak.inc"

start:

mov     ax,0EE02h
int     31h
sub     [video_mem],ebx

mov     ax,3D00h
mov     edx,offset ROM_file
int     21h
jnc     fopen_ok

mov     ah,09
mov     edx,offset fopen_error
int     21h
jmp     terminate

fopen_ok:
mov     bx,ax
mov     ah,3Fh
mov     ecx,262145
mov     edx,offset file_data
int     21h
cmp     eax,262144
je      fsize_ok

mov     ah,09
mov     edx,offset fsize_error
int     21h
jmp     terminate

fsize_ok:
mov     ah,3Eh
int     21h

; precalculate all possible bit patterns

mov     edi,offset PreCalcBuffer
xor     bx,bx
precalc:
mov     ax,bx
rol     ah,1
mov     cl,8
decode:
rol     al,1                    ; bit 0 of AL now contains bit 0 of pixel
rol     ah,1                    ; bit 1 of AL now contains bit 1 of pixel
mov     dx,ax
and     dx,0201h                ; mask the two bits we want
or      dl,dh                   ; add them together
mov     [byte ptr edi],dl       ; store the value
inc     edi
dec     cl
jnz     short decode
inc     bx
jnz     short precalc

call    _Set256x256Mode

mov     dx,3c8h
mov     al,1
out     dx,al
inc     dx
mov     esi,offset gb_pal
mov     ecx,3*3
rep     outsb

main_loop:

call    Draw_Room
call    Draw_NameTable

mov     esi,offset virtual_screen
mov     edi,[video_mem]
mov     ecx,(256*256)/4
rep     movsd

mov     ah,00
int     16h

cmp     ah,4Bh
je      left
cmp     ah,4Dh
je      right
cmp     al,27
je      exit
jmp     main_loop

left:
sub     [room_ofs],100h
jmp     main_loop
right:
cmp     [room_ofs],3FF00h
je      main_loop
add     [room_ofs],100h
jmp     main_loop

exit:
mov     ax,3
int     10h

terminate:
mov     ax,4c00h
int     21h

PROC    Draw_NameTable

pushad

mov     esi,offset name_table
mov     edi,offset virtual_screen
mov     dh,0
@@10:
mov     dl,0
push    edi
@@20:
movzx   eax,[byte ptr esi]
add     al,80h
push    esi
shl     eax,4
mov     esi,offset chr_data
add     esi,eax

Draw8x8Tile

pop     esi
inc     esi
add     edi,8
inc     dl
cmp     dl,32
jnz     @@20
pop     edi
add     edi,256*8
inc     dh
cmp     dh,32
jnz     @@10

popad
ret
ENDP    Draw_NameTable

PROC    Draw_Room

pushad

mov     esi,offset file_data
add     esi,[room_ofs]
mov     edi,offset name_table
mov     dh,16
@@10:
mov     dl,16
@@20:
movzx   ebx,[byte ptr esi]
shl     ebx,2
mov     al,[file_data + 21080h + ebx+0]
mov     [byte ptr edi+00],al
mov     al,[file_data + 21080h + ebx+1]
mov     [byte ptr edi+01],al
mov     al,[file_data + 21080h + ebx+2]
mov     [byte ptr edi+32],al
mov     al,[file_data + 21080h + ebx+3]
mov     [byte ptr edi+33],al
inc     esi
add     edi,2
dec     dl
jnz     @@20
add     edi,32
dec     dh
jnz     @@10

popad
ret
ENDP    Draw_Room

end     start
