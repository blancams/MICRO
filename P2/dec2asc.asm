;**************************************************************************
; MBS 2018 - PRACTICE 2 - EXERCISE 1
; Team number:
; 4
;
; Authors names:
; - Blanca Martin Selgas
; - Fernando Villar Gomez
;**************************************************************************

; DATA SEGMENT DEFINITION
DATOS SEGMENT
	array db 5 dup (0), 13, 10, '$'
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
; INITIALIZE THE SEGMENT REGISTERS
MOV AX, DATOS
MOV DS, AX
MOV AX, PILA
MOV SS, AX
MOV AX, EXTRA
MOV ES, AX
MOV SP, 64 ; LOAD THE STACK POINTER WITH THE HIGHEST VALUE
; PROGRAM START

		; This code implements an algorithm designed to get each digit of a number
		; The algorithm works as follows (C implementation):
		;
		; for(i=4; i>=0; i--) {
		; 	array[i] = number%10
		;	number = (number-array[i])/10
		; }
		;
		; With number = 65535, the steps are:
		; 1) array[4] = 65535%10 = 5, number = (65535-5)/10 = 6553
		; 2) array[3] = 6553%10 = 3, number = (6553-3)/10 = 655
		; 3) array[2] = 655%10 = 5, number = (655-5)/10 = 65
		; 4) array[1] = 65%10 = 5, number = (65-5)/10 = 6
		; 5) array[0] = 6%10 = 6, number = (6-6)/10 = 0
		;
		; In the end array = [6, 5, 5, 3, 5], therefore in the end we add 30h to every number to convert
		; them to their ASCII code, and finally we print all of the numbers
		
		MOV DI, 4				; DI is going to be the index of the array
		MOV BX, 65335			; We load 65535 to BX...
		MOV AX, BX				; ...and to AX to perform operations
		MOV BX, 10				; We load 10 to BX, as it's going to be used as modulo
bucle:	MOV DX, 0h				; Initialization of DX to perform the division
		DIV BX					; DX:AX / BX, AX keeps the quotient (which is (number-array[i]/10)) and DX stores the remainder
		ADD DX, 30h				; We add 30h to the remainder to convert it to ASCII code
		MOV array[DI], DL		; We store the value coded to ASCII in the array
		DEC DI					; Decrementation of DI to keep looping
		CMP DX, 30h				; Loop stops if the result of the division was 0 (as we have added 30h after the division, we compare DX with 30h)
		JNE bucle
		MOV DX, OFFSET array	; After exiting the loop, we need the original offset of the array to print it
		MOV AH, 09h				; Sets AH to 09h to print the sequence contained in 'array'
		INT 21h
; PROGRAM END
MOV AX, 4C00H
INT 21H
INICIO ENDP
; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO 