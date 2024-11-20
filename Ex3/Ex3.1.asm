    ORG	0000H           ; 设置程序起始地址为0000H
    LJMP   START        ; 跳转到START标签
    ORG    001BH        ; 设置中断向量地址为001BH
    LJMP   TIMER        ; 跳转到TIMER标签
    ORG    0050H        ; 设置程序起始地址为0050H

START: 		
    MOV 	SP, #60H     ; 初始化堆栈指针为60H
    MOV     TMOD, #10H   ; 设置定时器模式，定时器1为模式1
    MOV 	TL1, #0FDH   ; 设置定时器1低字节初值为0FDH
    MOV 	TH1, #4BH    ; 设置定时器1高字节初值为4BH
    MOV 	IE, #88H     ; 使能定时器1中断
    MOV 	DPTR, #TABLE ; 将DPTR指向TABLE
    MOV 	R3, #0E8H    ; 初始化R3为0E8H
    MOV 	R2, #0       ; 初始化R2为0,数码管显示寄存器
    MOV 	R1, #0       ; 初始化R1为0
    SETB 	TR1         ; 启动定时器1

DISPLAY:	
    MOV 	R0, #6       ; 初始化R0为6,数码管选通寄存器
    MOV 	R3, #0E8H    ; 重新初始化R3为0E8H
    MOV 	A, R2        ; 将R2的值移动到累加器A
    MOVC 	A, @A+DPTR   ; 从TABLE中读取数据到A

DISP:		
    MOV 	P0, A        ; 将A的值输出到P0端口
    MOV 	P1, R3      ; 将R3的值输出到P1端口
    LCALL 	DELAY      ; 调用DELAY子程序
    INC 	R3          ; 增加R3的值
    CJNE    R3, #0EEH,  LOADP ; 比较R3与0EEH，如果不相等则跳转到LOADP
    JMP     DISPLAY    ; 无条件跳转到DISPLAY
LOADP:    
    MOV 	P1, R3      ; 将新的R3值输出到P1端口
    DJNZ 	R0, DISP    ; R0减1，如果不为0则跳转到DISP
    JMP 	DISPLAY     ; 无条件跳转到DISPLAY

TIMER:		
    MOV 	TL1, #0FDH   ; 重新加载定时器1低字节初值为0FDH
    MOV 	TH1, #4BH    ; 重新加载定时器1高字节初值为4BH
    INC 	R1          ; 增加R1的值
    CJNE 	R1, #20, ENDT ; 比较R1与20，如果不相等则跳转到ENDT
    MOV 	R1, #0       ; 如果相等则将R1清零
    INC 	R2          ; 增加R2的值
    CJNE 	R2, #10, ENDT ; 比较R2与10，如果不相等则跳转到ENDT
    MOV 	R2, #0       ; 如果相等则将R2清零

ENDT:		
    RETI            ; 返回中断

DELAY: 		
    MOV   R7, #2     ; 初始化R7为2
    DE1:  		
    MOV   R6, #229   ; 初始化R6为229
    DE2:  		
    DJNZ  R6, DE2    ; R6减1，如果不为0则跳转到DE2
    DJNZ  R7, DE1    ; R7减1，如果不为0则跳转到DE1
    RET             ; 返回

TABLE:		
    DB 0C0H, 0F9H, 0A4H, 0B0H, 99H, 92H, 82H, 0F8H ; 数据表
    DB 80H, 90H, 88H, 83H, 0C6H, 0A1H, 86H, 8EH    ; 数据表
    END             ; 程序结束
