section .bss
	io resb 11
	io2 resb 5
section .text
	global _start
_start:
	mov r12,21875
	mov r13,18752
	mov r14,57059
	mov rax,145

	mov rax,0	;从终端读取种子
	mov rdi,0
	mov rsi,io2
	mov rdx,5
	syscall

	;解析用户输入
	;mov r10,rax
	xor rax,rax
	xor r8,r8	;io2指针
jiexi:
	xor rcx,rcx
	mov cl,[io2+r8]
	cmp cl,10
		jz _jiexiend
	cmp cl,58
		jns _inputerror
	cmp cl,48
		js _inputerror
	sub cl,48
	xor rdx,rdx
	mov r11,10
	mul r11
	add rax,rcx
	inc r8
	jmp jiexi

_jiexiend:
	xor rdx,rdx
	mul r12
	add rax,r13
	xor rdx,rdx
	div r14
	mov r8,rdx
	mov rax,10000
	xor rbx,rbx
	xor r10,r10
_prt0:
	test rax,rax
		jz _out
	cmp r8,rax
		js _prt1
	sub r8,rax
	inc bl
	jmp _prt0
_prt1:
	xor rdx,rdx
	mov r11,10
	div r11
	add bl,48
	mov [io+r10],bl
	inc r10
	xor rbx,rbx
	jmp _prt0
_out:
	mov byte [io+r10],0x0a
	inc r10
	mov rax,1
	mov rdi,1
	mov rsi,io
	mov rdx,11
	syscall
	mov rax,60	;正常退出
	xor rdi,rdi
	syscall

_inputerror:
	mov rax,60
	mov rdi,101
	syscall
