; Adjusts high score table and handles data entry, if necessary
handleHighScoreIfNecessary:
.if OCR_DOT
        lda #$01
        sta oamStaging+254
.endif
        ldy #0
        sty highScoreEntryRawPos
@compareWithPos:

        lda highscores+highScoreNameLength,y
        cmp score+3
        beq @checkHighByte
        bcs @tooSmall
        bcc adjustHighScores
@checkHighByte:
        lda highscores+highScoreNameLength +1,y
        cmp score+2
        beq @checkHundredsByte
        bcs @tooSmall
        bcc adjustHighScores
@checkHundredsByte:
        lda highscores+highScoreNameLength +2,y
        cmp score+1
        beq @checkOnesByte
        bcs @tooSmall
        bcc adjustHighScores
; This breaks ties by prefering the new score
@checkOnesByte:
        lda highscores+highScoreNameLength +3,y
        cmp score
        beq adjustHighScores
        bcc adjustHighScores
@tooSmall:

        tya
        clc
        adc #highScoreLength
        tay
        inc highScoreEntryRawPos
        lda highScoreEntryRawPos
        cmp #highScoreQuantity
        beq @ret
        jmp @compareWithPos

@ret:   rts

adjustHighScores:
        lda highScoreEntryRawPos
        cmp #$02
        bpl @doneMovingOldScores

        ldx #highScoreLength
        jsr copyHighscore

        lda highScoreEntryRawPos
        bne @doneMovingOldScores

        ldx #0
        jsr copyHighscore

@doneMovingOldScores:

        ldx highScoreEntryRawPos
        lda highScoreEntryRowOffsetLookup, x
        tax
        ldy #highScoreNameLength
        lda #$00
@clearNameLetter:
        sta highscores,x
        inx
        dey
        bne @clearNameLetter
        lda score+3
        sta highscores,x
        inx
        lda score+2
        sta highscores,x
        inx
        lda score+1
        sta highscores,x
        inx
        lda score
        sta highscores,x
        inx
        lda lines+1
        sta highscores,x
        inx
        lda lines
        sta highscores,x
        inx
        lda startLevel
        sta highscores,x
        inx
        lda levelNumber
        sta highscores,x
.if SAVE_HIGHSCORES
        jsr detectSRAM
        beq @noSRAM
        jsr copyScoresToSRAM
@noSRAM:
.endif
        jmp highScoreEntryScreen

copyHighscore:
        ldy #highScoreLength
@tmpHighScoreCopy:
        lda highscores,x
        sta highscores+highScoreLength,x
        inx
        dey
        bne @tmpHighScoreCopy
        rts

highScoreEntryScreen:
        lda #$09
        jsr setMusicTrack
        lda #$02
        sta renderMode
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
.if INES_MAPPER <> 0
        lda #CHRBankSet0
        jsr changeCHRBanks
.endif
        lda #NMIEnable
        sta PPUCTRL
        sta currentPpuCtrl
        jsr bulkCopyToPpu
        .addr   menu_palette
        jsr copyRleNametableToPpu
        .addr   enter_high_score_nametable
        jsr showHighScores
        lda #$20
        sta tmp1
        lda #$AE
        sta tmp2
        jsr displayModeText
        lda #$02
        sta renderMode
        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        jsr updateAudioWaitForNmiAndResetOamStaging

        ldx highScoreEntryRawPos
        lda highScoreEntryRowOffsetLookup, x
        sta highScoreEntryNameOffsetForRow

        lda #$00
        sta highScoreEntryNameOffsetForLetter
        sta oamStaging
        lda highScoreEntryRawPos
        tax
        lda highScorePosToY,x
        sta spriteYOffset
@renderFrame:
        lda #$00
        sta oamStaging
        lda highScoreEntryNameOffsetForLetter
        asl
        asl
        asl
        adc #$18
        sta spriteXOffset
        lda #$0E
        sta spriteIndexInOamContentLookup
        lda frameCounter
        and #$03
        bne @flickerStateSelected_checkForStartPressed
        lda #$02
        sta spriteIndexInOamContentLookup
@flickerStateSelected_checkForStartPressed:
        jsr loadSpriteIntoOamStaging
        lda newlyPressedButtons_player1
        and #$10
        beq @checkForAOrRightPressed
        lda #$02
        sta soundEffectSlot1Init
        jmp @ret

@checkForAOrRightPressed:
        lda #BUTTON_RIGHT
        jsr menuThrottle
        bne @nextTile
        lda #BUTTON_A
        jsr menuThrottle
        beq @checkForBOrLeftPressed
@nextTile:
        lda #$01
        sta soundEffectSlot1Init
        inc highScoreEntryNameOffsetForLetter
        lda highScoreEntryNameOffsetForLetter
        cmp #highScoreNameLength
        bmi @checkForBOrLeftPressed
        lda #$00
        sta highScoreEntryNameOffsetForLetter
@checkForBOrLeftPressed:
        lda #BUTTON_LEFT
        jsr menuThrottle
        bne @prevTile
        lda #BUTTON_B
        jsr menuThrottle
        beq @checkForDownPressed
@prevTile:
        lda #$01
        sta soundEffectSlot1Init
        dec highScoreEntryNameOffsetForLetter
        lda highScoreEntryNameOffsetForLetter
        bpl @checkForDownPressed
        lda #highScoreNameLength-1
        sta highScoreEntryNameOffsetForLetter
@checkForDownPressed:
        lda #BUTTON_DOWN
        jsr menuThrottle
        beq @checkForUpPressed
        lda #$01
        sta soundEffectSlot1Init
        lda highScoreEntryNameOffsetForRow
        sta generalCounter
        clc
        adc highScoreEntryNameOffsetForLetter
        tax
        lda highscores,x
        sta generalCounter
        dec generalCounter
        lda generalCounter
        bpl @letterDoesNotUnderflow
        clc
        adc #highScoreCharSize
        sta generalCounter
@letterDoesNotUnderflow:
        lda generalCounter
        sta highscores,x
.if SAVE_HIGHSCORES
        tay
        jsr detectSRAM
        beq @noSRAMDown
        tya
        sta SRAM_highscores, x
@noSRAMDown:
.endif
@checkForUpPressed:
        lda #BUTTON_UP
        jsr menuThrottle
        beq @waitForVBlank
        lda #$01
        sta soundEffectSlot1Init
        lda highScoreEntryNameOffsetForRow
        sta generalCounter
        clc
        adc highScoreEntryNameOffsetForLetter
        tax
        lda highscores,x
        sta generalCounter
        inc generalCounter
        lda generalCounter
        cmp #highScoreCharSize
        bmi @letterDoesNotOverflow
        sec
        sbc #highScoreCharSize
        sta generalCounter
@letterDoesNotOverflow:
        lda generalCounter
        sta highscores,x
.if SAVE_HIGHSCORES
        tay
        jsr detectSRAM
        beq @noSRAMUp
        tya
        sta SRAM_highscores, x
@noSRAMUp:
.endif
@waitForVBlank:
        lda highScoreEntryNameOffsetForRow
        clc
        adc highScoreEntryNameOffsetForLetter
        tax
        lda highscores,x
        sta highScoreEntryCurrentLetter
        lda #RENDER_HIGH_SCORE_LETTER
        sta renderFlags
        jsr updateAudioWaitForNmiAndResetOamStaging
        jmp @renderFrame

@ret:   jsr updateAudioWaitForNmiAndResetOamStaging
        rts

highScorePosToY:
        .byte   $3F,$5F,$7F
highScoreEntryRowOffsetLookup:
        .byte   $0, highScoreLength, highScoreLength*2
