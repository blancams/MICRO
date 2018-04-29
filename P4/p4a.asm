code SEGMENT
	ASSUME cs : code
	ORG 256


start: 
	jmp real_start
	fernando db "Fernando Villar Gomez", 13, 10, "$"
	blanca db "Blanca Martin Selgas", 13, 10, "$"
	team db "Team 9", 13, 10, "$"
	string1 db "Status: Installed", 13, 10, "$"
	string2 db "Status: Not Installed", 13, 10, "$"
	stringerr db "Arguments error", 13, 10, "$"
	installed db "The interruption's already been installed", 13, 10, "$"
	uninstalled db "The interruption's not yet been installed", 13, 10, "$"
	
real_start:
	cmp byte ptr ds:[80h], 0
	je no_args
	cmp byte ptr ds:[80h], 3
	jne wrong_args
	cmp byte ptr ds:[82h], 2Fh
	jne wrong_args
	cmp byte ptr ds:[83h], 49h
	jne continue
	mov dx, OFFSET installed
	mov cx, 0
	mov es, cx
	cmp byte ptr es:[55h*4], 0
	jne print
	cmp byte ptr es:[55h*4 + 2], 0
	jne print
	jmp installer
continue:
	cmp byte ptr ds:[83h], 55h
	jne wrong_args
	mov dx, OFFSET uninstalled
	mov cx, 0
	mov es, cx
	cmp byte ptr es:[55h*4], 0
	je test_sec
	jmp uninstall
test_sec:
	cmp byte ptr es:[55h*4 + 2], 0
	je print
	jmp uninstall
	
wrong_args:
	mov dx, OFFSET stringerr
	jmp print
	
no_args:
	mov ah, 9h
	mov dx, OFFSET fernando
	int 21h
	mov dx, OFFSET blanca
	int 21h
	mov dx, OFFSET team
	int 21h
	mov bx, 0
	mov es, bx
	mov dx, OFFSET string1
	cmp byte ptr es:[55h*4], 0
	jne print
	cmp byte ptr es:[55h*4 + 2], 0
	jne print
	mov dx, OFFSET string2
	
print:
	mov ah, 9h
	int 21h
	MOV AX, 4C00H
	INT 21H

isr PROC FAR ; Interrupt service routine
	; Save modified registers
	push bx ax bp dx ds
	; Routine instructions
	mov bp, dx
	cmp ah, 12h
	jne decrypt
	mov bl, 12
	jmp cesar
	decrypt:
		cmp ah, 13h
		jne fin
		mov bl, -12
	cesar:
		mov al, byte ptr ds:[bp]
		cmp al, 24h
		je fin
		add al, bl
		cmp al, 127
		jae over
		cmp al, 36
		jbe under
	cfin:
		mov byte ptr ds:[bp], al
		inc bp
		jmp cesar
	; Restore modified registers
	fin:
		mov ah, 9h
		int 21h
		mov ah, 2h
		mov dl, 13
		int 21h
		pop ds dx bp ax bx
		iret
		
	over:
		sub al, 90
		jmp cfin
	under:
		add al, 90
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