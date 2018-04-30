; DATA SEGMENT DEFINITION
DATOS SEGMENT
	string db 62 dup (?)
DATOS ENDS 
;**************************************************************************
; STACK SEGMENT DEFINITION
PILA SEGMENT STACK "STACK"
	DB 40H DUP (0) 
PILA ENDS
;**************************************************************************
; EXTRA SEGMENT DEFINITION
EXTRA SEGMENT
	RESULT DW 0,0
EXTRA ENDS
;**************************************************************************
; CODE SEGMENT DEFINITION
CODE SEGMENT
ASSUME CS: CODE, DS: DATOS, ES: EXTRA, SS: PILA
; BEGINNING OF THE MAIN PROCEDURE
INICIO PROC	
		MOV AX, DATOS
		MOV DS, AX
		MOV SP, 64 ; LOAD THE STACK POINTER WITH THE HIGHEST VALUE

		mov cx, 0    ; Decryption flag. (cx = 1 == Decryption) (cx = 0 == Encryption)
					 ; Encryption set by default.
	while_loop:
		mov ah, 0Ah            ; Read string from screen
		mov dx, offset string  ; and saving the result in ds:dx
		mov string[0], 60      ; with a maximum of 60 characters
		int 21h
		
		cmp cx, 0    ; If cx == 0 that means we have to encrypt the string
		jne decod    ; if not, we have to decrypt it.
		mov ah, 12h  ; In encryption we load into AH a 12h        
		jmp keep
	decod:
		mov cx, 0    ; and in decryption, we reset the flag to encryption
		mov ah, 13h  ; and load into AH a 13h

	keep:
		add dx, 2            ; The first two values of the string indicates the maximum of characters
		mov bh, 0            ; and the number of characters typed, so we add 2 to the offset
		mov bl, string[1]    ; We save in bx the number of characters typed
		cmp bl, 4            ; If that number is 4, we suspect the string must be 'quit'
		je quit				 
		cmp bl, 3            ; and if that number is 3, the string can either be 'dec' or 'cod'
		je dec_cod
	false_alarm:  
		mov string[bx + 2], 24h  ; If it wasn't any of the above, we set the end of the string '$' 
		int 55h	                 ; and call the interruption to encrypt/decrypt it.
		mov dl, 13
		mov ah, 2h
		int 21h
		mov dl, 10
		int 21h
		jmp while_loop           ; Repeating the process until we encounter the 'quit' string.
		
	dec_cod:
		cmp string[2], 64h    ; If the first letter is a 'd' we keep comparing
		jne cod       		  ; if not, it might be a 'c' so we check that.
		cmp string[3], 65h    ; If the second letter is an 'e' we keep comparing
		jne false_alarm       ; if not, we encrypt the string.
		cmp string[4], 63h    ; If the third letter is a 'c' we decrypt the string
		jne false_alarm       ; if not, we encrypt the string.
		mov cx, 1             ; Set the decryption flag to 1
		mov dl, 13            ; Prepare the cursor in a new line to read
		mov ah, 2h            ; the string that has to be decrypted.
		int 21h
		mov dl, 10
		int 21h
		jmp while_loop	      ; Continue the loop.
	
	cod:
		cmp string[2], 63h    ; If the first letter is a 'c' we keep comparing
		jne false_alarm       ; if not, we encrypt the string.
		cmp string[3], 6Fh    ; If the second letter is an 'o' we keep comparing
		jne false_alarm       ; if not, we encrypt the string.
		cmp string[4], 64h    ; If the third letter is a 'd' we keep comparing
		jne false_alarm       ; if not, we encrypt the string.
		mov dl, 13            ; Prepare the cursor in a new line to read
		mov ah, 2h            ; the string that has to be decrypted.
		int 21h
		mov dl, 10
		int 21h
		jmp while_loop	      ; Continue the loop.
		
		
	quit:
		cmp string[2], 71h    ; If the first letter is a 'q' we keep comparing
		jne false_alarm		  ; if not, we encrypt the string.
		cmp string[3], 75h    ; If the second letter is a 'u' we keep comparing
		jne false_alarm       ; if not, we encrypt the string.
		cmp string[4], 69h    ; If the third letter is an 'i' we keep comparing
		jne false_alarm       ; if not, we encrypt the string.
		cmp string[5], 74h    ; If the forth letter is a 't' we finish the loop
		jne false_alarm       ; if not, we encrypt the string.
		
	end_while:
		; PROGRAM END
		MOV AX, 4C00H
		INT 21H
INICIO ENDP

; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO 