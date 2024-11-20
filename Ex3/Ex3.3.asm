        ORG		0000H          ; 设置程序起始地址为0000H
        LJMP	START   ; 跳转到程序开始位置
        ORG		0003H  ; 设置外部中断0的中断向量地址
        LJMP	IN0     ; 跳转到外部中断0服务程序
        ORG		0013H  ; 设置外部中断1的中断向量地址
        LJMP	IN1     ; 跳转到外部中断1服务程序
        ORG		001BH  ; 设置定时器1的中断向量地址
        LJMP	TIMER   ; 跳转到定时器1中断服务程序
        ORG		0050H  ; 设置程序开始地址为0050H
START:	MOV		SP, #60H  ; 初始化堆栈指针
        MOV		TMOD, #10H ; 设置定时器1为模式1（16位定时器模式）
        MOV		TCON, #05H ; 设置外部中断0为低电平触发，外部中断1为边沿触发
        MOV		TL1, #0FDH ; 设置定时器1低字节初值
        MOV		TH1, #04BH ; 设置定时器1高字节初值
        MOV 	IE, #8DH  ; 使能定时器1、外部中断0、外部中断1中断
        SETB	PX1      ; 设置外部中断1为高优先级
        CLR		PX0      ; 设置外部中断0为低优先级
        MOV		DPTR, #TABLE ; 初始化数据指针
        MOV		R3, #0E8H ; 初始化R3
        MOV		R2, #0    ; 初始化R2
        MOV		R1, #0    ; 初始化R1
        MOV		R0, #0    ; 初始化R0
DISP:	MOV		R3, #0E8H ; 设置数码管选通信号
        MOV		A, #5    ; 设置累加器A为5
        MOVC	A, @A+DPTR ; 从查找表中获取数据
        MOV		P0, A    ; 将数据输出到P0口
        MOV		P1, R3   ; 将选通信号输出到P1口
        LCALL	DELAY   ; 调用延时子程序
        INC 	R3      ; R3加1
        MOV		A, R2    ; 将R2的值移动到累加器A
        MOVC	A, @A+DPTR ; 从查找表中获取数据
        MOV		P0, A    ; 将数据输出到P0口
        MOV		P1, R3   ; 将选通信号输出到P1口
        LCALL	DELAY   ; 调用延时子程序
        JMP 	DISP    ; 跳转到DISP

IN0:	PUSH 	ACC    ; 保存累加器的值
        LCALL	DELAY2 ; 调用延时子程序
        MOV		A, P3   ; 读取P3口的值
        ANL		A, #4   ; 检查P3.2的值
        JNZ		ENDI   ; 如果P3.2为高电平，跳转到ENDI
        MOV		A, R0   ; 将R0的值移动到累加器A
        JNZ 	PAUSE  ; 如果R0不为0，跳转到PAUSE
        SETB 	TR1    ; 启动定时器1
        MOV		R0, #1  ; 设置R0为1
        POP		ACC    ; 恢复累加器的值
        RETI         ; 中断返回
PAUSE:	CLR		TR1    ; 停止定时器1
        MOV		R0, #0  ; 设置R0为0
        LCALL	DELAY2 ; 调用延时子程序
        POP		ACC    ; 恢复累加器的值
        RETI         ; 中断返回
IN1:	PUSH 	ACC    ; 保存累加器的值
        LCALL	DELAY2 ; 调用延时子程序
        MOV		A, P3   ; 读取P3口的值
        ANL		A, #8   ; 检查P3.3的值
        JNZ		ENDI   ; 如果P3.3为高电平，跳转到ENDI
        MOV		TL1, #0FDH ; 设置定时器1低字节初值
        MOV		TH1, #04BH ; 设置定时器1高字节初值
        MOV		R2, #0  ; 设置R2为0
        MOV		R1, #0  ; 设置R1为0
ENDI:	POP 	ACC    ; 恢复累加器的值
        RETI         ; 中断返回

TIMER:	MOV		TL1, #0FDH ; 设置定时器1低字节初值
        MOV		TH1, #04BH ; 设置定时器1高字节初值
        INC		R1      ; R1加1
        CJNE	R1, #20, ENDT ; 比较R1和20，不相等则跳转到ENDT
        MOV		R1, #0  ; 设置R1为0
        INC		R2      ; R2加1
        CJNE 	R2, #10, ENDT ; 比较R2和10，不相等则跳转到ENDT
        MOV		R2, #0  ; 设置R2为0
ENDT:	RETI         ; 中断返回

DELAY:	MOV 	R6, #2  ; 设置R6为2
DEL1:	MOV 	R7, #229 ; 设置R7为229
DEL2:	DJNZ 	R7, DEL2 ; R7减1，如果不为0则跳转到DEL2
        DJNZ 	R6, DEL1 ; R6减1，如果不为0则跳转到DEL1
        RET          ; 返回

DELAY2:	MOV 	R4, #10 ; 设置R4为10
DEL3:	MOV 	R5, #229 ; 设置R5为229
DEL4:	DJNZ 	R5, DEL4 ; R5减1，如果不为0则跳转到DEL4
        DJNZ 	R4, DEL3 ; R4减1，如果不为0则跳转到DEL3
        RET          ; 返回

TABLE:	DB     	0C0H, 0F9H, 0A4H, 0B0H, 99H, 92H, 82H, 0F8H ; 数码管显示数据
        DB      80H, 90H, 88H, 83H, 0C6H, 0A1H, 86H, 8EH ; 数码管显示数据
        END          ; 程序结束
