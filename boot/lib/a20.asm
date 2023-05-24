check_a20:
    pushf
    push ds
    push es
    push di
    push si

    cli

    xor ax, ax
    mov es, ax
    not ax
    mov ds, ax
    mov di, 0x0500
    mov si, 0x0510
    mov al, byte [es:di]
    push ax
    mov al, byte [ds:si]
    push ax
    mov byte [es:di], 0x00
    mov byte [ds:si], 0xFF
    cmp byte [es:di], 0xFF
    pop ax
    mov byte [ds:si], al
    pop ax
    mov byte [es:di], al
    mov ax, 0
    je check_a20_exit
    mov ax, 1

check_a20_exit:
    pop si
    pop di
    pop es
    pop ds
    popf
    ret


enable_a20:

enable_a20_bios:
    sti
    mov ax, 0x2403          ; --- A20-Gate Support ---
    int 0x15
    jb enable_a20_keyboard  ; INT 15h is not supported
    cmp ah, 0
    jnz enable_a20_keyboard ; INT 15h is not supported
    mov ax, 0x2402          ; --- A20-Gate Status ---
    int 0x15
    jb enable_a20_keyboard  ; couldn't get status
    cmp ah, 0
    jnz enable_a20_keyboard ; couldn't get status
    cmp al, 1
    jz enable_a20_done      ; A20 is already activated
    mov ax, 0x2401          ; --- A20-Gate Activate ---
    int 0x15
    jb enable_a20_keyboard  ; couldn't activate the gate
    cmp ah, 0
    jnz enable_a20_keyboard ; couldn't activate the gate

    call check_a20
    cmp ax, 0
    jne enable_a20_done

enable_a20_keyboard:
    cli
    call .a20wait
    mov al,0xAD
    out 0x64, al
    call .a20wait
    mov al,0xD0
    out 0x64, al
    call .a20wait2
    in al,0x60
    push eax
    call .a20wait
    mov al,0xD1
    out 0x64, al
    call .a20wait
    pop eax
    or al,2
    out 0x60, al
    call .a20wait
    mov al,0xAE
    out 0x64, al
    call .a20wait
    sti
	call check_a20
    cmp ax, 0
    jne enable_a20_done
    stc
	ret

    .a20wait:
        in al,0x64
        test al,2
        jnz .a20wait
        ret

    .a20wait2:
        in al,0x64
        test al,1
        jz .a20wait2
        ret

enable_a20_done:
	clc
    ret