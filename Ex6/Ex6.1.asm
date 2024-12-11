            RS_LCD		BIT P1.0          ; 定义RS_LCD位于P1.0
            RW_LCD	    BIT P1.1          ; 定义RW_LCD位于P1.1
            EN_LCD		BIT P1.5          ; 定义EN_LCD位于P1.5
            BUSY		BIT P0.7          ; 定义BUSY位于P0.7
            LCD_DIS	    EQU 38H           ; LCD显示模式命令
            LCD_SHOW	EQU 0CH           ; LCD显示开命令
            LCD_CURS	EQU 06H           ; LCD光标移动命令
            LCD_CLR	    EQU 01H           ; LCD清屏命令
            LINE		EQU 0             ; 行地址
            ROW		    EQU 0             ; 列地址
            ADDR_INT	EQU LINE*40H+ROW  ; 初始地址
            ORG 	    0000H            ; 程序起始地址
            LJMP 	    START            ; 跳转到START
            ORG 	    0030H            ; 程序存储地址
START:	    MOV 	    SP, #60H         ; 初始化堆栈指针
            MOV	        DPTR, #TAB        ; 初始化DPTR指向TAB
            MOV	        R0, #11           ; 初始化R0为11
            MOV	        R1, #0            ; 初始化R1为0
            LCALL	    LCD_INT          ; 调用LCD初始化子程序
LOOP:	    MOV	        A, R1            ; 将R1的值移动到A
            INC		    R1               ; R1加1
            MOVC	    A, @A+DPTR       ; 从代码存储器中读取字符
            MOV	        R7, A            ; 将字符存入R7
            LCALL	    WRITE_DAT        ; 调用写数据子程序
            DJNZ	    R0, LOOP         ; R0减1，如果不为0则跳转到LOOP
            SJMP	    $                ; 无限循环
TAB:	    DB          ‘Happy 8051!’    ; 定义字符串
LCD_INT:    MOV	        R6, #LCD_DIS     ; 设置LCD显示模式
            LCALL	    WRITE_CMD       ; 调用写命令子程序
            MOV	        R6, #LCD_SHOW    ; 设置LCD显示开
            LCALL	    WRITE_CMD       ; 调用写命令子程序
            MOV	        R6, #LCD_CURS    ; 设置LCD光标移动
            LCALL	    WRITE_CMD       ; 调用写命令子程序
            MOV	        R6, #LCD_CLR     ; 设置LCD清屏
            LCALL	    WRITE_CMD       ; 调用写命令子程序
            MOV	        A, #ADDR_INT     ; 设置初始地址
            ORL	        A, #80H          ; 设置地址高位
            MOV	        R6, A            ; 将地址存入R6
            LCALL	    WRITE_CMD       ; 调用写命令子程序
            RET                         ; 返回
WRITE_DAT:	LCALL	    READ            ; 调用读子程序
            SETB	    RS_LCD          ; 设置RS_LCD为1
            CLR		    RW_LCD          ; 清除RW_LCD
            MOV	        P0, R7           ; 将R7的值移动到P0
            SETB	    EN_LCD          ; 设置EN_LCD为1
            CLR		    EN_LCD          ; 清除EN_LCD
            RET                         ; 返回
WRITE_CMD:	LCALL	    READ            ; 调用读子程序
            CLR		    RS_LCD          ; 清除RS_LCD
            CLR		    RW_LCD          ; 清除RW_LCD
            MOV	        P0, R6           ; 将R6的值移动到P0
            SETB	    EN_LCD          ; 设置EN_LCD为1
            CLR		    EN_LCD          ; 清除EN_LCD
            RET                         ; 返回
READ:	    MOV 	    P0, #0FFH       ; 将P0设置为输入模式
            CLR		    RS_LCD          ; 清除RS_LCD
            SETB	    RW_LCD          ; 设置RW_LCD为1
            SETB	    EN_LCD          ; 设置EN_LCD为1
            JNB		    BUSY, READ_END  ; 如果BUSY位为0则跳转到READ_END
            CLR		    EN_LCD          ; 清除EN_LCD
            SJMP	    READ            ; 跳转到READ
READ_END:	RET                         ; 返回
            END                         ; 程序结束
