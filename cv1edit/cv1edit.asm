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
ENDS

Levels  Level   <1001Ah,2D0h,1031Ah,078,1CE3Ah,gfx_CV1stage1>
        Level   <10865h,2A0h,10B35h,036,1CE4Dh,gfx_CV1stage2>
        Level   <10DD6h,360h,11166h,042,1CE60h,gfx_CV1stage3>
        Level   <1146Bh,2D0h,1176Bh,054,1CE73h,gfx_CV1stage4>
        Level   <11B51h,360h,11EE1h,042,1CE86h,gfx_CV1stage5>
        Level   <12217h,270h,12547h,054,1CE99h,gfx_CV1stage6>

welcome_msg     db 13,10
                db ' +--------------------------+',13,10
                db ' | Castlevania level editor |',13,10
                db ' +--------------------------+',13,10
                db ' (c) Kent Hansen 1998',13,10
                db 13,10
                db ' Read "cv1edit.txt" CAREFULLY to avoid trouble.',13,10
                db '$'

keyb_buffer     dd 000400h
video_mem       dd 0A0000h

rom_file        db 'castleva.nes',0

file_error      db 13,10,' ERROR: Could not open CASTLEVA.NES',13,10,'$'
size_error      db 13,10,' ERROR: CASTLEVA.NES must be 131,088 bytes',13,10,'$'
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

keyboard        db 128 dup (0)

include "cv1_0.inc"
include "cv1_1.inc"
include "cv1_2.inc"
include "cv1_3.inc"
include "cv1_4.inc"
include "cv1_5.inc"

oldint8         df ?
oldint9         df ?

level_ofs       dd ?
level_end       dd ?
struct_ofs      dd ?
max_struct      db ?
palette_ofs     dd ?
gfx_ofs         dd ?

mouse_x         dd ?
mouse_y         dd ?
button_status   db ?

virtual_screen  db 256*240 dup (?)
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

call    _Set256x240Mode

mov     ax,7
mov     cx,0
mov     dx,248*2
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
cmp     [Keyboard + 4Bh],1
je      map_left
cmp     [Keyboard + 4Dh],1
je      map_right
cmp     [Keyboard + 3Bh],1
je      change_level
cmp     [Keyboard + 3Fh],1
je      save_changes
cmp     [Keyboard + 49h],1
je      page_up
cmp     [Keyboard + 51h],1
je      page_down
jmp     main_loop

map_left:
cmp     [level_pos],0
je      main_loop
sub     [level_pos],6
call    waitvrt
call    waitvrt
call    waitvrt
call    waitvrt
jmp     main_loop

map_right:
mov     eax,[level_end]
cmp     eax,[level_pos]
je      main_loop
add     [level_pos],6
call    waitvrt
call    waitvrt
call    waitvrt
call    waitvrt
jmp     main_loop

page_down:
call    waitvrt
call    waitvrt
call    waitvrt
call    waitvrt
cmp     [level_pos],48
jbe     to_start
sub     [level_pos],48
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
add     [level_pos],48
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
mov     edi,offset virtual_screen + (256*100) + 70
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
add     [obj_pos],6
jmp     main_loop
prev_set:
cmp     [obj_pos],0
je      last_set
sub     [obj_pos],6
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

PROC    DrawStruct

pushad

; AL = structure #

movzx   eax,al
mov     esi,offset file_data
add     esi,[struct_ofs]
mov     edx,17
mul     edx
add     esi,eax
mov     bl,[byte ptr esi]
inc     esi
mov     ch,4
@@10:
mov     cl,4
push    edi
@@20:

push    ebx

cmp     ch,2
ja      @@hoho2
ror     bl,4
@@hoho2:
cmp     cl,2
ja      @@hoho
ror     bl,2
@@hoho:
and     bl,3
shl     bl,2
mov     bh,bl
push    bx
shl     ebx,16
pop     bx
mov     ebp,ebx

movzx   eax,[byte ptr esi]
push    esi edi

mov     esi,[gfx_ofs]
shl     eax,4
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
add     edi,256
endm

pop     edi esi
inc     esi
add     edi,8
pop     ebx
dec     cl
jnz     @@20
pop     edi
add     edi,8*256
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
mov     cl,6
push    edi
@@20:
lodsb
call    DrawStruct
add     edi,32*256
dec     cl
jnz     @@20
pop     edi
add     edi,32
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

