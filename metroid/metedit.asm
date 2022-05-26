IDEAL
P386N
MODEL FLAT
STACK 1000h
JUMPS

SC_INDEX        equ     03c4h   ;Sequence Controller Index
CRTC_INDEX      equ     03d4h   ;CRT Controller Index
MISC_OUTPUT     equ     03c2h   ;Miscellaneous Output register

DATASEG

include "metcoord.inc"
include "brinstar.ptr"
include "norfair.ptr"
include "kraid.ptr"
include "tourian.ptr"

map_colors      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                db 0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                db 0,4,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                db 0,4,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                db 0,4,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                db 0,4,0,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                db 0,4,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                db 0,4,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0
                db 0,4,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0
                db 0,4,4,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0
                db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0
                db 0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,1,0
                db 0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
                db 0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
                db 0,0,0,0,0,0,0,0,2,0,0,2,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0
                db 0,0,0,0,0,0,0,0,2,2,2,2,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
                db 0,0,0,0,0,0,0,0,2,2,2,2,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
                db 0,0,0,0,0,0,0,0,2,2,2,2,0,1,0,0,0,1,1,0,0,0,0,0,0,1,1,1,1,1,1,0
                db 0,2,0,0,0,0,0,2,2,0,0,2,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
                db 0,2,2,2,2,2,2,2,2,2,2,2,0,1,0,0,0,1,1,1,1,1,0,0,1,1,1,1,1,1,1,0
                db 0,2,2,2,2,2,2,2,2,2,2,2,0,1,0,0,1,1,1,1,1,1,0,0,1,1,0,0,0,0,1,0
                db 0,2,0,0,2,0,0,2,0,0,0,0,2,0,0,0,0,1,0,0,0,0,0,3,1,1,0,0,0,0,1,0
                db 0,2,0,0,2,2,2,2,2,2,2,2,2,0,3,0,0,3,3,3,3,3,3,3,3,3,0,0,0,0,3,0
                db 0,2,0,0,2,0,0,2,0,2,2,2,2,0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,0
                db 0,2,0,0,2,2,2,2,2,2,0,2,2,0,3,0,0,3,0,0,0,0,3,0,0,0,0,0,0,0,3,0
                db 0,2,2,2,2,2,2,2,2,2,2,2,2,0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,0
                db 0,2,0,2,2,2,2,2,2,2,2,2,2,0,3,0,0,0,0,0,0,0,3,0,0,0,0,0,0,0,3,0
                db 0,0,0,0,0,0,0,0,2,2,2,2,2,0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,0
                db 0,0,0,0,0,0,0,0,0,0,0,0,2,0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,0

mouse_cursor    db 249,249,0,0,0,0,0,0
                db 249,32,249,0,0,0,0,0
                db 249,32,32,249,0,0,0,0
                db 249,32,32,32,249,0,0,0
                db 249,32,32,32,32,249,0,0
                db 249,32,32,32,32,32,249,0
                db 249,32,32,32,32,32,32,249
                db 249,32,32,32,32,249,249,0
                db 249,32,32,249,249,0,0,0
                db 249,249,249,0,0,0,0,0

STRUC   Area
map_pos         dd ?
room_ptr        dd ?
room_ofs        dd ?
struct_ptr      dd ?
struct_ofs      dd ?
num_struct      db ?
macro_ofs       dd ?
palette_ofs     dd ?
num_rooms       db ?
gfx_ofs         dd ?
coords_ofs      dd ?
ENDS

Areas   Area <1A3h,06324h,06451h,06382h,06C94h,49,06F00h,06284h,46,offset brinstar, offset brincoords> ; Brinstar
        Area <196h,0A22Bh,0A3BBh,0A287h,0ACC9h,48,0AEFCh,0A18Bh,45,offset norfair, offset norcoords> ; Norfair
        Area <267h,121E5h,122C7h,1222Fh,12A7Bh,38,12C42h,12168h,36,offset kraid, offset kraidcoords>
        Area <2F9h,1618Fh,1624Fh,161E3h,169CFh,28,16B33h,160FEh,41,offset kraid, offset ridcoords>
        Area <063h,0E7E1h,0E8BFh,0E80Bh,0EC26h,31,0EE59h,0E72Bh,20,offset tourian, offset tourcoords>

map_rgb         db 00,30,63
                db 63,30,00
                db 00,53,30
                db 63,00,30
                db 50,50,50
                db 30,63,63

welcome_msg     db 13,10
                db ' ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿',13,10
                db ' ³ Metroid level editor ³',13,10
                db ' ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ',13,10
                db ' (c) Kent Hansen 1998, 1999',13,10
                db 13,10
                db ' Read "metedit.txt" CAREFULLY to avoid trouble.',13,10
                db '$'

keyb_buffer     dd 000400h
video_mem       dd 0A0000h
video_mem_DOS   dd 0B8000h

rom_file        db 'metroid.nes',0
map_file        db 'metedit.map',0

file_error      db 13,10,' ERROR: Could not open METROID.NES',13,10,'$'
size_error      db 13,10,' ERROR: METROID.NES must be 131,088 bytes',13,10,'$'

room_string     db 'ROOM:  ',0
map_string      db 'MAP POS:(00,00)',0
obj_string      db 'OBJECT:00(0,0)',0
save_string     db 'CHANGES SAVED',0

mouse_x         dd 0
mouse_y         dd 0
mouse_on        db 1
button_status   db 0
button_status2  db 0
drag_flag       db 0
temp_x          db 0
temp_y          db 0

current_area    db 0
current_obj     db 0

shade           db 0
fade_type       db 0

oldint8         df ?

map_ofs         dd 256Eh        ; ROM offset of level map
map_pos         dd 1A3h         ; initial map position
room_sub        dd ?
room_ptr        dd ?
room_ofs        dd ?
struct_ptr      dd ?
struct_ofs      dd ?
struct_sub      dd ?
num_struct      db ?
macro_ofs       dd ?
palette_ofs     dd ?
num_rooms       db ?
gfx_ofs         dd ?
coords_ofs      dd ?

virtual_screen  db 512*480 dup (?)
file_data       db 131088 dup (?)
precalcbuffer   db 10000h*8 dup (?)

CODESEG

include "palette.inc"
include "tweak.inc"
include "font.inc"

start:

mov     ah,09
mov     edx,offset welcome_msg
int     21h

mov     ah,00
int     16h

mov     ax,0EE02h
int     31h
sub     [video_mem],ebx
sub     [video_mem_DOS],ebx
sub     [keyb_buffer],ebx

mov     ax,3D00h
mov     edx,offset rom_file
int     21h                     ; attempt to open METROID.NES
jnc     file_ok                 ; if CF = 0, it was successful

mov     ah,09
mov     edx,offset file_error
int     21h
jmp     terminate

file_ok:
mov     bx,ax
mov     ah,3Fh
mov     edx,offset file_data
mov     ecx,131088
int     21h                     ; attempt to read 131,088 bytes
cmp     eax,131088              ; was exactly 131,088 bytes read?
je      size_ok                 ; if yes, the filesize is correct

mov     ah,09
mov     edx,offset size_error
int     21h
jmp     terminate

size_ok:
mov     ah,3Eh
int     21h                     ; close the file

mov     ax,3D00h
mov     edx,offset map_file
int     21h                     ; attempt to open METROID.MAP
jc      no_map

mov     bx,ax
mov     ah,3Fh
mov     edx,offset map_colors
mov     ecx,32*30
int     21h
mov     ah,3Eh
int     21h

no_map:

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

setpal:

call    _Set256x240Mode

;
;---- set palette for squares on map screen
;

mov     dx,3c8h
mov     al,64
out     dx,al
inc     dx
mov     esi,offset map_rgb
mov     ecx,6*3
rep     outsb

;
;----
;

mov     ax,00
int     33h
cmp     ax,0FFFFh
jnz     mouse_ok

mov     [mouse_on],1

mouse_ok:

mov     ax,7
mov     cx,0
mov     dx,248*2
int     33h

mov     ax,8
mov     cx,0
mov     dx,230
int     33h

main_loop:

mov     ebx,[map_pos]           ; fetch current map position
mov     al,[map_colors + ebx]   ; get the area #
mov     [current_area],al
call    SetArea

mov     esi,offset file_data
add     esi,[map_ofs]           ; ESI points to level map
mov     ebx,[map_pos]
movzx   eax,[byte ptr esi + ebx]        ; EAX = room #
call    DrawRoom

