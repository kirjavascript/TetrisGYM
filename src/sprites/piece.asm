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
        lda tetriminoY
        ; save value for use by hard/sonic drop in next frame
        sta hardDropGhostY
        ; check if equal to current position
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
@currentTile = generalCounter5
        lda pieceTileModifier
        beq @tileNormal
        and #$80
        bne @tileSingle
; @tileMultiple:
        lda @currentTile
        clc
        adc pieceTileModifier
        rts
@tileSingle:
        lda pieceTileModifier
        rts
@tileNormal:
        lda @currentTile
        rts

stageSpriteForCurrentPiece_actual:
@currentTile = generalCounter5
        lda tetriminoX
        cmp #TETRIMINO_X_HIDE
        beq stageSpriteForCurrentPiece_return
        asl a
        asl a
        asl a
        adc #$60
        sta generalCounter3
        clc
        lda tetriminoY
        rol a
        rol a
        rol a
        adc #$2F
        sta generalCounter4
        ldx currentPiece
        lda tetriminoTileFromOrientation,x
        sta @currentTile
        txa
        asl a
        asl a
        tax
        ldy oamStagingLength
        lda #$04
        sta generalCounter2
@stageMino:
        lda orientationTableY,x
        asl a
        asl a
        asl a
        clc
        adc generalCounter4
        sta oamStaging,y
        sta originalY
        inc oamStagingLength
        iny
        jsr tileModifierForCurrentPiece ; used to just load from orientationTable
        ; lda orientationTable, x
        sta oamStaging,y
        inc oamStagingLength
        iny
        lda #$02
        sta oamStaging,y
        lda originalY
        cmp #$2F
        bcs @validYCoordinate
        inc oamStagingLength
        dey
        lda #$FF
        sta oamStaging,y
        iny
        iny
        lda #$00
        sta oamStaging,y
        jmp @finishLoop

@validYCoordinate:
        inc oamStagingLength
        iny
        lda orientationTableX,x
        asl a
        asl a
        asl a
        clc
        adc generalCounter3
        sta oamStaging,y
@finishLoop:
        inc oamStagingLength
        iny
        inx
        dec generalCounter2
        bne @stageMino
stageSpriteForCurrentPiece_return:
        rts

stageSpriteForNextPiece:
        lda hideNextPiece
        bne @maybeDisplayNextPiece

@displayNextPiece:
        lda #$C8
        sta spriteXOffset
        lda #$77
        sta spriteYOffset
        ldx nextPiece
        lda tetriminoTypeFromOrientation,x
        clc
        adc #$6 ; piece sprites start at index 6
        sta spriteIndexInOamContentLookup
        jmp loadSpriteIntoOamStaging

@maybeDisplayNextPiece:
        lda practiseType
        cmp #MODE_HARDDROP
        beq @displayNextPiece
        lda debugFlag
        bne @displayNextPiece
        rts
