;**************************************************************************
; MBS 2018 - PRACTICE 4 - EXERCISE B
; Team number:
; 4
;
; Authors names:
; - Blanca Martin Selgas
; - Fernando Villar Gomez
;**************************************************************************
; DATA SEGMENT DEFINITION
DATOS SEGMENT
	string db 63 dup (?)
	enter_string db "Enter a test string: " , "$"
	encrypted db "Encrypted: ", "$"
	decrypted db "Decrypted: ", "$"
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

	mov ah, 9h                 ; Print a message that invites to enter
	mov dx, OFFSET enter_string
	int 21h                    ; a string to test encryption/decryption
	
	mov ah, 0Ah                ; Read string from screen
	mov dx, OFFSET string      ; and saving the result in ds:dx
	mov string[0], 60      	   ; with a maximum of 60 characters
	int 21h
	mov bl, string[1]		   ; Set the character of end of string '$'
	mov string[bx + 2], 24h    ; at number of characters typed + 2
	
	mov ah, 2h				   ; Prepare a new line 
	mov dl, 13
	int 21h
	mov dl, 10
	int 21h
	
	mov ah, 9h                 
	mov dx, OFFSET encrypted   
	int 21h
	mov ah, 12h
	mov dx, OFFSET string      ; We encrypt the string 
	add dx, 2                  ; avoiding the first byte of information
	int 55h                  
	
	mov ah, 2h                 ; Prepare a new line 
	mov dl, 13
	int 21h
	mov dl, 10
	int 21h
	
	mov ah, 9h
	mov dx, OFFSET decrypted
	int 21h
	mov ah, 13h
	mov dx, OFFSET string      ; We decrypt the string to test the 
	add dx, 2                  ; correct behaviour of the interrupt. 
	int 55h

	; PROGRAM END
	MOV AX, 4C00H
	INT 21H
INICIO ENDP
CODE ENDS
END INICIO 
