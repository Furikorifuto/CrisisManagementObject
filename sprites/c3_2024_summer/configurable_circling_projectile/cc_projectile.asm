;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Configurable circling projectile
; requested by Daizo Dee Von
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; exbit: tiny flag
; ex1: projectiles (n+3)
; ex2: max radius ((n+1)*8)
; ex3: speed
; ex4: tile
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	!radius = !187B
	!angle_low = !1602
	!angle_high = !1528

	!angle_low_mir = !1504
	!angle_high_mir = !1510
	!chase_index = !160E

	!x_low_mir = !151C
	!x_high_mir = !1534
	!y_low_mir = !1594
	!y_high_mir = !1626

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

	LDA #$FF
	STA !chase_index,x
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

angle_speed:
	dw $FFFC,$FFFD,$FFFE,$FFFF
	dw $0001,$0002,$0003,$0004

sprite:
	JSR gfx
	LDA #$00
	%SubOffScreen()
	LDA $9D
	BNE return

	LDA !chase_index,x
	BPL skip_check

	JSL $03B69F|!BankB
	LDY #!SprSize
-
	LDA !sprite_status,y
	CMP #$08
	BCC +
	PHX
	TYX
	JSL $03B6E5|!BankB
	PLX
	JSL $03B72B|!BankB
	BCC +
	TYA
	STA !chase_index,x
	BRA skip_check
+
	DEY
	BPL -
	BRA +
skip_check:
	PHX
	LDA !chase_index,x
	TAX
	LDA !sprite_x_low,x
	STA $00
	LDA !sprite_x_high,x
	STA $01
	LDA !sprite_y_low,x
	STA $02
	LDA !sprite_y_high,x
	STA $03	
	PLX
	
	LDA $00
	STA !sprite_x_low,x
	LDA $01
	STA !sprite_x_high,x
	LDA $02
	STA !sprite_y_low,x
	LDA $03
	STA !sprite_y_high,x
+
	;radius
	LDA !extra_byte_2,x
	INC A
	ASL #3
	STA $00

	LDA !radius,x
	INC A
	CMP $00
	BCS +
	STA !radius,x
+
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
	;check contact

	LDA !angle_low,x
	STA !angle_low_mir,x
	LDA !angle_high,x
	STA !angle_high_mir,x

	LDA !extra_byte_1,x
	CLC
	ADC #$02
	TAY
-
	PHY
	JSR get_angle

	LDA !sprite_x_low,x
	STA !x_low_mir,x
	LDA !sprite_x_high,x
	STA !x_high_mir,x
	LDA !sprite_y_low,x
	STA !y_low_mir,x
	LDA !sprite_y_high,x
	STA !y_high_mir,x

	LDA $04
	BMI +
	LDA !sprite_x_low,x
	CLC
	ADC $04
	STA !sprite_x_low,x
	LDA !sprite_x_high,x
	ADC #$00
	STA !sprite_x_high,x
	BRA ++
+
	LDA $04
	EOR #$FF
	INC A
	STA $04
	LDA !sprite_x_low,x
	SEC
	SBC $04
	STA !sprite_x_low,x
	LDA !sprite_x_high,x
	SBC #$00
	STA !sprite_x_high,x
++
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
	JSL $03B69F|!BankB
	JSL $03B664|!BankB
	JSL $03B72B|!BankB
	BCC +

	LDA !167A,x
	AND #$7F
	STA !167A,x
	JSL $01A7DC|!BankB
	LDA !167A,x
	AND #$80
	STA !167A,x
+
	LDA !y_high_mir,x
	STA !sprite_y_high,x
	LDA !y_low_mir,x
	STA !sprite_y_low,x
	LDA !x_high_mir,x
	STA !sprite_x_high,x
	LDA !x_low_mir,x
	STA !sprite_x_low,x

	PLY
	DEY
	BMI +
	JMP -
+

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

	STZ $02
	%BEC(+)
	LDA #$04
	STA $02
+
	LDA $00
	CLC
	ADC $04
	CLC
	ADC $02
	STA $0300|!Base2,y

	LDA $01
	CLC
	ADC $06
	CLC
	ADC $02
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

	%BES(+)
	LDY #$02  ;16x16
	BRA ++
+
	LDY #$00  ;8x8
++
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
	