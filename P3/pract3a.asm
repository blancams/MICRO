
PRAC3A SEGMENT BYTE PUBLIC 'CODE'
PUBLIC _checkSecretNumber, _fillUpAttempt
ASSUME CS: PRAC3A
_checkSecretNumber PROC FAR
PUSH BP
MOV BP, SP
PUSH BX DX ; Save registers

LES BX, [BP + 6] ; read parameters from stack
MOV AL, ES:[BX]
MOV AH, ES:[BX+1]
MOV DL, ES:[BX+2]
MOV DH, ES:[BX+3]
CMP AL, AH
JE bye
CMP AL, DL
JE bye
CMP AL, DH
JE bye
CMP AH, DL
JE bye
CMP AH, DH
JE bye
CMP DH, DL
JE bye

MOV AX, 0
JMP nobye
bye:   MOV AX, 1 ; data results in AX.
nobye: POP DX BX BP ; recover used registers
RET
_checkSecretNumber ENDP

_fillUpAttempt PROC FAR
PUSH BP
MOV BP, SP
PUSH BX DX ; Save registers

MOV AX, [BP + 6] ;num
LES BX, [BP + 8] ; el char*

		MOV DI, 3				; DI is going to be the index of the array
		MOV CX, 10				; We load 10 to BX, as it's going to be used as modulo
bucle:	MOV DX, 0h				; Initialization of DX to perform the division
		DIV CX					; DX:AX / BX, AX keeps the quotient (which is (number-array[i]/10)) and DX stores the remainder
		MOV ES:[BX][DI], DL		; We store the value coded to ASCII in the array
		DEC DI					; Decrementation of DI to keep looping
		CMP DX, 0h				; Loop stops if the result of the division was 0 (as we have added 30h after the division, we compare DX with 30h)
		JNE bucle
		
POP DX BX BP
RET
_fillUpAttempt ENDP
PRAC3A ENDS ; End of Segment
END
