        ORG 	0000H   ; 设置程序起始地址为0000H
        LJMP 	START   ; 跳转到程序开始位置
        ORG 	0023H   ; 设置串口中断的中断向量地址
        LJMP 	RECE    ; 跳转到串口中断服务程序
        ORG 	0030H   ; 设置程序开始地址为0030H
START:  	
        MOV	TCON, #00H ; 清除TCON寄存器
        SETB	EA      ; 使能全局中断
        SETB 	ES      ; 使能串口中断
        MOV   TMOD, #20H ; 设置定时器1为模式2（8位自动重装模式）
        MOV   TH1, #0F4H ; 设置定时器1高字节初值
        MOV   TL1, #0F4H ; 设置定时器1低字节初值
        MOV   PCON, #00H ; 设置电源控制寄存器
        MOV	R2, #16   ; 初始化R2
        SETB  	TR1     ; 启动定时器1
        MOV   SCON,#50H ; 设置串口控制寄存器
        MOV 	DPTR, #TABLE ; 初始化数据指针
DISP: 		
        ACALL	DISPLAY ; 调用DISPLAY子程序
        SJMP 	DISP    ; 无限循环
DISPLAY: 	
        MOV	R1, #100  ; 初始化R1
DISP0:		
        MOV	R0, #6    ; 初始化R0
        MOV	R3, #0E7H ; 初始化R3
DISP1:		
        INC		R3      ; R3加1
        MOV	A, R2    ; 将R2的值移动到累加器A
        MOVC 	A, @A+DPTR ; 从查找表中获取数据
        MOV 	P0, A    ; 将数据输出到P0口
        MOV 	P1, R3   ; 将选通信号输出到P1口
        LCALL	DELAY   ; 调用延时子程序
        DJNZ	R0, DISP1 ; R0减1，如果不为0则跳转到DISP1
        DJNZ	R1, DISP0 ; R1减1，如果不为0则跳转到DISP0
        RET             ; 返回
RECE:  		
        PUSH 	ACC    ; 保存累加器的值
        CLR 	RI     ; 清除接收中断标志
        MOV 	A, SBUF ; 将串口缓冲区的值移动到累加器A
        MOV 	R2, A   ; 将累加器A的值移动到R2
        POP 	ACC    ; 恢复累加器的值
        RETI         ; 中断返回
TABLE:		
        DB 0C0H, 0F9H, 0A4H, 0B0H, 99H, 92H, 82H, 0F8H ; 数码管显示数据
        DB 80H, 90H, 88H, 83H, 0C6H, 0A1H, 86H, 8EH, 0FFH ; 数码管显示数据
DELAY:		
        MOV 	R6, #4   ; 设置R6为4
DEL1:		
        MOV 	R7, #229 ; 设置R7为229
DEL2:		
        DJNZ 	R7, DEL2 ; R7减1，如果不为0则跳转到DEL2
        DJNZ 	R6, DEL1 ; R6减1，如果不为0则跳转到DEL1
        RET          ; 返回
        END          ; 程序结束
