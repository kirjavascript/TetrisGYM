playState_prepareNext:
        lda practiseType
        cmp #MODE_CHECKERBOARD
        bne @checkBType
        lda completedRow+3
        cmp #$13
        bne @endOfEndingCode
        jsr typeBEndingStuff
        rts

        ; bTypeGoalCheck
@checkBType:
        cmp #MODE_TYPEB
        bne @endOfEndingCode
        lda lines
        bne @endOfEndingCode

        jsr typeBEndingStuff

        ; patch levelNumber with score multiplier
        ldx levelNumber
        stx tmp3 ; and save a copy
        lda levelDisplayTable, x
        and #$F
        clc
        adc typeBModifier
        sta levelNumber
        beq @typeBScoreDone
        dec levelNumber

        ; patch some stuff
        lda #$5
        sta completedLines
        jsr addPointsRaw

        ; restore level
@typeBScoreDone:
        lda tmp3
        sta levelNumber

        rts
@endOfEndingCode:

        lda linecapState
        cmp #LINECAP_HALT
        bne @linecapHaltEnd
		lda crashFlag
		cmp #$F0
		bne @gg
		lda #'C'
		sta playfield+$66
		lda #'R'
		sta playfield+$67
		lda #'A'
		sta playfield+$68
		lda #'S'
		sta playfield+$69
		lda #'H'
		sta playfield+$6A
		lda #$28
        sta playfield+$6B
		bne @finish
@gg:
        lda #'G'
        sta playfield+$67
        sta playfield+$68
        lda #$28
        sta playfield+$6A
@finish:
        lda #0
        sta vramRow
        jsr typeBEndingStuffEnd
        rts
@linecapHaltEnd:

        jsr practisePrepareNext
        inc playState
        rts

typeBEndingStuff:
        ; copy success graphic
        ldx #$5C
        ldy #$0
@copySuccessGraphic:
        lda typebSuccessGraphic,y
        cmp #$80
        beq @graphicCopied
        sta playfield,x
        inx
        iny
        jmp @copySuccessGraphic
@graphicCopied:
        lda #$00
        sta vramRow

typeBEndingStuffEnd:
        ; play sfx
        lda #$4
        sta soundEffectSlot1Init

        lda outOfDateRenderFlags ; Flag needed to reveal hidden score
        ora #$4
        sta outOfDateRenderFlags
        lda #$0A ; playState_checkStartGameOver
        sta playState
        lda #$30
        jsr sleep_gameplay_nextSprite
        rts

sleep_gameplay_nextSprite:
        sta sleepCounter
        jsr stageSpriteForNextPiece
@loop:  jsr updateAudioWaitForNmiAndResetOamStaging
        jsr stageSpriteForNextPiece
        lda sleepCounter
        bne @loop
        rts

typebSuccessGraphic:
        .byte   $17,$12,$0C,$0E,$FF,$28,$80