call    ShowInfo
call    ReadMouse
call    DrawMouse
call    DrawScreen

call    waitvrt

mov     ah,01h
int     16h
jz      main_loop

pushad
mov     edi,[keyb_buffer]
mov     ax,[word ptr edi + 1Ah]
mov     [word ptr edi + 1Ch],ax
popad

cmp     al,0
je      extended_key
cmp     al,27
je      exit
cmp     al,20h
je      MAP_wait_key
cmp     al,09h
je      next_struct
cmp     al,'2'
je      change_color
cmp     al,'a'
je      prev_obj
cmp     al,'s'
je      next_obj
cmp     al,'A'
je      prev_obj
cmp     al,'S'
je      next_obj
jmp     main_loop

extended_key:
mov     al,ah
cmp     al,0Fh
je      prev_struct
cmp     al,74h
je      room_up
cmp     al,73h
je      room_down
cmp     al,3Bh
je      change_area
cmp     al,3Fh
je      save_changes
cmp     al,44h
je      show_data
cmp     al,48h
je      up
cmp     al,50h
je      down
cmp     al,4Bh
je      left
cmp     al,4Dh
je      right
jmp     main_loop

show_data:
mov     ax,3
int     10h

mov     esi,offset file_data
add     esi,[map_ofs]           ; ESI points to level map
mov     ebx,[map_pos]
movzx   eax,[byte ptr esi + ebx]        ; EAX = room #
mov     esi,offset file_data
add     esi,[room_ptr]          ; ESI points to room pointer table
movzx   eax,[word ptr esi + eax*2]      ; fetch pointer for this room
sub     eax,[room_sub]
mov     esi,offset file_data
add     esi,[room_ofs]
add     esi,eax                 ; ESI points to this room's data
inc     esi
mov     edi,[video_mem_DOS]
add     edi,160+4
mov     ah,7
xor     cl,cl
_yl:
mov     dl,16
push    edi
_xl:
mov     al,'O'
stosw
mov     al,'B'
stosw
mov     al,'J'
stosw
mov     al,cl
shr     al,4
call    HexDigit
stosw
mov     al,cl
and     al,00001111b
call    HexDigit
stosw
mov     al,':'
stosw
add     edi,2

rept    3
mov     al,[byte ptr esi]
shr     al,4
call    HexDigit
stosw
mov     al,[byte ptr esi]
and     al,00001111b
call    HexDigit
stosw
add     edi,2
inc     esi
endm
inc     cl
cmp     [byte ptr esi],0FDh
je      _xe
cmp     [byte ptr esi],0FFh
je      _xe
add     edi,160-32
dec     dl
jnz     _xl
pop     edi
add     edi,34
jmp     _yl
_xe:
pop     edi
mov     edi,[video_mem_DOS]
add     edi,160+4

movzx   eax,[current_obj]
shr     eax,4
mov     edx,34
mul     edx
add     edi,eax

movzx   eax,[current_obj]
and     al,00001111b
shl     eax,7
add     edi,eax
shr     eax,2
add     edi,eax
rept    15
mov     [byte ptr edi+1],15
add     edi,2
endm
mov     ah,00
int     16h
jmp     setpal

MAP_wait_key:
call    DrawMap
mov     ah,00
int     16h
cmp     al,20h
je      MAP_end
cmp     al,08h
je      set_map_start
cmp     ah,0Fh
je      MAP_change
cmp     ah,52h
je      MAP_insert
cmp     ah,53h
je      MAP_delete
cmp     ah,4Bh
je      MAP_map_left
cmp     ah,4Dh
je      MAP_map_right
cmp     ah,48h
je      MAP_map_up
cmp     ah,50h
je      MAP_map_down
jmp     MAP_wait_key

MAP_end:
mov     [drag_flag],0
mov     [current_obj],0
mov     esi,offset file_data
add     esi,[map_ofs]
mov     ebx,[map_pos]
cmp     [byte ptr esi + ebx],0FFh
jnz     main_loop
mov     [byte ptr esi + ebx],00h
jmp     main_loop

set_map_start:
mov     esi,offset file_data
add     esi,[map_ofs]
mov     ebx,[map_pos]
cmp     [byte ptr esi + ebx],0FFh
je      MAP_wait_key

