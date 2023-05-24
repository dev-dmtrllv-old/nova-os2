[bits 16]

%include "lib/defines.asm"

org BOOTLOADER_ADDR

boot_start:
    mov word [bpb_start], cx

    sti

    call enable_a20
    jc a20_error

    mov di, memory_map
    call init_memory_map
    jc mmap_error

    cli

	mov si, kernel_filename
	call fat32_read

	

;     lgdt [gdtr_ptr]
;     mov eax, cr0
;     or eax, 1     ; set PE (Protection Enable) bit in CR0 (Control Register 0)
;     mov cr0, eax

;     jmp 0x08:pm_entry

; pm_entry:
;     mov ax, 0x10
;     mov ds, ax
;     mov es, ax
;     mov fs, ax
;     mov gs, ax
;     mov ss, ax

    hlt
    jmp $

mmap_error:
    mov si, mmap_error_msg
    jmp print_and_exit

a20_error:
    mov si, a20_error_msg

print_and_exit:
    call print_line
    jmp wait_shutdown

a20_error_msg db "Could not setup A20!", 0
mmap_error_msg db "Could not create memory map!", 0
kernel_filename db "kernel.bin"

%include "lib/print.asm"
%include "lib/common.asm"
%include "lib/disk.asm"
%include "lib/a20.asm"
%include "lib/mmap.asm"

align 8

gdtr_ptr:
    dw (bpb_start - gdtr_null) - 1
    dw gdtr_null

gdtr_null:
    dw 0          ; limit
    dw 0          ; base_low (bits 0-16)
    db 0          ; base_middle (bits 17-24)
    db 0          ; access
    db 0          ; limit/flags
    db 0          ; base_high (bits 25-31)

gdtr_code:
    dw 0xFF       ; limit
    dw 0          ; base_low (bits 0-16)
    db 0          ; base_middle (bits 17-24)
    db 0b10011010 ; access
    db 0b11001111 ; limit/flags
    db 0          ; base_high (bits 25-31)

gdtr_data:
    dw 0xFF       ; limit
    dw 0          ; base_low (bits 0-16)
    db 0          ; base_middle (bits 17-24)
    db 0b10010010 ; access
    db 0b11001111 ; limit/flags
    db 0          ; base_high (bits 25-31)

bpb_start: dw 0

memory_map: db 0