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
        MOV     32H, #7FH    ; 初始化存储红外数据的寄存器32H
        MOV     33H, #00H    ; 初始化存储红外数据的寄存器33H

DISP:   
        MOV     P1, #0E8H    ; 设置P1端口输出值为0E8H
        MOV     A, 32H       ; 将32H寄存器的值移动到累加器A
        ACALL   CONVERT      ; 调用转换子程序
        MOV     P0, A        ; 将累加器A的值输出到P0端口
        LCALL   DELAY        ; 调用延时子程序
        SJMP    DISP         ; 无条件跳转到DISP标签处

INFARED: 
        PUSH    ACC          ; 保存累加器A的值到堆栈
        CLR     EA           ; 关闭全局中断
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
        MOV     44H, #34    ; 设置比较值高8位为34H
        MOV     43H, #51    ; 设置比较值低8位为51H
        MOV     42H, #25    ; 设置比较值高8位为25H
        MOV     41H, #154   ; 设置比较值低8位为154H
        RET                 ; 返回

T_HEAD2: 
        MOV     44H, #18    ; 设置比较值高8位为18H
        MOV     43H, #0     ; 设置比较值低8位为0
        MOV     42H, #14    ; 设置比较值高8位为14H
        MOV     41H, #102   ; 设置比较值低8位为102H
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

CONVERT:
        ; 根据32H的值转换输出到P0口
        CJNE    A, #7FH, CHECK_68 ; 如果A不等于7FH，跳转到CHECK_B0
        MOV     A, #7FH    ; 将7FH移动到累加器A
        RET

CHECK_68:        
        CJNE    A, #68H, CHECK_B0 ; 如果A不等于68H，跳转到CHECK_B0
        MOV     A, #0C0H    ; 将0C0H移动到累加器A
        RET

CHECK_B0:
        CJNE    A, #30H, CHECK_18 ; 如果A不等于30H，跳转到CHECK_18
        MOV     A, #0F9H    ; 将0F9H移动到累加器A
        RET

CHECK_18:
        CJNE    A, #18H, CHECK_7A  ; 如果A不等于18H，跳转到CHECK_7A
        MOV     A, #0A4H    ; 将0A4H移动到累加器A
        RET

CHECK_7A:
        CJNE    A, #7AH, CHECK_10  ; 如果A不等于7AH，跳转到CHECK_10
        MOV     A, #0B0H    ; 将0B0H移动到累加器A
        RET

CHECK_10:
        CJNE    A, #10H, CHECK_38  ; 如果A不等于10H，跳转到CHECK_38
        MOV     A, #99H     ; 将99H移动到累加器A
        RET

CHECK_38:
        CJNE    A, #38H, CHECK_5A  ; 如果A不等于38H，跳转到CHECK_5A
        MOV     A, #92H     ; 将92H移动到累加器A
        RET

CHECK_5A:
        CJNE    A, #5AH, CHECK_42  ; 如果A不等于5AH，跳转到CHECK_42
        MOV     A, #82H     ; 将82H移动到累加器A
        RET

CHECK_42:
        CJNE    A, #42H, CHECK_4A  ; 如果A不等于42H，跳转到CHECK_4A
        MOV     A, #0F8H    ; 将0F8H移动到累加器A
        RET

CHECK_4A:
        CJNE    A, #4AH, CHECK_52  ; 如果A不等于4AH，跳转到CHECK_52
        MOV     A, #80H     ; 将80H移动到累加器A
        RET

CHECK_52:
        CJNE    A, #52H, END_CONVERT ; 如果A不等于52H，跳转到END_CONVERT
        MOV     A, #90H     ; 将90H移动到累加器A
        RET

END_CONVERT:
        MOV     A, P0       ; 读取P0口的值赋给累加器A
        RET                 ; 返回

DELAY:  
        MOV     R6, #20     ; 设置R6为20

DEL1:   
        MOV     R7, #50     ; 设置R7为50

DEL2:   
        DJNZ    R7, DEL2    ; 如果R7不为0，跳转到DEL2
        DJNZ    R6, DEL1    ; 如果R6不为0，跳转到DEL1
        RET                 ; 返回

        END                 ; 程序结束