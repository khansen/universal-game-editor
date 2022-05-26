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
color_ofs       dd ?
gfx_ofs         dd ?
ENDS

level_array     db 0,7,13

Levels  Level   <003D0h,04C0h,00010h,105,00CB0h,00310h,gfx_MM1Cut>       ; Cutman
        Level   <043D0h,0400h,04010h,065,04CB0h,04310h,gfx_MM1Ice>       ; Iceman
        Level   <083D0h,0380h,08010h,125,08CB0h,08310h,gfx_MM1Bomb>      ; Bombman
        Level   <0C3D0h,0440h,0C010h,120,0CCB0h,0C310h,gfx_MM1Fire>      ; Fireman
        Level   <103D0h,03C0h,10010h,120,10CB0h,10310h,gfx_MM1Elec>      ; Elecman
        Level   <143D0h,03C0h,14010h,080,14CB0h,14310h,gfx_MM1Guts>      ; Gutsman
        Level   <008D0h,02C0h,00010h,065,00CE0h,00310h,gfx_MM1Wily>      ; Wily stage

        Level   <00510h,05C0h,00010h,140,03E12h,00410h,gfx_MM2Heat>      ; Heatman
        Level   <04510h,0540h,04010h,140,07E12h,04410h,gfx_MM2Air>       ; Airman
        Level   <08510h,05C0h,08010h,140,0BE12h,08410h,gfx_MM2Wood>      ; Woodman
        Level   <0C510h,0540h,0C010h,125,0FE12h,0C410h,gfx_MM2Bub>       ; Bubbleman
        Level   <10510h,05C0h,10010h,145,13E12h,10410h,gfx_MM2Quick>     ; Quickman
        Level   <14510h,04C0h,14010h,130,17E12h,14410h,gfx_MM2Flash>     ; Flashman
        Level   <18510h,0540h,18010h,225,1BE12h,18410h,gfx_MM2Metal>     ; Metalman
        Level   <1C510h,04C0h,1C010h,255,1FE12h,1C410h,gfx_MM2Crash>     ; Crashman
        Level   <00B10h,04C0h,00010h,140,03F12h,00410h,gfx_MM2Wily1>     ; 1st Wily stage
        Level   <04A90h,04C0h,04010h,140,07F12h,04410h,gfx_MM2Wily2>     ; 2nd Wily stage
        Level   <08B10h,0440h,08010h,140,0BF12h,08410h,gfx_MM2Wily3>     ; 3rd Wily stage
        Level   <0CA90h,0400h,0C010h,125,0FF12h,0C410h,gfx_MM2Wily4>     ; 4th Wily stage
        Level   <14A90h,0280h,14010h,125,17F12h,14410h,gfx_MM2Wily5>     ; 5th Wily stage

welcome_msg     db 13,10
                db ' +----------------------+',13,10
                db ' | MegaMan level editor |',13,10
                db ' +----------------------+',13,10
                db ' (c) Kent Hansen 1998',13,10
                db 13,10
                db ' Read "megaedit.txt" CAREFULLY to avoid trouble.',13,10
                db 13,10
                db ' Which Mega Man game do you wish to edit?',13,10
                db 13,10
                db ' 1: Mega Man I',13,10
                db ' 2: Mega Man II',13,10
                db '$'

keyb_buffer     dd 000400h
video_mem       dd 0A0000h

rom_file        db 'megaman!.nes',0

file_error      db 13,10,' ERROR: Could not open MEGAMAN!.NES',13,10,'$'
size_error      db 13,10,' ERROR: MEGAMAN!.NES must be 131,088 bytes',13,10,'$'
mouse_error     db 13,10,' ERROR: This program requires a mouse.',13,10,'$'

obj_string      db '0000',0
save_string     db 'CHANGES SAVED: STRIKE A KEY',0

include "mm1_0.inc"
include "mm1_1.inc"
include "mm1_2.inc"
include "mm1_3.inc"
include "mm1_4.inc"
include "mm1_5.inc"
include "mm1_6.inc"

include "mm2_0.inc"
include "mm2_1.inc"
include "mm2_2.inc"
include "mm2_3.inc"
include "mm2_4.inc"
include "mm2_5.inc"
include "mm2_6.inc"
include "mm2_7.inc"
include "mm2_8.inc"
include "mm2_9.inc"
include "mm2_10.inc"
include "mm2_11.inc"
include "mm2_12.inc"

game_ofs        dd 0
level_pos       dd 0
current_level   db 0
current_room    db 0
obj_pos         db 0
selected_obj    db 0
current_obj     db 0

shade           db 0
fade_type       db 0

keyboard        db 128 dup (0)

file_size       dd ?

oldint8         df ?

num_levels      db ?
level_ofs       dd ?
level_end       dd ?
struct_ofs      dd ?
max_struct      db ?
palette_ofs     dd ?
gfx_ofs         dd ?
color_ofs       dd ?

mouse_x         dd ?
mouse_y         dd ?
button_status   db ?

virtual_screen  db 320*256 dup (?)
file_data       db 262160 dup (?)
precalcbuffer   db 10000h*8 dup (?)

CODESEG

include "font.inc"
include "tweak.inc"
include "palette.inc"

start:

mov     ah,09
mov     edx,offset welcome_msg
int     21h

select_game:
mov     ah,00
int     16h
cmp     al,'1'
jb      select_game
cmp     al,'2'
ja      select_game

mov     [ROM_file + 7],al
mov     [file_error + 32],al
mov     [size_error + 17],al

sub     al,30h
movzx   eax,al
mov     bl,[level_array + eax]
mov     [num_levels],bl
dec     al
mov     al,[level_array + eax]
mov     edx,size Level
mul     edx
mov     [game_ofs],eax

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
mov     ecx,262160
int     21h

mov     [file_size],eax

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
cmp     al,9
je      switch_struct_set
cmp     al,27
je      exit
jmp     main_loop

extended_key:
mov     al,ah
cmp     al,3Bh
je      change_level
cmp     al,3Fh
je      save_changes
cmp     al,49h
je      page_up
cmp     al,51h
je      page_down
cmp     al,4Bh
je      map_left
cmp     al,4Dh
je      map_right
jmp     main_loop

map_right:
mov     eax,[level_end]
cmp     eax,[level_pos]
je      main_loop
add     [level_pos],8
jmp     main_loop

map_left:
cmp     [level_pos],0
je      main_loop
sub     [level_pos],8
jmp     main_loop

page_down:
cmp     [level_pos],64
jbe     to_start
sub     [level_pos],64
jmp     main_loop
to_start:
mov     [level_pos],0
jmp     main_loop

page_up:
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
mov     ecx,[file_size]
int     21h
mov     ah,3Eh
int     21h

mov     esi,offset save_string
mov     edi,offset virtual_screen + (320*100) + 70
call    disp_string
call    DrawScreen
mov     ah,00h
int     16h
jmp     main_loop

switch_struct_set:
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
inc     [current_level]
mov     al,[num_levels]
cmp     [current_level],al
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
pop     eax
add     al,2
add     edi,8
dec     cl
jnz     @@20
sub     al,3
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
mov     esi,offset file_data
add     esi,[color_ofs]
mov     bl,[byte ptr esi + eax]
mov     esi,offset file_data
add     esi,[struct_ofs]
shl     eax,2
add     esi,eax
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
mov     al,[byte ptr esi]
call    DrawMacro
add     esi,2
add     edi,16
pop     ebx
ror     bl,2
dec     cl
jnz     @@20
sub     esi,3
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
add     edi,32*320
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
add     ebx,[game_ofs]

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
mov     eax,[ebx + Levels.color_ofs]
mov     [color_ofs],eax

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

; mov     eax,[level_pos]
; mov     ebx,16
; mov     cl,4
; mov     edi,offset obj_string
; call    FNT_NumToASCII
; mov     esi,offset obj_string
; mov     edi,offset virtual_screen + (8*320)+8
; call    disp_string

;
; -----------------
;

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
and     edx,7
shl     edx,3
add     esi,edx
pop     edx
shr     edx,3
add     esi,edx
mov     al,[byte ptr esi]
mov     [selected_obj],al
jmp     @@end_read

@@put_struct:
mov     esi,offset file_data
add     esi,[level_ofs]
add     esi,[level_pos]
push    edx
and     edx,7
shl     edx,3
add     esi,edx
pop     edx
shr     edx,3
add     esi,edx
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

END     start
