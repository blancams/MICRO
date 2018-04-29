; DATA SEGMENT DEFINITION
DATOS SEGMENT
	string db 62 dup (?)
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
	MOV AX, DATOS
	MOV DS, AX
	MOV SP, 64 ; LOAD THE STACK POINTER WITH THE HIGHEST VALUE

	mov cx, 0 ;flag that indicates codification = 0; decodification = 1
while_loop:
	mov ah, 0Ah
	mov dx, offset string
	mov string[0], 60
	int 21h
	
	cmp cx, 0
	jne decod
	mov ah, 12h
	jmp keep
decod:
	mov cx, 0
	mov ah, 13h

keep:
	add dx, 2
	mov bh, 0
	mov bl, string[1]
	cmp bl, 4
	je quit
	cmp bl, 3
	je dec_cod
false_alarm:
	mov string[bx + 2], 24h
	int 55h	
	jmp while_loop
	
dec_cod:
	cmp string[2], 64h
	jne false_alarm
	cmp string[3], 65h
	jne false_alarm
	cmp string[4], 63h
	jne false_alarm
	mov cx, 1
	jmp while_loop	
	
quit:
	cmp string[2], 71h
	jne false_alarm
	cmp string[3], 75h
	jne false_alarm
	cmp string[4], 69h
	jne false_alarm
	cmp string[5], 74h
	jne false_alarm
	
end_while:
	; PROGRAM END
	MOV AX, 4C00H
	INT 21H
INICIO ENDP

; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO 