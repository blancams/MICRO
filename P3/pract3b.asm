;**************************************************************************
; MBS 2018 - PRACTICE 3 - EXERCISE B
; Team number:
; 4
;
; Authors names:
; - Blanca Martin Selgas
; - Fernando Villar Gomez
;**************************************************************************

; Declares computeMatches and computeSemiMatches and defines code segment
PRAC3B SEGMENT BYTE PUBLIC 'CODE'
PUBLIC  _computeMatches, _computeSemiMatches
ASSUME CS: PRAC3B

; Coding of computeMatches, specifying FAR to use LARGE model
_computeMatches PROC FAR
		PUSH BP
		MOV BP, SP
		PUSH BX DX DS CX SI ES 			; Save registers

		LDS CX, [BP + 6]   				; We save the offset of secretNum in CX, and the segment in DS
		LES BX, [BP + 10]  				; The offset of the array attemptDigits is saved in BX, and the segment in ES
		MOV BP, CX		  				; The offset of secretNum is now in BP

		MOV AX, 0          				; Initialization of AX, that will represent the number of matches
		MOV SI, 0		   				; Initialization of SI
it: 	MOV DX, DS:[BP][SI]				; We save in DX secretNum[SI]
		MOV CX, ES:[BX][SI]				; We save in CX attemptDigits[SI]
		CMP DL, CL						; As we are working with char variables, we only need to compare one byte
		JNE cnt							; if they aren't equal, we jump to avoid incrementing the counter DI
		INC AX							; if they are equal, we increment AX in one
cnt:	INC SI							; We continue incrementing SI
		CMP SI, 4						; If SI is equal to 4, that means the arrays have been computed
		JE bye							; and we jump to the final block of the code
		JMP it							; if SI is not equal to 4, we continue to compare the elements of the arrays
										; Program ends when SI = 4
bye:	POP ES SI CX DS DX BX BP		; Recovers registers
RET
_computeMatches ENDP


; Coding of computeSemiMatches, specifying FAR to use LARGE model
_computeSemiMatches PROC FAR
		PUSH BP
		MOV BP, SP
		PUSH BX DX DS CX SI DI ES		; Save registers

		LDS CX, [BP + 6] 				; Save in CX the offset of secretNum, and in DS the segment 
		LES BX, [BP + 10]   			; Save in BX the offset of attemptDigits, and in ES the segment 
		MOV BP, CX						; Now the offset of secretNum is in BP

		MOV AX, 0    					; Initialization of AX
		MOV SI, 4    					; Initialization of SI
att:	MOV DI, 0             			; Initialization of DI
		CMP SI, 0             			; If SI is equal to 0 we jump to the final block of code	
		JE b				  			; If SI is not equal to 0, we keep computing
		DEC SI				 			; Decrement of SI
h:		MOV CX, DS:[BP][SI]   			; Save in CX secretNum[SI]
		MOV DX, ES:[BX][DI]	  			; Save in DX attemptDigits[DI]
		CMP CL, DL			  			; As we are working with chars, we only compare the last 8 bits
		JNE cn				  			; If they are not equal, we jump and keep computing
		CMP SI, DI			  			; If they are equal, we compare the indexes, that is, SI and DI
		JE cn				  			; If SI and DI are equal, that means it is a match, not a semi-match, so we keep computing
		INC AX				  			; If they are not equal, we increment the number of semi-matches (AX) in one
cn:		INC DI				  			; We increment DI in one to keep going through attemptDigits
		CMP DI, 4			  			; We compare DI with 4, 
		JNE h				  			; and if they are not equal, we keep comparing with secretNum[SI]
		JMP att               			; If they are equal, we jump and advance to compare attemptDigits with secretNum[SI-1]
										; Program ends when SI = 0
b:		POP ES DI SI CX DS DX BX BP  	; Recovers registers
RET
_computeSemiMatches ENDP
PRAC3B ENDS ; End of Segment
END