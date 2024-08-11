;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Better Cheep-Cheep
; requested by GooberFan75000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ex1 - base speed
; ex2 - turn timer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Differences from the original
; .can set speed and timer
; .vertical fish faces player
; .add Sonikku's wet timer
; .fix star point
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tilemap:
	db $67,$69,$88,$CE   ;gfx tiles
tilepage:
	db $01,$01,$00,$00   ;gfx page
KickedXSpeed:
	db $F0,$10

	!vert_flip = !C2
	!gnd_to_water = !1504
	!timer = !1540
	!wet_timer = !1558
	!pose = !1602

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
	LDA #$00
	%SubOffScreen()
	JSR subgfx

	LDA $9D
	BNE return
	LDA !sprite_status,x
	CMP #$08
	BCC return

	JSL $018032|!BankB

	LDA !sprite_in_water,x
	BNE iswater
	JMP isgnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
iswater:
	;reset Dom't use... flag
	LDA !167A,x
	AND #$7F
	STA !167A,x

	;reset flip flag
	STZ !vert_flip,x

	;set wet timer
	LDA #$FF
	STA !wet_timer,x
	
	LDA !gnd_to_water,x
	BNE skip_speed
	INC !gnd_to_water,x

	%BES(isvert)
	STZ !sprite_speed_y,x
	%SubHorzPos()
	BCS +
	LDA !extra_byte_1,x
	STA !sprite_speed_x,x
	BRA ++
+
	LDA !extra_byte_1,x
	EOR #$FF
	INC A
	STA !sprite_speed_x,x
++
	BRA skip_speed
isvert:
	STZ !sprite_speed_x,x
	%SubVertPos()
	BCS +
	LDA !extra_byte_1,x
	STA !sprite_speed_y,x
	BRA ++
+
	LDA !extra_byte_1,x
	EOR #$FF
	INC A
	STA !sprite_speed_y,x
++
skip_speed:

	;set face
	LDA !sprite_speed_x,x
	BEQ +
	LSR #7
	AND #$01
	EOR #$01
	STA !sprite_misc_157c,x
	LDA !sprite_x_low,x
	LSR #3
	AND #$01
	STA !pose,x
	BRA ++
+
	%SubHorzPos()
	TYA
	EOR #$01
	STA !sprite_misc_157c,x
	LDA !sprite_y_low,x
	LSR #3
	AND #$01
	STA !pose,x
++
	;check wall
	JSL $019138|!BankB

	LDA !sprite_blocked_status,x
	AND #$0F
	BNE +

	LDA !timer,x
	BNE ++
+
	;flip x speed
	LDA !sprite_speed_x,x
	EOR #$FF
	INC A
	STA !sprite_speed_x,x

	;flip y speed
	LDA !sprite_speed_y,x
	EOR #$FF
	INC A
	STA !sprite_speed_y,x

	;reset timer
	LDA !extra_byte_2,x
	STA !timer,x
++
	;sprite move
	JSL $01801A|!BankB
	JSL $018022|!BankB
	JSL $01A7DC|!BankB
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
isgnd:
	;set Don't use... flag
	LDA !167A,x
	ORA #$80
	STA !167A,x

	;reset set speed flag
	STZ !gnd_to_water,x

	;set animation
	LDA $14
	LSR	#3
	AND #$01
	ORA #$02
	STA !pose,x

	;check celing
	LDA !sprite_blocked_status,x
	AND #$0C
	BEQ +
	STZ !sprite_speed_y,x
+
	LDA !sprite_blocked_status,x
	AND #$03
	BEQ +

	LDA !sprite_speed_x,x
	EOR #$FF
	INC A
	STA !sprite_speed_x,x

	LDA !sprite_misc_157c,x
	EOR #$01
	STA !sprite_misc_157c,x
+
	LDA !sprite_blocked_status,x
	AND #$04
	BEQ skip_gnd

	LDA !wet_timer,x
	BEQ +
	JSL $0284BC|!BankB
+
	JSL $01ACF9|!BankB
	STA $01

	;set random x speed (04-14)
	LDA #$10
	%Random()
	CLC
	ADC #$04
	STA $00
	;random speed flip
	LDA $01
	AND #$01
	BEQ +
	LDA $00
	EOR #$FF
	INC A
	STA $00
+
	LDA $00
	STA !sprite_speed_x,x

	;set random y speed (E8-D8)
	LDA #$18
	%Random()
	SEC
	SBC #$38
	STA !sprite_speed_y,x

	;set random y flip
	LDA $01
	AND #$02
	BEQ +
	LDA !vert_flip,x
	EOR #$80
	STA !vert_flip,x
+
	;set random x flip
	LDA $01
	AND #$04
	BEQ ++
	LDA #$00
	LDY !sprite_speed_x,x
	BEQ ++
	BPL +
	INC A
+
	STA !sprite_misc_157c,x
++

skip_gnd:
	JSL $01802A|!BankB
	JSL $01A7DC|!BankB
	BCC not_contact
	LDA $1490|!Base2
	BEQ +
	%Star()
	BRA ++
+
	LDA #$10
	STA $149A|!Base2

	LDA #$03
	STA $1DF9|!Base2

	%SubHorzPos()
	LDA KickedXSpeed,y
	STA !sprite_speed_x,x

	LDA #$E0
	STA !sprite_speed_y,x

	LDA #$02
	STA !sprite_status,x

	LDA #$01
	JSL $02ACE5|!BankB
++
not_contact:
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

subgfx:
	%GetDrawInfo()

	PHY
	LDA !pose,x
	TAY
	LDA tilemap,y
	STA $02

	STZ $04
	LDA !sprite_status,x
	CMP #$08
	BCS +
	LDA #$80
	STA $04
+
	LDA !sprite_misc_157c,x
	ASL #6
	ORA !sprite_oam_properties,x
	AND #$FE
	ORA tilepage,y
	ORA !vert_flip,x
	ORA $04
	ORA $64
	STA $03
	PLY
	
	LDA $00
	STA $0300|!Base2,y
	LDA $01
	STA $0301|!Base2,y
	LDA $02
	STA $0302|!Base2,y
	LDA $03
	STA $0303|!Base2,y

	LDY #$02
	LDA #$00
	%FinishOAMWrite()
	RTS