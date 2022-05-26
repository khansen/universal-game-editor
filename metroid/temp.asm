IDEAL
P386N
MODEL FLAT
STACK 1000h
CODESEG

start:
mov     ah,00
int     16h
mov     dl,ah
mov     ah,02
int     21h
mov     ax,4c00h
int     21h
end     start
