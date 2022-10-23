playState_checkForCompletedRows:
        lda vramRow
        cmp #$20
        bpl @updatePlayfieldComplete
        jmp playState_checkForCompletedRows_return

@updatePlayfieldComplete:

        lda tetriminoY
        sec
        sbc #$02
        bpl @yInRange
        lda #$00
@yInRange:
        clc
        adc lineIndex
        sta generalCounter2
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
        lda practiseType
        cmp #MODE_TSPINS
        beq @rowNotComplete

        lda practiseType
        cmp #MODE_FLOOR
        beq @fullRowBurningCheck
        lda linecapState
        cmp #LINECAP_FLOOR
        beq @fullRowBurningCheck
        bne @normalRow

@fullRowBurningCheck:
        ; bugfix to ensure complete rows aren't cleared
        ; used in floor / linecap floor
        lda currentPiece_copy
        beq @IJLTedge
        cmp #5
        beq @IJLTedge
        cmp #$10
        beq @IJLTedge
        cmp #$12
        beq @IJLTedge
        bne @normalRow
@IJLTedge:
        lda lineIndex
        cmp #3
        bcs @rowNotComplete
@normalRow:


@checkIfRowCompleteLoopStart:
        lda (playfieldAddr),y
        cmp #EMPTY_TILE
        beq @rowNotComplete
        iny
        dex
        bne @checkIfRowCompleteLoopStart

@rowIsComplete:
        ; sound effect $A to slot 1 used to live here
        inc completedLines
        ldx lineIndex
        lda generalCounter2
        sta completedRow,x
        ldy generalCounter
        dey
@movePlayfieldDownOneRow:
        lda (playfieldAddr),y
        ldx #$0A
        stx playfieldAddr
        sta (playfieldAddr),y
        lda #$00
        sta playfieldAddr
        dey
        cpy #$FF
        bne @movePlayfieldDownOneRow
        lda #EMPTY_TILE
        ldy #$00
@clearRowTopRow:
        sta (playfieldAddr),y
        iny
        cpy #$0A
        bne @clearRowTopRow
        lda #$13
        sta currentPiece
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
        cmp #0
        beq @tapQtyEnd
        ; mark as complete
        lda tqtyNext
        sta tqtyCurrent
        ; handle no burns
        lda tapqtyModifier
        and #$F0
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
