;**************************************************************************
; MBS 2018 - PRACTICE 1 - EXERCISE C
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


	; WARNING: The following instructions may access the resident portion of DOS
	; in the RAM, so the program may be unstable and not work as intended (the
	; addresses are included in the range 0x00600-0x0A000)

	; Real address: 06344h (0511h x 10h + 1234h)
	MOV BYTE PTR DS:[1234h], 4Fh 					; Testing purposes
	MOV AL, DS:[1234h]								; Loads the content of the memory address 06344h in AL

	; Real address: 05321h (0511h x 10h + 1010h)
	MOV BYTE PTR [BX], 5h 							; Testing purposes
	MOV AX, [BX]									; Loads the content of the memory address 05321h in AX

	; Real address: 06120h (0511h x 10h + 0211h)
	MOV [DI], AL									; Loads the content of AL in the memory address 06120h

	; PROGRAM END

	MOV AX, 4C00H
	INT 21H
INICIO ENDP

; END OF CODE SEGMENT
CODE ENDS

; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO
