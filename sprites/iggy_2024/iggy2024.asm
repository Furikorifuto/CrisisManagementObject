;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; iggy - 2024 ver
; requested by SMW Magic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; is 2 - fire
; is 3 - hammer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; you need smb3 hammer sfx
;      and smb3 shell sfx
;      and any annihilate object
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!max_hp = $05

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; do not change
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!hp = !C2
!pose = !1504
!shell_phase = !1510
!fire_counter = !151C
!direction_mirror = !1528
!turn_timer = !1540
!action_timer = !154C
!fire_timer = !1558
!speed_mirror = !1602

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
	%SubHorzPos()
	TYA
	STA !157C,x
	LDA #$60
	STA !action_timer,x
	RTL

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR sprite
	PLB
	RTL
	
walk_anime:
	db $00,$01,$02,$01
shell_anime:
	db $03,$04,$03
direction_table:
	db $00,$00,$01
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

	LDA !shell_phase,x
	BNE +
	JMP iswalk
+
	LDA $14
	AND #$0F
	BNE +
	;LDA #$??                      ;\ need smb3
	;STA $1DF?|!Base2              ;/ shell sfx
+
	LDA !hp,x
	CMP #!max_hp
	BCS +
	STZ !1662,x
	LDA #$01
	STA !167A,x
	JSL $01A7DC|!BankB
	JSL $01802A|!BankB
+
	LDA !turn_timer,x
	BNE ++
	LDA #$04
	STA !turn_timer,x
	INC !direction_mirror,x
	LDA !direction_mirror,x
	CMP #$03
	BCC +
	STZ !direction_mirror,x
+
	LDA !direction_mirror,x
	TAY
	LDA shell_anime,y
	STA !pose,x
	LDA direction_table,y
	STA !157C,x
++
	LDA !sprite_blocked_status,x
	AND #$03
	BEQ +
	LDA #$01
	STA $1DF9|!Base2
	LDA !sprite_speed_x,x
	EOR #$FF
	INC A
	STA !sprite_speed_x,x
+
	LDA !sprite_blocked_status,x
	AND #$08
	BEQ +
	STZ !sprite_speed_y,x
+
	LDA !sprite_blocked_status,x
	AND #$04
	BEQ ++
	STZ !sprite_speed_y,x
	LDA !action_timer,x
	BEQ +
	STZ !sprite_speed_x,x
	RTS
+
	DEC !shell_phase,x
	BNE +
	%SubHorzPos()
	TYA
	STA !157C,x
	LDA #$60
	STA !action_timer,x
	STZ !sprite_speed_y,x
	STZ !sprite_speed_x,x
	RTS
+
	LDA !hp,x
	CMP #!max_hp
	BCC +
	LDA #$23
	STA $1DF9|!Base2
	LDA #$C0
	STA !sprite_speed_y,x
	STZ !sprite_speed_x,x
	LDA #$02
	STA !sprite_status,x
	RTS
+
	LDA #$A8
	STA !sprite_speed_y,x
	LDA #$10
	%Random()
	CLC
	ADC #$10
	STA $00
	%SubHorzPos()
	BEQ +
	LDA $00
	EOR #$FF
	INC A
	STA $00
+
	LDA $00
	STA !sprite_speed_x,x
++
	RTS
iswalk:
	%SubHorzPos()
	TYA
	STA !157C,x

	LDA #$37
	STA !1662,x
	LDA #$81
	STA !167A,x

	LDA !sprite_blocked_status,x
	AND #$04
	BEQ +

	LDA !sprite_x_low,x
	LSR #3
	AND #$03
	TAY
	LDA walk_anime,y
	BRA ++
+
	LDA #$02
++
	STA !pose,x

	LDA !direction_mirror,x
	AND #$01
	BEQ +
	LDA !speed_mirror,x
	STA !sprite_speed_x,x
	BRA ++
+
	LDA !speed_mirror,x
	EOR #$FF
	INC A
	STA !sprite_speed_x,x
++
	JSR normal_contact
	JSL $01802A|!BankB

	LDA !sprite_blocked_status,x
	AND #$0C
	BEQ +
	STZ !sprite_speed_y,x
+
	LDA !sprite_blocked_status,x
	AND #$03
	BEQ +
	JSR set_speed
+
	LDA !turn_timer,x
	BNE +
	LDA !sprite_blocked_status,x
	AND #$04
	BEQ +
	JSR set_speed
+
	LDA !action_timer,x
	BNE ++
	LDA !hp,x
	CMP #$03
	BCC +
	LDA #$02
	%Random()
	CMP #$02
	BEQ +
	%BEC(gen_fire)
	%BES(gen_hammer)
+
	LDA #$C0
	STA !sprite_speed_y,x
	LDA #$20
	%Random()
	CLC
	ADC #$40
	STA !action_timer,x
++
	RTS

set_speed:
	LDA #$20
	%Random()
	CLC
	ADC #$20
	STA !turn_timer,x

	LDA #$08
	%Random()
	CLC
	ADC #$10
	STA !speed_mirror,x

	INC !direction_mirror,x
	RTS

fire_offset:
	db $10,$F0
gen_fire:
	%SubHorzPos()
	LDA fire_offset,y
	STA $00
	LDA #$FC
	STA $01
	STZ $02
	STZ $03
	CLC
	LDA #$B3
	%SpawnSprite()
	LDA #$17
	STA $1DFC|!Base2
	LDA #$20
	%Random()
	CLC
	ADC #$40
	STA !action_timer,x
	RTS
hammer_offset:
	db $08,$F8
gen_hammer:
	LDA #$10
	%Random()
	CLC
	ADC #$10
	STA $02
	%SubHorzPos()
	BEQ +
	LDA $02
	EOR #$FF
	INC A
	STA $02
+
	LDA hammer_offset,y
	STA $00
	LDA #$F8
	STA $01
	LDA #$10
	%Random()
	CLC
	ADC #$30
	EOR #$FF
	INC A
	STA $03
	LDA #$04
	%SpawnExtended()
	;LDA #$??               ;\ need smb3
	;STA $1DF?|!Base2       ;/ hammer sfx
	LDA #$20
	%Random()
	CLC
	ADC #$40
	STA !action_timer,x
	RTS
fire_hit:
	LDA !fire_timer,x  
	BNE +
	INC !fire_counter,x
	LDA #$20
	STA !fire_timer,x
	LDA #$03
	STA $1DF9|!Base2

	LDA !fire_counter,x
	CMP #$05
	BCC +
	STZ !fire_counter,x
	STZ !fire_timer,x
	JMP mario_win
+
	RTS

normal_contact:
	%FireballContact()
	BCS fire_hit

	%CapeContact()
	BCC +
	JMP mario_win
+
	JSL $03B69F|!BankB
	LDY #!SprSize
-
	LDA !sprite_status,y
	CMP #$09
	BCC +
	PHX
	TYX
	JSL $03B6E5|!BankB
	PLX
	JSL $03B72B|!BankB
	BCC +
	LDA #$02
	STA !sprite_status,y
	LDA #$00
	STA !sprite_speed_x,y
	STA !sprite_speed_y,y
	JMP mario_win
+
	DEY
	BPL -

	JSL $01A7DC|!BankB
	BCC +
	LDA $1490|!Base2
	BNE mario_win
	%SubVertPos()
	LDA $0F
	CMP #$E8
	BPL boss_win
	LDA $7D
	BPL ++
boss_win:
	JSL $00F5B7|!BankB
+
	RTS
++
	JSL $01AA33|!BankB
	JSL $01AB99|!BankB
mario_win:
	LDA #$20
	STA !action_timer,x
	LDA #$02
	STA !turn_timer,x
	STA !direction_mirror,x
	STZ !sprite_speed_y,x
	STZ !sprite_speed_x,x
	LDA #$09
	JSL $02ACEF|!BankB

	INC !hp,x
	LDA #$28
	STA $1DFC|!Base2
	LDA #$02
	%Random()
	INC #2
	STA !shell_phase,x
	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphic routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
x_offset:
	db $00,$F8,$F8
y_offset:
	db $00,$F0,$00
tilemap:
	db $2B,$0A,$2A
	db $4B,$0A,$4A
	db $4E,$0A,$4D
	db $0C,$0E
tileaddr:
	db $00,$03,$06,$09,$0A
tilemax:
	db $02,$02,$02,$00,$00
fire_pal:
	db $08,$04,$0A,$06
subgfx:
	%GetDrawInfo()
	LDA !15F6,x
	ORA $64
	STA $02

	LDA !157C,x
	EOR #$01
	AND #$01
	ASL #6
	STA $03

	STZ $06
	LDA !pose,x
	CMP #$02
	BNE +
	INC $06
+
	PHX
	LDA !pose,x
	TAX
	LDA tileaddr,x
	STA $04
	LDA tilemax,x
	STA $05
	PLX

	PHX
	LDA !fire_timer,x
	BEQ +
	AND #$03
	TAX
	LDA fire_pal,x
	STA $07
	LDA $02
	AND #$F1
	ORA $07
	STA $02
+
	PLX
	LDA !sprite_status,x
	CMP #$08
	BCS +
	LDA $02
	ORA #$80
	STA $02
+
	PHX
	LDX $05
-
	PHX
	LDA $03
	BNE +
	LDA x_offset,x
	BRA ++
+
	LDA x_offset,x
	EOR #$FF
	INC A
++
	CLC
	ADC $00
	STA $0300|!Base2,y

	LDA y_offset,x
	CLC
	ADC $01
	SEC
	SBC $06
	STA $0301|!Base2,y

	PHA
	TXA
	CLC
	ADC $04
	TAX
	LDA tilemap,x
	STA $0302|!Base2,y
	PLX

	LDA $02
	ORA $03
	STA $0303|!Base2,y

	PLX
	INY #4
	DEX
	BPL -

	PLX
	LDY #$02
	LDA $05
	%FinishOAMWrite()
	RTS
