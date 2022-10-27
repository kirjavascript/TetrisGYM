stageSpriteForCurrentPiece:
        lda #$0
        sta pieceTileModifier
        jsr stageSpriteForCurrentPiece_actual

        lda practiseType
        cmp #MODE_HARDDROP
        beq ghostPiece
        rts

ghostPiece:
        lda playState
        cmp #3
        bpl @noGhost
        lda tetriminoY
        sta tmp3
@loop:
        inc tetriminoY
        jsr isPositionValid
        beq @loop
        dec tetriminoY

        ; check if equal to current position
        lda tetriminoY
        cmp tmp3
        beq @noGhost

        lda frameCounter
        and #1
        asl
        asl
        adc #$0D
        sta pieceTileModifier
        jsr stageSpriteForCurrentPiece_actual
        lda tmp3
        sta tetriminoY
@noGhost:
        rts

tileModifierForCurrentPiece:
        lda pieceTileModifier
        beq @tileNormal
        and #$80
        bne @tileSingle
; @tileMultiple:
        lda orientationTable,x
        clc
        adc pieceTileModifier
        rts
@tileSingle:
        lda pieceTileModifier
        rts
@tileNormal:
        lda orientationTable,x
        rts

yDisp:
	.byte $0,$0,$0,$0,$0,$1,$1,$1,$1,$2,$2,$2,$2,$2,$3,$3,$3,$3,$4,$4,$4,$4,$5,$5,$5,$5,$5,$6,$6,$6,$6,$7,$7,$7,$7,$8,$8,$8,$8,$8,$9,$9,$9,$9,$a,$a,$a,$a,$b,$b,$b,$b,$b,$c,$c,$c,$c,$d,$d,$d,$d,$e,$e,$e,$e,$e,$f,$f,$f,$f,$10,$10,$10,$10,$11,$11,$11,$11,$11,$12,$12,$12,$12,$13,$13,$13,$13,$14,$14,$14,$14,$14,$15,$15,$15,$15,$16,$16,$16,$16,$17,$17,$17,$17,$17,$18,$18,$18,$18,$19,$19,$19,$19,$19,$1a,$1a,$1a,$1a,$1b,$1b,$1b,$1b,$1c,$1c,$1c,$1c,$1c,$1d,$1d,$1d,$1d,$1e,$1e,$1e,$1e,$1f,$1f,$1f,$1f,$1f,$20,$20,$20,$20,$21,$21,$21,$21,$22,$22,$22,$22

; tetriminoY 0x13 - 19
; yPos spriteX

; use lookup

; // seperate one for X, with negative

; spawn
;     yPos = 0

; frame -

;     displace = (tetriminoY * 8) - yPos // range(0-152)

;     yVel = lookup(displace)
;     yPos += lastyVel/2 + yVel



; lookup=Array.from({ length: 152 }, (_, i) => {

;     return (0.23 * (i))
; })


; console.log('\t.byte '+lookup.map(d=>`$${(0|d).toString(16)}`).join`,`);

; lookup=Array.from({ length: 255 }, (_, i) => {

;     return (0.2 * (i))
; })


; console.log('\t.byte '+lookup.map(d=>`$${(0|d).toString(16)}`).join`,`);


; https://codesandbox.io/s/vibrant-kepler-v59c0q

stageSpriteForCurrentPiece_actual:
        lda playState
        cmp #1
        beq @no
        cmp #2
        beq @no
        rts
@no:
        sec
        lda tetriminoY
        rol a
        rol a
        rol a
        sbc yPos
        tax
        lda yDisp, x
        clc
        adc yPos
        sta yPos


        lda tetriminoX
        cmp #TETRIMINO_X_HIDE
        beq stageSpriteForCurrentPiece_return
        asl a
        asl a
        asl a
        adc #$60
        sta generalCounter3
        clc
        lda yPos
        ; lda tetriminoY
        ; rol a
        ; rol a
        ; rol a
        adc #$2F
        sta generalCounter4
        lda currentPiece
        sta generalCounter5
        clc
        lda generalCounter5
        rol a
        rol a
        sta generalCounter
        rol a
        adc generalCounter
        tax
        ldy oamStagingLength
        lda #$04
        sta generalCounter2
L8A4B:  lda orientationTable,x
        asl a
        asl a
        asl a
        clc
        adc generalCounter4
        sta oamStaging,y
        sta originalY
        inc oamStagingLength
        iny
        inx
        jsr tileModifierForCurrentPiece ; used to just load from orientationTable
        ; lda orientationTable, x
        sta oamStaging,y
        inc oamStagingLength
        iny
        inx
        lda #$02
        sta oamStaging,y
        lda originalY
        cmp #$2F
        bcs L8A84
        inc oamStagingLength
        dey
        lda #$FF
        sta oamStaging,y
        iny
        iny
        lda #$00
        sta oamStaging,y
        jmp L8A93

L8A84:  inc oamStagingLength
        iny
        lda orientationTable,x
        asl a
        asl a
        asl a
        clc
        adc generalCounter3
        sta oamStaging,y
L8A93:  inc oamStagingLength
        iny
        inx
        dec generalCounter2
        bne L8A4B
stageSpriteForCurrentPiece_return:
        rts

stageSpriteForNextPiece:
        lda qualFlag
        beq @alwaysNextBox
        lda displayNextPiece
        bne @ret

@alwaysNextBox:
        lda #$C8
        sta spriteXOffset
        lda #$77
        sta spriteYOffset
        ldx nextPiece
        lda orientationToSpriteTable,x
        sta spriteIndexInOamContentLookup
        jmp loadSpriteIntoOamStaging
@ret:   rts