;
; -----------------
;
;
;mov     eax,[level_pos]
;mov     ebx,16
;mov     cl,4
;mov     edi,offset obj_string
;call    FNT_NumToASCII
;mov     esi,offset obj_string
;mov     edi,offset virtual_screen + (8*256)+8
;call    disp_string
;
;mov     eax,[mouse_x]
;mov     ebx,10
;mov     cl,4
;mov     edi,offset obj_string
;call    FNT_NumToASCII
;mov     esi,offset obj_string
;mov     edi,offset virtual_screen + (24*256)+8
;call    disp_string
;
;mov     eax,[mouse_y]
;mov     ebx,10
;mov     cl,4
;mov     edi,offset obj_string
;call    FNT_NumToASCII
;mov     esi,offset obj_string
;mov     edi,offset virtual_screen + (32*256)+8
;call    disp_string
;
;
; -----------------
;

movzx   eax,[current_obj]
shr     eax,3
shl     eax,5
shl     eax,8
mov     edi,offset virtual_screen
add     edi,eax
movzx   eax,[current_obj]
and     eax,7
shl     eax,5
add     edi,eax

mov     ecx,32
mov     al,33
rep     stosb
add     edi,256-32
push    edi
rept    31
mov     [byte ptr edi],al
add     edi,256
endm
pop     edi
push    edi
add     edi,31
rept    31
mov     [byte ptr edi],al
add     edi,256
endm
pop     edi
add     edi,30*256
mov     ecx,32
rep     stosb

popad
ret
ENDP    DrawCursor

PROC    DrawMouse
pushad
mov     esi,offset mouse_cursor
mov     edx,[mouse_y]
mov     edi,offset virtual_screen
shl     edx,8
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
add     edi,256-8
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
mov     ecx,(256*240)/4
rep     movsd

ret
ENDP    DrawScreen

PROC    DrawBoxes

pushad

mov     edi,offset virtual_screen + (192*256)
mov     ecx,(48*256)/4
xor     eax,eax
rep     stosd

mov     edi,offset virtual_screen + (200*256)+8
mov     cl,6
mov     al,[obj_pos]
@@10:
call    DrawStruct
add     edi,32
inc     al
dec     cl
jnz     @@10

add     edi,16
mov     al,[selected_obj]
call    DrawStruct

mov     edi,offset virtual_screen + (199*256)+8
mov     al,32
rept    2
mov     ecx,192
rep     stosb
add     edi,(256*33)-192
endm

mov     edi,offset virtual_screen + (199*256)+8
mov     cl,7
@@99:
push    edi
rept    34
mov     [byte ptr edi],al
add     edi,256
endm
pop     edi
add     edi,32
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
cmp     edx,192
jae     @@not_room

shr     ecx,5
shr     edx,5
shl     edx,3
add     edx,ecx
mov     [current_obj],dl

test    [button_status],2
jnz     @@select_texture

test    [button_status],1
jz      @@end_read

mov     esi,offset file_data
add     esi,[level_ofs]
add     esi,[level_pos]
push    edx
and     edx,7
mov     eax,edx
mov     edx,6
mul     edx
add     esi,eax
pop     edx
shr     edx,3
add     esi,edx
mov     al,[selected_obj]
mov     [byte ptr esi],al
jmp     @@end_read

@@select_texture:
mov     esi,offset file_data
add     esi,[level_ofs]
add     esi,[level_pos]
push    edx
and     edx,7
mov     eax,edx
mov     edx,6
mul     edx
add     esi,eax
pop     edx
shr     edx,3
add     esi,edx
mov     al,[byte ptr esi]
mov     [selected_obj],al
jmp     @@end_read

@@not_room:
test    [button_status],1
jz      @@end_read

cmp     ecx,8
jb      @@end_read
cmp     ecx,198
ja      @@end_read
cmp     edx,200
jb      @@end_read
cmp     edx,232
ja      @@end_read

sub     ecx,8
shr     ecx,5
add     cl,[obj_pos]
mov     [selected_obj],cl

@@end_read:
popad
ret
ENDP    ReadMouse

PROC    WaitRelease
@@10:
cmp     [Keyboard + ebx],1
je      short @@10
ret
ENDP    WaitRelease

end     start
