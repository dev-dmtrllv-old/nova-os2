[bits 16]

%include "lib/defines.asm"

org 0x2000

boot_start:
	sti

	mov si, hello_msg
	call print_line
	jmp wait_shutdown

hello_msg db "Hello", 0

%include "lib/print.asm"
%include "lib/common.asm"
%include "lib/disk.asm"