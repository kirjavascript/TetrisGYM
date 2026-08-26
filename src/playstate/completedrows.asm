playState_checkForCompletedRows:
        lda vramRow
        cmp #$20
        bpl @updatePlayfieldComplete
        jmp playState_checkForCompletedRows_return

@updatePlayfieldComplete:
        @currentRow = generalCounter2

        lda tetriminoY
        sec
        sbc #$02
        bpl @yInRange
        lda #$00
@yInRange:
        clc
        adc lineIndex
        sta @currentRow
        asl a
        sta generalCounter
        asl a
        asl a
        clc
        adc generalCounter
        sta generalCounter
        tay
        ldx #$0A
@checkIfRowComplete:
.if AUTO_WIN
        jmp @rowIsComplete
.endif
        lda teppozFlag
        bne @rowNotComplete

        lda practiseType
        cmp #MODE_TSPINS
        beq @rowNotComplete

        ; lda practiseType ; accumulator is still practiseType
        lda floorModifier
        bne @fullRowBurningCheck
        lda linecapState
        cmp #LINECAP_FLOOR
        bne @checkIfRowCompleteLoopStart

@fullRowBurningCheck:
        lda #$13
        sec
        sbc @currentRow ; contains current row being checked
        cmp currentFloor
        bcc @rowNotComplete ; ignore floor rows

@checkIfRowCompleteLoopStart:
        lda playfield,y
        cmp #EMPTY_TILE
        beq @rowNotComplete
        iny
        dex
        bne @checkIfRowCompleteLoopStart

@rowIsComplete:
        ; sound effect $A to slot 1 used to live here
        inc completedLines
        ldx lineIndex
        lda @currentRow
        sta completedRow,x
        ldy generalCounter
        dey
@movePlayfieldDownOneRow:
        lda playfield,y
        sta playfield+10,y
        dey
        cpy #$FF
        bne @movePlayfieldDownOneRow

        jsr refreshTopRow

        lda #PIECE_HIDDEN
        sta currentPiece
; draw surface of floor in case of top line clear
        jsr drawFloorTopRow
        jmp @incrementLineIndex

@rowNotComplete:
        ldx lineIndex
        lda #$00
        sta completedRow,x
@incrementLineIndex:

        ; patch tapquantity data
        lda practiseType
        cmp #MODE_TAPQTY
        bne @tapQtyEnd
        lda completedLines
        beq @tapQtyEnd
        ; mark as complete
        lda tqtyNext
        sta tqtyCurrent
        lda noLineClearDelayFlag
        beq @tapQtyEnd
        lda #0
        sta vramRow
        inc playState
        inc playState
        lda #$07
        sta soundEffectSlot1Init
        rts
@tapQtyEnd:

        lda completedLines
        beq :+
        lda #$0A
        sta soundEffectSlot1Init
:

        inc lineIndex
        lda lineIndex
        cmp #$04 ; check actual height
        bmi playState_checkForCompletedRows_return

        lda #$00
        sta vramRow
        sta rowY
        lda completedLines
        cmp #$04
        bne @skipTetrisSoundEffect
        lda #$04
        sta soundEffectSlot1Init
@skipTetrisSoundEffect:
        inc playState
        lda completedLines
        bne playState_checkForCompletedRows_return
@skipLines:
playState_completeRowContinue:
        inc playState
        lda #$07
        sta soundEffectSlot1Init
playState_checkForCompletedRows_return:
        rts
