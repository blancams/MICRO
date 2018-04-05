;**************************************************************************
; MBS 2018 - PRACTICE 2 - EXERCISE 3
; Team number:
; 4
;
; Authors names:
; - Blanca Martin Selgas
; - Fernando Villar Gomez
;**************************************************************************

; DATA SEGMENT DEFINITION
DATOS SEGMENT
	; Character strings to build the formatted computation result
	input db 13, 10, 'Input: "$'											; First line: "Input:" + input vector
	output db '"', 13, 10, 'Output: "$'										; Second line: "Output:" + output vector
	computation db '"', 13, 10, 'Computation:$'								; Third line: "Computation:"
	row1 db 13, 10, '     | P1 | P2 | D1 | P4 | D2 | D3 | D4 $'				; Fourth line: Bit headers
	row21 db 13, 10, 'Word | ?  | ?$'										; Fifth line: Original word in Di bits, Pi bits are set to "?"
	row22 db '  | ?$'														; Character string to write Pi bits (set to "?")
	separator db '  | $'													; Character string to write separations between different bits
	empty db '   | $'														; Character string to write empty spaces (in P2 and P3 when displaying P1, etc...)
	row3 db 13, 10, 'P1   | $'												; Parity of bits 1, 2 and 4
	row4 db 13, 10, 'P2   | $'												; Parity of bits 1, 3 and 4
	row5 db 13, 10, 'P4   | $'												; Parity of bits 2, 3 and 4
	initial_message db 'Introduce a number between 0 and 15: $'				; Initial message to inform the user
	message_error db 13, 10, 'The number is not valid$'						; Message error when the number introduced is not valid
	
	vector_i db 4 dup (?), '$'												; Vector where the number introduced by the user and other information will be stored for computing purposes
	vector db 4 dup (0)														; 4-bit vector (each bit stored in 1 byte) that contains the number introduced in binary
	matrix db 1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,1,1,0,1,1,0,1,1,0,1,1,1		; Matrix to be multiplied by the vector to obtain the parity bits
	result db 7 dup(0)														; Output 7-bit vector, each bit stored in 1 byte
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

; PROGRAM START

		; Prints the initial message
		MOV AH, 9h
		LEA DX, initial_message
		INT 21h

		; Requests introduction of a number.
		MOV AH, 0AH
		LEA DX, vector_i
		MOV vector_i[0], 3								; The maximum size of the number is 2 characters, so we need to be able to catch 3 (two digits + carriage return)
		INT 21h
		
		; Checks the value introduced by the user
		MOV AL, vector_i[1]
		CMP AL, 1										; If the user has introduced one character, we jump to 'oned' where proper management will be performed
		JE  oned
		CMP AL, 2										; If the user has introduced two characters, we jump to 'twod' where proper management will be performed
		JE  twod
		JMP fail										; The other option happens when no character has been introduced by the user. In this case, there is a failure to be dealt with.
		
		; Manages the case in which a one-digit number was introduced. In this case, we only have to add the number itself (after substracting 30h to decode it from ASCII)
oned:	MOV AX, 0
		MOV AL, vector_i[2]
		SUB AL, 30h
		JMP convrt
		
		; Manages the case in which a two-digit number was introduced. In this case, we need to multiply the first character by 10 and then sum the second character. For
		; example, if the user introduced 14, we need to store the number by multiplying 1*10 and summing 4 (after substracting 30h wherever needed)
twod:	MOV AX, 0
		MOV AL, vector_i[2]
		SUB AL, 30h
		MOV BX, 10
		MUL BX
		ADD AL, vector_i[3]
		SUB AL, 30h
		CMP AL, 0Fh										; If the result of the operation is less or equal than 15, then it jumps to 'convrt' where the program will continue
		JBE convrt										; Otherwise, the program goes to failure management

		; Deals with failures, which will happen if the user has not introduced any characters or if the number introduced was greater than 15
fail:	MOV AH, 9h
		LEA DX, message_error
		INT 21h
		JMP fin

		; Converts the number introduced (now stored in AX) to binary. As the number is less or equal than 15 it fits in 4 bits, and as 'vector' is initialized to "0000" we
		; fill each bit from the end to the start of 'vector' until any quotient is 0, in which case we have finished and the first bits must stay being 0.
convrt:	MOV DI, 3										; Initialization of DI, which will contain the index for 'vector' writings
		MOV BX, 2										; To convert any number to binary we have to divide by 2 in a loop until any quotient is 0
binary:	MOV DX, 0										; Reset of DX as it is going to change each time we perform a division
		DIV BX											; Division of DX:AX by 2, quotient is stored in AX and remainder in DX (the remainder will fit in 1 byte so we only need DL)
		MOV vector[DI], DL								; We fill 'vector' with the proper value
		DEC DI											; We decrement the index
		CMP AX, 0										; If the quotient (AX) is 0, we have finished, otherwise we repeat the loop
		JNE binary

		; The rest is just what we did in the previous exercise with no changes whatsoever
		
		; Saves to DX:BX the 4-bit input number
		MOV DX, WORD PTR vector[0]						; DH = vector[1], DL = vector[0]
		MOV BX, WORD PTR vector[2]						; BH = vector[3], BL = vector[2]
		
		; Multiplies the vector by the matrix
		call multiply_matrix
		
		; Moves the AX output of multiply_matrix to BX, so that it is processed by parity_fix
		MOV BX, AX
		
		; Performs modulo 2 computation
		call parity_fix
		
		; Prints the results
		call print
	
