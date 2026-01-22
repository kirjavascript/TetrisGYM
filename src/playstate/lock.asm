playState_lockTetrimino:
@currentTile = generalCounter5
        jsr isPositionValid
        beq @notGameOver
@gameOver:
        lda practiseType
        cmp #MODE_TYPEB
        bne @revealScore

        ; bonus points if score >= 30000
        lda score+3
        bne @typeBBonus
        lda score+2
        cmp #$03
        bcc @revealScore
@typeBBonus:
        jsr addBTypeBonus
@revealScore:
        lda renderFlags ; Flag needed to reveal hidden score
        ora #RENDER_SCORE
        sta renderFlags
        lda #$02
        sta soundEffectSlot0Init
        lda #$0A ; playState_checkStartGameOver
        sta playState
        lda #$F0
        sta curtainRow
        jsr updateAudio2

        ; reset checkerboard score
        lda practiseType
        cmp #MODE_CHECKERBOARD
        bne @noChecker
        lda #0
        sta binScore
        sta binScore+1
        jsr setupScoreForRender
@noChecker:
        ; make invisible tiles visible
        lda #$00
        sta invisibleFlag
        sta vramRow
        rts

@notGameOver:
        lda vramRow
        cmp #$20
        bmi @ret
        ldy tetriminoY
        lda multBy10Table,y
        clc
        adc tetriminoX
        sta generalCounter
        ldx currentPiece
        lda tetriminoTileFromOrientation,x
        sta @currentTile
        txa
        asl a
        asl a
        tax
        ldy #$00
        lda #$04
        sta generalCounter3
; Copies a single square of the tetrimino to the playfield
@lockSquare:
        ldy orientationTableY,x
        lda multBy10Table,y
        clc
        adc generalCounter
        sta positionValidTmp
        lda orientationTableX,x
        clc
        adc positionValidTmp
        tay
        lda @currentTile
        ; BLOCK_TILES
        sta playfield,y
        inx
        dec generalCounter3
        bne @lockSquare
        lda practiseType
        cmp #MODE_LOWSTACK
        bne @notAboveLowStack
        jsr checkIfAboveLowStackLine
        bcc @notAboveLowStack
        ldx #<lowStackNopeGraphic
        ldy #>lowStackNopeGraphic
        sec
        lda #19
        sbc lowStackRowModifier
        cmp #$09
        bcs @drawOnUpperHalf
; draw on lower half
        adc #$03 ; carry already clear
        bne @copyGraphic
@drawOnUpperHalf:
        sbc #$04 ; carry already set
@copyGraphic:
        jsr copyGraphicToPlayfieldAtCustomRow
        jmp @gameOver
@notAboveLowStack:
        lda #$00
        sta lineIndex
        jsr updatePlayfield
        jsr updateMusicSpeed
        inc playState
@ret:   rts
