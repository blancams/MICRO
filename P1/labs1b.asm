;**************************************************************************
; MBS 2018 - PRACTICE 1 - EXERCISE B
; Team number:
; 4
;
; Authors names:
; - Blanca Martin Selgas
; - Fernando Villar Gomez
;**************************************************************************

; DATA SEGMENT DEFINITION
DATOS SEGMENT

COUNTER DB ?									; 1 byte allocation without initialization for COUNTER
GRAB DW 0CAFEh									; 2 byte allocation with initialization for GRAB
TABLE DB 100 dup(0)								; 100*1-byte allocation for TABLE
ERROR1 DB "Incorrect data. Try again."			; 1 byte allocation with string initialization for ERROR1

TABLE_POS_1 DW 53h								; value to refer to a position in TABLE
TABLE_POS_2 DW 23h								; value to refer to a position in TABLE

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
	MOV DI, TABLE_POS_1								; Saving TABLE_POS_1 in DI, to refer to the position 53h of TABLE
	MOV AH, ERROR1[5]								; Saving the sixth character of ERROR1 in AH
	MOV TABLE[DI], AH								; Saving the sixth character of ERROR1 (AH) in TABLE[53h]

	MOV AX, GRAB									; Saving 2-byte word GRAB in AX
	MOV DI, TABLE_POS_2								; Saving TABLE_POS_2 in DI, to refer to the position 23h of TABLE
	MOV WORD PTR TABLE[DI], AX						; Saving AX (GRAB) in the position 23h of TABLE

	MOV DL, BYTE PTR GRAB[1]						; Saving the most significative byte of GRAB in DL
	MOV COUNTER, DL									; Saving DL (MSB of GRAB) in COUNTER
	; PROGRAM END

	MOV AX, 4C00H
	INT 21H
INICIO ENDP

; END OF CODE SEGMENT
CODE ENDS

; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO
