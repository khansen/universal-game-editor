IDEAL
P386N
MODEL FLAT
STACK 1000h
DATASEG

STRUC   Level
room_ofs        dd ?
struct_ofs      dd ?
macro_ofs       dd ?
palette_ofs     dd ?
gfx_ofs         dd ?
ENDS

Levels  Level   <10010h,07310h,07B10h,1DA94h,offset gfx_0>
        Level   <10058h,07310h,07B10h,1DA44h,offset gfx_1>

welcome_msg     db 13,10
                db ' +---------------------------+',13,10
                db ' | Duck Tales 1 level editor |',13,10
                db ' +---------------------------+',13,10
                db ' (c) Kent Hansen 1998',13,10
                db 13,10
                db ' Read "duckedit.txt" CAREFULLY to avoid trouble.',13,10
                db '$'

keyb_buffer     dd 000400h
video_mem       dd 0A0000h

rom_file        db 'dtales1.nes',0

file_error      db 13,10,' ERROR: Could not open DTALES1.NES',13,10,'$'
size_error      db 13,10,' ERROR: DTALES1.NES must be 131,088 bytes',13,10,'$'

room_string     db 'ROOM:  ',0
map_string      db 'MAP POS:   ',0
obj_string      db '00',0
save_string     db 'CHANGES SAVED',0

current_level   db 1
current_room    db 0
current_obj     db 0

shade           db 0
fade_type       db 0

include "dt1_0.inc"
include "dt1_1.inc"

oldint8         df ?

room_ofs        dd ?
struct_ofs      dd ?
macro_ofs       dd ?
palette_ofs     dd ?
gfx_ofs         dd ?

virtual_screen  db 512*480 dup (?)
file_data       db 131088 dup (?)
precalcbuffer   db 10000h*8 dup (?)

CODESEG

include "font.inc"
include "tweak.inc"
include "palette.inc"

start:

mov     ah,09
mov     edx,offset welcome_msg
int     21h

mov     ah,00
int     16h

mov     ax,0EE02h
int     31h
sub     [video_mem],ebx
sub     [keyb_buffer],ebx

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

call    _Set256x240Mode

mov     al,[current_level]
call    SetLevel

main_loop:

;mov     edi,offset virtual_screen
;mov     ecx,(512*480)/4
;xor     eax,eax
;rep     stosd

;movzx   eax,[macro_number]
;mov     edi,offset obj_string
;mov     cl,2
;mov     ebx,16
;call    FNT_NumToASCII

;mov     esi,offset obj_string
;mov     edi,offset virtual_screen + 48
;call    disp_string

;mov     edi,offset virtual_screen
;mov     al,[macro_number]
;call    DrawStruct

mov     esi,offset file_data
add     esi,[room_ofs]
movzx   eax,[current_room]
mov     edx,72
mul     edx
add     esi,eax

mov     edi,offset virtual_screen
call    DrawRoom

mov     esi,offset virtual_screen
mov     edi,[video_mem]
mov     bh,240
dump_screen:
mov     ecx,256/4
rep     movsd
add     esi,256
dec     bh
jnz     dump_screen

mov     ah,00
int     16h
cmp     al,27
je      exit
cmp     ah,4Dh
je      right
cmp     ah,4Bh
je      left
jmp     main_loop

left:
cmp     [current_room],0
je      main_loop
dec     [current_room]
jmp     main_loop
right:
inc     [current_room]
jmp     main_loop

exit:
mov     ax,3
int     10h

terminate:
mov     ax,4c00h
int     21h

PROC    DrawMacro

; AL = macro number

pushad
mov     esi,offset file_data
add     esi,[macro_ofs]
movzx   eax,al
add     esi,eax
mov     ch,2
@@10:
mov     cl,2
push    edi
@@20:
movzx   eax,[byte ptr esi]
shl     eax,4
push    esi
push    edi
mov     esi,[gfx_ofs]
add     esi,eax
rept    8
movzx   ebx,[byte ptr esi]
mov     bh,[byte ptr esi+8]
mov     eax,[dword ptr PreCalcBuffer + ebx*8]
; or      eax,ebp
mov     [dword ptr edi],eax
mov     eax,[dword ptr PreCalcBuffer + ebx*8+4]
; or      eax,ebp
mov     [dword ptr edi+4],eax
inc     esi
add     edi,512
endm
pop     edi
pop     esi
add     esi,256
add     edi,8
dec     cl
jnz     @@20
pop     edi
add     edi,8*512
dec     ch
jnz     @@10
popad
ret
ENDP    DrawMacro

PROC    DrawStruct

pushad

; AL = structure #

mov     esi,offset file_data
add     esi,[struct_ofs]
movzx   eax,al
shl     eax,2
add     esi,eax
mov     ch,2
@@10:
mov     cl,2
push    edi
@@20:
lodsb
call    DrawMacro
add     edi,16
dec     cl
jnz     @@20
pop     edi
add     edi,16*512
dec     ch
jnz     @@10

popad
ret
ENDP    DrawStruct

PROC    DrawRoom

; ESI = pointer to room data

pushad

mov     ch,8
@@10:
mov     cl,8
push    edi
@@20:
lodsb
call    DrawStruct
add     edi,32
dec     cl
jnz     @@20
pop     edi
add     edi,32*512
dec     ch
jnz     @@10

popad
ret
ENDP    DrawRoom

PROC    SetLevel

pushad

; AL = level #

movzx   eax,al
mov     edx,size Level
mul     edx
mov     ebx,eax

mov     eax,[ebx + Levels.room_ofs]
mov     [room_ofs],eax
mov     eax,[ebx + Levels.struct_ofs]
mov     [struct_ofs],eax
mov     eax,[ebx + Levels.macro_ofs]
mov     [macro_ofs],eax
mov     eax,[ebx + Levels.palette_ofs]
mov     [palette_ofs],eax
mov     eax,[ebx + Levels.gfx_ofs]
mov     [gfx_ofs],eax

mov     esi,offset file_data
add     esi,[palette_ofs]
call    SetPalette

popad
ret
ENDP    SetLevel

end     start
