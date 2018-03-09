;**************************************************************************
; ASSEMBLY CODE STRUCTURE EXAMPLE. MBS 2018
; Team number:
; 4
;
; Authors names:
; - Blanca Martin Selgas
; - Fernando Villar Gomez
;**************************************************************************

; DATA SEGMENT DEFINITION
DATOS SEGMENT
	
DATOS ENDS


;**************************************************************************
; STACK SEGMENT DEFINITION
PILA SEGMENT STACK "STACK"

	DB 40H DUP (0) ; initialization example, 64 bytes set to 0
	
PILA ENDS


;**************************************************************************
; EXTRA SEGMENT DEFINITION
EXTRA SEGMENT

	RESULT DW 0,0 ; initialization example. 2 WORDS (4 BYTES)
	
EXTRA ENDS


;**************************************************************************
; CODE SEGMENT DEFINITION
CODE SEGMENT
	ASSUME CS: CODE, DS: DATOS, ES: EXTRA, SS: PILA
; BEGINNING OF THE MAIN PROCEDURE

INICIO PROC
	; INITIALIZE THE SEGMENT REGISTERS
	MOV AX, DATOS
	MOV DS, AX
	MOV AX, PILA
	MOV SS, AX
	MOV AX, EXTRA
	MOV ES, AX
	MOV SP, 64 ; LOAD THE STACK POINTER WITH THE HIGHEST VALUE
	
	; PROGRAM START
	
	; Initialization of DS
	MOV AX, 0511h
	MOV DS, AX
	
	; Initialization of DI
	MOV AX, 1010h
	MOV DI, AX
	
	; Initialization of BX
	MOV AX, 0211h
	MOV BX, AX
	
	; Real address: 6344h (0511h x 10h + 1234h)
	MOV BYTE PTR DS:[1234h], 4Fh 					; Test
	MOV AL, DS:[1234h]
	
	; Real address: 5321h (0511h x 10h + 1010h)
	MOV BYTE PTR [BX], 5h 							; Test
	MOV AX, [BX]

	; Real address: 6120h (0511h x 10h + 0211h)
	MOV [DI], AL
	
	; PROGRAM END
	
	MOV AX, 4C00H
	INT 21H
INICIO ENDP

; END OF CODE SEGMENT
CODE ENDS

; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO 