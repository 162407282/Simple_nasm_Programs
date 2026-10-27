section .bss
	io resb 100
	io2 resb 101	;with the belief that this mem area should be 0x00 data
section .text
	global _start
_start:
	xor rax,rax	;read in from terminal
	xor rdi,rdi
	mov rsi,io
	mov rdx,100
	syscall

	xor r8,r8	;[io] ptr
	xor r12,r12	;A
	xor r13,r13	;B
	xor r9,r9
comp:				;dec to bin for A
	mov r9b,[io+r8]		;read 1 byte
	inc r8
	cmp r9b,58
		jns _comp2
	cmp r9b,48
		js _comp2
	mov rax,r12
	xor rdx,rdx
	mov rcx,10
	mul rcx
	mov r12,rax
	sub r9b,48
	add r12,r9
	jmp comp
_comp2:				;dec to bin for B
	mov r9b,[io+r8]
	inc r8
	cmp r9b,58
		jns _compend
	cmp r9b,48
		js _compend
	mov rax,r13
	xor rdx,rdx
	mov rcx,10
	mul rcx
	mov r13,rax
	sub r9b,48
	add r13,r9
	jmp _comp2
_compend:
	add r12,r13		;adding
	test r12,r12
		jz _zero

	mov r8,99
	mov rcx,10
	mov rax,r12
_transfer:
	test rax,rax
		jz _prt
	xor rdx,rdx
	div rcx
	add dl,48
	mov [io2+r8],dl
	dec r8
	jmp _transfer

_prt:
	mov rbx,100
	mov byte [io2+rbx],0x0a
	mov rax,1
	mov rdi,1
	lea rsi,[io2+r8+1]
	mov rdx,100
	sub rdx,r8
	syscall

	mov rax,60
	mov rdi,0
	syscall

_zero:
	mov rax,1
	mov rdi,1
	mov rsi,io2
	mov rdx,2
	xor r11,r11
	mov word [io2+r11],0x0a30
	syscall
	mov rax,60
	mov rdi,0
	syscall
