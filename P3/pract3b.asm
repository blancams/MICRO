
PRAC3A SEGMENT BYTE PUBLIC 'CODE'
PUBLIC  _computeMatches, _computeSemiMatches
ASSUME CS: PRAC3A
_computeMatches PROC FAR
PUSH BP
MOV BP, SP
PUSH BX DX DS CX SI DI; Save registers

LES BX, [BP + 6] 
MOV AX, ES
MOV DS, AX
MOV CX, BX
LES BX, [BP + 10]
MOV BP, CX

MOV DI, 0
MOV SI, 0
it: 	MOV DX, DS:[BP][SI]
		MOV CX, ES:[BX][SI]
		CMP DL, CL
		JE counter
ll:		INC SI
		CMP SI, 4
		JE bye
		JNE it
		
counter:CMP SI, 4
		JE bye
		INC DI
		JMP ll

bye:	MOV AX, DI
		POP DI SI CX DS DX BX BP
		RET
_computeMatches ENDP

_computeSemiMatches PROC FAR
PUSH BP
MOV BP, SP
PUSH BX DX DS CX SI DI; Save registers

LES BX, [BP + 6] 
MOV AX, ES
MOV DS, AX
MOV CX, BX
LES BX, [BP + 10]
MOV BP, CX

MOV AX, 0
MOV SI, 4
att:	MOV DI, 0
		CMP SI, 0
		JE b
		DEC SI
		
h:		MOV CX, DS:[BP][SI]
		MOV DX, ES:[BX][DI]
		CMP CL, DL
		JE cn
llamada:INC DI
		CMP DI, 4
		JNE h
		JMP att
		
cn:		CMP SI, DI
		JE llamada
		INC AX
		CMP SI, 4
		JE b
		JMP llamada

b:		POP DI SI CX DS DX BX BP
		RET
_computeSemiMatches ENDP
PRAC3A ENDS ; End of Segment
END