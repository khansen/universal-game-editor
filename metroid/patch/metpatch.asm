IDEAL
P386N
MODEL FLAT
STACK 1000h
DATASEG

include "metsub.inc"

file_error      db 13,10,' ERROR: Could not open METROID.NES',13,10,'$'
size_error      db 13,10,' ERROR: METROID.NES must be 131,088 bytes',13,10,'$'

rom_file        db 'METROID.NES',0

STRUC   Area
room_ptr        dd ?
room_ofs        dd ?
num_rooms       db ?
struct_ofs      dd ?
ENDS

Areas   Area <06324h,06451h,47,06C94h> ; Brinstar
        Area <0A22Bh,0A3BBh,46,0ACC9h> ; Norfair
        Area <0E7E1h,0E8BFh,21,0EC26h> ; Tourian
        Area <121E5h,122C7h,37,12A7Bh> ; Kraid
        Area <1618Fh,1624Fh,42,169CFh> ; Ridley

room_ptr        dd ?
room_ofs        dd ?
room_sub        dd ?
num_rooms       db ?
struct_ofs      dd ?

file_data       db 131088 dup (?)

CODESEG

start:

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

xor     ebp,ebp
main:
mov     eax,ebp
mov     edx,size Area
mul     edx
mov     ebx,eax
mov     eax,[ebx + Areas.room_ptr]
mov     [room_ptr],eax
mov     eax,[ebx + Areas.room_ofs]
mov     [room_ofs],eax
mov     al,[ebx + Areas.num_rooms]
mov     [num_rooms],al
mov     eax,[ebx + Areas.struct_ofs]
mov     [struct_ofs],eax
mov     esi,offset file_data
add     esi,[room_ptr]
movzx   eax,[word ptr esi]
mov     [room_sub],eax

mov     edi,offset file_data
add     edi,[room_ofs]

xor     ebx,ebx
_patch_room:
mov     esi,offset file_data
add     esi,[room_ptr]
movzx   eax,[word ptr esi + ebx*2]
sub     eax,[room_sub]
mov     esi,offset file_data
add     esi,[room_ofs]
add     esi,eax
movsb

_obj_loop:
movsb
lodsb
mov     [byte ptr edi],al
lodsb
ror     al,2
or      [byte ptr edi],al
inc     edi
cmp     [byte ptr esi],0FFh
je      _copy_rest
cmp     [byte ptr esi],0FDh
jnz     _obj_loop

_copy_rest:
movsb
cmp     [byte ptr esi-1],0FFh
jnz     _copy_rest

inc     bl
cmp     bl,[num_rooms]
jnz     _patch_room

mov     esi,offset file_data
add     esi,[struct_ofs]
xor     al,al
_clear:
mov     [byte ptr edi],al
inc     edi
cmp     edi,esi
jnz     _clear

mov     esi,offset file_data
add     esi,[room_ofs]
mov     edi,offset file_data
add     edi,[room_ptr]
movzx   edx,[word ptr edi]
add     edi,2
mov     cl,[num_rooms]
dec     cl
_l:
inc     dx
inc     esi
cmp     [byte ptr esi-1],0FFh
jnz     _l
mov     [word ptr edi],dx
add     edi,2
dec     cl
jnz     _l

inc     ebp
cmp     ebp,5
jnz     main

mov     esi,offset file_data + 1EAB6h
mov     [byte ptr esi],02h

mov     esi,offset file_data + 1EAA1h
mov     [byte ptr esi+0],020h
mov     [byte ptr esi+1],0DBh
mov     [byte ptr esi+2],0FFh

mov     esi,offset file_data + 1EAA6h
mov     [byte ptr esi+0],020h
mov     [byte ptr esi+1],0E1h
mov     [byte ptr esi+2],0FFh

mov     esi,offset metsub
mov     edi,offset file_data + 1FFEBh
mov     ecx,12
rep     movsb

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

terminate:
mov     ax,4c00h
int     21h

end     start
