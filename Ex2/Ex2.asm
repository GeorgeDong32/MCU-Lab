        ORG     0000H
        LJMP    START
        ORG     0003H           ; 外部中断0向量地址
        LJMP    INT0_ISR
        ORG     0013H           ; 外部中断1向量地址
        LJMP    INT1_ISR
        ORG     0030H
START:  MOV     SP, #60H        
        MOV     TCON, #00H      ; 设置外部中断0和1均为电平触发
        SETB    EA              ; 开启总中断
        SETB    EX0             ; 使能外部中断0
        SETB    EX1             ; 使能外部中断1
        SETB    PX1             ; 设置中断1为高优先级
        CLR     PX0             ; 设置中断0为低优先级
        MOV     DPTR, #TABLE    ; DPTR指向显示码表
        MOV     PSW, #00H       ; 使用寄存器组0
MAIN:   
        MOV     R5, #1          ; R5存储当前要显示的位置(1-6)
        MOV     R3, #0E7H      
DISP0:  
        INC     R3              ; 位选值+1（0E8H-0EDH）
        MOV     A, R5           ; 是目标位置则显示对应数字
SHOW:   
        MOVC    A, @A+DPTR      
        MOV     P0, A           ; 输出段选码
        MOV     P1, R3          ; 输出位选码
        ACALL   DELAY           ; 延时    
        INC     R5              ; 切换到下一个位置
        CJNE    R5, #7, DISP0   ; 跳转到DISP0，继续显示下一个数码管
        SJMP    MAIN
INT0_ISR:
        PUSH    ACC             ; 保护ACC
        PUSH    PSW             ; 保护PSW
        MOV     PSW, #10H       ; 切换到寄存器组1 (RS1=0, RS0=1)
        MOV     R2, #0          ; 设定前两位显示为0
        ACALL   DISPLAY_ISR     ; 调用通用显示子程序
        POP     PSW             ; 恢复PSW
        POP     ACC             ; 恢复ACC
		DEC     R3				; 切换到上一个位置
        RETI
INT1_ISR:
        PUSH    ACC             ; 保护ACC
        PUSH    PSW             ; 保护PSW
        MOV     PSW, #18H       ; 切换到寄存器组2 (RS1=1, RS0=0)
        MOV     R2, #1          ; 设定前两位显示为1
        ACALL   DISPLAY_ISR     ; 调用通用显示子程序
        POP     PSW             ; 恢复PSW
        POP     ACC             ; 恢复ACC
		DEC	 	R3              	; 切换到上一个位置
        RETI
DISPLAY_ISR:
        MOV     R4, #100
DISPLAY_ON:
        MOV     R3, #0E7H       ; 位选初始值
        INC     R3              ; 位选值+1
        MOV     A, R2           ; 根据R2显示0或1        
        MOVC    A, @A+DPTR
        MOV     P0, A           ; 输出段选码
        MOV     P1, R3          ; 输出位选码
        ACALL   DELAY_1
        INC     R3              ; 位选值+1
        MOV     A, R2           ; 根据R2显示0或1
        MOVC    A, @A+DPTR
        MOV     P0, A           ; 输出段选码
        MOV     P1, R3          ; 输出位选码
        ACALL   DELAY_1
        DJNZ    R4, DISPLAY_ON
NEXT_ISR:
        MOV     A, #16   
DISPLAY_OFF:
        MOV     R3, #0E7H
        INC     R3
        MOV     A, #16          ; 所有位都显示空码
        MOVC    A, @A+DPTR
        MOV     P0, A
        MOV     P1, R3
        ACALL   DELAY
        RET

; 延时子程序 (0.4s)
DELAY:  MOV     R6, #200        ; 外层循环200次
DEL1:   MOV     R7, #4        ; 中层循环4次
DEL2:   MOV     R4, #229        ; 内层循环229次
DEL3:   DJNZ    R4, DEL3        ; 内层循环
        DJNZ    R7, DEL2        ; 中层循环
        DJNZ    R6, DEL1        ; 外层循环
        RET
DELAY_1:  MOV     R6, #4        ; 外层循环200次
DEL_1:   MOV     R7, #229        ; 中层循环4次
DEL_2:  DJNZ    R7, DEL_2        ; 中层循环
        DJNZ    R6, DEL_1        ; 外层循环
        RET
TABLE:  DB 0C0H, 0F9H, 0A4H, 0B0H, 99H, 92H, 82H, 0F8H  ; 0-7的显示码
        DB 80H, 90H, 88H, 83H, 0C6H, 0A1H, 86H, 8EH      ; 8-F的显示码
        DB 0FFH                                           ; 空码(全灭)

        END