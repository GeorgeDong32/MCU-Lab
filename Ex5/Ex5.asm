            ORG	    0000H          ; 设置程序起始地址为0000H
            LJMP	START          ; 跳转到START标签
            ORG	    0050H          ; 设置程序起始地址为0050H
START:		MOV	    SP,#60H        ; 初始化堆栈指针
            MOV	    R5, #16        ; 将16赋值给寄存器R5
            MOV	    P1, #0E8H      ; 将0E8H赋值给P1端口
            MOV	    40H, #00H     ; 将00H赋值给内存地址40H
MAIN: 		MOV	    A, R5         ; 将R5的值赋给累加器A
            MOV	    DPTR, #TAB2   ; 将TAB2的地址赋给DPTR
            MOVC	A, @A+DPTR    ; 从代码存储器中读取数据到A
            MOV	    P0, A         ; 将A的值输出到P0端口
            LCALL	DELAY         ; 调用延时子程序
            ACALL	JUDGE         ; 调用判断子程序
            JZ		MAIN         ; 如果零标志位为0，跳转到MAIN
            LCALL	DELAY         ; 调用延时子程序
            ACALL	JUDGE         ; 调用判断子程序
            JZ		MAIN         ; 如果零标志位为0，跳转到MAIN
            ACALL	KEY           ; 调用按键子程序
            ACALL	NUM           ; 调用数字处理子程序
            LJMP	MAIN          ; 无条件跳转到MAIN

JUDGE:		MOV	    P2, #0FH      ; 将0FH赋值给P2端口
            MOV	    A, P2         ; 将P2的值赋给累加器A
            CLR		C            ; 清除进位标志位
            SUBB	A, #0FH       ; A减去0FH
            RET                 ; 返回

KEY:		PUSH	ACC          ; 保存累加器A的值
K_LINE: 	MOV 	P2, #0FH      ; 将0FH赋值给P2端口
            MOV 	A, P2         ; 将P2的值赋给累加器A
            MOV	    R1, A         ; 将A的值赋给R1
K_ROW:		MOV 	P2, #0F0H     ; 将0F0H赋值给P2端口
            MOV 	A, P2         ; 将P2的值赋给累加器A
            MOV	    R0, A         ; 将A的值赋给R0
K_VALUE:	MOV 	A, R1         ; 将R1的值赋给累加器A
            ANL 	A, #0FH       ; A与0FH进行逻辑与操作
            MOV 	R1, A         ; 将结果赋给R1
            MOV 	A, R0         ; 将R0的值赋给累加器A
            ANL 	A, #0F0H      ; A与0F0H进行逻辑与操作
            ORL 	A, R1         ; A与R1进行逻辑或操作
            MOV 	40H, A        ; 将结果存储到内存地址40H
            POP		ACC          ; 恢复累加器A的值
            RET                 ; 返回

NUM:		PUSH	DPL          ; 保存DPTR低字节
            PUSH	DPH          ; 保存DPTR高字节
            PUSH	ACC          ; 保存累加器A的值
            MOV 	DPTR, #TAB1   ; 将TAB1的地址赋给DPTR
            MOV	    R5, #0FFH     ; 将0FFH赋值给R5
NUM0: 		INC		R5          ; R5加1
            MOV 	A, R5         ; 将R5的值赋给累加器A
            MOVC 	A, @A+DPTR    ; 从代码存储器中读取数据到A
            CLR		C            ; 清除进位标志位
            SUBB	A, 40H        ; A减去40H
            JNZ		NUM0         ; 如果结果不为0，跳转到NUM0
NUM1: 		LCALL 	DELAY       ; 调用延时子程序
            MOV 	P2, #0FH      ; 将0FH赋值给P2端口
            MOV 	A, P2         ; 将P2的值赋给累加器A
            CJNE 	A, #0FH, NUM1 ; 如果A不等于0FH，跳转到NUM1
            POP		ACC          ; 恢复累加器A的值
            POP		DPH          ; 恢复DPTR高字节
            POP		DPL          ; 恢复DPTR低字节
            RET                 ; 返回

DELAY: 		MOV 	R7, #20       ; 将20赋值给R7
DEL1: 		MOV 	R6, #229      ; 将229赋值给R6
DEL2: 		DJNZ 	R6, DEL2      ; R6减1，如果不为0，跳转到DEL2
            DJNZ 	R7, DEL1      ; R7减1，如果不为0，跳转到DEL1
            RET                 ; 返回
TAB1: 		DB 		0EEH, 0E7H, 0D7H, 0B7H, 0EBH, 0DBH, 0BBH, 0EDH, 0DDH, 0BDH, 77H, 7BH, 7EH, 7DH, 0DEH, 0BEH ; 数据表1
TAB2: 		DB 		0C0H, 0F9H, 0A4H, 0B0H, 99H, 92H, 82H, 0F8H, 80H, 90H, 88H, 83H, 0C6H, 0A1H, 86H, 8EH, 0FFH ; 数据表2
            END                 ; 程序结束
