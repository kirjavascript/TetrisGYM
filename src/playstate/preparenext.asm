playState_prepareNext:
        lda practiseType
        cmp #MODE_CHECKERBOARD
        bne @checkBType
        ; check to see if bottom row for checkerboard has been cleared
        lda #$13
        sec
        sbc currentFloor
        cmp completedRow+3
        bne endOfEndingCode
        jsr typeBEndingStuff
        rts

        ; bTypeGoalCheck
@checkBType:
        cmp #MODE_TYPEB
        bne endOfEndingCode
        lda lines
        bne endOfEndingCode

        jsr typeBEndingStuff

addBTypeBonus:
        ; patch levelNumber with score multiplier
        lda heightOrRows
        beq @byHeight
        ldx rowsModifier
        lda rowsToHeight,x
        jmp @store
@byHeight:
        lda heightModifier
@store:
        sta generalCounter
        ldx levelNumber
        stx tmp3 ; and save a copy
        lda levelDisplayTable, x
        and #$F
        clc
        adc generalCounter
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
endOfEndingCode:

        lda linecapState
        cmp #LINECAP_HALT
        bne @linecapHaltEnd
        ldx #<haltEndingGraphic
        ldy #>haltEndingGraphic

        lda crashState ; LINECAP_HALT set in testCrash
        cmp #$F0
        bne @nonCrash
        ldx #<crashGraphic
        ldy #>crashGraphic
@nonCrash:
        jmp copyGraphic

@linecapHaltEnd:
        jsr practisePrepareNext
        inc playState
        rts

typeBEndingStuff:
        inc gameTimerStop
        ldx #<typebSuccessGraphic
        ldy #>typebSuccessGraphic
copyGraphic:
        jsr copyGraphicToPlayfield

typeBEndingStuffEnd:
        ; play sfx
        lda #$4
        sta soundEffectSlot1Init

        lda renderFlags ; Flag needed to reveal hidden score
        ora #$4
        sta renderFlags
        lda #$0A ; playState_checkStartGameOver
        sta playState
        lda #$30
        jsr sleep_gameplay_nextSprite
        rts

sleep_gameplay_nextSprite:
        sta sleepCounter
        jsr stageCurrentAndNextPieces
@loop:  jsr updateAudioWaitForNmiAndResetOamStaging
        jsr stageCurrentAndNextPieces
        lda sleepCounter
        bne @loop
        rts

copyGraphicToPlayfield:
        lda #$09 ; default row
copyGraphicToPlayfieldAtCustomRow:
        stx generalCounter
        sty generalCounter2
        tax
        lda multBy10Table,x
        clc
        adc #$02 ; indent
        tax
        ldy #$00
@copySuccessGraphic:
        lda (generalCounter),y
        beq @graphicCopied
        sta playfield,x
        inx
        iny
        bne @copySuccessGraphic
@graphicCopied: ; 0 in accumulator
        sta vramRow
        ; override if full playfield rendermode
        lda #RENDER_PLAY
        sta renderMode
        rts

; $28 is ! in game tileset
lowStackNopeGraphic:
        .byte   "N","O","P","E",$FF,$28,$00
haltEndingGraphic:
        .byte   $FF,'G','G',$FF,$28,$00
typebSuccessGraphic:
        .byte   'N','I','C','E',$FF,$28,$00
crashGraphic:
        .byte   'C','R','A','S','H',$28,$00
