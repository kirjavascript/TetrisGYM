stageCurrentAndNextPieces:
        jsr stageDasMeterSprites
        jsr stageSpriteForNextPiece
stageSpriteForCurrentPiece:
        jsr secretGradeSprite
        lda gameTimerFlag
        beq @noGameTimer
        lda #$C0
        sta spriteXOffset
        lda #$17
        sta spriteYOffset
        lda #gameTimer
        sta byteSpriteAddr
        lda #0
        sta byteSpriteAddr+1
        lda #0
        sta byteSpriteTile
        lda #2
        sta byteSpriteLen
        jsr byteSprite

@noGameTimer:
        lda #$0
        sta pieceTileModifier
        ; skip for harddrop, not tap qty
        lda practiseType
        cmp #MODE_TAPQTY
        beq @noSkip
        lda renderMode
        cmp #RENDER_TOPROWS
        beq @skipCurrent
@noSkip:
        jsr stageSpriteForCurrentPiece_actual
@skipCurrent:
        lda hardDropFlag
        bne ghostPiece
        lda ghostPieceFlag
        bne ghostPiece
@ret:
        rts

ghostPiece:
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
        lda ghostPieceFlag
        beq @noGhost
; no ghost piece during entry delay
        lda playState
        cmp #1
        beq @ghost
        cmp #8
        bne @noGhost
@ghost:
        lda currentPiece
        cmp #PIECE_HIDDEN
        beq @noGhost
        lda frameCounter
        and #1
        asl
        asl
        adc #$0D
        sta pieceTileModifier
        jsr stageSpriteForCurrentPiece_actual
@noGhost:
        lda tmp3
        sta tetriminoY
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
        bne @notHidden
        rts
@notHidden:
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
        sta originalY
        sta oamStaging,y
        lda mirrorVertFlag
        beq @notMirrorVert
        lda #$F6
        sec
        sbc originalY
        sta oamStaging,y
@notMirrorVert:
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
        sta oamStaging-1,y
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
        lda mirrorHorizFlag
        beq @finishLoop
        lda #$08
        sec
        sbc oamStaging,y
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
        bne @ret
@displayNextPiece:
        lda #$C8
        sta spriteXOffset
        lda #$77
        sta spriteYOffset
        ldx nextPiece
        cpx #PIECE_SPLIT_SQUARE
        bne @normal
        lda #7
        bne @store
@normal:
        lda tetriminoTypeFromOrientation,x
@store:
        sta spriteIndex
        lda tetriminoTileFromOrientation,x
        sta spriteTile
        jmp loadNextPieceIntoOamStaging
@ret:
        rts
