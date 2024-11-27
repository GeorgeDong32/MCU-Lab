        ORG		0000H          ; 设置程序起始地址为0000H
        LJMP	START         ; 跳转到START标签
        ORG		0023H          ; 设置中断向量地址为0023H
        LJMP	RECE          ; 跳转到RECE标签
        ORG 	0030H          ; 设置程序起始地址为0030H
START:	MOV		SP, #60H      ; 初始化堆栈指针
        MOV		TCON, #00H    ; 清除定时器控制寄存器
        SETB	EA            ; 使能全局中断
        SETB	ES            ; 使能串行中断
        MOV  	TMOD, #20H    ; 设置定时器1为8位自动重装模式
        MOV  	TH1, #0F4H    ; 设置定时器1高位初值
        MOV 	TL1, #0F4H    ; 设置定时器1低位初值
        MOV 	PCON, #00H    ; 清除电源控制寄存器
        SETB 	TR1           ; 启动定时器1
        MOV  	SCON, #50H    ; 设置串行控制寄存器
        MOV		DPTR, #TABLE  ; 初始化数据指针
        MOV		R0, #17       ; 初始化寄存器R0
        MOV		R1, #17       ; 初始化寄存器R1
        MOV		R2, #17       ; 初始化寄存器R2
        MOV		R5, #0        ; 初始化寄存器R5
DISP:	MOV		R3, #0EDH    ; 初始化寄存器R3
        MOV		A, R0        ; 将R0的值移动到累加器A
        MOVC	A, @A+DPTR   ; 从TABLE中读取数据到A
        MOV		P0, A        ; 将A的值输出到P0端口
        MOV		P1, R3       ; 将R3的值输出到P1端口
        DEC 	R3           ; R3减1
        LCALL	DELAY0       ; 调用延时子程序
        MOV		A, R1        ; 将R1的值移动到累加器A
        MOVC	A, @A+DPTR   ; 从TABLE中读取数据到A
        MOV		P0, A        ; 将A的值输出到P0端口
        MOV		P1, R3       ; 将R3的值输出到P1端口
        DEC		R3           ; R3减1
        LCALL	DELAY0       ; 调用延时子程序
        MOV		A, R2        ; 将R2的值移动到累加器A
        MOVC	A, @A+DPTR   ; 从TABLE中读取数据到A
        MOV		P0, A        ; 将A的值输出到P0端口
        MOV		P1, R3       ; 将R3的值输出到P1端口
        LCALL	DELAY0       ; 调用延时子程序
        SJMP 	DISP         ; 无条件跳转到DISP标签
DELAY0:	MOV 	R6, #4       ; 初始化延时计数器R6
DEL1:	MOV 	R7, #229     ; 初始化延时计数器R7
DEL2:	DJNZ 	R7, DEL2    ; R7减1，若不为0则跳转到DEL2
        DJNZ 	R6, DEL1    ; R6减1，若不为0则跳转到DEL1
        RET               ; 返回
TABLE:	DB 0C0H, 0F9H, 0A4H, 0B0H, 99H, 92H, 82H, 0F8H
        DB 80H, 90H, 88H, 83H, 0C6H, 0A1H, 86H, 8EH, 0FFH, 7FH ; 数据表
RECE:	PUSH	ACC         ; 保存累加器内容
        CLR		RI          ; 清除接收中断标志
        MOV		R0, SBUF    ; 将接收缓冲区内容移动到R0
        LCALL	DELAY0      ; 调用延时子程序
        JNB		RI, $       ; 等待接收中断标志置位
        CLR		RI          ; 清除接收中断标志
        MOV		R1, SBUF    ; 将接收缓冲区内容移动到R1
        LCALL	DELAY0      ; 调用延时子程序
        JNB		RI, $       ; 等待接收中断标志置位
        CLR		RI          ; 清除接收中断标志
        MOV		R2, SBUF    ; 将接收缓冲区内容移动到R2
        POP		ACC         ; 恢复累加器内容
        RETI              ; 返回中断
        END               ; 程序结束
