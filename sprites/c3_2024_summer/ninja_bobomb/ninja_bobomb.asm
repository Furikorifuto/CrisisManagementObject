;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Ninja Bobomb
; requested by Rykon-V73
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; exbit: no
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!tile = $CC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
	STZ !C2,x
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

	%SubHorzPos()
	TYA
	EOR #$01
	STA !157C,x

	LDA !C2,x
	BEQ wait
	DEC
	BNE fall
	JMP hide

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fall:
	JSL $01802A|!BankB

	LDA #$80
	STA !1510,x

	JSR subvertposplus
	REP #$20
	LDA $0E
	BPL +
	SEP #$20

	LDA #$0D		; \ turn sprite
	STA !9E,x		; / into bob-omb
	JSL $07F7D2|!BankB	; reset sprite tables
	LDA #$08		; \ sprite status:
	STA !14C8,x		; / normal
	LDA #$01		; \ make it
	STA !1534,x		; / explode
	LDA #$30		; \ set time for
	STA !1540,x		; / explosion
	LDA #$09		; \ play sound
	STA $1DFC|!Base2	; / effect
+
	SEP #$20
return:
	RTS

colortable:
	db $08,$04,$0A,$06

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wait:
	;is near
	%SubHorzPos()
	REP #$20
	LDA $0E
	CLC
	ADC #$0020
	CMP #$0040
	BCS +
	SEP #$20

	JSR subvertposplus
	REP #$20
	LDA $0E
	CLC
	ADC #$0040
	CMP #$0080
	BCS +

	SEP #$20
	LDA #$01
	STA !C2,x

	LDA #$40
	%Random()
	CLC
	ADC #$40
	STA !1540,x

	PHX
	STZ $00
	STZ $01
	LDA #$17
	STA $02
	LDA #$01
	%SpawnSmoke()
	PLX
+
	SEP #$20
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
hide:
	LDA $94
	STA !sprite_x_low,x
	LDA $95
	STA !sprite_x_high,x

	LDA $96
	SEC
	SBC #$40
	STA !sprite_y_low,x
	LDA $97
	SBC #$00
	STA !sprite_y_high,x

	LDA !1540,x
	BNE +

	PHX
	STZ $00
	STZ $01
	LDA #$17
	STA $02
	LDA #$01
	%SpawnSmoke()
	PLX

	LDA #$02
	STA !C2,x
	LDA #$20
	STA !sprite_speed_y,x
+
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

subvertposplus:
    LDA $96
    SEC
    SBC !sprite_y_low,x
    STA $0E
    LDA $97
    SBC !sprite_y_high,x
    STA $0F
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sub gfx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gfx:
	%GetDrawInfo()
	LDA !C2,x
	CMP #$01
	BNE +
	RTS
+
	;set prop
	LDA !157C,x
	ASL #6
	STA $03

	LDA !C2,x
	BNE +
	LDA !sprite_oam_properties,x
	ORA $03
	STA $03
	BRA ++
+
	LDA !sprite_oam_properties,x
	AND #$F1
	ORA !1510,x
	ORA $03
	STA $03
++
	LDA $00
	STA $0300|!Base2,y

	LDA $01
	STA $0301|!Base2,y

	LDA #!tile
	STA $0302|!Base2,y

	LDA $03
	ORA $64
	STA $0303|!Base2,y

	LDY #$02
	LDA #$00
	%FinishOAMWrite()

skip_gfx:
	RTS