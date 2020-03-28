format binary

use16

org 0x7c00

    jmp near EntryBoot

msg db '[*] BOOT: (1) DRIVE A,(2) HARD DISK (1/2) >> ',0x00

msg_hard db 0x0a,0x0d,'[*] select HARD DISK (0) 1,(1) 2 >> ',0

error db 0x0a,0x0d,'[-] Not found Drive',0x0a,0x0d,'[*] System HALT',0x00

EntryBoot:

    push word 0xb800
    pop fs
    xor di,di
    mov al,' ' 
    mov ah,0x0f 
.lp:
    mov word [fs:di],ax
    add di,2
    loop .lp
        
    mov ah,0x02
    xor dx,dx
    int 0x10
    
GetDrive:

    mov ah,0x0e
    mov si,msg
    xor bh,bh
    cld
    xor cx,cx
.lp:    
    lodsb
    
    test al,al
    jz .exit_loop
    
    int 0x10
    
    jmp short .lp

.exit_loop:

    xor ax,ax
    int 0x16 ; read keyboard
    
    cmp al,'1'
    jz DRIVE
    cmp al,'2'
    jz HARD

error_init_drive:    

    mov ah,0x0e
    mov si,error

.lp:
    lodsb
    
    test al,al
    jz .halt
    
    int 0x10
    
    jmp short .lp

.halt:
    
    cli
    hlt
        
HARD:

    mov ah,0x0e
    mov si,msg_hard
    xor bh,bh
.lp:
    lodsb
    
    test al,al
    jz .exit_loop
    
    int 0x10
             
    jmp short .lp    

.exit_loop:

    xor ah,ah
    int 0x16
    
    cmp al,'0'
    cmovz dx,[drive0]
    
    cmp al,'1'
    cmovz dx,[drive1]
    
    jmp short read_sectors

    drive0 dw 0x0080
    drive1 dw 0x0081

DRIVE:

    xor dx,dx

read_sectors:
    
    mov ah,0x02
    mov al,5
    mov cx,0x0002
    mov bx,GotoPm 
    int 0x13
    
    jc near error_init_drive
    
;    mov ah,0x03
;    xor bh,bh
;    int 0x10
    
;    mov byte [x],dh
;    mov byte [y],dl
    
    jmp near GotoPm                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
times 510 - ($ - $$) db 0x00
dw 0xaa55
 