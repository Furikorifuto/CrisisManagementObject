;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Screen Loop Platform
; requested by CalHal
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Ex1:    YXPPCCC0
;	YX  - turn with ON/OFF
;	PP  - platform width (32pix,48pix,64pix,80pix)
;	CCC - color (gold,silver,yellow,...)
; Ex2:    speed x (00-FF)
; Ex3:    speed y (00-FF)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!platform_tile = $EB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
	;set platform width
	LDA !extra_byte_1,x
	LSR #4
	AND #$03
	STA !C2,x

	;set platform color
	LDA !extra_byte_1,x
	AND #$0E
	STA !1510,x
	RTL

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR sprite
	PLB
	RTL

clip_table:
	db $1D,$04,$33,$05
xpos_table:
	db $08,$10,$18,$20

sprite:
	JSR gfx
;---
	;loop code
	LDA !sprite_speed_x,x
	BEQ skip_horz_loop
	LDA !sprite_x_high,x
	XBA
	LDA !sprite_x_low,x
	REP #$20
	STA $00
	SEC
	SBC $1A
	CMP #$FFCE
	BMI +
	CMP #$0124
	BMI ++
	LDA $00
	SEC
	SBC #$0150
	SEP #$20
	STA !sprite_x_low,x
	XBA
	STA !sprite_x_high,x
	BRA ++
+
	LDA $00
	CLC
	ADC #$0150
	SEP #$20
	STA !sprite_x_low,x
	XBA
	STA !sprite_x_high,x
++
	SEP #$20
skip_horz_loop:
;---
	LDA !sprite_speed_y,x
	BEQ skip_vert_loop
	LDA !sprite_y_high,x
	XBA
	LDA !sprite_y_low,x
	REP #$20
	STA $00
	SEC
	SBC $1C
	CMP #$FFEE   ;00-14
	BMI +
	CMP #$00EC   ;E0+0C
	BMI ++
	LDA $00
	SEC
	SBC #$00F8
	SEP #$20
	STA !sprite_y_low,x
	XBA
	STA !sprite_y_high,x
	BRA ++
+
	LDA $00
	CLC
	ADC #$00F8
	SEP #$20
	STA !sprite_y_low,x
	XBA
	STA !sprite_y_high,x
++
	SEP #$20
skip_vert_loop:
;---
	LDA $9D
	BNE return
	%SubOffScreen()

	;save and set pointer
	LDA !C2,x
	TAY
	LDA !sprite_x_low,x
	SEC
	SBC xpos_table,y
	STA !sprite_x_low,x
	LDA !sprite_x_high,x
	SBC #$00
	STA !sprite_x_high,x
;---
	;set x speed
	LDA $14AF|!Base2
	AND #$01
	BEQ +

	;set speed
	LDA !extra_byte_1,x
	AND #$40
	BEQ +

	LDA !extra_byte_2,x
	EOR #$FF
	INC A
	STA !sprite_speed_x,x
	BRA ++
+
	LDA !extra_byte_2,x
	STA !sprite_speed_x,x
++
;---
	;set y speed
	LDA $14AF|!Base2
	AND #$01
	BEQ +

	;set speed
	LDA !extra_byte_1,x
	BPL +

	LDA !extra_byte_3,x
	EOR #$FF
	INC A
	STA !sprite_speed_y,x
	BRA ++
+
	LDA !extra_byte_3,x
	STA !sprite_speed_y,x
++
;---
	;move sprite
	JSL $01801A|!BankB
	JSL $018022|!BankB
	STA !1528,x
	LDA !C2,x
	TAY
	LDA clip_table,y
	STA !1662,x
	JSL $01B44F|!BankB
;---
	;load and reset pointer
	LDA !C2,x
	TAY
	LDA !sprite_x_low,x
	CLC
	ADC xpos_table,y
	STA !sprite_x_low,x
	LDA !sprite_x_high,x
	ADC #$00
	STA !sprite_x_high,x
return:
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sub gfx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
start_table:
	db $F8,$F0,$E8,$E0
gfx:
	%GetDrawInfo()
	
	LDA !sprite_oam_properties,x
	AND #$F1
	ORA !1510,x
	STA $04
	
	LDA !C2,x
	PHA
	INC A
	STA $02
	
	PLA
	PHX
	TAX
	LDA start_table,x
	STA $03
	
	LDX $02
-
	LDA $00
	CLC
	ADC $03
	STA $0300|!Base2,y

	LDA $01
	INC A
	STA $0301|!Base2,y

	LDA #!platform_tile
	CPX $02
	BNE +
	LDA #!platform_tile-1
+
	CPX #$00
	BNE +
	LDA #!platform_tile+1
+
	STA $0302|!Base2,y
	LDA $04
	ORA $64
	STA $0303|!Base2,y
	LDA $03
	CLC
	ADC #$10
	STA $03
	
	INY #4
	DEX
	BPL -

	PLX
	LDY #$02
	LDA $02
	%FinishOAMWrite()
	RTS