mov     eax,[map_pos]
shr     eax,5
inc     al
mov     [file_data + 055E8h],al
mov     eax,[map_pos]
and     eax,31
mov     [file_data + 055E7h],al
jmp     MAP_wait_key

MAP_change:
mov     esi,offset file_data
add     esi,[map_ofs]
mov     ebx,[map_pos]
cmp     [byte ptr esi + ebx],0FFh
je      MAP_wait_key

mov     esi,offset map_colors
add     esi,[map_pos]
mov     al,[byte ptr esi]
cmp     al,4
jnz     _map_ok
mov     al,-1
_map_ok:
inc     al
mov     [byte ptr esi],al
mov     esi,offset file_data
add     esi,[map_ofs]
mov     ebx,[map_pos]
mov     [byte ptr esi + ebx],00h
jmp     MAP_wait_key

MAP_insert:
mov     esi,offset file_data
add     esi,[map_ofs]
mov     ebx,[map_pos]
cmp     [byte ptr esi + ebx],0FFh
jnz     MAP_wait_key
mov     [byte ptr esi + ebx],00h
jmp     MAP_wait_key

MAP_delete:
mov     esi,offset file_data
add     esi,[map_ofs]
mov     ebx,[map_pos]
mov     [byte ptr esi + ebx],0FFh
jmp     MAP_wait_key

MAP_map_left:
mov     ebx,[map_pos]
and     ebx,31
cmp     ebx,1
je      MAP_wait_key

dec     [map_pos]
mov     [current_obj],0
jmp     MAP_wait_key

MAP_map_right:
mov     ebx,[map_pos]
and     ebx,31
cmp     ebx,30
je      MAP_wait_key

inc     [map_pos]
mov     [current_obj],0
jmp     MAP_wait_key

MAP_map_up:
mov     ebx,[map_pos]
shr     ebx,5
and     ebx,31
cmp     ebx,0
je      MAP_wait_key

sub     [map_pos],32
mov     [current_obj],0
jmp     MAP_wait_key

MAP_map_down:
mov     ebx,[map_pos]
shr     ebx,5
and     ebx,31
cmp     ebx,29
je      MAP_wait_key

add     [map_pos],32
mov     [current_obj],0
jmp     MAP_wait_key

;
;-------
;

prev_obj:
mov     [drag_flag],0
cmp     [current_obj],0
je      main_loop
dec     [current_obj]
jmp     main_loop

next_obj:
mov     [drag_flag],0
mov     al,[current_obj]
call    FindObj
cmp     [byte ptr esi+3],0FDh
je      main_loop
cmp     [byte ptr esi+3],0FFh
je      main_loop
inc     [current_obj]
jmp     main_loop

change_color:
mov     al,[current_obj]
call    FindObj
inc     [byte ptr esi+2]
and     [byte ptr esi+2],3
jmp     main_loop

next_struct:
mov     al,[current_obj]
call    FindObj
mov     al,[num_struct]
cmp     al,[byte ptr esi+1]
jnz     struct_ok
mov     [byte ptr esi+1],0
jmp     main_loop
struct_ok:
inc     [byte ptr esi+1]
jmp     main_loop

prev_struct:
mov     al,[current_obj]
call    FindObj
cmp     [byte ptr esi+1],0
jnz     struct_ok2
mov     al,[num_struct]
mov     [byte ptr esi+1],al
jmp     main_loop
struct_ok2:
dec     [byte ptr esi+1]
jmp     main_loop

change_area:
mov     [drag_flag],0
inc     [current_area]
cmp     [current_area],5
jb      no_area_reset
mov     [current_area],0
no_area_reset:
movzx   eax,[current_area]
mov     edx,size Area
mul     edx
mov     ebx,eax
mov     eax,[ebx + Areas.map_pos]
mov     [map_pos],eax
mov     [current_obj],0
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
add     edi,(220*256)+100
call    disp_string
mov     esi,offset save_string
add     edi,256
call    disp_string
mov     ah,00
int     16h
jmp     main_loop

up:
mov     ah,02
int     16h
test    al,00000010b
jnz     map_up

mov     [drag_flag],0
mov     al,[current_obj]
call    FindObj

mov     al,[byte ptr esi]
and     al,11110000b
jz      main_loop
sub     [byte ptr esi],10h
jmp     main_loop

