        ORG	0000H          ; 设置程序起始地址为0000H
        LJMP	START   ; 跳转到程序开始位置
        ORG	0003H    ; 设置外部中断0的中断向量地址
        LJMP	IN0     ; 跳转到外部中断0服务程序
        ORG 	0013H    ; 设置外部中断1的中断向量地址
        LJMP 	IN1     ; 跳转到外部中断1服务程序
        ORG 	0030H    ; 设置程序开始地址为0030H
START:		
        MOV	TCON, #05H ; 设置外部中断0为低电平触发，外部中断1为边沿触发
        SETB	EA      ; 使能全局中断
        SETB	EX0     ; 使能外部中断0
        SETB	EX1     ; 使能外部中断1
        SETB	PX0     ; 设置外部中断0为高优先级
        CLR		PX1     ; 设置外部中断1为低优先级
        MOV  	TMOD, #20H ; 设置定时器1为模式2（8位自动重装模式）
        MOV  	TH1, #0F4H ; 设置定时器1高字节初值
        MOV 	TL1, #0F4H ; 设置定时器1低字节初值
        MOV 	PCON, #00H ; 设置电源控制寄存器
        SETB 	TR1      ; 启动定时器1
        MOV  	SCON, #50H ; 设置串口控制寄存器
        SJMP 	$        ; 无限循环
DELAY: 		
        MOV 	R5, #20  ; 设置R5为20
DEL3: 		
        MOV 	R4, #229 ; 设置R4为229
DEL4: 		
        DJNZ 	R4, DEL4 ; R4减1，如果不为0则跳转到DEL4
        DJNZ 	R5, DEL3 ; R5减1，如果不为0则跳转到DEL3
        RET          ; 返回
IN0:			
        MOV  	A, #00H ; 将累加器A清零
        MOV  	SBUF, A ; 将A的值发送到串口缓冲区
        JNB  	TI, $   ; 等待发送完成
        CLR  	TI     ; 清除发送中断标志
WAIT0: 		
        LCALL	DELAY   ; 调用延时子程序
        JNB		P3.2, WAIT0 ; 等待P3.2为高电平
        CLR		IE0    ; 清除外部中断0标志
        RETI         ; 中断返回
IN1:	 		
        MOV  	A, #01H ; 将累加器A设置为1
        MOV  	SBUF, A ; 将A的值发送到串口缓冲区
        JNB  	TI,  $  ; 等待发送完成
        CLR  	TI     ; 清除发送中断标志
WAIT1: 		
        LCALL	DELAY   ; 调用延时子程序
        JNB		P3.3, WAIT1 ; 等待P3.3为高电平
        CLR		IE1    ; 清除外部中断1标志
        RETI         ; 中断返回
    END            ; 程序结束
