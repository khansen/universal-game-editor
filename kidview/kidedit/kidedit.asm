IDEAL
P386N
MODEL FLAT
STACK 1000h
JUMPS

SC_INDEX        equ     03c4h   ;Sequence Controller Index
CRTC_INDEX      equ     03d4h   ;CRT Controller Index
MISC_OUTPUT     equ     03c2h   ;Miscellaneous Output register

DATASEG

STRUC           Level
num_rooms       db ?
room_ofs        dd ?
struct_ofs      dd ?
macro_ofs       dd ?
palette_ofs     dd ?
gfx_ofs         dd ?
room_ptr        dd ?
room_sub        dd ?
last_macro_ofs  dd ?
struct_ptr      dd ?
ENDS

Level_info      Level <28h,19950h,1A1BAh,1A2ECh,1A6F7h,04410h,01A56Ah,07000h,01A2E9h,01A5CCh>   ; Level 1-1
                Level <28h,19950h,1A1BAh,1A2ECh,1A717h,04410h,01A584h,07000h,01A2E9h>   ; Level 1-2
                Level <28h,19950h,1A1BAh,1A2ECh,1A737h,04410h,01A5A2h,07000h,01A2E9h>   ; Level 1-3
                Level <2Dh,0B04Ah,0B82Dh,0B940h,0BE46h,04C10h,00BB3Eh,0B03Ah,00B93Bh>   ; Level 2-1
                Level <2Dh,0B04Ah,0B82Dh,0B940h,0BE66h,04C10h,00BB76h,0B03Ah,00B93Bh>   ; Level 2-2
                Level <2Dh,0B04Ah,0B82Dh,0B940h,0BE86h,04C10h,00BBB4h,0B03Ah,00B93Bh>   ; Level 2-3
                Level <16h,1A7A0h,1ABC6h,1AC77h,1B06Ch,05410h,01AEF5h,07000h,01AC74h>   ; Level 3-1
                Level <16h,1A7A0h,1ABC6h,1AC77h,1B08Ch,05410h,01AF0Dh,07000h,01AC74h>   ; Level 3-2
                Level <16h,1A7A0h,1ABC6h,1AC77h,1B0ACh,05410h,01AF2Bh,07000h,01AC74h>   ; Level 3-3
                Level <06h,0FA8Ch,0FBFDh,0FCB8h,0FF34h,05C10h,00FEB6h,0BA7Ch,00FCA3h>   ; Level 4-1
                Level <19h,15BF5h,1626Dh,1631Eh,1B8D2h,05410h,01B130h,09BE5h>   ; Level 1-4, 2-4, 3-4

level_string    db 'LEVEL: - ',0
lvlpos_string   db 'MAP POS:  ',0
obj_string      db 'OBJECT:  ( , )',0
save_string     db 'CHANGES SAVED',0

welcome_msg     db 13,10
                db ' +-------------------------+',13,10
                db ' | Kid Icarus level editor |',13,10
                db ' +-------------------------+',13,10
                db ' (c) Kent Hansen 1998',13,10
                db 13,10
                db ' Read "kidedit.txt" for instructions.',13,10
                db '$'

current_level   db 0
shade           db 0
fade_type       db 0

keyb_buffer     dd 000400h
video_mem       dd 0A0000h

rom_file        db 'kidicar.nes',0

file_error      db 13,10,' ERROR: Could not open KIDICAR.NES',13,10,'$'
size_error      db 13,10,' ERROR: KIDICAR.NES must be 131,088 bytes',13,10,'$'

current_room    dd ?
current_obj     db ?
level_pos       dd ?
num_rooms       db ?
room_ofs        dd ?
struct_ofs      dd ?
macro_ofs       dd ?
palette_ofs     dd ?
room_ptr        dd ?
room_sub        dd ?
last_macro_ofs  dd ?

oldint8         df ?

virtual_screen  db 512*480 dup (?)
file_data       db 131088 dup (?)
pattern_table   db 16*256 dup (?)
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

mov     esi,offset file_data
add     esi,(256*16)+16
mov     edi,offset pattern_table
mov     ecx,256*12
rep     movsb

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

start_it_up:
mov     al,[current_level]
call    SetLevel

mov     ebx,[room_ptr]
movzx   eax,[word ptr file_data + ebx]
sub     eax,[room_sub]
add     eax,offset file_data
add     eax,[room_ofs]
mov     [current_room],eax

movzx   eax,[current_level]
mov     ebx,3
xor     edx,edx
div     ebx
inc     al
add     al,30h
mov     [level_string + 6],al
inc     dl
add     dl,30h
mov     [level_string + 8],dl

main_loop:

;
; -------------------
;

mov     eax,[level_pos]
mov     ebx,16
mov     cl,2
mov     edi,offset lvlpos_string + 8
call    NumToASCII

movzx   eax,[current_obj]
mov     ebx,16
mov     cl,2
mov     edi,offset obj_string + 7
call    NumToASCII

mov     esi,[current_room]
mov     al,[current_obj]
call    FindObj
movzx   eax,[byte ptr esi]
shr     al,4
mov     ebx,16
mov     cl,1
mov     edi,offset obj_string + 10
call    NumToASCII
movzx   eax,[byte ptr esi]
and     al,00001111b
add     edi,2
call    NumToASCII

;
; -------------------
;

mov     esi,[current_room]
call    DrawRoom

mov     esi,offset level_string
mov     edi,offset virtual_screen
call    disp_string

mov     esi,offset lvlpos_string
add     edi,8*512
call    disp_string

mov     esi,offset obj_string
add     edi,8*512
call    disp_string

mov     esi,[current_room]
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

show_screen:
mov     esi,offset virtual_screen
mov     edi,[video_mem]
mov     bh,240
@@show_room_y:
mov     ecx,256/4
rep     movsd
add     esi,256
dec     bh
jnz     @@show_room_y

wait_key:

mov     ah,00
int     16h

cmp     al,27
je      exit
cmp     al,'A'
je      prev_obj
cmp     al,'a'
je      prev_obj
cmp     al,'S'
je      next_obj
cmp     al,'s'
je      next_obj
cmp     ah,0Fh
je      change_struct
cmp     ah,3Bh
je      new_level
cmp     ah,3Fh
je      save_changes
cmp     ah,48h
je      up
cmp     ah,50h
je      down
cmp     ah,4Bh
je      left
cmp     ah,4Dh
je      right
cmp     ah,52h
je      ins_obj
cmp     ah,53h
je      del_obj
cmp     al,'2'
je      change_objcolor
jmp     wait_key

new_level:
inc     [current_level]
cmp     [current_level],10
jb      start_it_up
sub     [current_level],10
jmp     start_it_up

ins_obj:
mov     esi,[current_room]
find_last:
inc     esi
cmp     [word ptr esi-1],0FFFDh
jnz     find_last
cmp     [byte ptr esi+2],0FDh
jnz     wait_key
mov     [word ptr esi-1],0
jmp     main_loop

del_obj:
mov     esi,[current_room]
mov     al,[current_obj]
call    FindObj
cmp     [byte ptr esi+3],0FDh
je      wait_key
copy_loop:
cmp     [byte ptr esi+3],0FDh
je      done_copy
mov     al,[byte ptr esi+3]
mov     [byte ptr esi+0],al
mov     al,[byte ptr esi+4]
mov     [byte ptr esi+1],al
mov     al,[byte ptr esi+5]
mov     [byte ptr esi+2],al
add     esi,3
jmp     copy_loop
done_copy:
mov     [current_obj],0
mov     [byte ptr esi],0FDh
mov     [byte ptr esi+1],0FFh
jmp     main_loop

prev_obj:
cmp     [current_obj],0
je      wait_key
dec     [current_obj]
jmp     main_loop

next_obj:
mov     esi,[current_room]
mov     al,[current_obj]
call    FindObj
cmp     [byte ptr esi+3],0FDh
je      wait_key
inc     [current_obj]
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
jmp     wait_key

change_objcolor:
mov     esi,[current_room]
mov     al,[current_obj]
call    FindObj
inc     [byte ptr esi+2]
and     [byte ptr esi+2],3
jmp     main_loop

change_struct:

mov     esi,[current_room]
mov     al,[current_obj]
call    FindObj

mov     ah,02
int     16h
test    al,00000010b
jnz     prev_struct

mov     al,[byte ptr esi+1]
call    FindStruct
sub     esi,offset file_data
cmp     esi,[last_macro_ofs]
jnz     struct_ok
mov     esi,[current_room]
mov     al,[current_obj]
call    FindObj
mov     [byte ptr esi+1],0
jmp     main_loop

