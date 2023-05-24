; si => ptr to path to load 
fat32_read:
	ret

fat32_load_rootdir:
	xor cx, cx
	mov cx, byte [BPB_SECTORS_PER_CLUSTER]
	mov ax, 
	mov word [dap_sectors], cx
	
	ret

fat32_load_cluster:
	xor cx, cx
	mov cx, byte [BPB_SECTORS_PER_CLUSTER]
	mov word [dap_sectors], cx
	ret

fat32_path: dw 0