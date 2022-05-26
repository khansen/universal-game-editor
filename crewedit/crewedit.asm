IDEAL
P386N
MODEL FLAT
STACK 1000h
DATASEG

welcome_msg     db 13,10
                db ' /----------------------------\',13,10
                db ' | Wrecking Crew level editor |',13,10
                db ' \----------------------------/',13,10
                db ' Kent Hansen 1998',13,10
                db 13,10
                db '$'

rom_file        db 'WRECKING.NES',0
file_error      db ' ERROR: Could not open WRECKING.NES',13,10,'$'
size_error      db ' ERROR: WRECKING.NES must be 40,976 bytes',13,10,'$'

save_string     db 'CHANGES SAVED',0

macro_table     db 014h,01Eh,00Ah,000h,000h,05Eh,0E6h,0BCh
                db 0B2h,09Eh,0A8h,014h,014h,014h,014h,014h

macro_colors    db 1,0,1,1,2,1,3,0
                db 0,0,0,1,1,1,1,1

sprite_tiles    db 0BAh,04Ch,0BAh,04Dh,0BAh,04Eh,1,0
                db 0BAh,04Ch,0BAh,04Dh,0BAh,04Eh,3,0
                db 0BAh,0E3h,0BAh,0E4h,0BAh,0E5h,3,0
                db 006h,007h,009h,00Ch,0E8h,0E9h,2,0
                db 000h,001h,002h,003h,0E8h,0E9h,0,0

level_ofs       dd 00090h
macro_ofs       dd 05DF0h
gfx_ofs         dd 09010h
palette_ofs     dd 05C3Eh

video_mem       dd 0A0000h
keyb_buffer     dd 000400h

fade_type       db 0
shade           db 0

map_pos         db 0
map_pos_changed db 0
current_macro   db 0
screen_start    dd 0

attrib_table    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3
                db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

name_table      DB 36,36,36,36,36,36,36,36,36,36,36,15h,0Eh,1Fh,0Eh,15h,36,0,0,1,28h,36,36,36,36,36,36,36,36,36,36,36
                DB 36,36,36,36,36,36,36,36,36,36,88,91,91,91,91,91,91,91,91,91,91,93,36,36,36,36,36,36,36,36,36,36
                DB 36,36,36,81,83,85,85,85,85,86,89,92,92,92,92,92,92,92,92,92,92,94,176,85,85,85,85,178,179,36,36
                DB 36,36,36,80,82,84,84,84,84,84,87,90,36,36,36,36,36,36,36,36,36,36,95,177,84,84,84,84,84,180,181,36,36

                DB 0B8h,0B8h,0B8h,0B6h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,0B9h,0BBh,0BBh,0BBh
                db 0D4h,0D5h,0D6h,0B7h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,0BAh,0DAh,0D9h,0D8h
                db 0D7h,0D7h,0D7h,0B7h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,0BAh,0DBh,0DBh,0DBh
                db 030h,031h,030h,031h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,030h,031h,030h,031h

                DB 0B8h,0B8h,0B8h,0B6h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,0B9h,0BBh,0BBh,0BBh
                db 0D4h,0D5h,0D6h,0B7h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,0BAh,0DAh,0D9h,0D8h
                db 0D7h,0D7h,0D7h,0B7h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,0BAh,0DBh,0DBh,0DBh
                db 030h,031h,030h,031h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,030h,031h,030h,031h

                DB 0B8h,0B8h,0B8h,0B6h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,0B9h,0BBh,0BBh,0BBh
                db 0D4h,0D5h,0D6h,0B7h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,0BAh,0DAh,0D9h,0D8h
                db 0D7h,0D7h,0D7h,0B7h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,0BAh,0DBh,0DBh,0DBh
                db 030h,031h,030h,031h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,030h,031h,030h,031h

                DB 0B8h,0B8h,0B8h,0B6h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,0B9h,0BBh,0BBh,0BBh
                db 0D4h,0D5h,0D6h,0B7h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,0BAh,0DAh,0D9h,0D8h
                db 0D7h,0D7h,0D7h,0B7h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,0BAh,0DBh,0DBh,0DBh
                db 030h,031h,030h,031h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,030h,031h,030h,031h

                DB 0B8h,0B8h,0B8h,0B6h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,0B9h,0BBh,0BBh,0BBh
                db 0D4h,0D5h,0D6h,0B7h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,0BAh,0DAh,0D9h,0D8h
                db 0D7h,0D7h,0D7h,0B7h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,0BAh,0DBh,0DBh,0DBh
                db 030h,031h,030h,031h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,030h,031h,030h,031h

                DB 0B8h,0B8h,0B8h,0B6h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,0B9h,0BBh,0BBh,0BBh
                db 0D4h,0D5h,0D6h,0B7h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,0BAh,0DAh,0D9h,0D8h
                db 0D7h,0D7h,0D7h,0B7h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,0BAh,0DBh,0DBh,0DBh
                db 030h,031h,030h,031h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,030h,031h,030h,031h

                DB 0B8h,0B8h,0B8h,0B6h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,0B9h,0BBh,0BBh,0BBh
                db 0D4h,0D5h,0D6h,0B7h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,0BAh,0DAh,0D9h,0D8h
                db 0D7h,0D7h,0D7h,0B7h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,0BAh,0DBh,0DBh,0DBh
                db 030h,031h,030h,031h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,030h,031h,030h,031h

                DB 0B8h,0B8h,0B8h,0B6h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,0B9h,0BBh,0BBh,0BBh
                db 0D4h,0D5h,0D6h,0B7h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,0BAh,0DAh,0D9h,0D8h
                db 0D7h,0D7h,0D7h,0B7h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,0BAh,0DBh,0DBh,0DBh
                db 030h,031h,030h,031h,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,030h,031h,030h,031h

                db 0BCh,0BDh,0BCh,0BDh,0BCh,0BDh,0BCh,0BDh,0BCh,0BDh,0BCh,0BDh,0BCh,0BDh,0BCh,0BDh,0BCh,0BDh,0BCh,0BDh,0BCh,0BDh,0BCh,0BDh,0BCh,0BDh,0BCh,0BDh,0BCh,0BDh,0BCh,0BDh
                db 0BEh,0BFh,0BEh,0BFh,0BEh,0BFh,0BEh,0BFh,0BEh,0BFh,0BEh,0BFh,0BEh,0BFh,0BEh,0BFh,0BEh,0BFh,0BEh,0BFh,0BEh,0BFh,0BEh,0BFh,0BEh,0BFh,0BEh,0BFh,0BEh,0BFh,0BEh,0BFh

oldint8         df ?

virtual_screen  db 256*304 dup (?)
precalcbuffer   db 10000h*8 dup (?)
file_data       db 40976 dup (?)
decoded_level   db 12*8 dup (?)
obj_count       db 16 dup (?)

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
mov     ecx,40976
int     21h
cmp     eax,40976
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

mov     ax,204h                 ; f204h i31h - get interrupt
mov     bl,08h                  ; bl=interrupt number
int     31h                     ; dpmi call
                                ; returns cx:edx for the old int
mov     [dword ptr oldint8],edx            ; save old interrupt
mov     [word ptr oldint8+4],cx

mov     ax,205h                 ; f205h i31h - set interrupt
mov     bl,8                    ; int num
mov     cx,cs                   ; cx=seg - for newint8
mov     edx,offset newint8      ; edx offset - for newint8
int     31h

call    _Set256x240Mode

mov     esi,offset file_data
add     esi,[palette_ofs]
call    SetPalette

mov     esi,offset file_data
add     esi,[level_ofs]
call    DecodeLevel

main_loop:

call    DrawLevel

call    CheckLadders

call    DrawScreen

call    DrawSprites

call    CountObjs

call    DrawCursor

mov     esi,offset virtual_screen
add     esi,[screen_start]
mov     edi,[video_mem]
mov     ecx,(256*240)/4
rep     movsd

mov     ah,00
int     16h
cmp     ah,3Bh
je      prev_level
cmp     ah,3Ch
je      next_level
cmp     ah,44h
je      clear_level
cmp     ah,3Fh
je      save_changes
cmp     al,27
je      exit
cmp     ah,4Bh
je      map_left
cmp     ah,4Dh
je      map_right
cmp     ah,48h
je      map_up
cmp     ah,50h
je      map_down
cmp     al,'1'
je      switch_down_macro
cmp     al,'2'
je      switch_up_macro
jmp     main_loop

clear_level:
mov     edi,offset decoded_level
mov     ecx,12*8
xor     al,al
rep     stosb
jmp     main_loop

save_changes:
mov     edi,offset file_data
add     edi,[level_ofs]
call    EncodeLevel

mov     ah,3Ch
xor     cx,cx
mov     edx,offset rom_file
int     21h
mov     bx,ax
mov     ah,40h
mov     edx,offset file_data
mov     ecx,40976
int     21h
mov     ah,3Eh
int     21h

mov     esi,offset save_string
mov     edi,[video_mem]
add     edi,(120*256)+107
call    disp_string
mov     ah,00
int     16h
jmp     main_loop

prev_level:
mov     edi,offset file_data
add     edi,[level_ofs]
call    EncodeLevel

cmp     [level_ofs],90h
je      last_level
sub     [level_ofs],40h

mov     esi,offset file_data
add     esi,[level_ofs]
call    DecodeLevel

mov     eax,[level_ofs]
sub     eax,90h
mov     ebx,40h
xor     edx,edx
div     ebx
inc     al
mov     ebx,10
mov     cl,3
mov     edi,offset name_table + 17
call    NumToASCII
jmp     main_loop

last_level:
mov     [level_ofs],1950h

mov     esi,offset file_data
add     esi,[level_ofs]
call    DecodeLevel

mov     [name_table+17],1
mov     [name_table+18],0
mov     [name_table+19],0
jmp     main_loop

next_level:
mov     edi,offset file_data
add     edi,[level_ofs]
call    EncodeLevel

cmp     [level_ofs],1950h
je      first_level
add     [level_ofs],40h

mov     esi,offset file_data
add     esi,[level_ofs]
call    DecodeLevel

mov     eax,[level_ofs]
sub     eax,90h
mov     ebx,40h
xor     edx,edx
div     ebx
inc     al
mov     ebx,10
mov     cl,3
mov     edi,offset name_table + 17
call    NumToASCII
jmp     main_loop

first_level:
mov     [level_ofs],90h

mov     esi,offset file_data
add     esi,[level_ofs]
call    DecodeLevel

mov     [name_table+17],0
mov     [name_table+18],0
mov     [name_table+19],1
jmp     main_loop

switch_down_macro:
mov     esi,offset decoded_level
movzx   eax,[map_pos]
add     esi,eax
cmp     [map_pos_changed],0
je      dec_it1

mov     [map_pos_changed],0
mov     al,[current_macro]
mov     [byte ptr esi],al
call    CheckObj_down
jmp     main_loop

dec_it1:
dec     [byte ptr esi]
and     [byte ptr esi],00001111b
mov     al,[byte ptr esi]
mov     [current_macro],al
call    CheckObj_down
jmp     main_loop

switch_up_macro:
mov     esi,offset decoded_level
movzx   eax,[map_pos]
add     esi,eax
cmp     [map_pos_changed],0
je      inc_it1

mov     [map_pos_changed],0
mov     al,[current_macro]
mov     [byte ptr esi],al
call    CheckObj_up
jmp     main_loop

inc_it1:
inc     [byte ptr esi]
and     [byte ptr esi],00001111b
mov     al,[byte ptr esi]
mov     [current_macro],al
call    CheckObj_up
jmp     main_loop

map_left:
movzx   eax,[map_pos]
mov     ebx,12
xor     edx,edx
div     ebx
cmp     dl,0
je      to_row_end
mov     [map_pos_changed],1
dec     [map_pos]
jmp     main_loop
to_row_end:
add     [map_pos],11
jmp     main_loop

map_right:
movzx   eax,[map_pos]
mov     ebx,12
xor     edx,edx
div     ebx
cmp     dl,11
je      to_row_start
mov     [map_pos_changed],1
inc     [map_pos]
jmp     main_loop
to_row_start:
sub     [map_pos],dl
jmp     main_loop

map_up:
cmp     [map_pos],12
jb      main_loop
mov     [map_pos_changed],1
sub     [map_pos],12
movzx   eax,[map_pos]
mov     ebx,12
xor     edx,edx
div     ebx
cmp     al,1
ja      main_loop
cmp     [screen_start],0
je      main_loop
sub     [screen_start],32*256
jmp     main_loop

map_down:
movzx   eax,[map_pos]
mov     ebx,12
xor     edx,edx
div     ebx
cmp     al,7
je      main_loop
mov     [map_pos_changed],1
add     [map_pos],12
cmp     al,5
jb      main_loop
cmp     [screen_start],64*256
je      main_loop
add     [screen_start],32*256
jmp     main_loop

exit:

mov     ax,205h
mov     bl,08h
mov     edx,[dword ptr oldint8]                    ; set oldint8 back
mov     cx,[word ptr oldint8+4]
int     31h

mov     ax,3
int     10h

terminate:
mov     ax,4c00h
int     21h

PROC    DrawMacro

; AL = macro #
; EDI = position in name table

pushad

movzx   ebx,al
movzx   eax,[macro_table + ebx]
mov     esi,offset file_data
add     esi,[macro_ofs]
add     esi,eax
mov     al,[macro_colors + ebx]
inc     esi
rept    4
movsw
mov     [byte ptr edx+0],al
mov     [byte ptr edx+1],al
add     edx,32
add     edi,30
endm

popad
ret
ENDP    DrawMacro

PROC    DrawLevel

pushad

mov     esi,offset decoded_level
mov     edi,offset name_table + (4*32) + 4
mov     edx,offset attrib_table + (4*32) + 4
mov     ch,8
@@10:
mov     cl,12
push    edi edx
@@20:

movzx   eax,[byte ptr esi]
call    DrawMacro
add     edx,2
add     edi,2
inc     esi
dec     cl
jnz     @@20
pop     edx edi
add     edx,4*32
add     edi,4*32
dec     ch
jnz     @@10

popad
ret
ENDP    DrawLevel

; 1st byte:       %yyyyxxxx
;                
;                 yyyy: Y res of macro
;                 xxxx: X res of macro
;
; Next 8 bytes:   Tile indexes
;
; 10th byte:      ????????
;

PROC    DrawCursor

pushad

mov     edi,offset virtual_screen + (32*256) + 32
movzx   eax,[map_pos]
mov     ebx,12
xor     edx,edx
div     ebx
shl     eax,13
add     edi,eax
shl     edx,4
add     edi,edx

mov     al,33
push    edi
mov     ecx,16
rep     stosb
pop     edi
push    edi
rept    32
mov     [byte ptr edi],al
add     edi,256
endm
pop     edi
push    edi
add     edi,15
rept    32
mov     [byte ptr edi],al
add     edi,256
endm
pop     edi
add     edi,31*256
mov     ecx,16
rep     stosb

popad
ret
ENDP    DrawCursor

PROC    NewInt8
pushad
mov     dx,3c8h
mov     al,33
out     dx,al
inc     dx
mov     al,[shade]
out     dx,al
out     dx,al
out     dx,al

cmp     [fade_type],0
je      fade_in
sub     [shade],8
jnz     @@EOI
xor     [fade_type],1
jmp     @@EOI
fade_in:
add     [shade],8
cmp     [shade],56
jnz     @@EOI
xor     [fade_type],1
@@EOI:
mov     al,20h
out     20h,al
popad
iret
ENDP    NewInt8

PROC    DrawScreen

pushad

mov     esi,offset name_table
mov     edx,offset attrib_table
mov     edi,offset virtual_screen
mov     ch,38
@@10:
mov     cl,32
@@20:

movzx   eax,[byte ptr esi]
push    edi esi
shl     eax,4
mov     esi,offset file_data
add     esi,[gfx_ofs]
add     esi,eax

mov     al,[byte ptr edx]
shl     al,2
mov     ah,al
push    ax
shl     eax,16
pop     ax
mov     ebp,eax

call    Draw8x8Tile

pop     esi edi
inc     esi
add     edi,8
inc     edx
dec     cl
jnz     @@20
add     edi,7*256
dec     ch
jnz     @@10

popad
ret
ENDP    DrawScreen

PROC    CheckLadders

pushad

mov     edi,offset name_table + (7*32) + 4
mov     ch,7
@@10:
mov     cl,12
push    edi
@@20:
cmp     [word ptr edi],03130h
jnz     @@no_match
cmp     [word ptr edi+32],03332h
je      @@yellow_ladder
cmp     [word ptr edi+32],03F3Eh
je      @@white_ladder
jmp     @@no_match

@@white_ladder:
mov     [word ptr edi],0DDDCh
cmp     [word ptr edi-32],04342h
jnz     @@no_match
mov     [word ptr edi],04140h
mov     [word ptr edi+32],04342h
jmp     @@no_match

@@yellow_ladder:
mov     [word ptr edi],0DDDCh
cmp     [word ptr edi-32],03332h
jnz     @@no_match
mov     [word ptr edi],03332h

@@no_match:
add     edi,2
dec     cl
jnz     @@20
pop     edi
add     edi,4*32
dec     ch
jnz     @@10

popad
ret
ENDP    CheckLadders

PROC    NumToASCII
pushad
mov     ch,cl
@@10:
xor     edx,edx
div     ebx
push    edx
dec     cl
jnz     short @@10
@@20:
pop     edx
mov     al,dl
stosb
dec     ch
jnz     short @@20
popad
ret
ENDP    NumToASCII

PROC    DecodeLevel

pushad

mov     edi,offset decoded_level
mov     cl,6*8
@@10:
mov     al,[byte ptr esi]
shr     al,4
mov     [byte ptr edi],al
inc     edi
mov     al,[byte ptr esi]
and     al,00001111b
mov     [byte ptr edi],al
inc     edi
inc     esi
dec     cl
jnz     @@10

popad
ret
ENDP    DecodeLevel

PROC    EncodeLevel

pushad

mov     esi,offset decoded_level
mov     cl,6*8
@@10:
mov     al,[byte ptr esi+0]
shl     al,4
or      al,[byte ptr esi+1]
mov     [byte ptr edi],al
inc     edi
add     esi,2
dec     cl
jnz     @@10

popad
ret
ENDP    EncodeLevel

PROC    DrawSprites

pushad

mov     esi,offset decoded_level
mov     edi,offset virtual_screen + (32*256) + 32
mov     ch,8
@@10:
mov     cl,12
push    edi
@@20:
mov     al,[byte ptr esi]
cmp     al,0Bh
jb      @@no_sprite

pushad
sub     al,0Bh
movzx   eax,al
shl     eax,3
mov     esi,offset sprite_tiles
add     esi,eax

mov     dh,[byte ptr esi+6]
shl     dh,2
add     dh,10h

mov     ch,3
@@88:
mov     cl,2
push    edi
@@99:
movzx   eax,[byte ptr esi]
push    esi
mov     esi,offset file_data
add     esi,8010h
shl     eax,4
add     esi,eax
call    Draw8x8Sprite
pop     esi
inc     esi
add     edi,8
dec     cl
jnz     @@99
pop     edi
add     edi,8*256
dec     ch
jnz     @@88
popad

@@no_sprite:
inc     esi
add     edi,16
dec     cl
jnz     @@20
pop     edi
add     edi,32*256
dec     ch
jnz     @@10

popad
ret
ENDP    DrawSprites

PROC    Draw8x8Tile

; ESI = pointer to tile data

pushad

mov     cl,8
@@10:
movzx   ebx,[byte ptr esi]
mov     bh,[byte ptr esi+8]
mov     eax,[dword ptr PreCalcBuffer + ebx*8]
or      eax,ebp
mov     [dword ptr edi],eax
mov     eax,[dword ptr PreCalcBuffer + ebx*8+4]
or      eax,ebp
mov     [dword ptr edi+4],eax
inc     esi
add     edi,256
dec     cl
jnz     @@10

popad
ret
ENDP    Draw8x8Tile

PROC    Draw8x8Sprite

; ESI = pointer to tile data

pushad

mov     ch,8
@@10:
movzx   ebx,[byte ptr esi]
mov     bh,[byte ptr esi+8]
push    esi
mov     esi,offset precalcbuffer
shl     ebx,3
add     esi,ebx
mov     cl,8
@@20:
mov     al,[byte ptr esi]
cmp     al,0
je      @@no_draw
add     al,dh
mov     [byte ptr edi],al
@@no_draw:
inc     esi
inc     edi
dec     cl
jnz     @@20
pop     esi
inc     esi
add     edi,256-8
dec     ch
jnz     @@10

popad
ret
ENDP    Draw8x8Sprite

PROC    CountObjs

pushad

xor     al,al
mov     ch,16
mov     edi,offset obj_count
@@10:
xor     dl,dl
mov     esi,offset decoded_level
mov     cl,6*8
@@20:
cmp     al,[byte ptr esi]
jnz     @@99
inc     dl
@@99:
inc     esi
dec     cl
jnz     @@20
mov     [byte ptr edi],dl
inc     edi
inc     al
dec     ch
jnz     @@10

popad
ret
ENDP    CountObjs

PROC    CheckObj_up

pushad

mov     al,[current_macro]
cmp     al,0Ah
jbe     @@end
cmp     al,0Dh
jbe     @@enemy
cmp     al,0Eh
je      @@badguy
cmp     al,0Fh
je      @@mario

@@enemy:
mov     al,[obj_count + 0Bh]
add     al,[obj_count + 0Ch]
add     al,[obj_count + 0Dh]
cmp     al,6
jb      @@end
cmp     [obj_count + 0Eh],1
je      @@check_mario
mov     [current_macro],0Eh
mov     [byte ptr esi],0Eh
jmp     @@end
@@check_mario:
cmp     [obj_count + 0Fh],1
je      @@clear_it
mov     [current_macro],0Fh
mov     [byte ptr esi],0Fh
jmp     @@end
@@clear_it:
mov     [current_macro],00h
mov     [byte ptr esi],00h
jmp     @@end

@@badguy:
cmp     [obj_count + 0Eh],1
je      @@check_mario
mov     [current_macro],0Eh
mov     [byte ptr esi],0Eh
jmp     @@end

@@mario:
cmp     [obj_count + 0Fh],1
je      @@clear_it
mov     [current_macro],0Fh
mov     [byte ptr esi],0Fh

@@end:

popad
ret
ENDP    CheckObj_up

PROC    CheckObj_down

pushad

mov     al,[current_macro]
cmp     al,0Ah
jbe     @@end
cmp     al,0Fh
je      @@mario
cmp     al,0Eh
je      @@badguy

@@enemy:
mov     al,[obj_count + 0Bh]
add     al,[obj_count + 0Ch]
add     al,[obj_count + 0Dh]
cmp     al,6
jnz     @@end
mov     [current_macro],0Ah
mov     [byte ptr esi],0Ah
jmp     @@end

@@mario:
cmp     [obj_count + 0Fh],1
je      @@badguy
mov     [current_macro],0Fh
mov     [byte ptr esi],0Fh
jmp     @@end
@@clear_it:
mov     [current_macro],0Ah
mov     [byte ptr esi],0Ah
jmp     @@end

@@badguy:
cmp     [obj_count + 0Eh],1
je      @@enemy
mov     [current_macro],0Eh
mov     [byte ptr esi],0Eh
jmp     @@end

@@end:

popad
ret
ENDP    CheckObj_down

END     start
