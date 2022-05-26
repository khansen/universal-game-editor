IDEAL
P386N
MODEL FLAT
STACK 1000h

SC_INDEX        equ     03c4h   ;Sequence Controller Index
CRTC_INDEX      equ     03d4h   ;CRT Controller Index
MISC_OUTPUT     equ     03c2h   ;Miscellaneous Output register

DATASEG

mouse_cursor DB 0,32,0,0,0,0,0,0,0,32,32,0,0,0,0,0,0,32,32,32
 DB 0,0,0,0,0,32,32,32,32,0,0,0,0,32,32,32,32,32,0,0
 DB 0,32,32,32,32,32,32,0,0,32,32,32,32,0,0,0,0,32,32,0
 DB 0,0,0,0

STRUC   Level
room_ofs        dd ?
num_rooms       db ?
macro_ofs       dd ?
palette_ofs     dd ?
gfx_ofs         dd ?
color_ofs       dd ?
real_table      dd ?
num_tables      db ?
ENDS

Levels  Level <0583Ah,06,0790Ah,043F8h,offset gfx_0,07D0Ah,offset real_table_0,2>
        Level <05ECAh,02,0790Ah,04408h,offset gfx_0,07D0Ah,offset real_table_0,2>
        Level <0619Ah,01,0790Ah,04418h,offset gfx_0,07D0Ah,offset real_table_0,2>

        Level <0637Ah,06,0790Ah,04428h,offset gfx_1,0FDF5h,offset real_table_1,3>
        Level <06A0Ah,13,0790Ah,04438h,offset gfx_1,0FDF5h,offset real_table_1,3>
        Level <0772Ah,00,0790Ah,04448h,offset gfx_1,0FDF5h,offset real_table_1,3>

        Level <09967h,22,0B677h,08350h,offset gfx_2,offset col_2,offset real_table_2,3>

        Level <0AEF7h,04,0B677h,08360h,offset gfx_2,offset col_2,offset real_table_2,3>
        Level <0B3A7h,02,0B677h,08370h,offset gfx_2,offset col_2,offset real_table_2,3>

        Level <0DFB5h,14,0F9F5h,0C268h,offset gfx_3,offset col_3,offset real_table_3,1>
        Level <0EDC5h,09,0F9F5h,0C268h,offset gfx_3,offset col_3,offset real_table_3,1>
        Level <0F725h,00,0F9F5h,0C288h,offset gfx_3,offset col_3,offset real_table_3 + 72,0>

welcome_msg     db 13,10
                db ' +-------------------------------+',13,10
                db ' | Ghosts''n Goblins level editor |',13,10
                db ' +-------------------------------+',13,10
                db ' (c) Kent Hansen 1998',13,10
                db 13,10
                db ' Read "gngedit.txt" for instructions.',13,10
                db '$'

keyb_buffer     dd 000400h
video_mem       dd 0A0000h

rom_file        db 'gng.nes',0

file_error      db 13,10,' ERROR: Could not open GNG.NES',13,10,'$'
size_error      db 13,10,' ERROR: GNG.NES must be 131,088 bytes',13,10,'$'

save_string     db 'CHANGES SAVED: PRESS ENTER',0

current_level   db 0
current_room    db 0
current_obj     db 0
current_macro   db 0
current_table   db 0
table_ofs       dd 0

shade           db 0
fade_type       db 0

include "gfx_0.inc"
include "gfx_1.inc"
include "gfx_2.inc"
include "gfx_3.inc"

keyboard        db 128 dup (0)

oldint8         df ?
oldint9         df ?

room_ofs        dd ?
num_rooms       db ?
macro_ofs       dd ?
palette_ofs     dd ?
gfx_ofs         dd ?
color_ofs       dd ?
real_table      dd ?
num_tables      db ?

virtual_screen  db 320*256 dup (?)
file_data       db 131088 dup (?)
pattern_table   db 16*256 dup (?)
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

mov     edi,offset virtual_screen
mov     ecx,(320*240)/4
xor     eax,eax
rep     stosd

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

mov     ax,204h                 ; f204h i31h - get interrupt
mov     bl,9                    ; bl=interrupt number
int     31h                     ; dpmi call
                                ; returns cx:edx for the old int
mov     [dword ptr oldint9],edx            ; save old interrupt
mov     [word ptr oldint9+4],cx

mov     ax,205h                 ; f205h i31h - set interrupt
mov     bl,9                    ; int num
mov     cx,cs                   ; cx=seg - for newint9
mov     edx,offset newint9      ; edx offset - for newint9
int     31h

call    _Set320x240Mode

mov     ax,7
mov     cx,0
mov     dx,312*2
int     33h

mov     ax,8
mov     cx,0
mov     dx,232
int     33h

mov     al,[current_level]
call    SetLevel

main_loop:

mov     edi,offset virtual_screen + 256
xor     eax,eax
mov     bh,240
clear_vrscreen:
mov     ecx,(320-256)/4
rep     stosd
add     edi,256
dec     bh
jnz     clear_vrscreen

mov     al,[current_room]
call    DrawRoom

call    DrawIcons

mov     edi,offset virtual_screen + (208*320) + 280
movzx   eax,[current_macro]
mov     edx,[color_ofs]
add     edx,offset file_data
mov     bl,[byte ptr edx + eax]
shl     bl,2
mov     bh,bl
push    bx
shl     ebx,16
pop     bx
mov     ebp,ebx
call    DrawMacro

call    DrawMouse

mov     edi,offset virtual_screen
movzx   eax,[current_obj]
shr     eax,4
shl     eax,4
shl     eax,8
add     edi,eax
shr     eax,2
add     edi,eax
movzx   eax,[current_obj]
and     eax,15
shl     eax,4
add     edi,eax

mov     ecx,16
mov     al,33
rep     stosb
add     edi,320-16
push    edi
rept    15
mov     [byte ptr edi],al
add     edi,320
endm
pop     edi
push    edi
add     edi,15
rept    15
mov     [byte ptr edi],al
add     edi,320
endm
pop     edi
add     edi,14*320
mov     ecx,15
rep     stosb

;----------

;push    edi
;mov     al,[current_obj]
;call    FindObj
;movzx   eax,[byte ptr esi]
;mov     ebx,16
;mov     cl,2
;mov     edi,offset kul_string
;call    NumToASCII
;pop     edi
;
;sub     edi,320*8
;
;mov     esi,offset kul_string
;call    disp_string

;----------

call    waitvrt

call    DrawScreen

call    CheckMouse

cmp     [Keyboard + 1],1
je      exit
cmp     [Keyboard + 0Fh],1
je      change_tbl
cmp     [Keyboard + 3Bh],1
je      change_level
cmp     [Keyboard + 3Fh],1
je      save_changes
cmp     [Keyboard + 4Bh],1
je      room_left
cmp     [Keyboard + 4Dh],1
je      room_right
jmp     main_loop

change_tbl:
call    WaitVrt
call    WaitVrt
call    WaitVrt
call    WaitVrt
mov     al,[num_tables]
cmp     al,[current_table]
je      reset_tbl
add     [table_ofs],36
inc     [current_table]
jmp     main_loop
reset_tbl:
mov     [table_ofs],0
mov     [current_table],0
jmp     main_loop

room_left:
cmp     [current_room],0
je      main_loop
dec     [current_room]
call    WaitVrt
call    WaitVrt
call    WaitVrt
call    WaitVrt
jmp     main_loop

room_right:
mov     al,[num_rooms]
cmp     al,[current_room]
je      main_loop
inc     [current_room]
call    WaitVrt
call    WaitVrt
call    WaitVrt
call    WaitVrt
jmp     main_loop

save_changes:
mov     ah,3Ch
xor     cx,cx
mov     edx,offset rom_file
int     21h
mov     bx,ax
mov     ah,40h
mov     edx,offset file_data
mov     ecx,131088
int     21h
mov     ah,3Eh
int     21h

mov     esi,offset save_string
mov     edi,offset virtual_screen + (320*100) + 100
call    disp_string
call    DrawScreen
wait_enter:
cmp     [Keyboard + 1Ch],0
je      wait_enter
jmp     main_loop

change_level:
cmp     [Keyboard + 3Bh],1
je      change_level

cmp     [current_level],11
je      reset_level
inc     [current_level]
mov     al,[current_level]
call    SetLevel
jmp     main_loop
reset_level:
mov     [current_level],0
mov     al,[current_level]
call    SetLevel
jmp     main_loop

exit:

mov     ax,205h
mov     bl,08h
mov     edx,[dword ptr oldint8]                    ; set oldint8 back
mov     cx,[word ptr oldint8+4]
int     31h

mov     ax,205h
mov     bl,9
mov     edx,[dword ptr oldint9]                    ; set oldint9 back
mov     cx,[word ptr oldint9+4]
int     31h

mov     ax,3
int     10h

terminate:
mov     ax,4c00h
int     21h

PROC    SetLevel

; AL = level #

pushad

movzx   eax,al
mov     edx,size Level
mul     edx
mov     ebx,eax

mov     eax,[ebx + Levels.room_ofs]
mov     [room_ofs],eax
mov     al,[ebx + Levels.num_rooms]
mov     [num_rooms],al
mov     eax,[ebx + Levels.macro_ofs]
mov     [macro_ofs],eax
mov     eax,[ebx + Levels.palette_ofs]
mov     [palette_ofs],eax
mov     eax,[ebx + Levels.gfx_ofs]
mov     [gfx_ofs],eax
mov     eax,[ebx + Levels.color_ofs]
mov     [color_ofs],eax
mov     eax,[ebx + Levels.real_table]
mov     [real_table],eax
mov     al,[ebx + Levels.num_tables]
mov     [num_tables],al

mov     esi,offset file_data
add     esi,[palette_ofs]
call    SetPalette

mov     esi,[gfx_ofs]
mov     edi,offset pattern_table
mov     ecx,256*16
rep     movsb

mov     [current_room],0
mov     [current_table],0
mov     [table_ofs],0

mov     edx,[real_table]
mov     al,[byte ptr edx + 0]
mov     [current_macro],al

popad
ret
ENDP    SetLevel

PROC    DrawRoom

; AL = room #

pushad

mov     esi,offset file_data
add     esi,[room_ofs]
movzx   eax,al
mov     edx,240
mul     edx
add     esi,eax

mov     edi,offset virtual_screen
mov     ch,15
@@loop_y:
mov     cl,16
push    edi
@@loop_x:
movzx   eax,[byte ptr esi]

mov     edx,[color_ofs]
add     edx,offset file_data
mov     bl,[byte ptr edx + eax]
shl     bl,2
mov     bh,bl
push    bx
shl     ebx,16
pop     bx
mov     ebp,ebx

call    DrawMacro
inc     esi
add     edi,16
dec     cl
jnz     @@loop_x
pop     edi
add     edi,16*320
dec     ch
jnz     @@loop_y

popad
ret
ENDP    DrawRoom

PROC    DrawMacro

; AL = macro number

pushad
mov     esi,offset file_data
add     esi,[macro_ofs]
movzx   eax,al
shl     eax,2
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
mov     esi,offset pattern_table
add     esi,eax
rept    8
movzx   ebx,[byte ptr esi]
mov     bh,[byte ptr esi+8]
mov     eax,[dword ptr PreCalcBuffer + ebx*8]
or      eax,ebp
mov     [dword ptr edi],eax
mov     eax,[dword ptr PreCalcBuffer + ebx*8+4]
or      eax,ebp
mov     [dword ptr edi+4],eax
inc     esi
add     edi,320
endm
pop     edi
pop     esi
inc     esi
add     edi,8
dec     cl
jnz     @@20
pop     edi
add     edi,320*8
dec     ch
jnz     @@10
popad
ret
ENDP    DrawMacro

PROC    FindObj

; AL = object #

movzx   eax,al
mov     esi,offset file_data
add     esi,[room_ofs]
add     esi,eax
movzx   eax,[current_room]
mov     edx,240
mul     edx
add     esi,eax

ret
ENDP    FindObj

PROC    DrawIcons
pushad
mov     edi,offset virtual_screen + (320*8) + 264
mov     eax,[table_ofs]
mov     ch,12
@@loop_y:
mov     cl,3
push    edi
@@loop_x:
push    eax
mov     edx,[real_table]
mov     al,[byte ptr edx + eax]
mov     edx,[color_ofs]
add     edx,offset file_data
mov     bl,[byte ptr edx + eax]
shl     bl,2
mov     bh,bl
push    bx
shl     ebx,16
pop     bx
mov     ebp,ebx
call    DrawMacro
add     edi,16
pop     eax
inc     al
dec     cl
jnz     @@loop_x
pop     edi
add     edi,16*320
dec     ch
jnz     @@loop_y

mov     edi,offset virtual_screen + (320*8) + 264
mov     al,32
mov     bh,13
@@haha:
mov     ecx,16*3
rep     stosb
add     edi,272+(320*15)
dec     bh
jnz     @@haha

mov     edi,offset virtual_screen + (320*8) + 264
rept    192
mov     [byte ptr edi+00],al
mov     [byte ptr edi+16],al
mov     [byte ptr edi+32],al
mov     [byte ptr edi+48],al
add     edi,320
endm

popad
ret
ENDP    DrawIcons

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

PROC    NewInt9                         ; keyboard interrupt

push    ax bx edi

mov     edi,[Keyb_buffer]
mov     ax,[word ptr edi + 1Ch]
mov     [word ptr edi + 01Ah],ax        ; tail = head (clear kbbuffer)

in      al,60h                          ; read keyboard
movzx   ebx,al
and     bl,01111111b
and     al,10000000b
rol     al,1
xor     al,1
mov     [Keyboard + ebx],al

mov     al,20h
out     20h,al

pop     edi bx ax

iret
ENDP    NewInt9

PROC    WaitVrt
push    ax dx
    mov     dx,3dah
Vrt:
    in      al,dx
    test    al,1000b        
    jnz     Vrt            
NoVrt:
    in      al,dx
    test    al,1000b         
    jz      NoVrt         
pop     dx ax
    ret
ENDP    WaitVrt

PROC    DrawMouse
pushad
mov     esi,offset mouse_cursor
xor     ecx,ecx
xor     edx,edx
mov     ax,3
int     33h
shr     ecx,1
mov     edi,offset virtual_screen
shl     edx,8
add     edi,edx
shr     edx,2
add     edi,edx
add     edi,ecx

mov     ch,8
@@yloop:
mov     cl,8
@@xloop:
mov     al,[byte ptr esi]
cmp     al,0
je      @@no_draw
mov     [byte ptr edi],al
@@no_draw:
inc     esi
inc     edi
dec     cl
jnz     @@xloop
add     edi,320-8
dec     ch
jnz     @@yloop

popad
ret
ENDP    DrawMouse

PROC    CheckMouse
pushad
mov     ax,3
int     33h
shr     ecx,1
cmp     ecx,256
jae     @@not_room
shr     ecx,4
shr     edx,4
shl     edx,4
add     edx,ecx
mov     [current_obj],dl
test    bl,2
jnz     @@right_button
test    bl,1
jz      @@99
mov     al,[current_obj]
call    FindObj
mov     al,[current_macro]
mov     [byte ptr esi],al
jmp     @@99
@@right_button:
mov     al,[current_obj]
call    FindObj
mov     al,[byte ptr esi]
mov     [current_macro],al
jmp     @@99
@@not_room:
cmp     ecx,264
jb      @@99
cmp     ecx,312
jae     @@99
cmp     edx,8
jb      @@99
cmp     edx,200
jae     @@99
test    bl,1
jz      @@99
sub     ecx,264
shr     ecx,4
sub     edx,8
shr     edx,4
add     ecx,edx
add     ecx,edx
add     ecx,edx
add     ecx,[table_ofs]
mov     edx,[real_table]
mov     al,[byte ptr edx + ecx]
mov     [current_macro],al
@@99:
popad
ret
ENDP    CheckMouse

PROC    DrawScreen

mov     esi,offset virtual_screen
mov     edi,[video_mem]
mov     al,02h
mov     bh,240
@@show_room_y:
mov     cl,320/4
@@show_room_x:

mov     dx,SC_INDEX
mov     ah,00000001b
out     dx,ax
mov     dl,[byte ptr esi]
mov     [byte ptr edi],dl
inc     esi

mov     dx,SC_INDEX
mov     ah,00000010b
out     dx,ax
mov     dl,[byte ptr esi]
mov     [byte ptr edi],dl
inc     esi

mov     dx,SC_INDEX
mov     ah,00000100b
out     dx,ax
mov     dl,[byte ptr esi]
mov     [byte ptr edi],dl
inc     esi

mov     dx,SC_INDEX
mov     ah,00001000b
out     dx,ax
mov     dl,[byte ptr esi]
mov     [byte ptr edi],dl
inc     esi

inc     edi
dec     cl
jnz     @@show_room_x
dec     bh
jnz     @@show_room_y

ret
ENDP    DrawScreen

end     start
