;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Taily Ball
; requested by Roberto zampari
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!tile = $EA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
	RTL

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR sprite
	PLB
	RTL

sprite:
	JSR gfx
	LDA #$00
	%SubOffScreen()
	LDA $9D
	BNE return

	;sprite move
	JSL $01802A|!BankB
	JSL $01A7DC|!BankB

	LDA !sprite_blocked_status,x
	AND #$04
	BEQ +
	STZ !sprite_status,x

	LDA !15A0,x
	ORA !186C,x
	BNE +

	LDA !sprite_y_low,x
	STA $98
	LDA !sprite_y_high,x
	STA $99
	LDA !sprite_x_low,x
	STA $9A
	LDA !sprite_x_high,x
	STA $9B
	
	PHB
	LDA #$02
	PHA
	PLB
	LDA #$00
	JSL $028663|!BankB
	PLB
+
return:
	RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sub gfx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gfx:
	%GetDrawInfo()

	LDA $00
	STA $0300|!Base2,y

	LDA $01
	STA $0301|!Base2,y

	LDA #!tile
	STA $0302|!Base2,y

	LDA !sprite_oam_properties,x
	ORA $64
	STA $0303|!Base2,y

	LDY #$02
	LDA #$00
	%FinishOAMWrite()
	RTS