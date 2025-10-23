activeFloorMode := generalCounter5

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
        lda #$00
        sta activeFloorMode ; Don't draw floor unless active
        ldx #$0A
@checkIfRowComplete:
.if AUTO_WIN
        jmp @rowIsComplete
.endif
        lda practiseType
        cmp #MODE_TSPINS
        beq @rowNotComplete

        ; lda practiseType ; accumulator is still practiseType
        cmp #MODE_FLOOR
        beq @floorCheck
        lda linecapState
        cmp #LINECAP_FLOOR
        beq @fullRowBurningCheck
        bne @normalRow

@floorCheck:
        lda currentFloor
        beq @rowNotComplete

@fullRowBurningCheck:
        inc activeFloorMode ; Floor is active
        lda #$13
        sec
        sbc generalCounter2 ; contains current row being checked
        cmp currentFloor
        bcc @rowNotComplete ; ignore floor rows
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

; draw surface of floor in case of top line clear
        lda activeFloorMode
        beq @incrementLineIndex
        lda #$14
        sec
        sbc currentFloor
        tax
        ldy multBy10Table,x
        ldx #$0A
        lda #BLOCK_TILES+3
@drawFloorSurface:
        sta playfield,y
        iny
        dex
        bne @drawFloorSurface

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
        ; cmp #0 ; lda sets z flag
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

        ; update top row for crunch
        lda practiseType
        cmp #MODE_CRUNCH
        bne @crunchEnd
        jsr advanceSides ; clobbers generalCounter3 and generalCounter4
@crunchEnd:

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
