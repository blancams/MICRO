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
	cmp byte ptr ds:[80h], 0   		; If there are no arguments
	je no_args                 		; we print the information regarding the team and the installation.
	cmp byte ptr ds:[80h], 3    	; If the number of arguments isn't 3,
	jne wrong_args              	; those are not valid arguments for the program.
	cmp byte ptr ds:[82h], 2Fh      ; If the second argument isn't '/'
	jne wrong_args                  ; those are not valid arguments for the program.
	cmp byte ptr ds:[83h], 49h      ; If the third argument isn't 'I'
	jne continue                    ; it might be 'U', so we will check that...
	mov dx, OFFSET installed        ; if it is 'I', we load into dx the offset of the string 'installed'
	mov cx, 0                       ; in case the interruption is already installed.
	mov es, cx
	cmp byte ptr es:[55h*4], 0      ; We check if it had not been installed previously.
	jne print                       ; If it had, we inform the user and end the program.
	cmp byte ptr es:[55h*4 + 2], 0  
	jne print                       
	jmp installer                   ; if not, we install it.
continue:
	cmp byte ptr ds:[83h], 55h      ; If the third argument isn't 'U'
	jne wrong_args                  ; those are not valid arguments for the program.
	mov dx, OFFSET uninstalled      ; If it is 'U', we load into dx the offset of the string 'uninstalled'
	mov cx, 0
	mov es, cx
	cmp byte ptr es:[55h*4], 0      ; We check if it had not been uninstalled previously.
	je test_sec						
	jmp uninstall
test_sec:
	cmp byte ptr es:[55h*4 + 2], 0
	je print						; If it had, we inform the user and end the program.
	jmp uninstall					; if not, we uninstall it.
	
wrong_args:
	mov dx, OFFSET stringerr        ; If the arguments are not valid, we load into dx the offset 
	jmp print                       ; of the error string and print it.
	
no_args:
	mov ah, 9h                      ; If there are no arguments, 
	mov dx, OFFSET fernando         ; We print our names
	int 21h
	mov dx, OFFSET blanca
	int 21h
	mov dx, OFFSET team             ; Our team number
	int 21h
	mov bx, 0
	mov es, bx
	mov dx, OFFSET string1          
	cmp byte ptr es:[55h*4], 0      ; And we check if the interruption has been installed
	jne print                       ; If the memory area has something written in it, that means
	cmp byte ptr es:[55h*4 + 2], 0  ; it is installed, so we print the status as 'installed'.
	jne print                       
	mov dx, OFFSET string2          ; If not, it is not installed.
	
print:
	mov ah, 9h
	int 21h
	MOV AX, 4C00H
	INT 21H

isr PROC FAR ; Interrupt service routine
	; Save modified registers
	push bx ax bp dx ds
	
	; Routine instructions
	mov bp, dx   ; We load into BP, DX. So now the string to be encrypted is ds:bp
	cmp ah, 12h  ; If AH == 12h, it means we have to encrypt the string
	jne decrypt  ; if not, we may have to decrypt it, or it might be an error.
	mov bl, 12   ; In encryption we load into BL a 12 (team 9 + 3 = 12)
	jmp cesar    ; and we start encryption.
	decrypt:
		cmp ah, 13h   ; If AH == 13h, it means we have to decrypt the string
		jne fin       ; if not, thats not a supported value for AH and we terminate the program.
		mov bl, -12   ; In decryption we load into BL a -12  -(team 9 + 3 = 12)
	cesar:
		mov al, byte ptr ds:[bp]  ; Load into AL the first character of the string (ds:bp)
		cmp al, 24h               ; If AL == '$'
		je printi                 ; the encryption has finished and we print the result
		add al, bl                ; if not, we add to the character the encryption/decryption key
		cmp al, 127               ; If AL > 127
		jae over                  ; we have passed our limit and have to adjust the result
		cmp al, 36                ; If AL < 36
		jbe under                 ; we have passed our limit and have to adjust the result
	cfin:                         ; Now AL is in the interval (36, 127)
		mov byte ptr ds:[bp], al  ; Save the result in the original string
		inc bp                    ; bp = bp + 1
		jmp cesar                 ; Continue the loop until '$' is read.
	; Restore modified registers
	printi:	
		mov bp, dx			; Load DX into BP (the original offset of the string)
		
		mov al, 0Bh         
		out 70h, al         ; Enable the 0Bh register
		in al, 71h          ; Read the 0Bh register
		mov ah, al
		or ah, 00010000b    ; Set the UIE bit
		mov al, 0Bh
		out 70h, al         ; Enable the 0Bh register
		mov al, ah
		out 71h, al         ; Write the 0Bh register

		mov ah, 2h          ; Load into AH 2h to print characters into the screen
	print_loop:
		call RTC_wait1sec         ; Wait 1 second
		mov dl, byte ptr ds:[bp]  ; Load into DL one character of the string
		cmp dl, 24h               ; If DL == '$'
		je fin                    ; we have printed the whole string
		int 21h                   ; if not, we print DL
		inc bp                    ; bp = bp + 1
		jmp print_loop            ; Continue the loop until the character '$' is encountered.
		
	fin:
		mov al, 0Bh               
		out 70h, al         ; Enable the 0Bh register
		in al, 71h          ; Read the 0Bh register
		mov ah, al
		and ah, 11101111b   ; Unset the UIE bit
		mov al, 0Bh
		out 70h, al         ; Enable the 0Bh register
		mov al, ah
		out 71h, al         ; Write the 0Bh register
	
		pop ds dx bp ax bx
		iret
		
	over:
		sub al, 90    ; Substract 90 to AL to adjust the result to the interval (36, 127)
		jmp cfin      ; we return to the encryption loop.
	under:
		add al, 90    ; Add 90 to AL to adjust the result to the interval (36, 127)
		jmp cfin      ; we return to the encryption loop.
isr ENDP

RTC_wait1sec PROC

	waiting:
		mov al, 0Ch
		out 70h, al         ; Access to 0Ch register of RTC
		in al, 71h          ; Read the 0Ch register
		
		test al, 10010000b  ; Check if the interruption is the time update
		jz waiting          ; if not, keep waiting
                            ; if it is, a second has passed
	ret						
RTC_wait1sec ENDP

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