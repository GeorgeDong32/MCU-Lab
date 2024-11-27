        ORG		0000H          ; 设置起始地址为0000H
        LJMP	START          ; 长跳转到START
        ORG		0003H          ; 设置起始地址为0003H
        LJMP	IN0            ; 长跳转到IN0
        ORG 	0030H          ; 设置起始地址为0030H
START:	MOV		SP, #60H       ; 初始化堆栈指针
        MOV		TCON, #05H     ; 配置定时器控制
        SETB	EA             ; 使能全局中断
        SETB	EX0            ; 使能外部中断0
        SETB	PX0            ; 设置外部中断0优先级
        MOV  	TMOD, #25H     ; 设置定时器0和定时器1模式
        MOV  	TH0, #000H     ; 初始化定时器0高字节
        MOV 	TL0, #000H     ; 初始化定时器0低字节
        MOV  	TH1, #0F4H     ; 初始化定时器1高字节
        MOV 	TL1, #0F4H     ; 初始化定时器1低字节
        MOV 	PCON, #00H    ; 初始化电源控制寄存器
        SETB 	TR0          ; 启动定时器0
        SETB 	TR1          ; 启动定时器1
        MOV  	SCON, #50H   ; 设置串口控制寄存器
        MOV		DPTR, #TABLE  ; 初始化数据指针
        MOV		P1, #0EDH    ; 初始化端口1
DISP:	MOV		A, TL0        ; 将定时器0低字节值移动到累加器
        MOVC	A, @A+DPTR   ; 从查找表中获取数据
        MOV		P0, A       ; 将数据输出到端口0
        LCALL	DELAY0      ; 调用延时子程序
        MOV		A, TL0      ; 将定时器0低字节值移动到累加器
        SUBB	A, #15      ; 累加器减去15
        JC		DISP       ; 如果有借位则跳转到DISP
        CLR		TR0        ; 停止定时器0
        MOV  	TH0, #000H  ; 重置定时器0高字节
        MOV 	TL0, #000H  ; 重置定时器0低字节
        SETB	TR0        ; 启动定时器0
        SJMP 	DISP       ; 无条件跳转到DISP
DELAY0:	MOV 	R6, #4       ; 初始化R6为4
DEL1:	MOV 	R7, #229     ; 初始化R7为229
DEL2:	DJNZ 	R7, DEL2    ; R7减1，如果不为0则跳转到DEL2
        DJNZ 	R6, DEL1    ; R6减1，如果不为0则跳转到DEL1
        RET              ; 返回
DELAY1: MOV 	R5, #20      ; 初始化R5为20
DEL3: 	MOV 	R4, #229     ; 初始化R4为229
DEL4: 	DJNZ 	R4, DEL4    ; R4减1，如果不为0则跳转到DEL4
        DJNZ 	R5, DEL3    ; R5减1，如果不为0则跳转到DEL3
        RET              ; 返回
TABLE:	DB 0C0H, 0F9H, 0A4H, 0B0H, 99H, 92H, 82H, 0F8H ; 查找表数据
        DB 80H, 90H, 88H, 83H, 0C6H, 0A1H, 86H, 8EH, 0FFH ; 查找表数据
IN0:	PUSH 	ACC         ; 保存累加器内容
        MOV		A, TL0      ; 将定时器0低字节值移动到累加器
        ANL 	A, #01H     ; 累加器与1进行与操作
        JZ		SETONE     ; 如果结果为0则跳转到SETONE
        SJMP	SETTWO     ; 否则跳转到SETTWO
CONT0:	MOV  	A, R0       ; 将R0的值移动到累加器
        MOV  	SBUF, A     ; 将累加器的值发送到串口缓冲区
        JNB  	TI, $       ; 等待发送完成
        CLR  	TI          ; 清除发送中断标志
        LCALL	DELAY1      ; 调用延时子程序
        MOV		A, R1       ; 将R1的值移动到累加器
        MOV  	SBUF, A     ; 将累加器的值发送到串口缓冲区
        JNB  	TI, $       ; 等待发送完成
        CLR  	TI          ; 清除发送中断标志
        LCALL	DELAY1      ; 调用延时子程序
        MOV  	A, R2       ; 将R2的值移动到累加器
        MOV  	SBUF, A     ; 将累加器的值发送到串口缓冲区
        JNB  	TI, $       ; 等待发送完成
        CLR  	TI          ; 清除发送中断标志
WAIT0: 	LCALL	DELAY1      ; 调用延时子程序
        JNB		P3.2, WAIT0 ; 等待P3.2引脚变为低电平
        CLR		IE0        ; 清除外部中断0标志
        POP 	ACC         ; 恢复累加器内容
        RETI              ; 返回中断
SETONE:	MOV		R0, #01H    ; 将1赋值给R0
        MOV		R1, #02H    ; 将2赋值给R1
        MOV		R2, #01H    ; 将1赋值给R2
        SJMP 	CONT0       ; 跳转到CONT0
SETTWO:	MOV		R0, #01H    ; 将1赋值给R0
        MOV		R1, #01H    ; 将1赋值给R1
        MOV		R2, #05H    ; 将5赋值给R2
        SJMP 	CONT0       ; 跳转到CONT0
        END              ; 程序结束
