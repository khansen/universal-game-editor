IDEAL
P386N
MODEL FLAT
JUMPS
STACK 1000h

SC_INDEX        equ     03c4h   ;Sequence Controller Index
CRTC_INDEX      equ     03d4h   ;CRT Controller Index
MISC_OUTPUT     equ     03c2h   ;Miscellaneous Output register

DATASEG

mouse_cursor DB 0,32,0,0,0,0,0,0,0,32,32,0,0,0,0,0,0,32,32,32
 DB 0,0,0,0,0,32,32,32,32,0,0,0,0,32,32,32,32,32,0,0
 DB 0,32,32,32,32,32,32,0,0,32,32,32,32,0,0,0,0,32,32,0
 DB 0,0,0,0

STRUC   Area
room_ofs        dd ?
num_rooms       db ?
macro_ofs       dd ?
num_macros      db ?
palette_ofs     dd ?
gfx_ofs         dd ?
color_ofs       dd ?
ENDS

Areas   Area <0C010h,07,0E0B8h,54,1C7AFh,offset gfx_0,0E081h>
        Area <0C3D0h,09,0E0B8h,54,1C7D2h,offset gfx_0,0E081h>
        Area <0D7B0h,05,0E0B8h,54,1C930h,offset gfx_0,0E081h>
        Area <0DA50h,06,0E0B8h,54,1C930h,offset gfx_0,0E081h>
        Area <0C190h,11,0E69Ch,30,1C769h,offset gfx_1,0E67Dh>
        Area <0C5B0h,05,0E69Ch,30,1C78Ch,offset gfx_1,0E67Dh>
        Area <0D8D0h,07,0E69Ch,30,1C769h,offset gfx_1,0E67Dh>
        Area <0DBA0h,05,0E69Ch,30,1C769h,offset gfx_1,0E67Dh>
        Area <0CB20h,11,0EC5Dh,36,1C953h,offset gfx_2,0EC35h>
        Area <0CE80h,09,0EC5Dh,36,1C976h,offset gfx_2,0EC35h>
        Area <0D060h,15,0EC5Dh,36,1C999h,offset gfx_2,0EC35h>
        Area <0C6D0h,06,0EC5Dh,36,1C818h,offset gfx_2,0EC35h>
        Area <0C820h,10,0E8C4h,54,1C7F5h,offset gfx_3,0E88Dh>
        Area <0DCC0h,06,0F462h,48,1C881h,offset gfx_4,0F430h>
        Area <0CA30h,04,0E44Ch,30,1C9BCh,offset gfx_5,0E429h>
        Area <0D390h,21,0E44Ch,30,1C9BCh,offset gfx_5,0E429h>
        Area <0CD60h,05,0EF13h,48,1C83Bh,offset gfx_6,0EEDEh>
        Area <0DE70h,10,0F27Fh,24,1C8A4h,offset gfx_7,0F264h>

video_mem       dd 0A0000h
keyb_buffer     dd 000400h

welcome_msg     db ' +-------------------------+',13,10
                db ' | Goonies II level editor |',13,10
                db ' +-------------------------+',13,10
                db ' By Kent Hansen 1998',13,10
                db 13,10
                db ' Read "goonedit.txt" for instructions.'
                db 13,10,'$'

file_error      db 13,10,' ERROR: Could not open GOONIES2.NES',13,10,'$'
size_error      db 13,10,' ERROR: GOONIES2.NES must be 131,088 bytes',13,10,'$'
mouse_error     db 13,10,' ERROR: This program requires a mouse.',13,10,'$'

save_string     db 'CHANGES SAVED',0

rom_file        db 'goonies2.nes',0

current_texture db 0
current_area    db 0
current_room    db 0
current_obj     db 0
obj_pos         db 0

keyboard        db 128 dup (0)

include         "goon2_0.inc"
include         "goon2_1.inc"
include         "goon2_2.inc"
include         "goon2_3.inc"
include         "goon2_4.inc"
include         "goon2_5.inc"
include         "goon2_6.inc"
include         "goon2_7.inc"

shade           db 0
fade_type       db 0

room_ofs        dd ?
num_rooms       db ?
macro_ofs       dd ?
num_macros      db ?
palette_ofs     dd ?
gfx_ofs         dd ?
color_ofs       dd ?

button_status   db ?
mouse_x         dd ?
mouse_y         dd ?

oldint8         df ?
oldint9         df ?

virtual_screen  db 256*240 dup (?)
PreCalcBuffer   db 10000h*8 dup (?)
file_data       db 131088 dup (?)

CODESEG

include "font.inc"
include "palette.inc"
include "tweak.inc"

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

mov     al,[current_area]
call    SetArea

mov     edi,offset virtual_screen
mov     ecx,(256*240)/4
xor     eax,eax
rep     stosd

main_loop:

call    ReadMouse

mov     al,[current_room]
call    DrawRoom

call    DrawBoxes
call    DrawMouse
call    DrawCursor

call    WaitVrt

call    DrawScreen

cmp     [Keyboard + 01h],1
je      exit
cmp     [Keyboard + 0Fh],1
je      change_struct
cmp     [Keyboard + 3Bh],1
je      change_area
cmp     [Keyboard + 3Fh],1
je      save_changes
cmp     [Keyboard + 4Bh],1
je      room_left
cmp     [Keyboard + 4Dh],1
je      room_right
jmp     main_loop

change_area:
mov     ebx,3Bh
call    WaitRelease
inc     [current_area]
cmp     [current_area],18
jb      area_ok
mov     [current_area],0
area_ok:
mov     al,[current_area]
call    SetArea
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
mov     edi,[video_mem]
add     edi,(100*256)+100
call    disp_string
mov     esi,offset save_string
add     edi,256
call    disp_string
mov     cl,30
wait_loop:
call    waitvrt
dec     cl
jnz     wait_loop
jmp     main_loop

room_left:
cmp     [current_room],0
je      main_loop
mov     ebx,4Bh
call    WaitRelease
dec     [current_room]
jmp     main_loop

room_right:
mov     al,[current_room]
cmp     al,[num_rooms]
je      main_loop
mov     ebx,4Dh
call    WaitRelease
inc     [current_room]
jmp     main_loop

change_struct:
mov     ebx,0Fh
call    WaitRelease
cmp     [Keyboard + 2Ah],1
je      prev_set
mov     al,[num_macros]
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
mov     al,[num_macros]
mov     [obj_pos],al
jmp     main_loop
reset_set:
mov     [obj_pos],0
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

; AL = macro #

pushad
movzx   eax,al

mov     esi,eax
add     esi,[color_ofs]
add     esi,offset file_data
mov     bl,[byte ptr esi]

mov     esi,offset file_data
add     esi,[macro_ofs]
shl     eax,4
add     esi,eax
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
shl     eax,4
push    esi
push    edi
mov     esi,[gfx_ofs]
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
pop     edi
pop     esi
inc     edx
inc     esi
add     edi,8
pop     ebx
dec     cl
jnz     @@20
pop     edi
add     edi,256*8
dec     ch
jnz     @@10
popad
ret
ENDP    DrawMacro

PROC    DrawRoom

; AL = room #

pushad

movzx   eax,al
mov     edx,6*8
mul     edx
mov     esi,offset file_data
add     esi,[room_ofs]
add     esi,eax
mov     edi,offset virtual_screen
mov     ch,6
@@y_loop:
mov     cl,8
push    edi
@@x_loop:
lodsb
call    DrawMacro
add     edi,8*4
dec     cl
jnz     @@x_loop
pop     edi
add     edi,256*32
dec     ch
jnz     @@y_loop

popad
ret
ENDP    DrawRoom

PROC    SetArea

pushad

movzx   eax,al
mov     edx,size Area
mul     edx
mov     ebx,eax
mov     eax,[ebx + Areas.room_ofs]
mov     [room_ofs],eax
mov     al,[ebx + Areas.num_rooms]
mov     [num_rooms],al
mov     eax,[ebx + Areas.macro_ofs]
mov     [macro_ofs],eax
mov     al,[ebx + Areas.num_macros]
mov     [num_macros],al
mov     eax,[ebx + Areas.color_ofs]
mov     [color_ofs],eax

mov     eax,[ebx + Areas.palette_ofs]
mov     [palette_ofs],eax
mov     eax,[ebx + Areas.gfx_ofs]
mov     [gfx_ofs],eax

mov     esi,offset file_data
add     esi,[palette_ofs]
call    SetPalette

mov     [current_room],0
mov     [current_texture],0
mov     [obj_pos],0

popad
ret
ENDP    SetArea

PROC    FindObj

; AL = object #

movzx   eax,al
push    eax
movzx   eax,[current_room]
mov     edx,6*8
mul     edx
mov     esi,offset file_data
add     esi,[room_ofs]
add     esi,eax
pop     eax
add     esi,eax

ret
ENDP    FindObj

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

PROC    DrawScreen

mov     esi,offset virtual_screen
mov     edi,[video_mem]
mov     ecx,(256*240)/4
rep     movsd

ret
ENDP    DrawScreen

PROC    DrawCursor

pushad

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

mov     al,[current_obj]
call    FindObj
mov     al,[current_texture]
mov     [byte ptr esi],al
jmp     @@end_read

@@select_texture:
mov     al,[current_obj]
call    FindObj
mov     al,[byte ptr esi]
mov     [current_texture],al
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
mov     [current_texture],cl

@@end_read:
popad
ret
ENDP    ReadMouse

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

PROC    WaitRelease
@@10:
cmp     [Keyboard + ebx],1
je      short @@10
ret
ENDP    WaitRelease

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
call    DrawMacro
add     edi,32
inc     al
dec     cl
jnz     @@10

add     edi,16
mov     al,[current_texture]
call    DrawMacro

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

end     start
