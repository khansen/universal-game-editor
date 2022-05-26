IDEAL
P386N
MODEL FLAT
STACK 1000h
DATASEG

welcome_msg     db 13,10
                db ' ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿',13,10
                db ' ³ NES Multi Editor ³',13,10
                db ' ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ',13,10
                db ' (c) Kent Hansen 1998',13,10
                db 13,10,'$'

syntax_msg      db ' Syntax: UNIV [name_of_game]',13,10
                db 13,10
                db ' Where [name_of_game] is the name of the .DLL file, minus the extension.',13,10
                db ' See "games.txt" for a list of the games currently supported.',13,10
                db '$'

dll_filename    db 128 dup (0)

CODESEG

; varibles holding pointers to each function in A_DLL.DLL
;
main    dd ?

start:

mov     ah,09
mov     edx,offset welcome_msg
int     21h

mov     ax,0ee02h
int     31h

movzx   ecx,[byte ptr esi+80h]
jcxz    no_param

add     esi,81h
find_first_char:
cmp     [byte ptr esi],20h
jnz     short copy_filename
dec     cl
jz      no_param
inc     esi
jmp     short find_first_char

no_param:
mov     ah,09
mov     edx,offset syntax_msg
int     21h
jmp     terminate

copy_filename:
mov     edi,offset dll_filename
rep     movsb
mov     [byte ptr edi+0],'.'
mov     [byte ptr edi+1],'D'
mov     [byte ptr edi+2],'L'
mov     [byte ptr edi+3],'L'

  ;
  ; Function EE10h to setup a DOS32 Dynamic Linkable Library file.
  ;
  ; Expects CS:EDX -> pointing to file name.
  ;            EBX = seek position from beginning of file.
  ;
  ;
    mov  ax,0EE10h
    mov  edx, Offset dll_FileName
    mov  ebx,0
    int  31h
    jnc  Ok
    cmp  al,1                   ; if carry set then get error code from AL
    je   error1                 ; 1 = file not found
    cmp  al,2                   ; 2 = bad format
    je   error2
Ok:

  ; Returns EAX with number of bytes required to load the library.
  ;         EBX = DLL file size


  ;
  ; Allocate memory for the loadable program.
  ;
    mov edx,eax
    mov ax,0EE42h
    int 31h
    jc error


  ;
  ; Load the DLL
  ;
  ;      Expects CS:EDX -> pointing to memory block to holding
  ;                         the DLL program.
  ;
    mov  ax,0EE11h
    int  31h
    jc error1

    ;
    ; Returns CS:EDX -> pointing to the DLL public symbol.
    ;
    ; TEST.DLL is written so that the public symbol ('DOS32_DLL') points
    ; to an array of pointers to each procedure.
    ;

    mov     eax,[edx]             ; get first function pointer
    mov     [main],eax

   ; Use these two functions
   ;

call    [main]

terminate:
    mov ax,4c00h
    int 21h


;---------------------------------------------------------------------
error:
    mov edx, offset error_mesg
    mov ah,9
    int 21h
    jmp terminate
error_mesg db 'mot enough memory to load DLL',13,10,36

;---------------------------------------------------------------------
error1:
    mov edx, offset error1_mesg
    mov ah,9
    int 21h
    jmp terminate
error1_mesg db ' Error opening loadable library.',13,10,36

;-------------------------------------------------------------------
error2:
    mov edx, offset error2_mesg
    mov ah,9
    int 21h
    jmp terminate
error2_mesg db ' Bad DOS32 Lodabale Library format.',13,10,36

end start