struct_ok:
mov     esi,[current_room]
mov     al,[current_obj]
call    FindObj
inc     [byte ptr esi+1]
jmp     main_loop

prev_struct:
cmp     [byte ptr esi+1],0
je      main_loop
dec     [byte ptr esi+1]
jmp     main_loop

left:
mov     ah,02
int     16h
test    al,00000010b
jz      move_left

cmp     [level_pos],0
je      wait_key
mov     [current_obj],0
dec     [level_pos]
mov     ebx,[level_pos]
add     ebx,ebx
add     ebx,[room_ptr]
movzx   eax,[word ptr file_data + ebx]
sub     eax,[room_sub]
add     eax,offset file_data
add     eax,[room_ofs]
mov     [current_room],eax
jmp     main_loop

move_left:
mov     esi,[current_room]
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

right:
mov     ah,02
int     16h
test    al,00000010b
jz      move_right

mov     ebx,[level_pos]
add     ebx,ebx
add     ebx,[room_ptr]
add     ebx,2
movzx   eax,[word ptr file_data + ebx]
cmp     eax,0FFFFh
je      wait_key
cmp     eax,00000h
je      exit
sub     eax,[room_sub]
add     eax,offset file_data
add     eax,[room_ofs]
mov     [current_room],eax
mov     [current_obj],0
inc     [level_pos]
jmp     main_loop

move_right:
mov     esi,[current_room]
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

up:
mov     esi,[current_room]
mov     al,[current_obj]
call    FindObj
mov     al,[byte ptr esi]
and     al,11110000b
jz      main_loop
sub     [byte ptr esi],10h
jmp     main_loop

down:
mov     esi,[current_room]
mov     al,[current_obj]
call    FindObj
mov     al,[byte ptr esi]
and     al,11110000b
cmp     al,0E0h
je      main_loop
add     [byte ptr esi],10h
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

PROC    FindObj

; AL = object number

inc     esi
cmp     al,0
je      @@99
@@10:
add     esi,3
dec     al
jnz     @@10
@@99:
ret
ENDP    FindObj

PROC    FindStruct

; AL = structure number

mov     esi,offset file_data
add     esi,[struct_ofs]

cmp     al,0
je      @@99
mov     ah,al
@@find_ff:
lodsb
cmp     al,0FFh
jnz     @@find_ff
dec     ah
jnz     @@find_ff
@@99:
ret
ENDP    FindStruct

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

PROC    DrawStruct

; AL = structure #

pushad
call    FindStruct

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

PROC    DrawRoom

; ESI = pointer to room data

pushad

mov     edi,offset virtual_screen
xor     ebx,ebx
mov     ecx,(256*240*2)/4
@@clear_vrscreen:
mov     [dword ptr edi],ebx
add     edi,4
dec     ecx
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
mov     al,[byte ptr esi+1]             ; structure #
call    DrawStruct

add     esi,3
cmp     [word ptr esi],0FFFDh
jnz     @@draw_element

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
mov     eax,[ebx + level_info.room_ofs]
mov     [room_ofs],eax
mov     eax,[ebx + level_info.struct_ofs]
mov     [struct_ofs],eax
mov     eax,[ebx + level_info.macro_ofs]
mov     [macro_ofs],eax
mov     eax,[ebx + level_info.palette_ofs]
mov     [palette_ofs],eax
mov     al,[ebx + level_info.num_rooms]
mov     [num_rooms],al
mov     eax,[ebx + level_info.room_ptr]
mov     [room_ptr],eax
mov     eax,[ebx + level_info.room_sub]
mov     [room_sub],eax
mov     eax,[ebx + level_info.last_macro_ofs]
mov     [last_macro_ofs],eax

mov     esi,offset file_data
mov     eax,[ebx + level_info.gfx_ofs]
add     esi,eax
mov     edi,offset pattern_table + (12*256)
mov     ecx,256*4
rep     movsb

mov     esi,offset file_data
add     esi,[palette_ofs]
call    SetPalette

mov     [level_pos],0
mov     [current_obj],0

popad
ret
ENDP    SetLevel

PROC    NumToASCII
pushad
mov     ch,cl
@@10:
xor     edx,edx
div     ebx
push    edx
dec     cl
jnz     short @@10
mov     ah,0Eh
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

end     start
