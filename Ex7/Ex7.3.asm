ORG     0000H           ; 设置程序起始地址为0000H
        LJMP    START   ; 跳转到START标签处执行
ORG     0013H           ; 设置中断向量地址为0013H
        LJMP    INFARED ; 跳转到INFARED标签处执行
ORG     0050H           ; 设置程序地址为0050H

START:  
        MOV     TMOD, #01H   ; 设置定时器0为模式1（16位定时器）
        MOV     TL0, #00H    ; 初始化定时器0低8位
        MOV     TH0, #00H    ; 初始化定时器0高8位
        MOV     SP, #60H     ; 设置堆栈指针初始值为60H
        SETB    EA           ; 开启全局中断
        SETB    EX1          ; 开启外部中断1
        SETB    IT1          ; 设置外部中断1为下降沿触发
        CLR     00H          ; 清除标志位00H
        CLR     01H          ; 清除标志位01H
        CLR     10H          ; 清除标志位10H
        MOV     30H, #00H    ; 初始化存储红外数据的寄存器30H
        MOV     31H, #00H    ; 初始化存储红外数据的寄存器31H
        MOV     32H, #0FFH   ; 初始化存储红外数据的寄存器32H
        MOV     33H, #00H    ; 初始化存储红外数据的寄存器33H
        MOV     50H, #0FEH   ; 存储当前显示值,初始为0000_0001
        MOV     51H, #00H    ; 存储显示方向,0表示左移,1表示右移
        MOV     P0, #0FFH    ; 初始化P0口为1111_1111

DISP:   
        MOV     P1, #0EEH    ; 输出1110_1110    
        MOV     A, 51H       ; 检查是否接收到红外信号
        JZ      NO_SIGNAL    ; 如果51H为0，表示未接收到信号
        
        MOV     A, 32H       ; 接收到信号，执行原有的显示逻辑
        CJNE    A, #38H, CHECK_A2  ; 检查是否为38H
        MOV     A, 50H
        MOV     P0, A         ; 输出当前值
        LCALL   DELAY_400MS   ; 延时0.4s
        MOV     A, 50H       
        RR      A             ; 右移一位
        MOV     50H, A        
        CJNE    A, #00H, DISP ; 如果未溢出则继续
        MOV     50H, #01H    ; 重新开始
        SJMP    DISP

NO_SIGNAL:
        MOV     P0, #0FFH    ; 未接收到信号时输出1111_1111
        SJMP    DISP

CHECK_A2:
        CJNE    A, #0A2H, OTHER_CASE  ; 检查是否为0A2H
        MOV     P0, #0FFH     ; 输出1111_1111
        SJMP    DISP

OTHER_CASE:
        MOV     A, 50H
        MOV     P0, A         ; 输出当前值
        LCALL   DELAY_400MS   ; 延时0.4s
        MOV     A, 50H
        RL      A             ; 左移一位
        MOV     50H, A
        CJNE    A, #00H, DISP ; 如果未溢出则继续
        MOV     50H, #80H     ; 重新开始
        SJMP    DISP

INFARED: 
        PUSH    ACC          ; 保存累加器A的值到堆栈
        CLR     EA           ; 关闭全局中断
        MOV     51H, #01H    ; 设置接收到信号的标志位
        LCALL   READ         ; 调用读取红外数据子程序

END_INFA: 
        CLR     IE1          ; 清除外部中断1标志
        SETB    EA           ; 开启全局中断
        POP     ACC          ; 恢复累加器A的值
        RETI                ; 返回中断

READ:   
        ; 读整条红外信息
READHEAD: 
        LCALL   T_LOW        ; 调用低电平计时子程序
        LCALL   T_HEAD1      ; 调用头部1计时子程序
        LCALL   COMPARE      ; 调用比较子程序
        JB      00H, END_READ; 如果00H标志位为1，跳转到END_READ
        JB      01H, END_READ; 如果01H标志位为1，跳转到END_READ
        LCALL   T_HIGH       ; 调用高电平计时子程序
        LCALL   T_HEAD2      ; 调用头部2计时子程序
        LCALL   COMPARE      ; 调用比较子程序
        JB      00H, END_READ; 如果00H标志位为1，跳转到END_READ
        JB      01H, END_READ; 如果01H标志位为1，跳转到END_READ
        MOV     R1, #30H     ; 设置R1指向存储红外数据的起始地址30H
        MOV     R2, #4       ; 设置R2为4，表示需要读取4个字节

READBYTE: 
        MOV     R3, #8       ; 设置R3为8，表示每个字节有8位
        CLR     A            ; 清除累加器A

READBIT: 
        RL      A            ; 将累加器A左移一位
        ACALL   ONEBIT       ; 调用读取一位二进制数子程序
        MOV     C, 10H       ; 将10H标志位的值移动到进位标志C
        MOV     ACC.0, C     ; 将进位标志C的值移动到累加器A的最低位
        DJNZ    R3, READBIT  ; 如果R3不为0，跳转到READBIT
        MOV     @R1, A       ; 将累加器A的值存储到R1指向的地址
        INC     R1           ; R1加1，指向下一个存储地址
        DJNZ    R2, READBYTE ; 如果R2不为0，跳转到READBYTE

END_READ: 
        RET                 ; 返回

T_HEAD1: 
        MOV     44H, #34    ; 设置比较值高8位为34
        MOV     43H, #51    ; 设置比较值低8位为51
        MOV     42H, #25    ; 设置比较值高8位为25
        MOV     41H, #154   ; 设置比较值低8位为154
        RET                 ; 返回

T_HEAD2: 
        MOV     44H, #18    ; 设置比较值高8位为18
        MOV     43H, #0     ; 设置比较值低8位为0
        MOV     42H, #14    ; 设置比较值高8位为14
        MOV     41H, #102   ; 设置比较值低8位为102
        RET                 ; 返回

T_BIT1: 
        MOV     44H, #2     ; 设置比较值高8位为2
        MOV     43H, #206   ; 设置比较值低8位为206
        MOV     42H, #1     ; 设置比较值高8位为1
        MOV     41H, #59    ; 设置比较值低8位为59
        RET                 ; 返回

T_BIT2: 
        MOV     44H, #6     ; 设置比较值高8位为6
        MOV     43H, #214   ; 设置比较值低8位为214
        MOV     42H, #5     ; 设置比较值高8位为5
        MOV     41H, #65    ; 设置比较值低8位为65
        RET                 ; 返回

T_LOW:  
        ; 计时低电平时长函数
        MOV     TL0, #00H   ; 初始化定时器0低8位
        MOV     TH0, #00H   ; 初始化定时器0高8位
        SETB    P3.3        ; 设置P3.3为高电平
        SETB    TR0         ; 启动定时器0
        JNB     P3.3, $     ; 等待P3.3变为低电平
        CLR     TR0         ; 停止定时器0
        RET                 ; 返回

T_HIGH: 
        ; 计时高电平时长函数
        MOV     TL0, #00H   ; 初始化定时器0低8位
        MOV     TH0, #00H   ; 初始化定时器0高8位
        SETB    P3.3        ; 设置P3.3为高电平
        SETB    TR0         ; 启动定时器0
        JB      P3.3, $     ; 等待P3.3变为高电平
        CLR     TR0         ; 停止定时器0
        RET                 ; 返回

COMPARE: 
        PUSH    ACC         ; 保存累加器A的值到堆栈
        CLR     00H         ; 清除标志位00H
        CLR     01H         ; 清除标志位01H
        CLR     C           ; 清除进位标志C
        MOV     A, 43H      ; 将43H寄存器的值移动到累加器A
        SUBB    A, TL0      ; 累加器A减去定时器0低8位的值
        MOV     A, 44H      ; 将44H寄存器的值移动到累加器A
        SUBB    A, TH0      ; 累加器A减去定时器0高8位的值
        MOV     01H, C      ; 将进位标志C的值移动到01H标志位
        CLR     C           ; 清除进位标志C
        MOV     A, TL0      ; 将定时器0低8位的值移动到累加器A
        SUBB    A, 41H      ; 累加器A减去41H寄存器的值
        MOV     A, TH0      ; 将定时器0高8位的值移动到累加器A
        SUBB    A, 42H      ; 累加器A减去42H寄存器的值
        MOV     00H, C      ; 将进位标志C的值移动到00H标志位
        POP     ACC         ; 恢复累加器A的值
        RET                 ; 返回

ONEBIT: 
        ; 读一位二进制数
        CLR     10H         ; 清除标志位10H
        ACALL   T_LOW       ; 调用低电平计时子程序
        ACALL   T_BIT1      ; 调用位1计时子程序
        LCALL   COMPARE     ; 调用比较子程序
        JB      00H, END_BIT; 如果00H标志位为1，跳转到END_BIT
        JB      01H, END_BIT; 如果01H标志位为1，跳转到END_BIT

BIT_0:  
        ACALL   T_HIGH      ; 调用高电平计时子程序
        ACALL   T_BIT1      ; 调用位1计时子程序
        LCALL   COMPARE     ; 调用比较子程序
        JB      00H, END_BIT; 如果00H标志位为1，跳转到END_BIT
        JB      01H, BIT_1  ; 如果01H标志位为1，跳转到BIT_1
        SJMP    END_BIT     ; 无条件跳转到END_BIT

BIT_1:  
        ACALL   T_BIT2      ; 调用位2计时子程序
        LCALL   COMPARE     ; 调用比较子程序
        JB      00H, END_BIT; 如果00H标志位为1，跳转到END_BIT
        JB      01H, END_BIT; 如果01H标志位为1，跳转到END_BIT
        SETB    10H         ; 设置标志位10H为1

END_BIT: 
        RET                 ; 返回

DELAY:  
        MOV     R6, #20     ; 设置R6为20

DEL1:   
        MOV     R7, #50     ; 设置R7为50

DEL2:   
        DJNZ    R7, DEL2    ; 如果R7不为0，跳转到DEL2
        DJNZ    R6, DEL1    ; 如果R6不为0，跳转到DEL1
        RET                 ; 返回

DELAY_400MS:                 ; 0.4s延时子程序
        MOV     R5, #4       ; 循环4次100ms延时

DELAY_100MS:
        MOV     R6, #200     

DEL_1:   
        MOV     R7, #250     

DEL_2:   
        DJNZ    R7, DEL_2    
        DJNZ    R6, DEL_1    
        DJNZ    R5, DELAY_100MS
        RET                 

        END                 ; 程序结束