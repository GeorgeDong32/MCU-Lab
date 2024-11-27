        ORG     0000H
        LJMP    START
        ORG     0023H
        LJMP    RECE
        ORG     0030H
START:  MOV     SP,#60H
        MOV     TCON,#00H
        SETB    EA
        SETB    ES
        MOV     TMOD,#20H
        MOV     TH1,#0F4H
        MOV     TL1,#0F4H
        MOV     PCON,#00H
        MOV     R2,#16
        MOV     R4,#16
        MOV     R5,#16
        MOV     R3,#0EDH
        SETB    TR1
        MOV     SCON,#50H
        MOV     DPTR,#TABLE
DISP:   ACALL   DISPLAY
        SJMP    DISP
DISPLAY:
        MOV     R3,#0EAH
        INC     R3
        MOV     A,R2
        MOVC    A,@A+DPTR
        MOV     P0,A
        MOV     P1,R3
        ACALL   DELAY
        INC     R3
        MOV     A,R4
        SUBB    A,#10
        MOVC    A,@A+DPTR
        MOV     P0,A
        MOV     P1,R3
        ACALL   DELAY
        INC     R3
        MOV     A,R5
        MOVC    A,@A+DPTR
        MOV     P0,A
        MOV     P1,R3
        ACALL   DELAY
        RET

RECE:   PUSH    ACC
        JNB     RI,$
        CLR     RI
        MOV     A,SBUF
        MOV     R2,A
        ACALL   DELAY
        JNB     RI,$
        CLR     RI
        MOV     A,SBUF
        MOV     R4,A
        ACALL   DELAY
        JNB     RI,$
        CLR     RI
        MOV     A,SBUF
        MOV     R5,A
        ACALL   DELAY
        POP     ACC
        RETI

TABLE:  DB      0C0H,0F9H,0A4H,0B0H,99H,92H,82H,0F8H
        DB      80H,90H,88H,83H,0C6H,0A1H,86H,8EH,7FH

DELAY:  MOV     R6,#4
DEL1:   MOV     R7,#229
DEL2:   DJNZ    R7,DEL2
        DJNZ    R6,DEL1
        RET
        END


