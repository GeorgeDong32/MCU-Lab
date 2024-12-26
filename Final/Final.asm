; 中断向量表设置
    ORG 0000H       ; 程序起始地址
    LJMP START      ; 上电后跳转到主程序
    ORG 000BH       ; 定时器0中断向量地址
    LJMP TMR_ISR    ; 跳转到定时器中断服务程序
    ORG 0030H       ; 程序代码起始地址
    ; 全局变量定义
    FREQ_IDX    EQU 30H     ; 当前播放音符的索引(0-4)
    TMR_CNT     EQU 31H     ; 定时器计数值(用于0.5秒计时)
    HALF_SEC    EQU 461     ; 半秒计数阈值(12MHz晶振)
    LED_IDX     EQU 32H     ; 当前显示数字的索引(0-9)
    FREQ_MEM    EQU 40H     ; 频率表在RAM中的起始地址(40H-49H)
    BEEP_EN     EQU 33H     ; 蜂鸣器使能控制位

START:
    MOV TMOD, #01H          ; 设置定时器0为16位模式
    MOV FREQ_IDX, #0        ; 初始化音符索引
    MOV TMR_CNT, #0         ; 清零计时器计数
    MOV LED_IDX, #0         ; 初始化显示为数字0
    ; ROM到RAM的频率表复制
    MOV R0, #FREQ_MEM       ; R0指向RAM目标地址
    MOV DPTR, #FREQ_TABLE   ; DPTR指向ROM源数据
    MOV R1, #10             ; 需要复制10个字节(5个音符)

INIT_FREQ:                ; 频率表初始化循环
    CLR A                 ; 累加器清零
    MOVC A, @A+DPTR       ; 从ROM读取频率数据
    MOV @R0, A            ; 保存到RAM
    INC R0                ; RAM指针+1
    INC DPTR              ; ROM指针+1
    DJNZ R1, INIT_FREQ    ; 循环直到复制完成

    SETB ET0              ; 使能定时器0中断
    SETB EA               ; 使能全局中断
    ACALL SET_FREQ        ; 设置初始频率
    SETB TR0              ; 启动定时器0

MAIN:                     ; LED扫描主循环
    MOV R1, #50           ; 外循环:显示刷新率控制
LOOP1: 
    MOV R2, #12          ; 中循环:消除显示闪烁
LOOP2: 
    MOV R3, #00H         ; 内循环:8行LED逐行扫描
LOOP3:
    MOV A, R3            ; 获取当前扫描行号
    ANL A, #07H          ; 确保行号在0-7范围内
    ORL A, #0A0H         ; 设置P1.5-P1.7为1
    MOV P0, #0FFH        ; 暂时关闭所有LED列
    MOV P1, A            ; 选通当前行

    ; LED显示数据获取与输出
    MOV A, LED_IDX       ; 获取当前显示的数字
    RL A                 ; 左移3次(相当于乘8)
    RL A                 ; 因为每个数字占8行数据
    RL A                 
    ADD A, R3            ; 加上当前行号
    MOV DPTR, #LED_TABLE ; 指向LED字形表
    MOVC A, @A+DPTR      ; 读取当前行的显示数据
    MOV P0, A            ; 输出到LED列
    ACALL ROW_DELAY
    INC R3
    CJNE R3, #08H, LOOP3
    DJNZ R2, LOOP2
    DJNZ R1, LOOP1
    SJMP MAIN

TMR_ISR:                 ; 定时器0中断服务程序
    PUSH ACC             ; 保护ACC和PSW
    PUSH PSW
    CLR TF0              ; 清除定时器溢出标志

    ; 根据LED_IDX控制蜂鸣器
    MOV A, LED_IDX       
    CLR C
    SUBB A, #5           ; 判断是否>=5
    JC MUTE_BEEP         ; <5则静音
    MOV A, LED_IDX
    CLR C
    SUBB A, #10          ; 判断是否<10
    JNC MUTE_BEEP        ; >=10则静音
    
    MOV A, LED_IDX
    CLR C                ; 清除进位标志
    SUBB A, #5           ; 计算频率索引
    MOV FREQ_IDX, A      ; 保存频率索引
    
    MOV A, TMR_CNT       ; 获取定时器计数值
    JZ SKIP_T            ; 如果计数值为0则跳过
    CPL P1.6             ; 反转蜂鸣器控制位
