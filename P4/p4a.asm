code SEGMENT
	ASSUME cs : code
	ORG 256


start: 
	jmp real_start
	fernando db "Fernando Villar Gomez$", 13, 10
	blanca db "Blanca Martin Selgas$", 13, 10
	team db "Team 9$", 13, 10
	string1 db "Status: Installed$", 13, 10
	string2 db "Status: Not Installed$", 13, 10
	stringerr db "Arguments error$", 13, 10
	
real_start:
	mov ah, 9h
	cmp byte ptr ds:[80h], 0
	je no_args
	cmp byte ptr ds:[80h], 3
	jne wrong_args
	cmp byte ptr ds:[82h], 2Fh
	jne wrong_args
	cmp byte ptr ds:[83h], 49h
	jne continue
	jmp installer
continue:
	cmp byte ptr ds:[83h], 55h
	jne wrong_args
	jmp uninstall
	
wrong_args:
	mov dx, OFFSET stringerr
	jmp print
	
no_args:
	mov dx, OFFSET fernando
	int 21h
	mov dx, OFFSET blanca
	int 21h
	mov dx, OFFSET team
	int 21h
	mov bx, 0
	mov es, bx
	cmp byte ptr es:[55h*4], 0
	jne instalado
	cmp byte ptr es:[55h*4 + 2], 0
	jne instalado
	mov dx, OFFSET string2
	jmp print
instalado:
	mov dx, OFFSET string1
print:
	int 21h
	MOV AX, 4C00H
	INT 21H

isr PROC FAR ; Interrupt service routine
	; Save modified registers
	push bx ax bp
	; Routine instructions
	mov bp, dx
	cmp ah, 12h
	jne decrypt
	mov bx, 12
	jmp cesar
	decrypt:
		cmp ah, 13h
		jne fin
		mov bx, -12
	cesar:
		mov ax, ds:[bp]
		add ax, bx
		cmp ax, 127
		jge over
		cmp ax, 36
		jle under
	cfin:
		mov ds:[bp], ax
		inc bp
		cmp byte ptr ds:[bp], 24h
		jne cesar
	; Restore modified registers
	fin:pop bp ax bx
		iret
		
	over:
		sub ax, 90
		jmp cfin
	under:
		add ax, 90
		jmp cfin
isr ENDP

installer PROC
	mov ax, 0
	mov es, ax
	mov ax, OFFSET isr
	mov bx, cs
	cli
	mov es:[ 55h*4 ], ax
	mov es:[ 55h*4+2 ], bx
	sti
	mov dx, OFFSET installer
	int 27h ; Terminate and stay resident
	; PSP, variables, isr routine.
installer ENDP

uninstall PROC ; Uninstall ISR of INT 55h
	push ax bx cx ds es
	mov cx, 0
	mov ds, cx ; Segment of interrupt vectors
	mov es, ds:[ 55h*4+2 ] ; Read ISR segment
	mov bx, es:[ 2Ch ] ; Read segment of environment from ISR’s PSP.
	mov ah, 49h
	int 21h ; Release ISR segment (es)
	mov es, bx
	int 21h ; Release segment of environment variables of ISR
	; Set vector of interrupt 55h to zero
	cli
	mov ds:[ 55h*4 ], cx ; cx = 0
	mov ds:[ 55h*4+2 ], cx
	sti
	pop es ds cx bx ax
	ret
uninstall ENDP


code ENDS
END start