room_up:
mov     esi,offset file_data
add     esi,[map_ofs]
mov     ebx,[map_pos]
mov     al,[num_rooms]
cmp     al,[byte ptr esi + ebx]
je      main_loop
inc     [byte ptr esi + ebx]
mov     [current_obj],0
mov     [drag_flag],0
jmp     main_loop

map_up:
cmp     [map_pos],32
jb      main_loop

mov     esi,offset file_data
add     esi,[map_ofs]
mov     ebx,[map_pos]
movzx   eax,[byte ptr esi + ebx-32]
cmp     al,0FFh
je      main_loop

sub     [map_pos],32
mov     [current_obj],0
jmp     main_loop

down:
mov     ah,02
int     16h
test    al,00000010b
jnz     map_down

mov     [drag_flag],0
mov     al,[current_obj]
call    FindObj

add     [byte ptr esi],10h
mov     al,[byte ptr esi]
shr     al,4
cmp     al,0Fh
jnz     main_loop
and     [byte ptr esi],0Fh
jmp     main_loop

room_down:
mov     esi,offset file_data
add     esi,[map_ofs]
mov     ebx,[map_pos]
cmp     [byte ptr esi + ebx],0
je      main_loop
dec     [byte ptr esi + ebx]
mov     [current_obj],0
mov     [drag_flag],0
jmp     main_loop

map_down:

mov     esi,offset file_data
add     esi,[map_ofs]
mov     ebx,[map_pos]
movzx   eax,[byte ptr esi + ebx+32]
cmp     al,0FFh
je      main_loop

add     [map_pos],32
mov     [current_obj],0
jmp     main_loop

left:
mov     ah,02
int     16h
test    al,00000010b
jnz     map_left

mov     [drag_flag],0
mov     al,[current_obj]
call    FindObj

mov     al,[byte ptr esi]
mov     bl,al
and     bl,11110000b
dec     al
and     al,00001111b
or      bl,al
mov     [byte ptr esi],bl

jmp     main_loop

map_left:
cmp     [map_pos],0
je      main_loop

mov     esi,offset file_data
add     esi,[map_ofs]
mov     ebx,[map_pos]
movzx   eax,[byte ptr esi + ebx-1]
cmp     al,0FFh
je      main_loop

dec     [map_pos]
mov     [drag_flag],0
mov     [current_obj],0
jmp     main_loop

right:
mov     ah,02
int     16h
test    al,00000010b
jnz     map_right

mov     [drag_flag],0
mov     al,[current_obj]
call    FindObj

mov     al,[byte ptr esi]
mov     bl,al
and     bl,11110000b
inc     al
and     al,00001111b
or      bl,al
mov     [byte ptr esi],bl
jmp     main_loop

map_right:
mov     esi,offset file_data
add     esi,[map_ofs]
mov     ebx,[map_pos]
movzx   eax,[byte ptr esi + ebx+1]
cmp     al,0FFh
je      main_loop

inc     [map_pos]
mov     [drag_flag],0
mov     [current_obj],0
jmp     main_loop

exit:

mov     ax,205h
mov     bl,08h
mov     edx,[dword ptr oldint8]                    ; set oldint8 back
mov     cx,[word ptr oldint8+4]
int     31h

mov     ah,3Ch
xor     cx,cx
mov     edx,offset map_file
int     21h
mov     bx,ax
mov     ah,40h
mov     edx,offset map_colors
mov     ecx,32*30
int     21h
mov     ah,3Eh
int     21h

mov     ax,3
int     10h

terminate:
mov     ax,4c00h
int     21h

PROC    DrawRoom

; EAX = room #

pushad

mov     esi,offset file_data
add     esi,[room_ptr]          ; ESI points to room pointer table
movzx   eax,[word ptr esi + eax*2]      ; fetch pointer for this room
sub     eax,[room_sub]
mov     esi,offset file_data
add     esi,[room_ofs]
add     esi,eax                 ; ESI points to this room's data

mov     edi,offset virtual_screen
xor     eax,eax
mov     bh,240
@@clear_vrscreen:
mov     ecx,256/4
rep     stosd
add     edi,256
dec     bh
jnz     @@clear_vrscreen

inc     esi
@@draw_element:
movzx   eax,[byte ptr esi]
and     al,11110000b                    ; isolate Y coord
shl     eax,9
movzx   ebx,[byte ptr esi]
and     bl,00001111b                    ; isolate X coord
shl     ebx,4
add     eax,ebx
mov     edi,offset virtual_screen
add     edi,eax
movzx   eax,[byte ptr esi+2]
shl     al,2
mov     ah,al
push    ax
shl     eax,16
pop     ax
mov     ebp,eax
movzx   eax,[byte ptr esi+1]             ; structure #
call    DrawStruct

add     esi,3
cmp     [byte ptr esi],0FDh
je      @@done
cmp     [byte ptr esi],0FFh
jnz     @@draw_element
@@done:

popad
ret
ENDP    DrawRoom

PROC    DrawStruct

; AL = structure #

pushad

mov     esi,offset file_data
add     esi,[struct_ptr]
movzx   ebx,[word ptr esi + eax*2]
sub     ebx,[struct_sub]
mov     esi,offset file_data
add     esi,[struct_ofs]
add     esi,ebx

@@draw_it:
mov     cl,[byte ptr esi]               ; times to draw structure
inc     esi
push    edi
@@draw_loop:
mov     al,[byte ptr esi]               ; macro #
call    DrawMacro
inc     esi
add     edi,16
dec     cl
jnz     @@draw_loop
pop     edi
add     edi,512*16
cmp     [byte ptr esi],0FFh
jnz     @@draw_it

popad
ret
ENDP    DrawStruct

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
push    esi
push    edi
mov     esi,[gfx_ofs]
mov     eax,[dword ptr esi + eax*4]
mov     esi,offset file_data
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
add     edi,512
endm
pop     edi
pop     esi
inc     esi
add     edi,8
dec     cl
jnz     @@20
pop     edi
add     edi,512*8
dec     ch
jnz     @@10
popad
ret
ENDP    DrawMacro

PROC    SetArea

; AL = level #

pushad
movzx   eax,al
mov     edx,size Area
mul     edx
mov     ebx,eax
mov     eax,[ebx + Areas.room_ptr]
mov     [room_ptr],eax
mov     eax,[ebx + Areas.room_ofs]
mov     [room_ofs],eax
mov     al,[ebx + Areas.num_rooms]
mov     [num_rooms],al
mov     eax,[ebx + Areas.struct_ptr]
mov     [struct_ptr],eax
mov     eax,[ebx + Areas.struct_ofs]
mov     [struct_ofs],eax
mov     al,[ebx + Areas.num_struct]
mov     [num_struct],al
mov     eax,[ebx + Areas.macro_ofs]
mov     [macro_ofs],eax
mov     eax,[ebx + Areas.palette_ofs]
mov     [palette_ofs],eax

mov     esi,offset file_data
add     esi,[room_ptr]
movzx   eax,[word ptr esi]
mov     [room_sub],eax

mov     esi,offset file_data
add     esi,[struct_ptr]
movzx   eax,[word ptr esi]
mov     [struct_sub],eax

mov     eax,[ebx + Areas.gfx_ofs]
mov     [gfx_ofs],eax

mov     eax,[ebx + Areas.coords_ofs]
mov     [coords_ofs],eax

mov     esi,offset file_data
add     esi,[palette_ofs]
call    SetPalette

popad
ret
ENDP    SetArea

PROC    FindObj

; in: AL = object number
; out: ESI = pointer to object data

push    ebx edx

movzx   eax,al
mov     esi,offset file_data
add     esi,[map_ofs]
mov     ebx,[map_pos]
movzx   ebx,[byte ptr esi + ebx]
mov     esi,offset file_data
add     esi,[room_ptr]
movzx   ebx,[word ptr esi + ebx*2]
sub     ebx,[room_sub]
mov     esi,offset file_data
add     esi,ebx
add     esi,[room_ofs]
inc     esi

mov     edx,3
mul     edx
add     esi,eax

pop     edx ebx
ret
ENDP    FindObj

PROC    ShowInfo

pushad

mov     esi,offset file_data
add     esi,[map_ofs]           ; ESI points to level map
mov     ebx,[map_pos]         ; current position on map
movzx   eax,[byte ptr esi + ebx]
mov     ebx,16
mov     cl,2
mov     edi,offset room_string + 5
call    NumToASCII

mov     al,[current_obj]
mov     edi,offset obj_string + 7
call    NumToASCII

