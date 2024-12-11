            RS_LCD      BIT P1.0          ; 定义 RS_LCD 位于 P1.0
            RW_LCD      BIT P1.1          ; 定义 RW_LCD 位于 P1.1
            EN_LCD      BIT P1.5          ; 定义 EN_LCD 位于 P1.5
            BUSY        BIT P0.7          ; 定义 BUSY 位于 P0.7
            LCD_DIS     EQU 38H           ; LCD 显示模式命令
            LCD_SHOW    EQU 0CH           ; LCD 显示开命令
            LCD_CURS    EQU 06H           ; LCD 光标移动命令
            LCD_CLR     EQU 01H           ; LCD 清屏命令
            TIMER_MODE  EQU 01H           ; 定时器模式1
            TIMER_HIGH  EQU 0DCH          ; 定时器初始值高字节
            TIMER_LOW   EQU 0H            ; 定时器初始值低字节
            ORG         0000H             ; 起始地址
            LJMP        START     ; 跳转到 START
            ORG         000BH             ; 定时器0中断向量地址
            LJMP        TIMER0_ISR; 跳转到定时器0中断处理程序
START:      MOV         SP, #60H      ; 初始化堆栈指针
            LCALL       LCD_INT       ; 调用 LCD 初始化子程序
            MOV         A, #30H       ; 初始化显示字符 '0'
            MOV         R7, A         ; 将字符 '0' 存入 R7
            MOV         R6, #84H      ; 设置地址指针到第一行中间位置
            LCALL       WRITE_CMD     ; 调用写命令子程序
            LCALL       WRITE_DAT     ; 调用写数据子程序
            MOV         DPTR, #PLUS   ; 显示 "+"
            MOV         R0, #1
DISPLAY_PLUS_0:
            CLR         A
            MOVC        A, @A+DPTR
            MOV         R7, A
            INC         DPTR
            LCALL       WRITE_DAT
            DJNZ        R0, DISPLAY_PLUS_0
            MOV         A, #31H       ; 显示 "1"
            MOV         R7, A
            LCALL       WRITE_DAT
            MOV         A, #35H       ; 显示 "5"
            MOV         R7, A
            LCALL       WRITE_DAT
            MOV         DPTR, #EQUAL  ; 显示 "="
            MOV         R0, #1
DISPLAY_EQUAL_0:
            CLR         A
            MOVC        A, @A+DPTR
            MOV         R7, A
            INC         DPTR
            LCALL       WRITE_DAT
            DJNZ        R0, DISPLAY_EQUAL_0
            MOV         A, #31H       ; 显示 "1"
            MOV         R7, A
            MOV         R6, #89H      ; 设置地址指针到第一行第10个位置
            LCALL       WRITE_CMD     ; 调用写命令子程序
            LCALL       WRITE_DAT     ; 调用写数据子程序
            MOV         A, #35H       ; 显示 "5"
            MOV         R7, A
            MOV         R6, #8AH      ; 设置地址指针到第一行第11个位置
            LCALL       WRITE_CMD     ; 调用写命令子程序
            LCALL       WRITE_DAT     ; 调用写数据子程序
            MOV         TMOD, #TIMER_MODE ; 设置定时器模式
            MOV         TH0, #TIMER_HIGH ; 设置定时器初始值高字节
            MOV         TL0, #TIMER_LOW  ; 设置定时器初始值低字节
            SETB        TR0           ; 启动定时器0
            SETB        ET0           ; 使能定时器0中断
            SETB        EA            ; 使能全局中断
            SJMP        $             ; 无限循环
LCD_INT:    MOV         R6, #LCD_DIS  ; 设置显示模式
            LCALL       WRITE_CMD     ; 调用写命令子程序
            MOV         R6, #LCD_SHOW ; 打开显示
            LCALL       WRITE_CMD     ; 调用写命令子程序
            MOV         R6, #LCD_CURS ; 设置光标移动
            LCALL       WRITE_CMD     ; 调用写命令子程序
            MOV         R6, #LCD_CLR  ; 清屏
            LCALL       WRITE_CMD     ; 调用写命令子程序
            RET                   ; 返回
