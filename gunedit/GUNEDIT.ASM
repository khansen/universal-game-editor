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
level_ofs       dd ?
level_end       dd ?
struct_ofs      dd ?
max_struct      db ?
palette_ofs     dd ?
gfx_ofs         dd ?
flip_ofs        dd ?
ENDS

Levels  Level   <00448h,2C0h,00010h,075,1C513h,gfx_0,flip_0>
        Level   <04448h,2C0h,04010h,130,1C534h,gfx_1,flip_1>
        Level   <08448h,4C0h,08010h,115,1C555h,gfx_2,flip_2>
        Level   <0C448h,3C0h,0C010h,130,1C576h,gfx_3,flip_3>
        Level   <10448h,2C0h,10010h,190,1C597h,gfx_4,flip_4>
        Level   <14448h,4C0h,14010h,135,1C5B8h,gfx_5,flip_5>

welcome_msg     db 13,10
                db ' +-----------------------+',13,10
                db ' | GunSmoke level editor |',13,10
                db ' +-----------------------+',13,10
                db ' (c) Kent Hansen 1998',13,10
                db 13,10
                db ' Read "gunedit.txt" CAREFULLY to avoid trouble.',13,10
                db '$'

keyb_buffer     dd 000400h
video_mem       dd 0A0000h

rom_file        db 'gunsmoke.nes',0

file_error      db 13,10,' ERROR: Could not open GUNSMOKE.NES',13,10,'$'
size_error      db 13,10,' ERROR: GUNSMOKE.NES must be 131,088 bytes',13,10,'$'
mouse_error     db 13,10,' ERROR: This program requires a mouse.',13,10,'$'

obj_string      db '0000',0
save_string     db 'CHANGES SAVED: PRESS ENTER',0

level_pos       dd 0
current_level   db 0
current_room    db 0
obj_pos         db 0
selected_obj    db 0
current_obj     db 0

shade           db 0
fade_type       db 0

vflip           db 0

include "gun_0.inc"
include "gun_1.inc"
include "gun_2.inc"
include "gun_3.inc"
include "gun_4.inc"
include "gun_5.inc"

keyboard        db 128 dup (0)

oldint8         df ?
oldint9         df ?

level_ofs       dd ?
level_end       dd ?
struct_ofs      dd ?
max_struct      db ?
palette_ofs     dd ?
gfx_ofs         dd ?
flip_ofs        dd ?

mouse_x         dd ?
mouse_y         dd ?
button_status   db ?

virtual_screen  db 320*256 dup (?)
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

mov     ax,0
int     33h
cmp     ax,0FFFFh
je      mouse_ok

mov     ah,09
mov     edx,offset mouse_error
int     21h
jmp     terminate

mouse_ok:

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

call    ReadMouse

mov     esi,offset file_data
add     esi,[level_ofs]
add     esi,[level_pos]
mov     edi,offset virtual_screen
call    DrawRoom

call    DrawCursor
call    DrawBoxes
call    DrawMouse

call    waitvrt

call    DrawScreen

cmp     [Keyboard + 01h],1
je      exit
cmp     [Keyboard + 0Fh],1
je      switch_struct_set
cmp     [Keyboard + 3Bh],1
je      change_level
cmp     [Keyboard + 3Fh],1
je      save_changes
cmp     [Keyboard + 49h],1
je      page_up
cmp     [Keyboard + 51h],1
je      page_down
jmp     main_loop

page_down:
call    waitvrt
call    waitvrt
call    waitvrt
call    waitvrt
cmp     [level_pos],64
jbe     to_start
sub     [level_pos],64
jmp     main_loop
to_start:
mov     [level_pos],0
jmp     main_loop

page_up:
call    waitvrt
call    waitvrt
call    waitvrt
call    waitvrt
mov     eax,[level_pos]
add     eax,64
cmp     eax,[level_end]
jae     to_end
add     [level_pos],64
jmp     main_loop
to_end:
mov     eax,[level_end]
mov     [level_pos],eax
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
mov     edi,offset virtual_screen + (320*100) + 70
call    disp_string
call    DrawScreen
wait_enter:
cmp     [Keyboard + 1Ch],0
je      wait_enter
jmp     main_loop

switch_struct_set:
call    waitvrt
call    waitvrt
call    waitvrt
call    waitvrt
cmp     [Keyboard + 2Ah],1
je      prev_set
mov     al,[max_struct]
cmp     al,[obj_pos]
je      reset_set
add     [obj_pos],5
jmp     main_loop
prev_set:
cmp     [obj_pos],0
je      last_set
sub     [obj_pos],5
jmp     main_loop
last_set:
mov     al,[max_struct]
mov     [obj_pos],al
jmp     main_loop
reset_set:
mov     [obj_pos],0
jmp     main_loop

