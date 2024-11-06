		ORG 	0000H
		LJMP 	START
		ORG 	0030H
START:	MOV 	P0, #0FFH
		MOV 	P1, #0EEH  
		MOV 	A, P1
		ANL 	A, #0C0H
		RL 		A
		RL 		A
		MOV   DPTR, #TAB
		MOVC  A, @A+DPTR
		ACALL	DELAY
		JMP    @A+DPTR
TAB:	DB     	PRG0-TAB
		DB     	PRG1-TAB
		DB     	PRG2-TAB
		DB     	PRG3-TAB
PRG0:	MOV 	P0, #00H
		ACALL	DELAY
		LJMP	START
PRG1:	MOV 	P0, #55H
		ACALL	DELAY
		LJMP	START
PRG2:	MOV 	P0, #0AAH
		ACALL	DELAY
		LJMP	START
PRG3:	MOV 	P0, #0FFH
		ACALL	DELAY
		LJMP	START
DELAY: 	MOV    R1, #5 
DEL1:  	MOV    R2, #200
DEL2:  	MOV    R3, #229
DEL3:  	DJNZ   R3, DEL3
       	DJNZ   R2, DEL2
       	DJNZ   R1, DEL1
        RET
		END