WRITE_DAT:  LCALL       READ          ; 调用读子程序
            SETB        RS_LCD        ; 设置 RS_LCD
            CLR         RW_LCD        ; 清除 RW_LCD
            MOV         P0, R7        ; 将 R7 的值移动到 P0
            SETB        EN_LCD        ; 设置 EN_LCD
            CLR         EN_LCD        ; 清除 EN_LCD
            RET                   ; 返回
WRITE_CMD:  LCALL       READ          ; 调用读子程序
            CLR         RS_LCD        ; 清除 RS_LCD
            CLR         RW_LCD        ; 清除 RW_LCD
            MOV         P0, R6        ; 将 R6 的值移动到 P0
            SETB        EN_LCD        ; 设置 EN_LCD
            CLR         EN_LCD        ; 清除 EN_LCD
            RET                   ; 返回
READ:       MOV         P0, #0FFH     ; 将 P0 设置为输入
            CLR         RS_LCD        ; 清除 RS_LCD
            SETB        RW_LCD        ; 设置 RW_LCD
            SETB        EN_LCD        ; 设置 EN_LCD
            JNB         BUSY, READ_END; 如果 BUSY 位未设置，跳转到 READ_END
            CLR         EN_LCD        ; 清除 EN_LCD
            SJMP        READ          ; 跳转到 READ
READ_END:   RET                   ; 返回
TIMER0_ISR: CLR     TR0           ; 停止定时器0
            MOV     TH0, #TIMER_HIGH ; 重置定时器初始值高字节
            MOV     TL0, #TIMER_LOW  ; 重置定时器初始值低字节
            INC     R2            ; 溢出计数器自增
            CJNE    R2, #100, NOT_100 ; 如果 R2 不等于 100，跳转到 NOT_100
            MOV     R2, #0        ; 否则重置 R2 为 0
            INC     R1            ; 计数器自增
            CJNE    R1, #10, NOT_10 ; 如果 R1 不等于 10，跳转到 NOT_10
            MOV     R1, #0        ; 否则重置 R1 为 0
NOT_10:     MOV     A, R1         ; 将 R1 的值移动到 A
            ADD     A, #30H       ; 将数字转换为ASCII码
            MOV     R7, A         ; 将结果存入 R7
            MOV     R6, #84H      ; 设置地址指针到第一行中间位置
            LCALL   WRITE_CMD     ; 调用写命令子程序
            LCALL   WRITE_DAT     ; 调用写数据子程序
            MOV     DPTR, #PLUS   ; 显示 "+"
            MOV     R0, #1
DISPLAY_PLUS:
            CLR     A
            MOVC    A, @A+DPTR
            MOV     R7, A
            INC     DPTR
            LCALL   WRITE_DAT
            DJNZ    R0, DISPLAY_PLUS
            MOV     A, #31H       ; 显示 "1"
            MOV     R7, A
            LCALL   WRITE_DAT
            MOV     A, #35H       ; 显示 "5"
            MOV     R7, A
            LCALL   WRITE_DAT
            MOV     DPTR, #EQUAL  ; 显示 "="
            MOV     R0, #1
DISPLAY_EQUAL:
            CLR     A
            MOVC    A, @A+DPTR
            MOV     R7, A
            INC     DPTR
            LCALL   WRITE_DAT
            DJNZ    R0, DISPLAY_EQUAL
            MOV     A, R1         ; 计算 Z = X + 15
            ADD     A, #15
            MOV     B, #10
            DIV     AB            ; A = 商, B = 余数
            ADD     A, #30H       ; 将商转换为ASCII码
            MOV     R7, A         ; 将商存入 R7
            MOV     R6, #89H      ; 设置地址指针到第一行第10个位置
            LCALL   WRITE_CMD     ; 调用写命令子程序
            LCALL   WRITE_DAT     ; 调用写数据子程序
            MOV     A, B          ; 将余数转换为ASCII码
            ADD     A, #30H
            MOV     R7, A         ; 将余数存入 R7
            MOV     R6, #8AH      ; 设置地址指针到第一行第11个位置
            LCALL   WRITE_CMD     ; 调用写命令子程序
            LCALL   WRITE_DAT     ; 调用写数据子程序
NOT_100:    SETB    TR0           ; 重新启动定时器0
            RETI                  ; 返回中断
PLUS:       DB '+'                ; 定义字符串 "+"
EQUAL:      DB '='                ; 定义字符串 "="
            END                   ; 结束