change_level:
mov     ebx,3Bh
call    WaitRelease

inc     [current_level]
cmp     [current_level],6
jb      level_ok
mov     [current_level],0
level_ok:
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
mov     bl,09h
mov     edx,[dword ptr oldint9]                    ; set oldint9 back
mov     cx,[word ptr oldint9+4]
int     31h

mov     ax,3
int     10h

terminate:
mov     ax,4c00h
int     21h

PROC    DrawMacro

; AL = macro number

pushad
and     al,3Fh
movzx   eax,al
shl     eax,2
mov     ch,2
cmp     [vflip],0
je      @@10
add     al,2
@@10:
mov     cl,2
push    edi
@@20:
push    eax
push    esi
push    edi
shl     eax,4
mov     esi,[gfx_ofs]
add     esi,eax

cmp     [vflip],1
je      @@vflip

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
jmp     @@next_tile

@@vflip:
rept    8
mov     eax,ebp
movzx   ebx,[byte ptr esi]
mov     bh,[byte ptr esi+8]
mov     al,[byte ptr PreCalcBuffer + ebx*8+7]
or      al,ah
mov     [byte ptr edi+0],al
mov     al,[byte ptr PreCalcBuffer + ebx*8+6]
or      al,ah
mov     [byte ptr edi+1],al
mov     al,[byte ptr PreCalcBuffer + ebx*8+5]
or      al,ah
mov     [byte ptr edi+2],al
mov     al,[byte ptr PreCalcBuffer + ebx*8+4]
or      al,ah
mov     [byte ptr edi+3],al
mov     al,[byte ptr PreCalcBuffer + ebx*8+3]
or      al,ah
mov     [byte ptr edi+4],al
mov     al,[byte ptr PreCalcBuffer + ebx*8+2]
or      al,ah
mov     [byte ptr edi+5],al
mov     al,[byte ptr PreCalcBuffer + ebx*8+1]
or      al,ah
mov     [byte ptr edi+6],al
mov     al,[byte ptr PreCalcBuffer + ebx*8+0]
or      al,ah
mov     [byte ptr edi+7],al
inc     esi
add     edi,320
endm

@@next_tile:
pop     edi
pop     esi
pop     eax
add     al,2
add     edi,8
cmp     [vflip],0
je      @@haha
sub     al,4
@@haha:
dec     cl
jnz     @@20
sub     al,3
cmp     [vflip],0
je      @@haha2
add     al,8
@@haha2:
pop     edi
add     edi,8*320
dec     ch
jnz     @@10
popad
ret
ENDP    DrawMacro

PROC    DrawStruct

pushad

; AL = structure #

movzx   eax,al
mov     esi,[flip_ofs]
mov     bl,[byte ptr esi + eax]
mov     [vflip],bl

mov     esi,offset file_data
add     esi,[struct_ofs]
mov     edx,5
mul     edx
add     esi,eax
mov     bl,[byte ptr esi+4]
mov     ch,2
@@10:
mov     cl,2
push    edi
@@20:
push    ebx
and     bl,3
shl     bl,2
mov     bh,bl
push    bx
shl     ebx,16
pop     bx
mov     ebp,ebx
lodsb
call    DrawMacro
add     edi,16
pop     ebx
ror     bl,2
dec     cl
jnz     @@20
pop     edi
add     edi,16*320
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
add     edi,32*320
sub     esi,16
dec     ch
jnz     @@10

popad
ret
ENDP    DrawRoom

PROC    SetLevel

; AL = level #

pushad

movzx   eax,al
mov     edx,size Level
mul     edx
mov     ebx,eax

mov     eax,[ebx + Levels.level_ofs]
mov     [level_ofs],eax
mov     eax,[ebx + Levels.level_end]
mov     [level_end],eax
mov     eax,[ebx + Levels.struct_ofs]
mov     [struct_ofs],eax
mov     al,[ebx + Levels.max_struct]
mov     [max_struct],al
mov     eax,[ebx + Levels.palette_ofs]
mov     [palette_ofs],eax
mov     eax,[ebx + Levels.gfx_ofs]
mov     [gfx_ofs],eax
mov     eax,[ebx + Levels.flip_ofs]
mov     [flip_ofs],eax

mov     esi,offset file_data
add     esi,[palette_ofs]
call    SetPalette

