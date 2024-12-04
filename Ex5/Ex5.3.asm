        ORG		0000H
        LJMP	START          ; 跳转到程序开始位置
        ORG		0050H
START:	MOV		SP,#60H       ; 初始化堆栈指针
        MOV		R5, #16       ; 将16赋值给R5
        MOV		P1, #0EEH     ; 将0EEH赋值给P1
        MOV		40H, #00H     ; 将00H赋值给内存地址40H
        MOV		R2, #0        ; 将0赋值给R2
MAIN: 	MOV		A, R5         ; 将R5的值赋给累加器A
        MOV		DPTR, #TAB3   ; 将TAB3的地址赋给DPTR
        MOVC	A, @A+DPTR    ; 从TAB3中读取数据到A
        MOV		DPTR, #TAB2   ; 将TAB2的地址赋给DPTR
        MOVC	A, @A+DPTR    ; 从TAB2中读取数据到A
        MOV		P0, A         ; 将A的值赋给P0
        LCALL	DELAY         ; 调用延时子程序
        ACALL	JUDGE         ; 调用判断子程序
        JZ		MAIN         ; 如果判断结果为零，跳转到MAIN
        LCALL	DELAY         ; 调用延时子程序
        ACALL	JUDGE         ; 调用判断子程序
        JZ		MAIN         ; 如果判断结果为零，跳转到MAIN
        ACALL	KEY           ; 调用按键处理子程序
        ACALL	NUM           ; 调用数字处理子程序
        DEC 	P1            ; P1减1
        INC		R2            ; R2加1
        MOV		A, R2         ; 将R2的值赋给A
        CLR		C             ; 清除进位标志
        SUBB	A, #7         ; A减7
        JNC		RST           ; 如果没有借位，跳转到RST
        CLR		A             ; 清除A
        LJMP	MAIN          ; 跳转到MAIN

RST:	MOV		P1, #0EDH     ; 将0EDH赋值给P1
        MOV		R2, #1        ; 将1赋值给R2
        LJMP	MAIN          ; 跳转到MAIN

JUDGE:	MOV		P2, #0FH      ; 将0FH赋值给P2
        MOV		A, P2         ; 将P2的值赋给A
        CLR		C             ; 清除进位标志
        SUBB	A, #0FH       ; A减0FH
        RET                ; 返回

KEY:	PUSH	ACC           ; 保存累加器的值
K_LINE: MOV 	P2, #0FH      ; 将0FH赋值给P2
        MOV 	A, P2         ; 将P2的值赋给A
        MOV		R1, A         ; 将A的值赋给R1
K_ROW:	MOV 	P2, #0F0H     ; 将0F0H赋值给P2
        MOV 	A, P2         ; 将P2的值赋给A
        MOV		R0, A         ; 将A的值赋给R0
K_VALUE:MOV 	A, R1         ; 将R1的值赋给A
        ANL 	A, #0FH       ; A与0FH按位与
        MOV 	R1, A         ; 将A的值赋给R1
        MOV 	A, R0         ; 将R0的值赋给A
        ANL 	A, #0F0H      ; A与0F0H按位与
        ORL 	A, R1         ; A与R1按位或
        MOV 	40H, A        ; 将A的值赋给内存地址40H
        POP		ACC           ; 恢复累加器的值
        RET                ; 返回

NUM:	PUSH	DPL           ; 保存DPTR低字节
        PUSH	DPH           ; 保存DPTR高字节
        PUSH	ACC           ; 保存累加器的值
        MOV 	DPTR, #TAB1   ; 将TAB1的地址赋给DPTR
        MOV		R5, #0FFH    ; 将0FFH赋值给R5
NUM0: 	INC		R5           ; R5加1
        MOV 	A, R5         ; 将R5的值赋给A
        MOVC 	A, @A+DPTR    ; 从TAB1中读取数据到A
        CLR		C             ; 清除进位标志
        SUBB	A, 40H        ; A减去内存地址40H的值
        JNZ		NUM0         ; 如果结果不为零，跳转到NUM0
NUM1: 	LCALL 	DELAY        ; 调用延时子程序
        MOV 	P2, #0FH      ; 将0FH赋值给P2
        MOV 	A, P2         ; 将P2的值赋给A
        CJNE 	A, #0FH, NUM1 ; 如果A不等于0FH，跳转到NUM1
        POP		ACC           ; 恢复累加器的值
        POP		DPH           ; 恢复DPTR高字节
        POP		DPL           ; 恢复DPTR低字节
        RET                ; 返回

DELAY: 	MOV 	R7, #20       ; 将20赋值给R7
DEL1: 	MOV 	R6, #229      ; 将229赋值给R6
DEL2: 	DJNZ 	R6, DEL2      ; R6减1，如果不为零，跳转到DEL2
        DJNZ 	R7, DEL1      ; R7减1，如果不为零，跳转到DEL1
        RET                ; 返回
TAB1: 	DB 	0EEH, 0E7H, 0D7H, 0B7H, 0EBH, 0DBH, 0BBH, 0EDH, 0DDH, 0BDH, 77H, 7BH, 7EH, 7DH, 0DEH, 0BEH
TAB2: 	DB 		0C0H, 0F9H, 0A4H, 0B0H, 99H, 92H, 82H, 0F8H, 80H, 90H, 88H, 83H, 0C6H, 0A1H, 86H, 8EH, 0FFH
TAB3:	DB		0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 5, 5, 5, 5, 5, 5, 16
        END
