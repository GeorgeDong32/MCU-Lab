        ORG	0000H          ; 设置程序起始地址为0000H
		LJMP	START       ; 跳转到START标签处执行
		ORG	0003H          ; 设置中断0的入口地址为0003H
		LJMP	IN0         ; 跳转到IN0标签处执行
		ORG	0013H          ; 设置中断1的入口地址为0013H
		LJMP	IN1         ; 跳转到IN1标签处执行
		ORG	0030H          ; 设置程序的其他部分起始地址为0030H
START:	MOV	SP, #60H  ; 初始化堆栈指针为60H
		MOV	TCON, #01H   ; 设置定时器控制寄存器，��动定时器0
		SETB	EA          ; 使能全局中断
		SETB	EX0         ; 使能外部中断0
		SETB	EX1         ; 使能外部中断1
		SETB	PX1         ; 设置外部中断1的优先级为高
		CLR		PX0         ; 设置外部中断0的优先级为低
		MOV 	DPTR, #TABLE ; 将数据指针寄存器指向TABLE
		MOV	PSW, #00H    ; 清除程序状态字寄存器
		MOV	R2, #6       ; 将R2寄存器初始化为6
DISP: 	ACALL	DISPLAY ; 调用DISPLAY子程序
		SJMP 	DISP      ; 无限循环，跳转到DISP标签
DISPLAY: MOV	R1, #100 ; 将R1寄存器初始化为100
DISP0:	MOV	R0, #6    ; 将R0寄存器初始化为6
		MOV	R3, #0E7H  ; 将R3寄存器初始化为0E7H
DISP1:	INC		R3       ; 增加R3寄存器的值
		MOV	A, R2       ; 将R2的值移动到累加器A
		MOVC 	A, @A+DPTR ; 从TABLE中读取数据到累加器A
		MOV 	P0, A      ; 将累加器A的值输出到P0端口
		MOV 	P1, R3     ; 将R3的值输出到P1端口
		LCALL	DELAY     ; 调用DELAY子程序
		DJNZ	R0, DISP1  ; R0减1，如果不为0则跳转到DISP1
		DJNZ	R1, DISP0  ; R1减1，如果不为0则跳转到DISP0
		RET              ; 返回主程序
TABLE:	DB 0C0H, 0F9H, 0A4H, 0B0H, 99H, 92H, 82H, 0F8H ; 定义显示字符的查找表
		DB 80H, 90H, 88H, 83H, 0C6H, 0A1H, 86H, 8EH ; 定义更多显示字符
IN0:		PUSH	ACC    ; 保存累加器的值
		PUSH	PSW    ; 保存程序状态字
		MOV	PSW, #10H ; 切换到寄存器组1
		MOV	R2, #0   ; 将R2寄存器初始化为0
		ACALL	DISPLAY ; 调用DISPLAY子程序
		POP		PSW    ; 恢复程序状态字
		POP		ACC    ; 恢复累加器的值
		RETI           ; 返回主程序并使能中断
IN1:		PUSH	ACC    ; 保存累加器的值
		PUSH	PSW    ; 保存程序状态字
		MOV	PSW, #18H ; 切换到寄存器组3
		MOV	R2, #1   ; 将R2寄存器初始化为1
		ACALL	DISPLAY ; 调用DISPLAY子程序
		POP		PSW    ; 恢复程序状态字
		POP		ACC    ; 恢复累加器的值
		RETI           ; 返回主程序并使能中断
DELAY:	MOV 	R6, #4  ; 将R6寄存器初始化为4
DEL1:	MOV 	R7, #229 ; 将R7寄存器初始化为229
DEL2:	DJNZ 	R7, DEL2 ; R7减1，如果不为0则跳转到DEL2
		DJNZ 	R6, DEL1 ; R6减1，如果不为0则跳转到DEL1
		RET              ; 返回主程序
		END              ; 程序结束