mov     dx,3c8h
xor     al,al
out     dx,al
inc     dx
out     dx,al
out     dx,al
out     dx,al

mov     [obj_pos],0
mov     [level_pos],0
mov     [selected_obj],0

popad
ret
ENDP    SetLevel

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

PROC    DrawCursor

pushad

movzx   eax,[current_obj]
shr     eax,3
shl     eax,5
shl     eax,8
mov     edi,offset virtual_screen
add     edi,eax
shr     eax,2
add     edi,eax
movzx   eax,[current_obj]
and     eax,7
shl     eax,5
add     edi,eax

mov     ecx,32
mov     al,33
rep     stosb
add     edi,320-32
push    edi
rept    31
mov     [byte ptr edi],al
add     edi,320
endm
pop     edi
push    edi
add     edi,31
rept    31
mov     [byte ptr edi],al
add     edi,320
endm
pop     edi
add     edi,30*320
mov     ecx,32
rep     stosb

popad
ret
ENDP    DrawCursor

PROC    ReadMouse

pushad

xor     ecx,ecx
xor     edx,edx
mov     ax,3
int     33h
mov     [button_status],bl
shr     ecx,1
mov     [mouse_x],ecx
mov     [mouse_y],edx
cmp     ecx,256
jae     @@not_roomdata
shr     ecx,5
shr     edx,5
shl     edx,3
add     edx,ecx
mov     [current_obj],dl

test    [button_status],1
jnz     @@put_struct
test    [button_status],2
jz      @@end_read

mov     esi,offset file_data
add     esi,[level_ofs]
add     esi,[level_pos]
push    edx
and     edx,00000111b
add     esi,edx
pop     edx
and     edx,11111000b
sub     esi,edx
mov     al,[byte ptr esi]
mov     [selected_obj],al
jmp     @@end_read

@@put_struct:
mov     esi,offset file_data
add     esi,[level_ofs]
add     esi,[level_pos]
push    edx
and     edx,00000111b
add     esi,edx
pop     edx
and     edx,11111000b
sub     esi,edx
mov     al,[selected_obj]
mov     [byte ptr esi],al
jmp     @@end_read

@@not_roomdata:
test    [button_status],1
jz      @@end_read
cmp     ecx,272
jb      @@end_read
cmp     ecx,303
ja      @@end_read
cmp     edx,16
jb      @@end_read
cmp     edx,176
ja      @@end_read

sub     edx,16
shr     edx,5
add     dl,[obj_pos]
mov     [selected_obj],dl
jmp     @@end_read

@@end_read:
cmp     [current_obj],7
jbe     @@map_up
cmp     [current_obj],56
jae     @@map_down
jmp     @@end_it_all

@@map_up:
mov     eax,[level_end]
cmp     eax,[level_pos]
je      @@end_it_all
add     [level_pos],8
call    waitvrt
call    waitvrt
call    waitvrt
call    waitvrt
jmp     @@end_it_all
@@map_down:
cmp     [level_pos],0
je      @@end_it_all
sub     [level_pos],8
call    waitvrt
call    waitvrt
call    waitvrt
call    waitvrt

@@end_it_all:
popad
ret
ENDP    ReadMouse

PROC    DrawMouse
pushad
mov     esi,offset mouse_cursor
mov     edx,[mouse_y]
mov     edi,offset virtual_screen
shl     edx,8
add     edi,edx
shr     edx,2
add     edi,edx
add     edi,[mouse_x]

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

PROC    DrawBoxes

pushad

mov     edi,offset virtual_screen + 256
mov     eax,0FFFFFFFFh
rept    240
mov     ecx,(320-256)/4
rep     stosd
add     edi,256
endm

mov     edi,offset virtual_screen + (16*320)+272
mov     cl,5
mov     al,[obj_pos]
@@10:
call    DrawStruct
add     edi,32*320
inc     al
dec     cl
jnz     @@10

add     edi,16*320
mov     al,[selected_obj]
call    DrawStruct

mov     edi,offset virtual_screen + (16*320)+272
mov     al,32
rept    6
push    edi
mov     ecx,32
rep     stosb
pop     edi
add     edi,32*320
endm

mov     edi,offset virtual_screen + (16*320)+271
mov     cl,2
@@99:
push    edi
rept    161
mov     [byte ptr edi],al
add     edi,320
endm
pop     edi
add     edi,33
dec     cl
jnz     @@99

popad
ret
ENDP    DrawBoxes

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

PROC    WaitRelease
@@10:
cmp     [Keyboard + ebx],1
je      short @@10
ret
ENDP    WaitRelease

end     start
