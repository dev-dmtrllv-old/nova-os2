[bits 16]

%include "lib/defines.asm"

org MBR_BOOT_ADDR

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov sp, STACK_START
    mov bp, sp
    mov si, ax
    mov di, ax
    cld

    ; move this code to 0x7A00
    mov cx, 0x80  ; 128 * 4 (DWORD) = 0x200 (512 bytes)
    mov si, 0x7C00 ; from
    mov di, MBR_BOOT_ADDR ; to
    rep movsd

    jmp 0:relocated_start

relocated_start:
	; setup the boot drive number
    mov byte [booted_drive_index], dl

	call check_drive_ext
	jc disk_extension_error

    ; find the first bootable partition
    mov cx, 3
    mov si, partition_1
.find_boot_loop:
    xor ax, ax
    mov al, byte [es:si]
    cmp al, 0x80
    je .boot_found
    add si, 0x10
    dec cx
    jz boot_not_found
    jmp .find_boot_loop

.boot_found:
    mov ax, [si + 0x08]
	push ax
    mov [dap_lba], ax
    mov word [dap_buf_off], BPB_BOOT_ADDR
    mov word [dap_sectors], 0x1
    sti
    call read_sectors
    jc disk_read_error
    cmp ah, 0
    jne disk_read_error
	xor dh, dh
    mov dl, byte [booted_drive_index]
	pop cx
    jmp 0:BPB_BOOT_ADDR

disk_extension_error:
	mov si, disk_ext_err_msg
	call print_line
	jmp wait_shutdown

boot_not_found:
    mov si, boot_not_found_msg
    call print_line
    jmp wait_shutdown

disk_read_error:
    mov si, boot_read_error_msg
    call print_line
	jmp wait_shutdown

disk_ext_err_msg		db "Drive extension not available!", 0
boot_not_found_msg 		db "No bootable partition found!", 0
boot_read_error_msg 	db "Read error!", 0

%include "./lib/disk.asm"
%include "./lib/print.asm"
%include "./lib/common.asm"

TIMES 446 - ($ - $$) db 0x0

partition_1: TIMES 16 db 0x0
partition_2: TIMES 16 db 0x0
partition_3: TIMES 16 db 0x0
partition_4: TIMES 16 db 0x0