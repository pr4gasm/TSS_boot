;format binary

struc TSS32
{
.PreviousTaskLink dw ?
.Reserved0 dw ? ;--4
.ESP0 dd ?
.SS0 dw ?
.Reserved1 dw ? ;--12
.ESP1 dd ?
.SS1 dw ?
.Reserved2 dw ? ; 20
.ESP2 dd ?
.SS2 dw ?
.Reserved3 dw ? ; 28
.tsCR3 dd ?
.tsEIP dd ? ; 36
.tsEFLAGS dd ?
.tsEAX dd ? ; 44
.tsECX dd ?
.tsEDX dd ? ; 52
.tsEBX dd ?
.tsESP dd ? ; 60
.tsEBP dd ?
.tsESI dd ?
.tsEDI dd ? ; 72
.tsES dw ?
.Reserved4 dw ? ; 76
.tsCS dw ?
.Reserved5 dw ?
.tsSS dw ?
.Reserved6 dw ?
.tsDS dw ?
.Reserved7 dw ?
.tsFS dw ?
.Reserved8 dw ?
.tsGS dw ?
.Reserved9 dw ?
.LDTSegmentSelector dw ?
.Reserved10 dw ?
.DebugByte db ?
.Reserved11 db ?
.IOMapBaseAddress dw ?

}

struc TSS {

    .limit dw 0x100
    .adrlow dw ?
    .adrcenter db ?
    .conffield1 db ?
    .conffield2 db ?
    .adrhigh db ?
    
}

GotoPm:
   
    cli
   
    in al,0x70
    bts ax,7
    out 0x70,al
    
    in al,0x92
    or al,0x02
    out 0x92,al
   
    lgdt fword [GDTR]
    
    mov edx,cr0
    or dl,0x01
    mov cr0,edx
    
    jmp far 0x0008:EntryProtected

use32

EntryProtected:

    mov dx,0x0010
    mov ds,dx
    mov es,dx
    mov ss,dx
    mov gs,dx
    mov dl,0x48
    mov fs,dx
    
    mov esp,0x01000000
    xor ebp,ebp
    
InitInterrupts:

.InitPIC:

    mov al,0x11
    out 0x20,al
    out 0xa0,al
    mov al,0x30
    out 0x21,al
    out 0xa1,al
    mov al,0x04
    out 0x21,al
    mov al,0x02
    out 0xa1,al
    dec al
    out 0x21,al
    
.InitPIT:

    mov al,00110100b
    out 0x43,al
    
    mov ax,1193180/100
    out 0x40,al
    shr ax,8
    out 0x40,al     

.InitStructsIDT:

    lea eax,[cs:stdhandle]
    mov word [ds:keyboard],ax
    mov word [ds:slave_PIC],ax
    mov word [ds:com24],ax
    mov word [ds:com13],ax
    mov word [ds:LPT2],ax
    mov word [ds:controller_floppy],ax
    mov word [ds:LPT1],ax
    mov word [ds:real_timer],ax
    mov word [ds:any_device],ax
    mov word [ds:any_device2],ax
    mov word [ds:any_device3],ax    
    mov word [ds:any_device4],ax
    mov word [ds:error_fpu_operation],ax
    mov word [ds:any_device5],ax
    mov word [ds:any_device6],ax
    
    shr eax,16
    mov word [ds:keyboard+6],ax
    mov word [ds:slave_PIC+6],ax
    mov word [ds:com24+6],ax
    mov word [ds:com13+6],ax
    mov word [ds:LPT2+6],ax
    mov word [ds:controller_floppy+6],ax
    mov word [ds:LPT1+6],ax
    mov word [ds:real_timer+6],ax
    mov word [ds:any_device+6],ax
    mov word [ds:any_device2+6],ax
    mov word [ds:any_device3+6],ax    
    mov word [ds:any_device4+6],ax
    mov word [ds:error_fpu_operation+6],ax
    mov word [ds:any_device5+6],ax
    mov word [ds:any_device6+6],ax
      
    mov eax,GuiManager
    mov word [ds:Hgui],ax
    shr eax,16
    mov word [ds:Hgui+6],ax   
    
    lidt fword [IDTR]
    
.Init_TSS:
    
    xor bl,bl
    
    mov edx,TSS_kernel_manager
_1:
    test bl,bl
    jnz .user

.kernel:

    mov byte [kernel_manager.conffield1],10001001b
    jmp short .continue
    
.user:

    mov byte [kernel_manager.conffield1],11101001b

.continue:

    mov word [kernel_manager.adrlow],dx
    shr edx,16
    mov byte [kernel_manager.adrcenter],dl
    mov byte [kernel_manager.conffield2],10000000b
    shr dx,8
    mov byte [kernel_manager.adrhigh],dl

    
    inc bl
    
    mov edx,TSS_UPROCESS1


_2:
    test bl,bl
    jnz .user

.kernel:

    mov byte [UPROCESS1.conffield1],10001001b
    jmp short .continue
.user:

    mov byte [UPROCESS1.conffield1],11101001b

.continue:

    mov word [UPROCESS1.adrlow],dx
    shr edx,16
    mov byte [UPROCESS1.adrcenter],dl
    mov byte [UPROCESS1.conffield2],10000000b
    shr dx,8
    mov byte [UPROCESS1.adrhigh],dl
    
    
    mov edx,TSS_UPROCESS2
    
_3:
    test bl,bl
    jnz .user

.kernel:

    mov byte [UPROCESS2.conffield1],10001001b
    jmp short .continue
.user:

    mov byte [UPROCESS2.conffield1],11101001b

.continue:

    mov word [UPROCESS2.adrlow],dx
    shr edx,16
    mov byte [UPROCESS2.adrcenter],dl
    mov byte [UPROCESS2.conffield2],10000000b
    shr dx,8
    mov byte [UPROCESS2.adrhigh],dl
              
           
    mov edx,TSS_UPROCESS3

_4:
    test bl,bl
    jnz .user

.kernel:

    mov byte [UPROCESS3.conffield1],10001001b
    jmp short .continue
.user:

    mov byte [UPROCESS3.conffield1],11101001b

.continue:

    mov word [UPROCESS3.adrlow],dx
    shr edx,16
    mov byte [UPROCESS3.adrcenter],dl
    mov byte [UPROCESS3.conffield2],10000000b
    shr dx,8
    mov byte [UPROCESS3.adrhigh],dl


    
    dec bl
    

    mov edx,TSS_ExitProcess
    
        
_5:
    test bl,bl
    jnz .user

.kernel:

    mov byte [Ext.conffield1],10001001b
    jmp short .continue
.user:

    mov byte [Ext.conffield1],11101001b

.continue:

    mov word [Ext.adrlow],dx
    shr edx,16
    mov byte [Ext.adrcenter],dl
    mov byte [Ext.conffield2],10000000b
    shr dx,8
    mov byte [Ext.adrhigh],dl
;==================================            
    
    mov word [TSS_kernel_manager.tsCS],0x0008
    mov word [TSS_UPROCESS1.tsCS],0x0018
    mov word [TSS_UPROCESS2.tsCS],0x0018
    mov word [TSS_UPROCESS3.tsCS],0x0018
    mov word [TSS_ExitProcess.tsCS],0x0008
        
    mov dword [TSS_kernel_manager.tsEIP],KernelManager
    mov dword [TSS_UPROCESS1.tsEIP],PROCESS1
    mov dword [TSS_UPROCESS2.tsEIP],PROCESS2
    mov dword [TSS_UPROCESS3.tsEIP],PROCESS3
    mov dword [TSS_ExitProcess.tsEIP],ExitProcess
    
    mov word [TSS_kernel_manager.tsDS],0x0010
    mov word [TSS_kernel_manager.tsES],0x0010
    mov word [TSS_kernel_manager.tsSS],0x0010
    mov word [TSS_ExitProcess.tsDS],0x0010
    mov word [TSS_ExitProcess.tsES],0x0010
    mov word [TSS_ExitProcess.tsSS],0x0010
        
    mov word [TSS_UPROCESS1.tsDS],0x0020
    mov word [TSS_UPROCESS1.tsES],0x0020
    mov word [TSS_UPROCESS1.tsSS],0x0020
    
    mov word [TSS_UPROCESS2.tsDS],0x0020
    mov word [TSS_UPROCESS2.tsES],0x0020
    mov word [TSS_UPROCESS2.tsSS],0x0020
    
    mov word [TSS_UPROCESS3.tsDS],0x0020
    mov word [TSS_UPROCESS3.tsES],0x0020
    mov word [TSS_UPROCESS3.tsSS],0x0020
    
    mov dword [TSS_kernel_manager.tsEAX],0x00000000
    mov dword [TSS_kernel_manager.tsEBX],0x00000000
    mov dword [TSS_kernel_manager.tsECX],0x00000000
    mov dword [TSS_kernel_manager.tsEDX],0x00000000
    mov dword [TSS_kernel_manager.tsESP],esp
    mov dword [TSS_kernel_manager.tsEBP],ebp
    
set_taskmode:
        
    mov dx,0x0030
    
    ltr dx
    
    sti

;=====================================
                                                                        
PROCESS1:

;section .text

