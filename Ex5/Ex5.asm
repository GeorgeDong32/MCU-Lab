        ORG     0000H ; 指定下一条长转移指令的地址为0000H。使单片机开机能自动执行
        LJMP    START ; 长转移指令，跳转至主程序段执行
        ORG     0050H ; 指定标号为START的主程序段起始地址为0050H
START:  MOV     SP, #60H ; 设置堆栈指针
        MOV     R5, #16 ; 送16到寄存器R5，(R5)-16
        MOV     R3, #0EEH ; 送0EEH到寄存器R3，(R3)-0EEH
        MOV     40H, #00H ; 送00H到40H单元
MAIN:   MOV     P1, R3 ; 将R3的数据传送到P1口，实现对应的数码管点亮
        MOV     A, R5 ; 将R5的数据送入累加器A
        MOV     DPTR, #TAB2 ; 送TAB2的地址到DPTR
        MOVC    A, @A+DPTR ; 查表指令，TAB2为数码管能显示的数字/字母表
        MOV     P0, A ; 将ACC的数据送到P0口，数码管能显示对应数字/字母
        LCALL   DELAY ; 长调用DELAY延时子程序，延时0.1s
        ACALL   JUDGE ; 绝对调用JUDGE子程序，判断是否有按键被按下
        JZ      MAIN ; 累加器内容为0则转MAIN执行，即没有按键按下就再次循环
        LCALL   DELAY ; 长调用DELAY延时子程序，延时0.1s
        ACALL   JUDGE ; 绝对调用JUDGE子程序，判断是否有按键被按下
        JZ      MAIN ; 累加器内容为0则转MAIN执行，即没有按键按下就再次循环
        DEC     R3 ; R3内容减一
        CJNE    R3, #0E7H, MAIN1 ; 判断R3=0E7H，不等则转MAIN1执行，相等则执行下一条语句
        MOV     R3, #0EDH ; 送0E7H到寄存器R3，(R3)-0E7H

MAIN1:  ACALL   KEY ; 绝对调用KEY子程序，查询按键对应的行列值
        ACALL   NUM ; 绝对调用NUM子程序，将按键行列值与相应的数字/字母对应起来
        LJMP    MAIN ; 长转移指令，转MAIN执行

JUDGE:
        MOV     P2, #0FH ; 送0FFH到P2口，(P2)-0FH=00001111B
        MOV     A, P2 ; 将P2的数据送入累加器
        CLR     C ; 把进位清零
        SUBB    A, #0FH ; A中数据减去0FFH，若有按键按下，则减去0FFH后累加器内容不为0
        RET ; 子程序返回

KEY:    PUSH    ACC ; 压栈操作，将ACC中的数据压入堆栈
K_LINE: MOV     P2, #0FH ; 送0FH到P2口，(P2)-0FH=00001111B
        MOV     A, P2 ; 将P2的数据送入累加器
        MOV     R1, A ; 将A的数据送入寄存器R1
K_ROW:  MOV     P2, #0F0H ; 送0F0H到P2口，(P2)-0F0H=11110000B
        MOV     A, P2 ; 将P2的数据送入累加器
        MOV     R1, A ; 将A的数据送入寄存器R0
K_VALUE:
        MOV     A, R1 ; 将R1的内容送入累加器
        ANL     A, #0FH ; 将A的内容与0FH相与，即清空数据的高4位
        MOV     R1, A ; 将A的数据送入寄存器R1
        MOV     A, R0
        ANL     A, #0F0H ; 将A的内容与0FH相与，即清空数据的高4位
        ORL     A, R1 ; 将R1的内容与A的内容相或
        MOV     40H, A ; 将A的内容送入40H单元
        POP     ACC
        RET ; 子程序返回

; 此子程序用于查询按键行列值所对应的数字/字母
NUM:    PUSH    DPL ; 压栈操作，将DPL中数据送入堆栈
        PUSH    DPH ; 压栈操作，将DPH中数据送入堆栈
        PUSH    ACC ; 压栈操作，将ACC中数据送入堆栈
        MOV     DPTR, #TAB1 ; 表格初始化，TAB1为按键对应的行列值
        MOV     R5, #0FFH ; 送0FFH到寄存器R5，(R5)-0FFH
NUM0:   INC     R5 ; R5内容加一
        MOV     A, R5 ; 将R5中的数据送入累加器
        MOVC    A, @A+DPTR ; 查表指令
        CLR     C ; 把进位清零
        SUBB    A, 40H ; 累加器中数据减去40H中数据
        JNZ     NUM0 ; 累加器A中内容不为0则转NUM0执行，对应应表格中的行列值则不再循环
NUM1:   LCALL   DELAY ; 长调用DELAY延时子程序，延时0.1s
        MOV     P2, #0FH ; 送0FH到寄存器R2，(R2)-0FH
        MOV     A, P2 ; 将P2的数据送入累加器
        CJNE    A, #0FH, NUM1 ; 判断A=0FH，不等则转NUM1的执行
        POP     ACC ; 出栈操作，将数据从堆栈中取出送回ACC
        POP     DPH ; 出栈操作，将数据从堆栈中取出送回DPH
        POP     DPL ; 出栈操作，将数据从堆栈中取出送回DPL
        RET ; 子程序返回

DELAY:  MOV R7, #20 ; 送20到R7，(R7)-20
        MOV R6, #229 ; 送229到R6，(R6)-229
DEL1:   DJNZ R6, DEL2 ; R6内容减一，非0则转DEL2执行
DEL2:   DJNZ R7, DEL1 ; R7内容减一，非0则转DEL1执行
        RET ; 子程序返回

TAB1: 	DB 0EEH, 0E7H, 0D7H, 0B7H, 0EBH, 0DBH, 0BBH, 0EDH, 0DDH, 0BDH, 77H, 7BH, 7EH, 7DH, 0DEH, 0BEH ; 数据表1
TAB2: 	DB 0C0H, 0F9H, 0A4H, 0B0H, 99H, 92H, 82H, 0F8H, 80H, 90H, 88H, 83H, 0C6H, 0A1H, 86H, 8EH, 0FFH ; 数据表2
        END                 ; 程序结束