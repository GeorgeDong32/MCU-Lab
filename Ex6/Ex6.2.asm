        RS_LCD		BIT P1.0      ; 定义LCD的RS引脚位于P1.0
        RW_LCD		BIT P1.1      ; 定义LCD的RW引脚位于P1.1
        EN_LCD		BIT P1.5      ; 定义LCD的EN引脚位于P1.5
        BUSY		BIT P0.7      ; 定义LCD的忙信号位于P0.7
        LCD_DIS		EQU 38H       ; LCD显示模式设置命令码
        LCD_SHOW	EQU 0CH       ; LCD显示打开命令码
        LCD_CURS	EQU 06H       ; LCD光标设置命令码
        LCD_CLR		EQU 01H       ; LCD清屏命令码
        LINE		EQU 1         ; 定义行号为1
        ROW			EQU 3         ; 定义列号为3
        ADDR_INT	EQU LINE*40H+ROW ; 计算LCD初始地址
        ORG 	0000H           ; 设置程序起始地址
        LJMP 	START           ; 跳转到START段
        ORG    	001BH           ; 定义定时器1中断入口
        LJMP   	TIMER           ; 跳转到TIMER中断处理程序
        ORG 	0030H           ; 程序存储起始地址

START:	MOV 	SP, #60H       ; 初始化栈指针
        MOV   	TMOD, #10H     ; 设置定时器1为模式1
        MOV 	TL1, #0FDH     ; 设置定时器1初值低字节
        MOV 	TH1, #4BH      ; 设置定时器1初值高字节
        MOV 	IE, #88H       ; 使能定时器1中断
        MOV		DPTR, #TAB     ; 数据指针指向TAB表
        MOV		R1, #0         ; 清零R1寄存器
        SETB 	TR1            ; 启动定时器1
        LCALL	LCD_INT        ; 初始化LCD
        MOV		A, R1          ; 将R1的值送入累加器A
        MOVC	A, @A+DPTR     ; 从TAB表中读取数据
        MOV		R7, A          ; 将读取的数据存入R7
        LCALL	W_DAT          ; 写数据到LCD
        SJMP	$              ; 无限循环

TAB:	DB 		'0123456789'    ; 定义数字字符表

TIMER:	MOV 	TL1, #0FDH     ; 重置定时器1初值低字节
        MOV 	TH1, #4BH      ; 重置定时器1初值高字节
        INC 	R4             ; R4加1
        CJNE 	R4, #20, ENDT  ; 比较R4是否等于20，不等则跳转ENDT
        MOV 	R4, #0         ; 计数到20后清零R4
        INC 	R1             ; R1加1
        CLR		C              ; 清除进位标志位
        MOV		A, R1          ; 将R1的值送入累加器A
        SUBB 	A, #10         ; A减去10
        JNC 	RST            ; 如果结果大于等于0，跳转RST

TWD:	LCALL	LCD_INT        ; 初始化LCD
        MOV		A, R1          ; 将R1的值送入累加器A
        MOVC	A, @A+DPTR     ; 从TAB表中读取数据
        MOV		R7, A          ; 将读取的数据存入R7
        LCALL	W_DAT          ; 写数据到LCD

ENDT:	RETI                 ; 返回中断

RST:	MOV		R1, #0         ; 将R1清零
        SJMP	TWD            ; 跳转到TWD

LCD_INT:MOV		R6, #LCD_DIS   ; 设置LCD显示模式
        LCALL	W_CMD          ; 写命令到LCD
        MOV		R6, #LCD_SHOW  ; 显示打开
        LCALL	W_CMD          ; 写命令到LCD
        MOV		R6, #LCD_CURS  ; 光标设置
        LCALL	W_CMD          ; 写命令到LCD
        MOV		R6, #LCD_CLR   ; 清屏指令
        LCALL	W_CMD          ; 写命令到LCD
        MOV		A, #ADDR_INT   ; 设置显示地址
        ORL		A, #80H        ; 设置DDRAM地址
        MOV		R6, A          ; 将地址存入R6
        LCALL	W_CMD          ; 写命令到LCD
        RET                   ; 返回

W_DAT:	LCALL	READ           ; 读取LCD状态
        SETB	RS_LCD         ; 数据寄存器选择
        CLR		RW_LCD         ; 写操作
        MOV		P0, R7         ; 数据输出到P0口
        SETB	EN_LCD         ; 使能LCD
        CLR		EN_LCD         ; 关闭使能
        RET                   ; 返回

W_CMD:	LCALL	READ           ; 读取LCD状态
        CLR		RS_LCD         ; 命令寄存器选择
        CLR		RW_LCD         ; 写操作
        MOV		P0, R6         ; 命令输出到P0口
        SETB	EN_LCD         ; 使能LCD
        CLR		EN_LCD         ; 关闭使能
        RET                   ; 返回

READ:	MOV 	P0, #0FFH      ; 设置P0口为输入模式
        CLR		RS_LCD         ; 命令寄存器选择
        SETB	RW_LCD         ; 读操作
        SETB	EN_LCD         ; 使能LCD
        JNB		BUSY, READ_E   ; 判断LCD是否忙，忙则跳转READ_E
        CLR		EN_LCD         ; 关闭使能
        SJMP	READ           ; 如果忙，重复读取

READ_E:	RET                   ; 返回
        END                   ; 程序结束