SKIP_T:    
    SJMP UPDATE_TMR
MUTE_BEEP:
    CLR P1.6
    MOV FREQ_IDX, #0
UPDATE_TMR:
    MOV A, FREQ_IDX       ; 获取当前频率索引
    ADD A, ACC            ; 频率值占2字节
    ADD A, #FREQ_MEM      ; 加上频率表基址
    MOV R0, A             ; R0指向频率数据
    MOV A, @R0            ; 读取高字节
    MOV TH0, A            ; 设置定时器高字节
    INC R0                ; 指向低字节
    MOV A, @R0            ; 读取低字节
    MOV TL0, A            ; 设置定时器低字节
    INC TMR_CNT           ; 计数器加1
    MOV A, TMR_CNT        ; 获取计数器值
    CJNE A, #HALF_SEC, TMR_EXIT ; 判断是否达到半秒
    MOV TMR_CNT, #0       ; 重置计数器
    INC LED_IDX           ; LED索引加1
    MOV A, LED_IDX        ; 获取LED索引
    CJNE A, #0AH, TMR_EXIT ; 判断是否达到10
    MOV LED_IDX, #00H     ; 重置LED索引
TMR_EXIT:
    POP PSW
    POP ACC
    RETI

SET_FREQ:                ; 设置蜂鸣器频率子程序
    MOV A, FREQ_IDX      ; 获取频率索引
    ADD A, ACC           ; 乘2(每个频率占2字节)
    ADD A, #FREQ_MEM     ; 加上RAM基址
    MOV R0, A            ; R0指向频率数据
    MOV A, @R0           ; 读取高字节
    MOV TH0, A           ; 设置定时器高字节
    INC R0
    MOV A, @R0
    MOV TL0, A
    RET

ROW_DELAY:  ; LED行扫描延时
    PUSH 4
    PUSH 5
    MOV R4, #02H
    MOV R5, #07H

DELAY_LOOP: ; 延时循环
    NOP
    DJNZ R5, DELAY_LOOP
    DJNZ R4, DELAY_LOOP+1
    POP 5
    POP 4
    RET

FREQ_TABLE:             ; 频率表(定时器初值)
    DB 0F9H, 15H        ; DO   (261Hz) - TH,TL
    DB 0F9H, 0E5H       ; RE   (294Hz)
    DB 0FAH, 94H        ; MI   (330Hz)
    DB 0FAH, 0D8H       ; FA   (349Hz)
    DB 0FBH, 67H        ; SOL  (392Hz)

LED_TABLE:               ; LED点阵字形数据(8×8)
    ; 每个数字占8字节,每字节代表一行,1灭0亮
    DB 0E0H,0EEH,0EEH,0EEH,0EEH,0EEH,0E0H,0FFH  ; 数字0
    DB 0EFH,0EFH,0EFH,0EFH,0EFH,0EFH,0EFH,0FFH  ; 数字1
    DB 0E0H,0EFH,0EFH,0E0H,0FEH,0FEH,0E0H,0FFH  ; 数字2
    DB 0E0H,0EFH,0EFH,0E0H,0EFH,0EFH,0E0H,0FFH  ; 数字3
    DB 0EEH,0EEH,0EEH,0E0H,0EFH,0EFH,0EFH,0FFH  ; 数字4
    DB 0E0H,0FEH,0FEH,0E0H,0EFH,0EFH,0E0H,0FFH  ; 数字5
    DB 0E0H,0FEH,0FEH,0E0H,0EEH,0EEH,0E0H,0FFH  ; 数字6
    DB 0E0H,0EFH,0EFH,0EFH,0EFH,0EFH,0EFH,0FFH  ; 数字7
    DB 0E0H,0EEH,0EEH,0E0H,0EEH,0EEH,0E0H,0FFH  ; 数字8
    DB 0E0H,0EEH,0EEH,0E0H,0EFH,0EFH,0E0H,0FFH  ; 数字9
END