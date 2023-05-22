check_drive_ext:					; checks if the drive extension is available
	xor ax, ax
	xor dx, dx
	mov ah, 0x41
	mov dl, byte [booted_drive_index]
	mov bx, 0x55aa
	int 0x13
	jc .drive_ext_err
	cmp bx, 0xaa55
	jnz .drive_ext_err
	clc
	ret

.drive_ext_err:
	stc
	ret

read_sectors:
	mov ah, 0x42
	mov dl, byte [booted_drive_index]
	mov si, dap
	int 0x13
	ret


dap:
dap_size: 			db 0x10
dap_reserved:		db 0x0
dap_sectors:		dw 0x1
dap_buf_off:		dw 0x0
dap_buf_seg:		dw 0x0
dap_lba:			dd 0x0
					dd 0x0

booted_drive_index:	db 0x0