mov     eax,[map_pos]
and     al,1Fh
mov     edi,offset map_string + 9
call    NumToASCII

mov     eax,[map_pos]
shr     eax,5
inc     al
mov     edi,offset map_string + 12
call    NumToASCII

mov     al,[current_obj]
call    FindObj
mov     al,[byte ptr esi]
and     al,00001111b
mov     ebx,16
mov     cl,1
mov     edi,offset obj_string + 10
call    NumToASCII
mov     al,[byte ptr esi]
shr     al,4
add     edi,2
call    NumToASCII

mov     edi,offset virtual_screen + (4*512)+4
mov     esi,offset map_string
call    disp_string

add     edi,8*512
mov     esi,offset room_string
call    disp_string

add     edi,8*512
mov     esi,offset obj_string
call    disp_string

mov     al,[current_obj]
call    FindObj
movzx   eax,[byte ptr esi]
and     al,11110000b
shl     eax,9
mov     edi,offset virtual_screen
add     edi,eax
movzx   eax,[byte ptr esi]
and     al,00001111b
shl     eax,4
add     edi,eax
mov     ecx,16
mov     al,33
rep     stosb
add     edi,512-16
mov     ecx,16
rep     stosb

popad
ret
ENDP    ShowInfo

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
call    HexDigit
stosb
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

PROC    DrawScreen

pushad

mov     esi,offset virtual_screen
mov     edi,[video_mem]
mov     bh,240
@@show_room_y:
mov     ecx,256/4
rep     movsd
add     esi,256
dec     bh
jnz     @@show_room_y

popad
ret
ENDP    DrawScreen

PROC    DrawMap

pushad

mov     edi,offset virtual_screen
mov     ecx,(256*240)/4
xor     eax,eax
rep     stosd

xor     edx,edx
mov     esi,offset file_data
add     esi,[map_ofs]
mov     edi,offset virtual_screen
mov     bh,30
map_y:
push    edi
mov     bl,32
map_x:
push    edi
mov     al,[byte ptr esi]
cmp     al,0FFh
je      draw_blank
mov     al,64
add     al,[map_colors + edx]
draw_blank:
rept    7
mov     ecx,7
rep     stosb
add     edi,256-7
endm
inc     esi
pop     edi
add     edi,8
inc     edx
dec     bl
jnz     map_x
pop     edi
add     edi,8*256
dec     bh
jnz     map_y

movzx   eax,[file_data + 055E8h]
dec     al
shl     eax,3
shl     eax,8
mov     edi,offset virtual_screen
add     edi,eax
movzx   eax,[file_data + 055E7h]
shl     eax,3
add     edi,eax
mov     al,64+5
rept    7
mov     ecx,7
rep     stosb
add     edi,256-7
endm

mov     edi,offset virtual_screen
mov     eax,[map_pos]
shr     eax,5
shl     eax,3
shl     eax,8
add     edi,eax
mov     eax,[map_pos]
and     eax,31
shl     eax,3
add     edi,eax
mov     al,33
rept    6
mov     [byte ptr edi],al
inc     edi
endm
rept    6
mov     [byte ptr edi],al
add     edi,256
endm
rept    6
mov     [byte ptr edi],al
dec     edi
endm
rept    6
mov     [byte ptr edi],al
sub     edi,256
endm

mov     esi,offset virtual_screen
mov     edi,[video_mem]
mov     ecx,(256*240)/4
rep     movsd

popad
ret
ENDP    DrawMap

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

PROC    WaitVrt
push    eax edx
    mov     dx,3dah
Vrt:
    in      al,dx
    test    al,1000b        
    jnz     Vrt            
NoVrt:
    in      al,dx
    test    al,1000b         
    jz      NoVrt         
pop     edx eax
    ret
ENDP    WaitVrt

PROC    CmpMouse

cmp     [mouse_x],eax
jb      @@false
cmp     [mouse_y],ebx
jb      @@false
cmp     [mouse_x],ecx
ja      @@false
cmp     [mouse_y],edx
ja      @@false

mov     ecx,[mouse_x]
sub     ecx,eax
mov     edx,[mouse_y]
sub     edx,ebx

xor     al,al
ret

@@false:
xor     al,al
inc     al

ret
ENDP    CmpMouse

PROC    ReadMouse
pushad
cmp     [mouse_on],0
je      @@99

