;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Cement/Cloud Ring
; requested by Daizo Dee Von
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; exbit: Cement / Cloud
; ex1: projectiles (n+3)
; ex2: max radius ((n+1)*8)
; ex3: speed
; ex4: tile
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	!radius = !187B
	!angle_low = !1602
	!angle_high = !160E

	!angle_low_mir = !1504
	!angle_high_mir = !1510

	!ride_num   = !extra_prop_1
	!ride_mir   = !extra_prop_2
	!flame_move = !C2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
	LDA !extra_byte_1,x
	AND #$07
	STA !extra_byte_1,x
	LDA !extra_byte_2,x
	AND #$07
	STA !extra_byte_2,x

	;radius
	LDA !extra_byte_2,x
	INC A
	ASL #3
	STA !radius,x
	RTL

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR sprite
	PLB
	RTL

return:
	RTS

sprite:
	JSR gfx
	LDA #$00
	%SubOffScreen()
	LDA $9D
	BNE return

	LDA !extra_byte_3,x
	BMI +
 
	LDA !extra_byte_3,x
	CLC
	ADC !angle_low,x
	STA !angle_low,x
	LDA !angle_high,x
	ADC #$00
	STA !angle_high,x
	BRA ++
+
	LDA !extra_byte_3,x
	CLC
	ADC !angle_low,x
	STA !angle_low,x
	LDA !angle_high,x
	ADC #$FF
	STA !angle_high,x
++
	LDA !angle_low,x
	STA !angle_low_mir,x
	LDA !angle_high,x
	STA !angle_high_mir,x

	;check_contact
	LDA !extra_byte_1,x
	CLC
	ADC #$02
	TAY
-
	PHY
	JSR check_platform
	LDA !extra_byte_1,x
	TAY
	LDA angle_addr,y
	CLC
	ADC !angle_low_mir,x
	STA !angle_low_mir,x
	LDA !angle_high_mir,x
	ADC #$00
	STA !angle_high_mir,x
	PLY

	DEY
	BPL -
	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; check platform
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check_platform:

	;check contact
	LDA !sprite_x_low,x
	PHA
	LDA !sprite_x_high,x
	PHA
	LDA !sprite_y_low,x
	PHA
	LDA !sprite_y_high,x
	PHA

	;get angle
	LDA !angle_high_mir,x
	XBA
	LDA !angle_low_mir,x
	
	REP #$20
	AND #$01FF
	STA $00
	SEP #$20

	PHY
	LDA !radius,x
	TAY
	JSR get_angle_main
	PLY

;check x
	LDA $04
	BMI x_minus
	LDA !sprite_x_low,x
	CLC
	ADC $04
	STA !sprite_x_low,x
	PHP

	TYA
	CMP !ride_num,x
	BNE ++
	CMP !ride_mir,x
	BEQ +
	LDA !sprite_x_low,x
	STA !flame_move,x
	LDA !ride_num,x
	STA !ride_mir,x
+
	LDA !sprite_x_low,x
	SEC
	SBC !flame_move,x
	STA !1528,x
	LDA !sprite_x_low,x
	STA !flame_move,x
++
	PLP
	LDA !sprite_x_high,x
	ADC #$00
	STA !sprite_x_high,x
	BRA check_y
x_minus:
	LDA $04
	EOR #$FF
	INC A
	STA $04
	LDA !sprite_x_low,x
	SEC
	SBC $04
	STA !sprite_x_low,x
	PHP

	TYA
	CMP !ride_num,x
	BNE ++
	CMP !ride_mir,x
	BEQ +
	LDA !sprite_x_low,x
	STA !flame_move,x
	LDA !ride_num,x
	STA !ride_mir,x
+
	LDA !sprite_x_low,x
	SEC
	SBC !flame_move,x
	STA !1528,x
	LDA !sprite_x_low,x
	STA !flame_move,x
++
	PLP
	LDA !sprite_x_high,x
	SBC #$00
	STA !sprite_x_high,x
check_y:
	LDA $06
	BMI +
	LDA !sprite_y_low,x
	CLC
	ADC $06
	STA !sprite_y_low,x
	LDA !sprite_y_high,x
	ADC #$00
	STA !sprite_y_high,x
	BRA ++
+
	LDA $06
	EOR #$FF
	INC A
	STA $06
	LDA !sprite_y_low,x
	SEC
	SBC $06
	STA !sprite_y_low,x
	LDA !sprite_y_high,x
	SBC #$00
	STA !sprite_y_high,x
++
;;;;;
	%BEC(+)
	LDA !190F,x
	ORA #$01
	STA !190F,x
+
;solid sprite

	PHY
	JSL $01B44F|!BankB
	PLY
	BCC +
	TYA
	STA !ride_num,x
+
	PLA
	STA !sprite_y_high,x
	PLA
	STA !sprite_y_low,x
	PLA
	STA !sprite_x_high,x
	PLA
	STA !sprite_x_low,x

	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sub gfx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gfx:
	%GetDrawInfo()

	LDA !angle_low,x
	STA !angle_low_mir,x
	LDA !angle_high,x
	STA !angle_high_mir,x

	PHX
	LDA !extra_byte_1,x
	CLC
	ADC #$02
	TAX
-
	JSR get_angle

	PHX
	LDX $15E9|!Base2

	LDA $00
	CLC
	ADC $04
	STA $0300|!Base2,y

	LDA $01
	CLC
	ADC $06
	STA $0301|!Base2,y

	;set tile
	LDA !extra_byte_4,x
	STA $0302|!Base2,y

	;set prop
	LDA !sprite_oam_properties,x
	ORA $64
	STA $0303|!Base2,y
	PLX

	INY #4
	DEX
	BPL -
	PLX

	LDY #$02  ;16x16
	LDA !extra_byte_1,x
	CLC
	ADC #$02
	%FinishOAMWrite()

skip_gfx:
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;graphic angle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
angle_addr:
	db $AA,$80,$66,$55
	db $49,$40,$38,$33
get_angle:
	PHY
	LDA $00
	PHA
	LDA $01
	PHA
	
	TXA
	ASL
	TAY
	
	PHX
	LDX $15E9|!Base2

	PHY
	LDA !extra_byte_1,x
	TAY
	LDA angle_addr,y
	CLC
	ADC !angle_low_mir,x
	STA !angle_low_mir,x
	LDA !angle_high_mir,x
	ADC #$00
	STA !angle_high_mir,x
	PLY

	LDA !angle_high_mir,x
	XBA
	LDA !angle_low_mir,x
	
	REP #$20
	AND #$01FF
	STA $00
	SEP #$20
	
	LDA !radius,x
	PLX
	TAY
	JSR get_angle_main

	PLA
	STA $01
	PLA
	STA $00
	PLY
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sin cos routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

get_angle_main:

	PHX
	TYA
	STA $08

	REP #$30
	LDA $00
	
	CLC
	ADC #$0080
	AND #$01FF
	STA $02

	LDA $00
	ASL
	AND #$01FF
	TAX
	LDA $07F7DB|!BankB,x
	STA $04
	
	LDA $02
	ASL
	AND #$01FF
	TAX
	LDA $07F7DB|!BankB,x
	STA $06

	SEP #$30
	
	LDA $04
	
	if !SA1
		STZ $2250
		STA $2251
		STZ $2252
	else
		STA $4202
	endif
	
	LDA $08
	LDY $05
	BNE +
	
	if !SA1
		STA $2253
		STZ $2254
	else
		STA $4203
	endif
	
	NOP #4
	
	if !SA1
		ASL $2306
		LDA $2307
	else
		ASL $4216
		LDA $4217
	ADC #$00
	endif
	
	ADC #$00
+
	LSR $01
	BCC +
	EOR #$FF
	INC A
+
	STA $04

	LDA $06
	
	if !SA1
		STZ $2250
		STA $2251
		STZ $2252
	else
		STA $4202
	endif
	
	LDA $08
	LDY $07
	BNE +
	
	if !SA1
		STA $2253
		STZ $2254
	else
		STA $4203
	endif
	
	NOP #4
	
	if !SA1
		ASL $2306
		LDA $2307
	else
		ASL $4216
		LDA $4217
	ADC #$00
	endif
	
+
	LSR $03
	BCC +
	EOR #$FF
	INC A
+
	STA $06
	
	PLX
	RTS
	