; PROGRAM END
fin:	MOV AX, 4C00H
		INT 21H
INICIO ENDP

; Subroutine that multiplies the 4-bit vector contained in DX:BX {DL, DH, BL, BH} by the 4x7 matrix contained in 'matrix'
; and saves the memory address of the result in DX:AX (segment:offset)
;
;
; There is a better solution for this problem without using DX:BX as parameters, allowing us to nest two loops:
;
; multiply_matrix proc
;			MOV DI, 0
;			MOV SI, 0
; column:	MOV BX, 0
; row:		MOV AL, vector[BX]
;			MUL matrix[BX][SI]
;			ADD result[DI], AX
;			INC BX
;			CMP BX, 4
;			JNE row
;			ADD SI, 4
;			INC DI
;			CMP DI, 7
;			JNE column
;			ret
multiply_matrix proc
		MOV DI, 0					; DI is going to be the index of the vector 'result' being processed
		MOV SI, 0					; SI is going to be the number of the column of 'matrix' being processed 
column:	MOV AL, DL					; AL = vector[0]
		MUL matrix[0][SI]			; AX = vector[0] * matrix[SI] (as it is a bit product, it doesn't matter what AH may contain, our information is in AL)
		ADD result[DI], AL			; result[DI] += AL
		MOV AL, DH					; AL = vector[1]
		MUL matrix[1][SI]			; AX = vector[1] * matrix[SI+1]
		ADD result[DI], AL			; result[DI] += AL
		MOV AL, BL					; AL = vector[2]
		MUL matrix[2][SI]			; AX = vector[2] * matrix[SI+2]
		ADD result[DI], AL			; result[DI] += AL
		MOV AL, BH					; AL = vector[3]
		MUL matrix[3][SI]			; AX = vector[3] * matrix[SI+3]
		ADD result[DI], AL			; result[DI] += AL (therefore, result[DI] now contains the scalar product vector*matrix[1] (first column of the matrix)
		ADD SI, 4					; In 'matrix' there are four rows, so we add 4 to SI to change to the next column
		INC DI						; 'result' is a vector, so we just increase DI by 1
		CMP DI, 7					; If DI is 7, it means we have generated our 7 desired bits, so...
		JNE column					; ... we don't repeat the loop again
		MOV DX, SEG result			; The memory address of 'result' must be saved to DX:AX, therefore we save its segment to DX and its offset to AX
		MOV AX, OFFSET result
		ret
multiply_matrix endp


; Subroutine that takes a vector of length 7 contained in the memory address with segment DS and offset BX and
; substitutes each of the last three values by '1' if it is odd or by '0' if it is even (calculates modulo 2 of each value).
; In the end, each byte will contain one bit
parity_fix proc
		MOV DI, 4					; DI is going to be the index of the vector, it is initialized to 4 so that it changes the last three values only
		MOV CL, 2					; CL is set to 2 to perform division (thus calculating modulo 2)
parity:	MOV AH, 0					; Initialization of AX to perform division, we assume that the number to be divided by 2 can be contained in an 8-bit register
		MOV AL, DS:[BX][DI]			; The number to be divided is located in memory address with segment DS, offset BX+DI
		DIV CL						; AX = AX / CL (integer division, the remainder is saved to AH)
		MOV DS:[BX][DI], AH			; Substitution of the value for its parity
		ADD DI, 1					; We increase the index to continue computing
		CMP DI, 7					; Once we reach the seventh position, we have finished computing the last three values, so...
		JNE parity					; ... we don't repeat the loop again
		ret
parity_fix endp

; Prints the 4-bit input vector
print_input proc
	; Prints "Input: " as it is being called with DX = input
	MOV AH, 9h
	INT 21h
	
	; Prints bits, starting from DI=0 and stopping after four prints (DI=4).
	MOV AH, 2h
	MOV DI, 0
i:  MOV DL, DS:[BX][DI]				; BX is the offset of the memory address in which that vector is contained
	ADD DL, 30h						; Necessary to generate ASCII character associated to the number
	INT 21h
	INC DI
	CMP DI, 4						; The loop stops after four iterations
	JNE i
	ret	
print_input endp

; Prints the 7-bit result in the desired format (P1-P2-D1-P3-D2-D3-D4)
print_output proc
	; Prints "Output: " as it is being called with DX = output
	MOV AH, 9h
	INT 21h
	
	; Prints the bit P1, contained in result[4]
	MOV AH, 2h
	MOV DL, DS:[BX][4]				; BX is the offset of the memory address in which result is contained
	ADD DL, 30h						; Necessary to generate ASCII character associated to the number
	INT 21h
	
	; Prints the bit P2, contained in result[5]
	MOV DL, DS:[BX][5]
	ADD DL, 30h
	INT 21h
	
	; Prints the bit D1, contained in result[0]
	MOV DL, DS:[BX][0]
	ADD DL, 30h
	INT 21h
	
	; Prints the bit P2, contained in result[6]
	MOV DL, DS:[BX][6]
	ADD DL, 30h
	INT 21h
	
	; Loop that prints the bits D2, D3 and D4, contained in result[1], result[2] and result[3]
	MOV DI, 1
o:	MOV DL, DS:[BX][DI]				; It starts in result[1] as DI=1
	ADD DL, 30h
	INT 21h
	INC DI
	CMP DI, 4						; Loop stops after three iterations, when DI=4
	JNE o
	ret
print_output endp

; Prints the structure '  | A' where A is the number contained in BL
print_num_sep proc
	; Prints '  | '
	MOV AH, 9h
	LEA DX, separator
	INT 21h
	
	; Prints the number contained in BL
	MOV AH, 2h
	MOV DL, BL
	ADD DL, 30h
	INT 21h
	ret
print_num_sep endp

; Prints the number contained in BL	
print_num proc
	MOV AH, 2h
	ADD DL, 30h
	INT 21h
	ret
print_num endp

; Prints the last three bits (D2-D3-D4) with separators, used for the rows 'Word' and 'P3'
fill proc
	MOV DI, 1						; Starts at vector[1], where D2 is stored
f:	MOV BL, vector[DI]
	call print_num_sep				; Prints '  | A' where A is vector[DI]
	INC DI
	CMP DI, 4						; Loop stops after three iterations
	JNE f
	ret
fill endp

; Prints the 4-bit input vector, the 7-bit output result properly ordered and the table describing the computational process
print proc
	; Prints input
	LEA DX, input
	LEA BX, vector
	call print_input
	
	; Prints output
	LEA DX, output
	LEA BX, result
	call print_output

	; Prints the third line, "Computation:"
	MOV AH, 9h	
	LEA DX, computation
	INT 21h
	
	; Prints the fourth line, contained in row1 (headers of the table)
	LEA DX, row1
	INT 21h 
	
	; Prints the start of the fifth line, contained in row21
	LEA DX, row21
	INT 21h
	
	; Prints the value associated to row "Word" and column "D1"
	MOV BL, vector[0]
	call print_num_sep
	
	; Prints the continuation of this line, contained in row22
	MOV AH, 9h
	LEA DX, row22
	INT 21h
	
	; Prints the rest of the row, the last three values of 'vector' (D2-D3-D4)
	call fill

	; Prints the start of the sixth line, contained in row3
	MOV AH, 9h
	LEA DX, row3
	INT 21h
	
	; Prints the value associated to row "P1" and column "P1"
	MOV DL, result[4]
	call print_num
	
	; Prints separators and empty spaces in row "P1" and column "P2"
	MOV AH, 9h
	LEA DX, separator
	INT 21h
	LEA DX, empty
	INT 21h
	
	; Prints the value associated to row "P1" and column "D1"
	MOV DL, vector[0]
	call print_num
	
	; Prints separators and empty spaces in row "P1" and column "P4"
	MOV AH, 9h
	LEA DX, separator
	INT 21h
	LEA DX, empty
	INT 21h
	
	; Prints the value associated to row "P1" and column "D2"
	MOV DL, vector[1]
	call print_num
	
	; Prints separators and empty spaces in row "P1" and column "D3"
	MOV AH, 9h
	LEA DX, separator
	INT 21h
	LEA DX, empty
	INT 21h
	
	; Prints the value associated to row "P1" and column "D4"
	MOV DL, vector[2]
	call print_num
	
	; Prints the start of the seventh line, contained in row4
	MOV AH, 9h
	LEA DX, row4
	INT 21h
	
	; Prints separators and empty spaces in row "P2" and column "P1"
	LEA DX, empty
	INT 21h
	
	; Prints the value associated to row "P2" and column "P2"
	MOV DL, result[5]
	call print_num
	
	; Prints the value associated to row "P2" and column "D1"
	MOV BL, vector[0]
	call print_num_sep
	
	; Prints separators and empty spaces in row "P2" and columns "P4" and "D2"
	MOV AH, 9h
	LEA DX, separator
	INT 21h
	LEA DX, empty
	INT 21h
	LEA DX, empty
	INT 21h
	
	; Prints the value associated to row "P2" and column "D3"
	MOV DL, vector[2]
	call print_num
	
	; Prints the value associated to row "P2" and column "D4"
	MOV BL, vector[3]
	call print_num_sep
	
	; Prints the start of the eighth line, contained in row5
	MOV AH, 9h
	LEA DX, row5
	INT 21h
	
	; Prints empty spaces in row "P4" and columns "P1", "P2" and "D1"
	LEA DX, empty
	INT 21h
	LEA DX, empty
	INT 21h
	LEA DX, empty
	INT 21h
	
	; Prints the value associated to row "P4" and column "P4"
	MOV DL, result[6]
	call print_num
	
	; Prints the rest of the row, the last three values of 'vector' (D2-D3-D4)
	call fill
		
	ret
print endp

; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO 