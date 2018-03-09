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
	
	MOV AX, 13h								; Load 13h in AX
	MOV BX, 00BAh							; Load BAh in BX
	MOV CX, 3412h							; Load 3412h in CX
	
	MOV DX, CX								; Load CX in DX
	
	; Initialization of DS
	MOV AX, 6524h 
	MOV DS, AX
	MOV BYTE PTR DS:[6], 23h 				; Testing purposes
	MOV BYTE PTR DS:[7], 24h 				; Testing purposes
	MOV AL, DS:[6] 							; Load the content of the memory address 65246h in AL
	MOV AH, DS:[7] 							; Load the content of the memory address 65247h in AH
	
	;, Initialization of DS
	MOV AX, 4000h
	MOV DS, AX
	MOV DS:[4h], CH 						; Load the content of CH in the memory address 40004h
	
	MOV AX, [DI]							; Load the memory address pointed by DI in AX
	MOV AX, [BP+8]							; Load the memory address pointed by BP+8 in AX
	
	; PROGRAM END
	MOV AX, 4C00H
	INT 21H
INICIO ENDP

; END OF CODE SEGMENT
CODE ENDS

; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO