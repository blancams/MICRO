
; DATA SEGMENT DEFINITION
DATOS SEGMENT
	input db 'Input: "$'
	output db '"', 13, 10, 'Output: "$'
	computation db '"', 13, 10, 'Computation:$'
	row1 db 13, 10, '     | P1 | P2 | D1 | P4 | D2 | D3 | D4 $'
	row21 db 13, 10, 'Word | ?  | ?$'
	row22 db '  | ?$'
	separator db '  | $'
	empty db '   | $'
	row3 db 13, 10, 'P1   | $'
	row4 db 13, 10, 'P2   | $'
	row5 db 13, 10, 'P3   | $'
	message_error db 'The number must be between 0 and 15$'
	
	vector_i db 5 dup (?), '$'
	vector db 4 dup (?)
	matrix db 1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,1,1,0,1,1,0,1,1,0,1,1,1
	result dw 7 dup(0)
DATOS ENDS 
;**************************************************************************
; STACK SEGMENT DEFINITION
PILA SEGMENT STACK "STACK"
	DB 40H DUP (0) 
PILA ENDS
;**************************************************************************
; EXTRA SEGMENT DEFINITION
EXTRA SEGMENT
	r dw 7 dup (0)
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
; ; PROGRAM START

		MOV AH, 0AH
		LEA DX, vector_i
		MOV vector_i[0], 3
		INT 21h
		
		MOV AX, 0
		ADD AL, vector_i[2]
		SUB AL, 30h
		MOV BX, 10
		MUL BX
		ADD AL, vector_i[3]
		SUB AL, 30h
		CMP AL, 0Fh
		JBE less
		MOV AH, 9h
		LEA DX, message_error
		INT 21h
		JMP fin	
		
less:	CMP AL, 0h
		JNE convrt
		
convrt:	MOV AH, 0h
		MOV DX, 0h
		MOV DI, 4
		MOV BX, 2
binary:	DIV BX
		DEC DI
		MOV vector[DI], DL
		CMP DI, 0
		JNE binary
					
			
okey:	MOV DI, 0 
column:	MOV BX, 0
row:	MOV AL, vector[BX]
		MUL matrix[BX][DI]
		ADD result[DI], AX
		INC BX
		CMP BX, 4
		JNE row
		ADD DI, 4
		CMP DI, 1Ch
		JNE column		
	
		MOV DI, 10h
		MOV BX, 2
parity:	MOV DX, 0h
		MOV AX, result[DI]
		DIV BX
		MOV result[DI], DX
		ADD DI, 4
		CMP DI, 1Ch
		JNE parity
			
call print
	
; PROGRAM END
fin:	MOV AX, 4C00H
		INT 21H
INICIO ENDP

print_str_vector proc
	MOV AH, 9h
	INT 21h
	MOV AH, 2h
	MOV DI, 0
p:  MOV DL, ds:[BX][DI]
	ADD DL, 30h
	INT 21h
	ADD DI, SI
	CMP DI, CX
	JNE p
	ret	
print_str_vector endp

print_num_sep proc
	MOV AH, 9h
	LEA DX, separator
	INT 21h
	MOV AH, 2h
	MOV DL, BL
	ADD DL, 30h
	INT 21h
	ret
print_num_sep endp
	
print_num proc
	MOV AH, 2h
	ADD DL, 30h
	INT 21h
	ret
print_num endp

fill proc
	MOV DI, 1
f:	MOV BL, vector[DI]
	call print_num_sep
	INC DI
	CMP DI, 4
	JNE f
	ret
fill endp

print proc
	MOV SI, 1
	MOV CX, 4h
	LEA DX, input
	LEA BX, vector
	call print_str_vector
	
	MOV SI, 4
	MOV CX, 1Ch
	LEA DX, output
	LEA BX, result
	call print_str_vector

	MOV AH, 9h	
	LEA DX, computation
	INT 21h
	
	LEA DX, row1
	INT 21h 
	
	LEA DX, row21
	INT 21h 
	MOV BL, vector[0]
	call print_num_sep
	MOV AH, 9h
	LEA DX, row22
	INT 21h
	MOV DI, 1
	call fill

		
	MOV AH, 9h
	LEA DX, row3
	INT 21h
	MOV DX, result[10h]
	call print_num
	MOV AH, 9h
	LEA DX, separator
	INT 21h
	LEA DX, empty
	INT 21h
	MOV DL, vector[0]
	call print_num
	MOV AH, 9h
	LEA DX, separator
	INT 21h
	LEA DX, empty
	INT 21h
	MOV DL, vector[1]
	call print_num
	MOV AH, 9h
	LEA DX, separator
	INT 21h
	LEA DX, empty
	INT 21h
	MOV DL, vector[2]
	call print_num
	
	MOV AH, 9h
	LEA DX, row4
	INT 21h
	LEA DX, empty
	INT 21h
	MOV DX, result[14h]
	call print_num
	MOV BL, vector[0]
	call print_num_sep
	MOV AH, 9h
	LEA DX, separator
	INT 21h
	LEA DX, empty
	INT 21h
	LEA DX, empty
	INT 21h
	MOV DL, vector[2]
	call print_num
	MOV BL, vector[3]
	call print_num_sep
	
		
	MOV AH, 9h
	LEA DX, row5
	INT 21h
	LEA DX, empty
	INT 21h
	LEA DX, empty
	INT 21h
	LEA DX, empty
	INT 21h
	MOV DX, result[18h]
	call print_num		
	call fill
		
	ret
print endp

; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO 