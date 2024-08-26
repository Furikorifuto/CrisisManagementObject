;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Taily(Beta)
; requested by Roberto zampari
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; exbit: no
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!sprite = $0D ;spawn sprite num

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

return:
	RTS

speed_table:
	db $F8,$08

sprite:
	JSR gfx
	LDA #$00
	%SubOffScreen()
	LDA $9D
	BNE return

	%BES(+)
	%SubHorzPos()
	TYA
	EOR #$01
	STA !157C,x
	BRA ++
+
	;check wall
	JSL $019138|!BankB
	LDA !sprite_blocked_status,x
	AND #$03
	BEQ +
	LDA !157C,x
	EOR #$01
	STA !157C,x
+
	LDA !157C,x
	TAY
	LDA speed_table,y
	STA !sprite_speed_x,x
++
	LDA !1540,x
	CMP #$20
	BCC +
	LDA !154C,x
	BNE +
	;sprite move
	JSL $01801A|!BankB
	JSL $018022|!BankB
+
	JSL $01A7DC|!BankB

	LDA !1540,x
	BNE +

	LDA #$40
	%Random()
	CLC
	ADC #$60
	STA !1540,x

	LDA #$10
	STA !154C,x

	STZ $00
	STZ $01
	STZ $02
	STZ $03

	SEC
	LDA #!sprite
	%SpawnSprite()
+
	RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sub gfx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tilemap:
	db $E0,$E2     ;walk
	db $E4,$E6,$E8 ;shot

gfx:
	%GetDrawInfo()

	LDA !1540,x
	CMP #$10
	BCS +
	LDA #$03
	BRA ++
+
	%BEC(+)
	LDA !1540,x
	CMP #$20
	BCC +
	LDA !sprite_x_low,x
	LSR #2
	AND #$01
	BRA ++
+
	LDA #$02
++
	STA !C2,x

	LDA !154C,x
	BEQ +
	LDA #$04
	STA !C2,x
+
	;set tile
	PHY
	LDA !C2,x
	TAY
	LDA tilemap,y
	STA $02
	PLY

	;set prop
	LDA !157C,x
	ASL #6
	ORA !sprite_oam_properties,x
	STA $03

	LDA $00
	STA $0300|!Base2,y

	LDA $01
	STA $0301|!Base2,y

	LDA $02
	STA $0302|!Base2,y

	LDA $03
	ORA $64
	STA $0303|!Base2,y

	LDY #$02
	LDA #$00
	%FinishOAMWrite()

skip_gfx:
	RTS