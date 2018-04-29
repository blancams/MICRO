; DATA SEGMENT DEFINITION
DATOS SEGMENT
	string db "Teststring", "$"
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

	mov ah, 12h
	mov dx, OFFSET string
	int 55h
	mov ah, 13h
	int 55h

	; PROGRAM END
	MOV AX, 4C00H
	INT 21H
INICIO ENDP
; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO 