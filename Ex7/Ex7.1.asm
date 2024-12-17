            ORG     0000H          ; 设置程序起始地址为0000H
            LJMP    START          ; 跳转到START标签
            ORG     0013H          ; 设置中断向量地址为0013H
            LJMP    INFARED        ; 跳转到INFARED标签
            ORG     0050H          ; 设置程序起始地址为0050H
START:      MOV     TMOD,#01H       ; 设置定时器模式
            MOV     TL0, #00H       ; 初始化定时器低位
            MOV     TH0, #00H       ; 初始化定时器高位
            MOV     SP, #60H        ; 设置堆栈指针
            SETB    EA            ; 开启全局中断
            SETB    EX1           ; 开启外部中断1
            SETB    IT1           ; 设置外部中断1为下降沿触发
            CLR     00H           ; 清除标志位00H
            CLR     01H           ; 清除标志位01H
            CLR     10H           ; 清除标志位10H
            MOV     30H, #00H     ; 初始化30H地址
            MOV     31H, #00H     ; 初始化31H地址
            MOV     32H, #00H     ; 初始化32H地址
            MOV     33H, #00H     ; 初始化33H地址
DISP:       MOV     P1, #0E8H     ; 设置P1端口输出
            MOV     A, 32H        ; 将32H地址的值移动到累加器A
            MOV     P0, A         ; 将累加器A的值输出到P0端口
            LCALL   DELAY         ; 调用延时子程序
            SJMP    DISP          ; 无条件跳转到DISP标签

INFARED:    PUSH    ACC           ; 保存累加器A的值
            CLR     EA            ; 关闭全局中断
            LCALL   READ          ; 调用READ子程序
END_INFA:   CLR     IE1           ; 清除外部中断1标志
            SETB    EA            ; 开启全局中断
            POP     ACC           ; 恢复累加器A的值
            RETI                  ; 中断返回

READ:       ; 读整条红外信息
READHEAD:   LCALL   T_LOW         ; 调用T_LOW子程序
            LCALL   T_HEAD1       ; 调用T_HEAD1子程序
            LCALL   COMPARE       ; 调用COMPARE子程序
            JB      00H, END_READ ; 如果00H标志位为1，跳转到END_READ
            JB      01H, END_READ ; 如果01H标志位为1，跳转到END_READ
            LCALL   T_HIGH        ; 调用T_HIGH子程序
            LCALL   T_HEAD2       ; 调用T_HEAD2子程序
            LCALL   COMPARE       ; 调用COMPARE子程序
            JB      00H, END_READ ; 如果00H标志位为1，跳转到END_READ
            JB      01H, END_READ ; 如果01H标志位为1，跳转到END_READ
            MOV     R1, #30H      ; 初始化R1寄存器
            MOV     R2, #4        ; 初始化R2寄存器
READBYTE:   MOV     R3, #8        ; 初始化R3寄存器
            CLR     A             ; 清除累加器A
READBIT:    RL      A             ; 左移累加器A
            ACALL   ONEBIT        ; 调用ONEBIT子程序
            MOV     C, 10H        ; 将10H标志位移动到进位标志C
            MOV     ACC.0, C      ; 将进位标志C移动到累加器A的最低位
            DJNZ    R3, READBIT   ; R3减1，如果不为0，跳转到READBIT
            MOV     @R1, A        ; 将累加器A的值存储到R1指向的地址
            INC     R1            ; R1加1
            DJNZ    R2, READBYTE  ; R2减1，如果不为0，跳转到READBYTE
END_READ:   RET                   ; 返回

T_HEAD1:    MOV     44H, #34      ; 设置44H地址的值为34
            MOV     43H, #51      ; 设置43H地址的值为51
            MOV     42H, #25      ; 设置42H地址的值为25
            MOV     41H, #154     ; 设置41H地址的值为154
            RET                   ; 返回
T_HEAD2:    MOV     44H, #18      ; 设置44H地址的值为18
            MOV     43H, #0       ; 设置43H地址的值为0
            MOV     42H, #14      ; 设置42H地址的值为14
            MOV     41H, #102     ; 设置41H地址的值为102
            RET                   ; 返回
