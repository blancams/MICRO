;**************************************************************************
; MBS 2018 - PRACTICE 3 - EXERCISE A
; Team number:
; 4
;
; Authors names:
; - Blanca Martin Selgas
; - Fernando Villar Gomez
;**************************************************************************

; Declares checkSecretNumber and fillUpAttempt and defines code segment
PRAC3A SEGMENT BYTE PUBLIC 'CODE'
PUBLIC _checkSecretNumber, _fillUpAttempt
ASSUME CS: PRAC3A

; Coding of checkSecretNumber, specifying FAR to use LARGE model
_checkSecretNumber PROC FAR
		PUSH BP
		MOV BP, SP
		PUSH BX DX ES 			; Saves registers

		LES BX, [BP + 6] 		; Reads parameters from stack (array of 4 char* elements, i.e. 4 bytes, 1 digit per byte)
		MOV AL, ES:[BX]			; Saves first digit in AL
		MOV AH, ES:[BX+1]		; Saves second digit in AH
		MOV DL, ES:[BX+2]		; Saves third digit in DL
		MOV DH, ES:[BX+3]		; Saves fourth digit in DH
		CMP AL, AH				; Compares first and second digit. If they are equal, jumps to bye
		JE bye
		CMP AL, DL				; Compares first and third digit. If they are equal, jumps to bye
		JE bye
		CMP AL, DH				; Compares first and fourth digit. If they are equal, jumps to bye
		JE bye
		CMP AH, DL				; Compares second and third digit. If they are equal, jumps to bye
		JE bye
		CMP AH, DH				; Compares second and fourth digit. If they are equal, jumps to bye
JE bye
		CMP DH, DL				; Compares third and fourth digit. If they are equal, jumps to bye
		JE bye

		MOV AX, 0				; If this instruction is executed, there is no coincidence between digits and 0 is returned
		JMP nobye				; Jumps to end of program
bye:   MOV AX, 1 				; If this instruction is executed, there has been a coincidence between digits and 1 is returned
nobye: POP ES DX BX BP 			; Recovers used registers
RET
_checkSecretNumber ENDP

; Coding of fillUpAttempt, specifying FAR to use LARGE model
_fillUpAttempt PROC FAR
		PUSH BP
		MOV BP, SP
		PUSH DI CX BX DX ES 	; Saves registers

		MOV AX, [BP + 6] 		; Reads first parameter, the 4-digit number
		LES BX, [BP + 8] 		; Reads second parameter, the array of 4 char variables to be filled

; This is the method with which we coded the first exercise of the previous practice
; It splits a 4-digit number into its four digits, storing each digit in a byte
; Those bytes belong to the array loaded through BX
		MOV DI, 4				; DI is going to be the index of the array
		MOV CX, 10				; We load 10 to BX, as it's going to be used as modulo
bucle:	DEC DI					; Decrementation of DI to keep looping
		MOV DX, 0h				; Initialization of DX to perform the division
		DIV CX					; DX:AX / BX, AX keeps the quotient (which is (number-array[i]/10)) and DX stores the remainder
		MOV ES:[BX][DI], DL		; We store the value in the array
		CMP DI, 0h				; Loop stops if the result of the division was 0
		JNE bucle

		POP ES DX BX CX DI BP	; Recovers used registers
RET
_fillUpAttempt ENDP
PRAC3A ENDS ; End of Segment
END