._start:
                
    mov eax,0x02
    mov ebx,.msg
    mov ecx,0x0a
    int 0x40 ; call GUI manager
    
    int 0x41 ; ExitProcess
;section .rdata

    .msg db 0x0a,'Process1',0x0a

;=====================================

PROCESS2:

;section .text

._start:

    mov eax,0x02
    mov ebx,.msg
    mov ecx,0x09
    int 0x40
    
    int 0x41 

;section .rdata

    .msg db 'Process2',0x0a    

;====================================

PROCESS3:

;section .text

._start:

    mov eax,0x02
    mov ebx,.msg
    mov ecx,0x09
    int 0x40
    
    int 0x41 

;section .rdata

    .msg db 'Process3',0x0a    

;===================================                    
                                                             

;set_task:
;
;   virtual at esi
;    
;    .esi TSS
;    
;    end virtual
;
;    test bl,bl
;    jnz .user
;
;.kernel:
;
;    mov byte [.esi.conffield1],10001001b
;
;.user:
;
;    mov byte [esi.conffield1],11101001b
;
;.continue:
;
;    mov word [esi.adrlow],dx
;    shr edx,16
;    mov byte [esi.adrcenter],dl
;    mov byte [esi.conffield2],10000000b
;    shr dx,8
;    mov byte [esi.adrhigh],dl
;    retn                    



TSS_kernel_manager TSS32
  
TSS_UPROCESS1 TSS32

    
TSS_UPROCESS2 TSS32


TSS_UPROCESS3 TSS32

TSS_ExitProcess TSS32
              
                    
GDT:
    rq 1
    KCSD db 0xff,0xff,0x00,0x00,0x00,10011010b,11001111b,0x00
    KDATD db 0xff,0xff,0x00,0x00,0x00,10010010b,11000000b,0x00
    UCSD db 0xff,0xff,0x00,0x00,0x00,11111010b,11001111b,0x00
    UDATD db 0xff,0xff,0x00,0x00,0x00,11110010b,11001111b,0x00
    kernel_manager TSS  
    UPROCESS1 TSS
    UPROCESS2 TSS
    UPROCESS3 TSS 
    VIDEO db 0xff,0xff,0x00,0x80,0x0b,10010010b,00001111b,0x00
    Ext TSS
    
    len_GDT equ $ - GDT
    
GDTR:
    
    dw len_GDT - 1
    dd GDT
IDT:

    rq 0x30
    
    timer db 0x00,0x00,0x28,0x00,0x00,10000101b,0x00,0x00 ; IRQ 30
    keyboard db 0x00,0x00,0x08,0x00,0x00,10001110b,0x00,0x00 ; IRQ 31
    slave_PIC db 0x00,0x00,0x08,0x00,0x00,10001110b,0x00,0x00 ; IRQ 32
    com24 db 0x00,0x00,0x08,0x00,0x00,10001110b,0x00,0x00 ; IRQ 33
    com13 db 0x00,0x00,0x08,0x00,0x00,10001110b,0x00,0x00 ; IRQ 34
    LPT2 db 0x00,0x00,0x08,0x00,0x00,10001110b,0x00,0x00 ; IRQ 35
    controller_floppy db 0x00,0x00,0x08,0x00,0x00,10001110b,0x00,0x00 ; IRQ 36
    LPT1 db 0x00,0x00,0x08,0x00,0x00,10001110b,0x00,0x00 ; IRQ 37
    real_timer db 0x00,0x00,0x08,0x00,0x00,10001110b,0x00,0x00 ; IRQ 38
    any_device db 0x00,0x00,0x08,0x00,0x00,10001110b,0x00,0x00 ; IRQ 39
    any_device2 db 0x00,0x00,0x08,0x00,0x00,10001110b,0x00,0x00 ; IRQ 3a
    any_device3 db 0x00,0x00,0x08,0x00,0x00,10001110b,0x00,0x00 ; IRQ 3b
    any_device4 db 0x00,0x00,0x08,0x00,0x00,10001110b,0x00,0x00 ; IRQ 3c
    error_fpu_operation db 0x00,0x00,0x08,0x00,0x00,10001110b,0x00,0x00 ; IRQ 3d
    any_device5 db 0x00,0x00,0x08,0x00,0x00,10001110b,0x00,0x00 ; IRQ 3e
    any_device6 db 0x00,0x00,0x08,0x00,0x00,10001110b,0x00,0x00 ; IRQ 3f
    Hgui db 0x00,0x00,0x08,0x00,0x00,11101110b,0x00,0x00 ; IRQ 40
    IExitProcess db 0x00,0x00,0x50,0x00,0x00,10000101b,0x00,0x00 ; IRQ 41
    IDTlen equ $ - IDT

IDTR:

    dw IDTlen
    dd IDT    

ExitProcess:

    virtual at edx
    
    .edx TSS
    
    end virtual
    
    
    movzx edx,[pid]
    
    add edx,GDT
    bts word [.edx.conffield2],12 ; .conffield2 
    
    int 0x30
    
    jmp near ExitProcess

KernelManager:

    virtual at ebx
    
    .ebx TSS32
    
    end virtual
    
    virtual at edx
    
    .edx TSS
    
    end virtual
    
    cmp byte [pid],0x40
    jnz .continue
    
    jmp short .exts        

.continue:

    mov dl,[pid]  
      
    movzx edx,dl
    add edx,GDT
    
    mov bx,word [.edx.adrlow]
    ror ebx,16
    mov bl,byte [.edx.adrcenter]
    ror ebx,8
    mov bl,byte [.edx.adrhigh]
    ror ebx,8
    
    bt word [.edx.conffield2],12 ; check if Process existing AVL flag
    jc .exts
.set:    
    btr word [.edx.conffield2],1 ; reset busy flag in old process
    
    add byte [pid],0x08
    
    movzx dx,byte [pid]
    
    mov word [.ebx.PreviousTaskLink],dx ; load next process
    
    mov edx,Ext
    btr word [.edx.conffield2],1 ; reset busy flag in ExitProcess
    jmp short .return 
.exts:
    
    inc cl
    cmp cl,0x03
    jnz .set
    
    jmp short .continue2

    .msg db 0x0a,0x0d,'[*] All Processes are Exitsting'
    .lenext db $ - .msg
    
.continue2:
        
    mov esi,.msg
    mov ecx,.lenext
    call PrintString    
        
    or al,0xff
    out 0x21,al
    out 0xa1,al     
        
    cli
    hlt
        
.return:    

    mov al,0x20
    out 0x20,al
    out 0xa0,al
    iretd
    
    jmp near KernelManager    
            
    pid db 0x30        
    
stdhandle:
    
    mov al,0x20
    out 0x20,al
    out 0xa0,al
    iretd            
                            
GuiManager:

    push ax
    
    cli
    
    in al,0x70
    btr ax,7
    out 0x70,al
    
    pop ax
    
    cmp eax,0x00000001
    jz .locate
    cmp eax,0x00000002
    jz .PrintString

    mov eax,0xffffffff ; error
    jmp short .return
    
.locate:

    movzx eax,byte ptr x
    movzx ebx,byte ptr y
    
    call locate
    
    mov ebx,eax ; ebx return value
    
    jmp short .return

.PrintString:

    mov esi,ebx
    
    call PrintString
    
    mov ebx,eax        
                            
.return:

    push eax

    in al,0x70
    bts ax,7
    out 0x70,al

    sti

    pop eax
    
; eax return value
    
    iretd    
           
locate:
    
    push ebp
    mov ebp,esp
    
    push edx
    push ebx
    
    xchg eax,ebx
    mov edx,160
    
    mul edx
    add eax,ebx ; eax return located string
      
    pop ebx
    pop edx
    
    mov esp,ebp
    pop ebp
                  
    retn
    
PrintString:
    
    push ebp
    mov ebp,esp
    
    push edi
    push esi
    push ecx
    push ebx
    
    movzx eax,byte ptr x
    movzx ebx,byte ptr y
    
    call locate
    
    mov edi,eax
    mov ah,0x0f

.lp:
    
    lodsb
    cmp al,0x0a
    jz .newline
    mov [fs:edi],ax
    
    add edi,2
    loop .lp
    jmp near .return
    
.newline:
    push eax
    
    xor eax,eax
    movzx ebx,byte [y]
    inc bl
    
    call locate
    
    mov edi,eax
    
    mov byte [x],0x00
    mov byte [y],bl
    
    pop eax
    
    jmp short .lp              
                                        
.return:

    pop ax

    mov byte ptr x,ah
    mov byte ptr y,al
    
    pop ebx
    pop ecx
    pop esi
    pop edi

    xor eax,eax
    mov esp,ebp
    pop ebp
    
    retn            

PutChar:
    
    cmp byte ptr x,160
    jz .newline
    inc byte ptr x
.newline:

    inc byte ptr y
    
    push ebx
    push eax
    
    movzx eax,byte ptr x
    movzx ebx,byte ptr y
    
    call locate
    
    mov ebx,eax
    pop eax
    mov ah,0x0f
    
    mov [fs:ebx],ax
    
    pop ebx
    
    retn

storage rb 10
x db 0x00
y db 0x00                                                   