mov     al,[button_status]
mov     [button_status2],al
xor     ecx,ecx
xor     edx,edx
mov     ax,3
int     33h
shr     ecx,1
mov     [mouse_x],ecx
mov     [mouse_y],edx
mov     [button_status],bl

cmp     [drag_flag],1
je      @@drag_obj

test    [button_status],1
jz      @@99
test    [button_status2],1
jnz     @@99

mov     esi,offset file_data
add     esi,[map_ofs]           ; ESI points to level map
mov     ebx,[map_pos]
movzx   eax,[byte ptr esi + ebx]        ; EAX = room #
mov     esi,offset file_data
add     esi,[room_ptr]          ; ESI points to room pointer table
movzx   eax,[word ptr esi + eax*2]      ; fetch pointer for this room
sub     eax,[room_sub]
mov     esi,offset file_data
add     esi,[room_ofs]
add     esi,eax                 ; ESI points to this room's data
inc     esi
mov     edi,esi
sub     edi,3
xor     ebp,ebp
@@go_end:
cmp     [byte ptr esi+3],0FDh
je      @@10
cmp     [byte ptr esi+3],0FFh
je      @@10
inc     ebp
add     esi,3
jmp     @@go_end
@@10:
movzx   eax,[byte ptr esi]
and     al,00001111b                    ; isolate X coord
shl     eax,4
movzx   ebx,[byte ptr esi]
and     bl,11110000b                    ; isolate Y coord

push    edi
mov     edi,[coords_ofs]
movzx   edx,[byte ptr esi+1]
movzx   ecx,[byte ptr edi + edx*2]
add     ecx,eax
dec     ecx
mov     dl,[byte ptr edi + edx*2 + 1]
add     edx,ebx
dec     edx
pop     edi

call    CmpMouse
je      @@obj_click

dec     ebp
sub     esi,3
cmp     esi,edi
jnz     @@10
jmp     @@99

@@obj_click:
mov     eax,ebp
mov     [current_obj],al
mov     [drag_flag],1
call    FindObj
mov     bl,[byte ptr esi]
and     bl,00001111b
mov     eax,[mouse_x]
shr     eax,4
sub     al,bl
mov     [temp_x],al
mov     bl,[byte ptr esi]
and     bl,11110000b
mov     eax,[mouse_y]
and     al,11110000b
sub     al,bl
shr     al,4
mov     [temp_y],al
jmp     @@99

@@drag_obj:
mov     al,[current_obj]
call    FindObj
mov     eax,[mouse_x]
shr     eax,4
and     [byte ptr esi],11110000b
sub     al,[temp_x]
js      @@nope1
or      [byte ptr esi],al
@@nope1:
mov     eax,[mouse_y]
and     al,11110000b
and     [byte ptr esi],00001111b
shr     al,4
sub     al,[temp_y]
js      @@nope2
shl     al,4
or      [byte ptr esi],al
@@nope2:
test    [button_status],2
jz      @@check_left
test    [button_status2],2
jnz     @@check_left

mov     ah,02
int     16h
test    al,00000010b
jz      @@next_struct

mov     al,[current_obj]
call    FindObj
cmp     [byte ptr esi+1],0
je      @@set_last

dec     [byte ptr esi+1]
jmp     @@check_left

@@set_last:
mov     al,[num_struct]
mov     [byte ptr esi+1],al
jmp     @@check_left

@@next_struct:
mov     al,[current_obj]
call    FindObj
mov     al,[num_struct]
cmp     al,[byte ptr esi+1]
jnz     @@struct_ok
mov     [byte ptr esi+1],0
jmp     main_loop
@@struct_ok:
inc     [byte ptr esi+1]

@@check_left:
test    [button_status],1
jz      @@99
test    [button_status2],1
jnz     @@99
mov     [drag_flag],0
jmp     @@99

@@99:
popad
ret
ENDP    ReadMouse

PROC    DrawMouse
pushad
cmp     [mouse_on],0
je      @@99
mov     esi,offset mouse_cursor
mov     edi,offset virtual_screen
mov     eax,[mouse_y]
shl     eax,9
add     edi,eax
add     edi,[mouse_x]

mov     ch,10
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
add     edi,512-8
dec     ch
jnz     @@yloop

@@99:
popad
ret
ENDP    DrawMouse

end     start