T_BIT1:     MOV     44H, #2       ; 设置44H地址的值为2
            MOV     43H, #206     ; 设置43H地址的值为206
            MOV     42H, #1       ; 设置42H地址的值为1
            MOV     41H, #59      ; 设置41H地址的值为59
            RET                   ; 返回
T_BIT2:     MOV     44H, #6       ; 设置44H地址的值为6
            MOV     43H, #214     ; 设置43H地址的值为214
            MOV     42H, #5       ; 设置42H地址的值为5
            MOV     41H, #65      ; 设置41H地址的值为65
            RET                   ; 返回
T_LOW:      ; 计时低电平时长函数
            MOV     TL0, #00H     ; 初始化定时器低位
            MOV     TH0, #00H     ; 初始化定时器高位
            SETB    P3.3          ; 设置P3.3引脚为高电平
            SETB    TR0           ; 启动定时器0
            JNB     P3.3, $       ; 等待P3.3引脚变为低电平
            CLR     TR0           ; 停止定时器0
            RET                   ; 返回
T_HIGH:     ; 计时高电平时长函数
            MOV     TL0, #00H     ; 初始化定时器低位
            MOV     TH0, #00H     ; 初始化定时器高位
            SETB    P3.3          ; 设置P3.3引脚为高电平
            SETB    TR0           ; 启动定时器0
            JB      P3.3, $       ; 等待P3.3引脚变为高电平
            CLR     TR0           ; 停止定时器0
            RET                   ; 返回
COMPARE:    
            PUSH    ACC           ; 保存累加器A的值
            CLR     00H           ; 清除标志位00H
            CLR     01H           ; 清除标志位01H
            CLR     C             ; 清除进位标志C
            MOV     A, 43H        ; 将43H地址的值移动到累加器A
            SUBB    A, TL0        ; 累加器A减去定时器低位
            MOV     A, 44H        ; 将44H地址的值移动到累加器A
            SUBB    A, TH0        ; 累加器A减去定时器高位
            MOV     01H, C        ; 将进位标志C移动到01H标志位
            CLR     C             ; 清除进位标志C
            MOV     A, TL0        ; 将定时器低位移动到累加器A
            SUBB    A, 41H        ; 累加器A减去41H地址的值
            MOV     A, TH0        ; 将定时器高位移动到累加器A
            SUBB    A, 42H        ; 累加器A减去42H地址的值
            MOV     00H, C        ; 将进位标志C移动到00H标志位
            POP     ACC           ; 恢复累加器A的值
            RET                   ; 返回
ONEBIT:     ; 读一位二进制数
            CLR     10H           ; 清除标志位10H
            ACALL   T_LOW         ; 调用T_LOW子程序
            ACALL   T_BIT1        ; 调用T_BIT1子程序
            LCALL   COMPARE       ; 调用COMPARE子程序
            JB      00H, END_BIT  ; 如果00H标志位为1，跳转到END_BIT
            JB      01H, END_BIT  ; 如果01H标志位为1，跳转到END_BIT
BIT_0:      ACALL   T_HIGH        ; 调用T_HIGH子程序
            ACALL   T_BIT1        ; 调用T_BIT1子程序
            LCALL   COMPARE       ; 调用COMPARE子程序
            JB      00H, END_BIT  ; 如果00H标志位为1，跳转到END_BIT
            JB      01H, BIT_1    ; 如果01H标志位为1，跳转到BIT_1
            SJMP    END_BIT       ; 无条件跳转到END_BIT
BIT_1:      ACALL   T_BIT2        ; 调用T_BIT2子程序
            LCALL   COMPARE       ; 调用COMPARE子程序
            JB      00H, END_BIT  ; 如果00H标志位为1，跳转到END_BIT
            JB      01H, END_BIT  ; 如果01H标志位为1，跳转到END_BIT
            SETB    10H           ; 设置标志位10H
END_BIT:    RET                   ; 返回

DELAY:      MOV     R6, #20       ; 初始化R6寄存器
DEL1:       MOV     R7, #50       ; 初始化R7寄存器
DEL2:       DJNZ    R7, DEL2      ; R7减1，如果不为0，跳转到DEL2
            DJNZ    R6, DEL1      ; R6减1，如果不为0，跳转到DEL1
            RET                   ; 返回
            END                   ; 程序结束
