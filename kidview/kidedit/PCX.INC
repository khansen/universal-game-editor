picfile         db 'img.pcx',0

PCXheader       DB 10,5,1,8,0,0,0,0,255,0,239,0,0,0,0,0,0,0,0,0
                DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                DB 0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0
                DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                DB 0,0,0,0,0,0,0,0

PROC    SavePCX

pushad

mov     esi,[Video_Mem]
mov     edi,offset virtual_screen

mov     bp,769
xor     bh,bh
mov     ch,240
PCX_yloop:
xor     cl,cl
Encode_PCX:
mov     al,[byte ptr esi]
cmp     al,[byte ptr esi+1]
jnz     write_data

cmp     cl,1
je      write_data
dec     cl
mov     bl,1
inc     esi
haha:
cmp     [byte ptr esi],al
jnz     finish
inc     bl
inc     esi
dec     cl
jz      finish
cmp     bl,3Fh
je      finish
jmp     haha

finish:
or      bl,11000000b
mov     [byte ptr edi],bl
inc     edi
mov     [byte ptr edi],al
inc     edi
add     bp,2
cmp     cl,0
je      done_scanline
jmp     encode_pcx

write_data:
mov     [byte ptr edi],al
inc     esi
inc     edi
inc     bp
dec     cl
jnz     Encode_PCX
done_scanline:
dec     ch
jnz     PCX_yloop

write_to_disk:

mov     [byte ptr edi],0Ch
inc     edi
mov     esi,offset file_data
add     esi,[palette_ofs]
mov     cx,32
copy_colors:
movzx   ebx,[byte ptr esi]
mov     al,[Palette + ebx*4]
shl     al,2
stosb
mov     al,[Palette + ebx*4 + 1]
shl     al,2
stosb
mov     al,[Palette + ebx*4 + 2]
shl     al,2
stosb
inc     esi
loop    copy_colors

mov     ah,3Ch
xor     cx,cx
mov     edx,offset picfile
int     21h
mov     bx,ax
mov     ah,40h
mov     edx,offset PCXheader
mov     cx,128
cli
int     21h
sti
mov     ah,40h
mov     edx,offset virtual_screen
mov     cx,bp
cli
int     21h
sti
mov     ah,3Eh
int     21h

popad
ret

ENDP    SavePCX
