ORG 	0000H
        LJMP 	START
        ORG 	0030H
START:	MOV 	P0, #0FFH  ; 初始化 P0 端口为全高电平
        MOV 	P1, #0EEH ; 初始化 P1 端口，使LED灯组使能
        MOV 	P3, #04H   ; 初始化 P3.2 为输入
CHECK_KO:
        JB 	P3.2, ALL_OFF  ; 如果 P3.2 为高电平，跳转到 ALL_OFF
        ACALL	FLASH_LEDS    ; 否则，调用闪烁 LED 的子程序
        SJMP	CHECK_KO      ; 返回检查 KO 状态
ALL_OFF:
        MOV 	P0, #0FFH  ; 关闭所有 LED
        SJMP	CHECK_KO    ; 返回检查 KO 状态
FLASH_LEDS:
        MOV 	P0, #0F0H  ; 打开 LED2~LED5
        ACALL	DELAY_400MS ; 延时 0.4 秒
        MOV 	P0, #0FFH  ; 关闭 LED2~LED5
        ACALL	DELAY_400MS ; 延时 0.4 秒
        RET

DELAY_400MS: ;延时函数
        MOV    R1, #4 
DEL1:  	MOV    R2, #200
DEL2:  	MOV    R3, #229
DEL3:  	DJNZ   R3, DEL3
        DJNZ   R2, DEL2
        DJNZ   R1, DEL1
        RET
        END
