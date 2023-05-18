print_char:					; print the charracter in al
	mov ah, 0x0e
	int 0x10
	ret

print:						; prints the string pointed to by si
	lodsb
	or al, al
	jz .print_done
	call print_char
	jmp print
.print_done:
	ret

print_line:					; print the string with a new line at the end
	call print
	call print_nl
	ret

clear_screen:				; clears the screen
	pusha
	mov ah, 0x00
	mov al, 0x03			; text mode 80x25 16 colours
	int 0x10
	popa
	ret

print_nl:					; prints a new lint
	mov si, msg_EOL
	call print
	ret

; data
msg_EOL 	db 13, 10, 0
