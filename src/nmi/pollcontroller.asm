pollControllerButtons:
        ; lda gameMode
        ; cmp #$05
        ; beq @demoGameMode
        ; beq @recording
        jsr pollController
        rts

@demoGameMode:
        lda $D0
        cmp #$FF
        beq @recording
        jsr pollController
        lda newlyPressedButtons_player1
        cmp #$10
        beq @startButtonPressed
        lda demo_repeats
        beq @finishedMove
        dec demo_repeats
        jmp @moveInProgress

@finishedMove:
        ldx #$00
        lda (demoButtonsAddr,x)
        sta generalCounter
        jsr demoButtonsTable_indexIncr
        lda demo_heldButtons
        eor generalCounter
        and generalCounter
        sta newlyPressedButtons_player1
        lda generalCounter
        sta demo_heldButtons
        ldx #$00
        lda (demoButtonsAddr,x)
        sta demo_repeats
        jsr demoButtonsTable_indexIncr
        lda demoButtonsAddr+1
        cmp #>demoTetriminoTypeTable
        beq @ret
        jmp @holdButtons

@moveInProgress:
        lda #$00
        sta newlyPressedButtons_player1
@holdButtons:
        lda demo_heldButtons
        sta heldButtons_player1
@ret:   rts

@startButtonPressed:
        lda #>demoButtonsTable
        sta demoButtonsAddr+1
        lda #$00
        sta frameCounter+1
        lda #$01
        sta gameMode
        rts

@recording:
        jsr pollController
        lda gameMode
        cmp #$05
        bne @ret2
        ; lda $D0
        ; cmp #$FF
        bne @ret2
        lda heldButtons_player1
        cmp demo_heldButtons
        beq @buttonsNotChanged
        ldx #$00
        lda demo_heldButtons
        sta (demoButtonsAddr,x)
        jsr demoButtonsTable_indexIncr
        lda demo_repeats
        sta (demoButtonsAddr,x)
        jsr demoButtonsTable_indexIncr
        lda demoButtonsAddr+1
        cmp #>demoTetriminoTypeTable ; check movie has ended
        beq @ret2
        lda heldButtons_player1
        sta demo_heldButtons
        lda #$00
        sta demo_repeats
        rts

@buttonsNotChanged:
        inc demo_repeats

@ret2:  rts

demoButtonsTable_indexIncr:
        lda demoButtonsAddr
        clc
        adc #$01
        sta demoButtonsAddr
        lda #$00
        adc demoButtonsAddr+1
        sta demoButtonsAddr+1
        rts

pollController_actualRead:
        ldx joy1Location
        inx
        stx JOY1
        dex
        stx JOY1
        ldx #$08
@readNextBit:
        lda JOY1
        lsr a
        rol newlyPressedButtons_player1
        lsr a
        rol tmp1
        lda JOY2_APUFC
        lsr a
        rol newlyPressedButtons_player2
        lsr a
        rol tmp2
        dex
        bne @readNextBit
        rts

addExpansionPortInputAsControllerInput:
        lda tmp1
        ora newlyPressedButtons_player1
        sta newlyPressedButtons_player1
        lda tmp2
        ora newlyPressedButtons_player2
        sta newlyPressedButtons_player2
        rts

        jsr pollController_actualRead
        beq diffOldAndNewButtons
pollController:
        jsr pollController_actualRead
        jsr addExpansionPortInputAsControllerInput
        lda newlyPressedButtons_player1
        sta generalCounter2
        lda newlyPressedButtons_player2
        sta generalCounter3
        jsr pollController_actualRead
        jsr addExpansionPortInputAsControllerInput
        lda newlyPressedButtons_player1
        and generalCounter2
        sta newlyPressedButtons_player1
        lda newlyPressedButtons_player2
        and generalCounter3
        sta newlyPressedButtons_player2

        lda goofyFlag
        beq @noGoofy
        lda newlyPressedButtons_player1
        asl
        and #$AA
        sta tmp3
        lda newlyPressedButtons_player1
        and #$AA
        lsr
        ora tmp3
        sta newlyPressedButtons_player1
@noGoofy:

diffOldAndNewButtons:
        ldx #$01
@diffForPlayer:
        lda newlyPressedButtons_player1,x
        tay
        eor heldButtons_player1,x
        and newlyPressedButtons_player1,x
        sta newlyPressedButtons_player1,x
        sty heldButtons_player1,x
        dex
        bpl @diffForPlayer
        rts
