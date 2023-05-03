playState_checkStartGameOver:
.if !ALWAYS_CURTAIN
        ; skip curtain / rocket when not qualling
        lda qualFlag
        beq @checkForStartButton
.endif

        lda curtainRow
        cmp #$14
        beq @curtainFinished
        lda frameCounter
        and #$03
        bne @ret
        ldx curtainRow
        bmi @incrementCurtainRow
        lda multBy10Table,x
        tay
        lda #$00
        sta generalCounter3
        lda #$13
        sta currentPiece
@drawCurtainRow:
        lda #$4F
        sta (playfieldAddr),y
        iny
        inc generalCounter3
        lda generalCounter3
        cmp #$0A
        bne @drawCurtainRow
        lda curtainRow
        sta vramRow
@incrementCurtainRow:
        inc curtainRow
@ret:   rts

@curtainFinished:
.if ALWAYS_CURTAIN
        lda qualFlag
        beq @checkForStartButton
.endif
        lda score+3
        bne @over30kormaxedout
        lda score+2
        cmp #$03
        bcc @checkForStartButton
@over30kormaxedout:

        lda #$80
        ldx palFlag
        cpx #0
        beq @notPAL
        lda #$66
@notPAL:
        jsr sleep_gameplay
        jsr endingAnimation

        jmp @exitGame

@checkForStartButton:
        lda newlyPressedButtons_player1
        cmp #$10
        bne @ret2
@exitGame:
        lda #$00
        sta playState
        sta newlyPressedButtons_player1
@ret2:  rts

sleep_gameplay:
        sta sleepCounter
@loop:  jsr updateAudioWaitForNmiAndResetOamStaging
        lda sleepCounter
        bne @loop
        rts

endingAnimation: ; rocket_screen
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
.if INES_MAPPER = 1
        lda #$02
        jsr changeCHRBank0
        lda #$02
        jsr changeCHRBank1
.elseif INES_MAPPER = 3
CNROM_CHR_ROCKET:
        lda #0
        sta CNROM_CHR_ROCKET+1
.endif
        jsr copyRleNametableToPpu
        .addr rocket_nametable
        jsr bulkCopyToPpu
        .addr rocket_palette

        ; lines
        lda #$21
        sta PPUADDR
        lda #$98
        sta PPUADDR
        lda lines+1
        sta PPUDATA
        lda lines
        jsr twoDigsToPPU

        ; score
        lda #$21
        sta PPUADDR
        lda #$18
        sta PPUADDR

        lda score+3
        beq @scoreEnd
        cmp #$A
        bmi @scoreHighWrite
        jsr twoDigsToPPU
        jmp @scoreEnd
@scoreHighWrite:
        sta PPUDATA
@scoreEnd:
        jsr renderBCDScoreData

        ; level
        lda #$22
        sta PPUADDR
        lda #$98
        sta PPUADDR
        lda startLevel
        jsr renderByteBCDNoPad
        lda #$22
        sta PPUADDR
        lda #$18
        sta PPUADDR
        lda levelNumber
        jsr renderByteBCDNoPad

        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr updateAudioWaitForNmiAndEnablePpuRendering
.if INES_MAPPER <> 3
        jsr updateAudioWaitForNmiAndResetOamStaging
.endif

        lda #0
        sta screenStage
        lda #$5
        sta renderMode
        lda #$1
        sta endingSleepCounter
        lda #$80 ; timed in bizhawk tasstudio to be 1 frame longer than usual (probably a lag frame)
        sta endingSleepCounter+1

endingLoop:
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr handleRocket

        lda screenStage
        bne @waitEnd

        ; rocket counter
        lda endingSleepCounter+1
        bne @notZero
        lda endingSleepCounter
        beq @counterEnd
        dec endingSleepCounter
@notZero:
        dec endingSleepCounter+1
        jmp endingLoop

@counterEnd:
        lda #1
        sta screenStage
        lda #0
        sta endingRocketCounter
@waitEnd:
        lda newlyPressedButtons_player1
        cmp #$10
        bne endingLoop
        rts

handleRocket:
        ; controls
        lda heldButtons_player1
        and #BUTTON_UP
        beq @notPressedUp
        dec endingRocketY
@notPressedUp:
        lda heldButtons_player1
        and #BUTTON_DOWN
        beq @notPressedDown
        inc endingRocketY
@notPressedDown:
        lda heldButtons_player1
        and #BUTTON_LEFT
        beq @notPressedLeft
        dec endingRocketX
@notPressedLeft:
        lda heldButtons_player1
        and #BUTTON_RIGHT
        beq @notPressedRight
        inc endingRocketX
@notPressedRight:

        ; render
        lda endingRocketCounter
        adc #2
        sta endingRocketCounter
        jsr sin_A
        txa
        cmp #$80 ; setup for ASR
        ror ; A / 2
        cmp #$80
        ror ; A / 4
        cmp #$80
        ror ; A / 8
        cmp #$80
        ror ; A / 16
        adc #$78
        adc endingRocketY

        ; draw cathedral
        sta spriteYOffset
        lda #$68
        adc endingRocketX
        sta spriteXOffset
        lda #<spriteCathedral
        sta $0
        lda #>spriteCathedral
        sta $1
        jsr loadRectIntoOamStaging

        lda #$3F
        adc spriteYOffset
        sta spriteYOffset
        lda #$78
        adc endingRocketX
        sta spriteXOffset
        lda #<spriteCathedralFire0
        sta $0
        lda #>spriteCathedralFire0
        sta $1
        lda frameCounter
        and #1
        beq @otherFrame
        lda #<spriteCathedralFire1
        sta $0
        lda #>spriteCathedralFire1
        sta $1
@otherFrame:
        jsr loadRectIntoOamStaging
        rts
