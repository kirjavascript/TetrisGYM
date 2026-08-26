playState_lockTetrimino:
VITS_SCORE = 100000
@currentTile = generalCounter5
        jsr isPositionValid
        beq @notGameOver
@gameOver:
        lda secretGradingFlag
        beq @notSecretGrade

        lda practiseType
        cmp #MODE_LOWSTACK
        beq @notSecretGrade  ; locking lst piece breaks lowstack.  fix by skipping for now

        jsr @noWait ; lock last piece in playfield for secret grade
@notSecretGrade:
        inc gameTimerStop
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
        bpl @noWait
        rts
@noWait:
        ldy tetriminoY
        lda multBy10Table,y
        clc
        adc tetriminoX
        sta generalCounter

; score if vits
        ldx vitsScoreFlag
        beq @noVits
        ldx currentPiece
        cpx #PIECE_I_VERT
        bne @noVits
        ; check if tile exists above
        sec
        sbc #30
        tax
        lda playfield,x
        bmi @noVits
        ; tile exists
        clc
        lda #<VITS_SCORE
        adc binScore
        sta binScore
        lda #>VITS_SCORE
        adc binScore+1
        sta binScore+1
        lda #^VITS_SCORE
        adc binScore+2
        sta binScore+2
        lda #0
        adc binScore+3
        sta binScore+3
        jsr setupScoreForRender
        lda renderFlags
        ora #RENDER_SCORE
        sta renderFlags
@noVits:
        ldx currentPiece
        lda #EMPTY_TILE
        ldy practiseType
        cpy #MODE_TAP
        beq @storeTile
        cpy #MODE_PRESETS
        beq @storeTile
;normal tile
        lda tetriminoTileFromOrientation,x
@storeTile:
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
        bmi @notAboveLowStack
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
        jmp secretGradeGrading
