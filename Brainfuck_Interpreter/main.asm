section .data
	faddr db "bfcode.txt",0
section .text
	global _start

_start:
	;申请内存并保存读取的内容
	mov rax,9
	mov rdi,0
	mov rsi,4096
	mov rdx,3
	mov r10,0x22
	mov r8,-1
	mov r9,0
	syscall
	test rax,rax
		js _mem_fail
	mov r15,rax

	;申请代码段内存
	mov rax,9
	mov rdi,0
	mov rsi,1048576
	mov rdx,3
	mov r10,0x22
	mov r8,-1
	mov r9,0
	syscall
	test rax,rax
		js _mem_fail
	mov r14,rax

	;打开文件
	mov rax,2
	lea rdi,[faddr]
	mov rsi,0
	mov rdx,0
	syscall
	test rax,rax
		js _open_fail
	mov r13,rax

	;读取代码内容
	mov rax,0
	mov rdi,r13
	mov rsi,r14
	mov rdx,1048576
	syscall
	test rax,rax
		js _fread_fail
	mov r12,rax

	;关闭文件
	mov rax,3
	mov rdi,r13
	syscall

	;申请纸条内存
	mov rax,9
	mov rdi,0
	mov rsi,30000
	mov rdx,3
	mov r10,0x22
	mov r8,-1
	mov r9,0
	syscall
	test rax,rax
		js _mem_fail
	mov r13,rax

	mov [r15+2],r14
	mov [r15+10],r12
	mov [r15+18],r13

	;申请栈内存
	mov rax,9
	mov rdi,0
	mov rsi,1024
	mov rdx,3
	mov r10,0x22
	mov r8,-1
	mov r9,0
	syscall
	test rax,rax
		js _mem_fail
	;mov r13,rax
	mov [r15+26],rax
	mov [r15+34],rax

	xor r12,r12
	mov r13,[r15+18]

_main:	;正式开始解释代码内容
	movzx rax,byte [r14+r12]
	inc r12
	cmp rax,43
		jz _main_1
	cmp rax,45
		jz _main_2
	cmp rax,60
		jz _main_3
	cmp rax,62
		jz _main_4
	cmp rax,44
		jz _main_5
	cmp rax,46
		jz _main_6
	cmp rax,91
		jz _main_7
	cmp rax,93
		jz _main_8
	mov rcx,[r15+10]
	cmp r12,rcx
		jz _ending
	jmp _main
_main_1:
	inc byte [r13]
	jmp _main
_main_2:
	dec byte [r13]
	jmp _main
_main_3:
	dec r13
	jmp _move_test
_main_4:
	inc r13
	jmp _move_test
_main_6:
	mov rax,1
	mov rdi,1
	mov rsi,r13
	mov rdx,1
	syscall
	test rax,rax
		js _write_fail
	jmp _main
_main_5:
	mov rax,0
	mov rdi,0
	mov rsi,r13
	mov rdx,1
	syscall
	test rax,rax
		js _read_fail
	jmp _main
_main_7:
	cmp byte [r13],0  ;当前单元格为0：跳过整个循环体
		jz _7_skip
	mov r14,[r15+34]  ;当前单元格不为0，压栈，进入循环体
	mov [r14],r12
	add r14,8
	mov rcx,[r15+26]
	add rcx,1024
	cmp rcx,r14  ;检查栈位置
		jb _stack_overflow
	mov [r15+34],r14
	mov r14,[r15+2]
	jmp _main
_main_8:
	cmp byte [r13],0  ;当前单元格为0，弹栈，离开循环
		jz _8_leave
	mov r14,[r15+34]  ;当前单元格不为0，读栈不弹，回到循环体开头
	mov r12,[r14-8]
	mov r14,[r15+2]
	jmp _main
_7_skip:
	xor r11,r11
	inc r11
_7_skip_0:
	mov rcx,[r15+2]
	movzx rax,byte [r12+rcx]
	inc r12
	mov rcx,[r15+10]
	cmp r12,rcx
		jz _ending
	cmp rax,91
		jnz _7_skip_1
	inc r11
_7_skip_1:
	cmp rax,93
		jnz _7_skip_2
	dec r11
_7_skip_2:
	test r11,r11
		jz _main
	jmp _7_skip_0
_8_leave:
	mov r14,[r15+34]
	sub r14,8
	mov qword [r14],0
	mov rcx,[r15+26]
	cmp r14,rcx
		jb _stack_error  ;栈底扎穿
	mov [r15+34],r14
	mov r14,[r15+2]
	jmp _main
_move_test:
	cmp r13,[r15+18]
		jb _r13_fail
	mov rcx,[r15+18]
	add rcx,30000
	cmp rcx,r13
		jb _r13_fail
	jmp _main

_ending:
	mov byte [r15+1],0x0a
	mov rax,1
	mov rdi,1
	lea rsi,[r15+1]
	mov rdx,1
	syscall

	mov rax,60
	mov rdi,0
	syscall

_read_fail:
	mov rax,3
	mov rdi,r13
	syscall
	mov rax,60
	mov rdi,101
	syscall
_mem_fail:	
	mov rax,60
	mov rdi,102
	syscall
_open_fail:
	mov rax,60
	mov rdi,103
	syscall

_fread_fail:
	mov rax,60
	mov rdi,104
	syscall

_r13_fail:
	mov rax,60
	mov rdi,105
	syscall

_write_fail:
	mov rax,60
	mov rdi,106
	syscall

_stack_overflow:
	mov rax,60
	mov rdi,107
	syscall

_stack_error:
	mov rax,60
	mov rdi,108
	syscall
