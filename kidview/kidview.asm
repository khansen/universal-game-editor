IDEAL
P386N
MODEL FLAT
STACK 1000h
JUMPS

DATASEG

welcome_msg     db 13,10
                db ' +------------------------------+',13,10
                db ' | Kid Icarus level data viewer |',13,10
                db ' +------------------------------+',13,10
                db ' (c) Kent Hansen 1998',13,10,'$'

level_msg       db 13,10
                db ' Syntax: kidview [level]',13,10
                db 13,10
                db ' Valid values for [level]:',13,10
                db 13,10
                db ' 1: Level 1-1, 1-2, 1-3',13,10
                db ' 2: Level 2-1, 2-2, 2-3',13,10
                db ' 3: Level 3-1, 3-2, 3-3',13,10
                db ' 4: Level 1-4, 2-4, 3-4',13,10
                db ' 5: Level 4-1',13,10,'$'

level_info      dd 19950h,1A1BAh,1A2ECh,1A6F7h,00028h,04410h   ; Level 1
                dd 0B04Ah,0B82Dh,0B940h,0BE46h,0002Dh,04C10h   ; Level 2
                dd 1A7A0h,1ABC6h,1AC77h,1B06Ch,00016h,05410h   ; Level 3
                dd 15BF5h,1626Dh,1631Eh,1B8D2h,00019h,05410h   ; Level 1-4, 2-4, 3-4
                dd 0FA8Ch,0FBFDh,0FCB8h,0FF34h,00006h,05C10h   ; Level 4-1

view_method     db 0
level_number    db 0
current_room    db 0
max_rooms       db 0

video_mem       dd 0A0000h

rom_file        db 'kidicar.nes',0

file_error      db 13,10,' ERROR: Could not open KIDICAR.NES',13,10,'$'
size_error      db 13,10,' ERROR: KIDICAR.NES must be 131,088 bytes',13,10,'$'

room_data_ofs   dd ?
struct_ofs      dd ?
macro_ofs       dd ?
palette_ofs     dd ?

virtual_screen  db 512*480 dup (?)
file_data       db 131088 dup (?)
pattern_table   db 16*256 dup (?)
precalcbuffer   db 10000h*8 dup (?)

CODESEG

include "palette.inc"
include "tweak.inc"

start:

mov     ah,09
mov     edx,offset welcome_msg
int     21h

mov     ax,0EE02h
int     31h
sub     [video_mem],ebx

movzx   ecx,[byte ptr esi+80h]
jcxz    show_syntax

add     esi,81h
find_first_char:
cmp     [byte ptr esi],20h
jnz     copy_filename
dec     cl
jz      show_syntax
inc     esi
jmp     short find_first_char

copy_filename:
mov     al,[byte ptr esi]
cmp     al,'1'
je      level_ok
cmp     al,'2'
je      level_ok
cmp     al,'3'
je      level_ok
cmp     al,'4'
je      level_ok
cmp     al,'5'
je      level_ok

show_syntax:
mov     ah,09
mov     edx,offset level_msg
int     21h
jmp     terminate

level_ok:
sub     al,30h
dec     al
mov     [level_number],al

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

call    SetModeTWEAKED

mov     esi,offset file_data
add     esi,(256*16)+16
mov     edi,offset pattern_table
mov     ecx,256*12
rep     movsb

mov     al,[level_number]
call    SetLevel

hehe:
mov     al,[current_room]
call    DrawRoom
mov     [view_method],0

wait_key:
mov     ah,00
int     16h
cmp     ah,39h
je      change_view
cmp     ah,4Bh
je      left
cmp     ah,4Dh
je      right
cmp     al,27
je      exit
jmp     wait_key
change_view:
mov     [view_method],1
jmp     hehe
left:
cmp     [current_room],0
je      wait_key
dec     [current_room]
jmp     hehe
right:
mov     al,[current_room]
cmp     al,[max_rooms]
je      wait_key
inc     [current_room]
jmp     hehe

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
mov     esi,offset file_data
add     esi,[struct_ofs]
cmp     al,0
je      @@draw_it
mov     ah,al
@@find_ff:
lodsb
cmp     al,0FFh
jnz     @@find_ff
dec     ah
jnz     @@find_ff

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

; AL = room #

pushad

mov     edi,offset virtual_screen
xor     ebx,ebx
mov     ecx,(256*240*2)/4
@@clear_vrscreen:
mov     [dword ptr edi],ebx
add     edi,4
dec     ecx
jnz     @@clear_vrscreen

mov     esi,offset file_data
add     esi,[room_data_ofs]
cmp     al,0
je      @@draw_it
@@find_fffd:
inc     esi
cmp     [word ptr esi-1],0FFFDh
jnz     @@find_fffd
inc     esi
dec     al
jnz     @@find_fffd

@@draw_it:
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

cmp     [view_method],0
je      @@next_object

push    ecx esi edi
mov     esi,offset virtual_screen
mov     edi,[video_mem]
mov     bl,240
@@show_obj:
mov     ecx,256/4
rep     movsd
add     esi,256
dec     bl
jnz     @@show_obj
pop     edi esi ecx

call    waitvrt
call    waitvrt
call    waitvrt
call    waitvrt
call    waitvrt
call    waitvrt
call    waitvrt
call    waitvrt

@@next_object:
add     esi,3
cmp     [word ptr esi],0FFFDh
jnz     @@draw_element

mov     esi,offset virtual_screen
mov     edi,[video_mem]
mov     bl,240
@@show_room:
mov     ecx,256/4
rep     movsd
add     esi,256
dec     bl
jnz     @@show_room

popad
ret
ENDP    DrawRoom

PROC    SetLevel

; AL = level #

pushad
movzx   eax,al
mov     edx,24
mul     edx
mov     esi,offset level_info
add     esi,eax

lodsd
mov     [room_data_ofs],eax
lodsd
mov     [struct_ofs],eax
lodsd
mov     [macro_ofs],eax
lodsd
mov     [palette_ofs],eax
lodsd
mov     [max_rooms],al

lodsd
mov     esi,offset file_data
add     esi,eax
mov     edi,offset pattern_table + (12*256)
mov     ecx,256*4
rep     movsb

mov     esi,offset file_data
add     esi,[palette_ofs]
call    SetPalette
popad
ret
ENDP    SetLevel

PROC    WAITVRT
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

end     start
