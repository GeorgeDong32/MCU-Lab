        ORG     0000H
        LJMP    START           ; 跳转到程序开始位置
        ORG     0003H
        LJMP    INT0_ISR        ; 跳转到外部中断0服务程序
        ORG      000BH
        LJMP    TIMER0_ISR      ; 跳转到定时器0中断服务程序
        ORG     0013H
        LJMP    INT1_ISR        ; 跳转到外部中断1服务程序
        ORG     001BH
        LJMP    TIMER1_ISR      ; 跳转到定时器1中断服务程序
        ORG     0050H
START:  MOV     SP, #60H        ; 初始化堆栈指针
        MOV     TMOD, #10H      ; 设置定时器1为模式1（16位定时器模式）
        MOV     TL1, #0FDH      ; 设置定时器1初值
        MOV     TH1, #4BH       ; 设置定时器1初值
        SETB    EA              ; 使能全局中断
        SETB    EX0             ; 使能外部中断0
        SETB    IT1             ; 设置外部中断1为边沿触发
        SETB    EX1             ; 使能外部中断1
        SETB    PX1             ; 设置外部中断1为高优先级
        CLR     PX0             ; 设置外部中断0为低优先级
        SETB    PT1             ; 设置定时器1中断为高优先级
        MOV     DPTR, #TABLE    ; 初始化数据指针
        MOV     R2, #0          ; 初始化R2
        MOV     R1, #0          ; 初始化R1

DISPLAY:MOV     A, R2           ; 将R2的值移动到累加器A
        MOVC    A, @A+DPTR      ; 从查找表中获取数据
        MOV     P0, A           ; 将数据输出到P0口
        MOV     P1, #0E8H       ; 选通第一位数码管
        LCALL   DELAY           ; 调用延时子程序
        JMP     DISPLAY         ; 跳转到DISPLAY

INT0_ISR:
        SETB    ET1             ; 使能定时器1中断
        SETB    TR1             ; 启动定时器1
        RETI                    ; 中断返回

INT1_ISR:
        MOV     R2, #0          ; R2清零
        RETI                    ; 中断返回

TIMER0_ISR:
        CLR     TR0             ; 停止定时器0
        CLR     ET0             ; 禁用定时器0中断
        MOV     TL0, #0FDH      ; 重装定时器0初值
        MOV     TH0, #4BH       ; 重装定时器0初值
        INC     R1              ; R1加1
        CJNE    R1, #20, ENDT   ; 比较R1和20，不相等则跳转到ENDT
        MOV     R1, #0          ; R1清零
        INC     R2              ; R2加1
        CJNE    R2, #10, ENDT   ; 比较R2和10，不相等则跳转到ENDT
        MOV     R2, #0          ; R2清零
ENDT:   RETI                    ; 中断返回

TIMER1_ISR:
        CLR     TR1             ; 停止定时器1
        CLR     ET1             ; 禁用定时器1中断
        MOV     TL1, #0FDH      ; 重装定时器1初值
        MOV     TH1, #4BH       ; 重装定时器1初值
        INC     R1              ; R1加1
        CJNE    R1, #20, ENDT_1   ; 比较R1和20，不相等则跳转到ENDT
        MOV     R1, #0          ; R1清零
        INC     R2              ; R2加1
        CJNE    R2, #10, ENDT_1   ; 比较R2和10，不相等则跳转到ENDT
        MOV     R2, #0          ; R2清零
ENDT_1:   RETI                    ; 中断返回

DELAY:  MOV     R7, #2          ; 初始化R7
DE1:    MOV     R6, #229        ; 初始化R6
DE2:    DJNZ    R6, DE2         ; R6减1，如果不为0则跳转到DE2
        DJNZ    R7, DE1         ; R7减1，如果不为0则跳转到DE1
        RET                     ; 返回

TABLE:  DB      0C0H, 0F9H, 0A4H, 0B0H, 99H, 92H, 82H, 0F8H ; 数码管显示数据
        DB      80H, 90H, 88H, 83H, 0C6H, 0A1H, 86H, 8EH    ; 数码管显示数据

        END                                             ; 程序结束