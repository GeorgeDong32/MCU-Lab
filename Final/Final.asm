    ORG 0000H
    LJMP START
    ORG 000BH
    LJMP TIMER0_ISR
    ORG 0030H
    ; 变量定义
    FREQ_INDEX  EQU 30H     ; 当前频率索引
    TIME_COUNT  EQU 31H     ; 时间计数器
    HALF_SEC    EQU 461     ; 0.5秒对应的计数值
    LED_INDEX   EQU 32H     ; LED显示的数字索引
    FREQ_RAM    EQU 40H     ; 频率表在RAM中的起始地址(40H-49H)
    BEEP_BEEP_EN     EQU 33H     ; 扬声器使能标志EN    
START:
    ; 初始化定时器
    MOV TMOD, #01H      ; 设置定时器0为模式1
    MOV FREQ_INDEX, #0  ; 初始化频率索引
    MOV TIME_COUNT, #0  ; 初始化时间计数器
    MOV LED_INDEX, #0   ; 初始化LED显示索引

; 将频率表拷贝到RAM
    MOV R0, #FREQ_RAM   ; RAM目标地址
    MOV DPTR, #FREQ_TABLE
    MOV R1, #10         ; 拷贝10个字节(5个频率×2字节)
INIT_FREQ:
    CLR A
    MOVC A, @A+DPTR
    MOV @R0, A
    INC R0
    INC DPTR
    DJNZ R1, INIT_FREQ

    ; 初始化中断
    SETB ET0           ; 使能定时器0中断
    SETB EA            ; 使能全局中断
    ACALL SET_FREQ     ; 设置初始频率
    SETB TR0           ; 启动定时器0
MAIN_LOOP:
    ; LED扫描主循环
    MOV R1, #50       ; 外循环计数
OUTER_LOOP:
    MOV R2, #12       ; 内循环计数
INNER_LOOP:
    MOV R3, #00H      ; 行索引从0开始
SCAN_ROWS:
    ; 选择LED矩阵行
    MOV A, R3         
    ANL A, #07H       ; 保留低3位(0-7)
    ORL A, #0A0H      ; P1.5-P1.7置1
    MOV P0, #0FFH     
    MOV P1, A         
    ; 获取当前数字的列数据
    MOV A, LED_INDEX   
    RL A              
    RL A              
    RL A              
    ADD A, R3         
    MOV DPTR, #DIGITS_TABLE
    MOVC A, @A+DPTR   
    MOV P0, A         
    ACALL ROW_DELAY   
    INC R3            
    CJNE R3, #08H, SCAN_ROWS
    DJNZ R2, INNER_LOOP
    DJNZ R1, OUTER_LOOP
    SJMP MAIN_LOOP
; 定时器中断服务程序
TIMER0_ISR:
    PUSH ACC
    PUSH PSW
    CLR TF0
    
    ; 根据LED_INDEX控制扬声器 - 改进判断逻辑
    MOV A, LED_INDEX
    CLR C
    SUBB A, #5         ; LED_INDEX - 5
    JC MUTE_BEEP       ; 如果 < 5 则静音
    MOV A, LED_INDEX
    CLR C
    SUBB A, #10        ; LED_INDEX - 10  
    JNC MUTE_BEEP      ; 如果 >= 10 则静音
    
    ; LED_INDEX 在5-9之间,启用扬声器
    MOV A, LED_INDEX
    CLR C
    SUBB A, #5         ; 将5-9映射为0-4作为频率索引
    MOV FREQ_INDEX, A
    
    ; 判断是否要翻转蜂鸣器输出
    MOV A, TIME_COUNT  ; 仅在TIME_COUNT不为0时翻转,确保静音立即生效
    JZ SKIP_TOGGLE
    CPL P1.6           ; 翻转扬声器输出
SKIP_TOGGLE:    
    SJMP UPDATE_TIMER
MUTE_BEEP:
    CLR P1.6           ; 关闭扬声器
    MOV FREQ_INDEX, #0 ; 重置频率索引
UPDATE_TIMER:
    ; 从RAM中读取频率值
    MOV A, FREQ_INDEX
    ADD A, ACC        
    ADD A, #FREQ_RAM  
    MOV R0, A        
    MOV A, @R0       
    MOV TH0, A
    INC R0
    MOV A, @R0      
    MOV TL0, A

    ; 更新计数器
    INC TIME_COUNT
    MOV A, TIME_COUNT
    CJNE A, #HALF_SEC, TIMER_EXIT
    
    ; 0.5秒到,更新显示
    MOV TIME_COUNT, #0
    INC LED_INDEX
    MOV A, LED_INDEX
    CJNE A, #0AH, TIMER_EXIT
    MOV LED_INDEX, #00H

TIMER_EXIT:
    POP PSW
    POP ACC
    RETI
; 设置频率子程序
SET_FREQ:              
    MOV A, FREQ_INDEX
    ADD A, ACC        
    ADD A, #FREQ_RAM  
    MOV R0, A
    MOV A, @R0       
    MOV TH0, A
    INC R0
    MOV A, @R0       
    MOV TL0, A
    RET
; LED行扫描延时
ROW_DELAY:
    PUSH 4            ; 保存R4
    PUSH 5            ; 保存R5
    MOV R4, #02H     
    MOV R5, #07H     
DELAY_INNER:
    NOP              
    DJNZ R5, DELAY_INNER
    DJNZ R4, DELAY_INNER+1
    POP 5             ; 恢复R5
    POP 4             ; 恢复R4
    RET
; 数据表
FREQ_TABLE:
    ; 261Hz (DO)
    DB 0F9H, 15H     
    ; 294Hz (RE) 
    DB 0F9H, 0E5H    
    ; 330Hz (MI)
    DB 0FAH, 94H     
    ; 349Hz (FA)
    DB 0FAH, 0D8H    
    ; 392Hz (SOL)
    DB 0FBH, 67H     
DIGITS_TABLE:
    ; 数字0-9的LED显示模式
    DB      0E0H, 0EEH, 0EEH, 0EEH, 0EEH, 0EEH, 0E0H, 0FFH
    DB      0EFH, 0EFH, 0EFH, 0EFH, 0EFH, 0EFH, 0EFH, 0FFH
    DB      0E0H, 0EFH, 0EFH, 0E0H, 0FEH, 0FEH, 0E0H, 0FFH
    DB      0E0H, 0EFH, 0EFH, 0E0H, 0EFH, 0EFH, 0E0H, 0FFH
    DB      0EEH, 0EEH, 0EEH, 0E0H, 0EFH, 0EFH, 0EFH, 0FFH
    DB      0E0H, 0FEH, 0FEH, 0E0H, 0EFH, 0EFH, 0E0H, 0FFH
    DB      0E0H, 0FEH, 0FEH, 0E0H, 0EEH, 0EEH, 0E0H, 0FFH
    DB      0E0H, 0EFH, 0EFH, 0EFH, 0EFH, 0EFH, 0EFH, 0FFH
    DB      0E0H, 0EEH, 0EEH, 0E0H, 0EEH, 0EEH, 0E0H, 0FFH
    DB      0E0H, 0EEH, 0EEH, 0E0H, 0EFH, 0EFH, 0E0H, 0FFH
END