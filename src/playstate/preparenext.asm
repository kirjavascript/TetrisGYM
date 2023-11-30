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
        ldx #<haltEndingGraphic
        ldy #>haltEndingGraphic
        jmp copyGraphic
@linecapHaltEnd:
        jsr practisePrepareNext
        inc playState
        rts
typeBEndingStuff:
        ldx #<typebSuccessGraphic
        ldy #>typebSuccessGraphic
copyGraphic:
        jsr copyGraphicToPlayfield

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

copyGraphicToPlayfield:
        stx generalCounter
        sty generalCounter2
        ldy #$00
@copySuccessGraphic:
        lda (generalCounter),y
        beq @graphicCopied
        sta playfield+$5C,y
        iny
        bne @copySuccessGraphic
@graphicCopied: ; 0 in accumulator
        sta vramRow
        rts

; $28 is ! in game tileset
lowStackFail:
        .byte   "F","A","I","L",$FF,$28,$00
haltEndingGraphic:
        .byte   $FF,"G","G",$FF,$28,$00
typebSuccessGraphic:
        .byte   "N","I","C","E",$FF,$28,$00

