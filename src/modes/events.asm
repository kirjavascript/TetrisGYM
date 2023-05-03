practiseInitGameState:
        lda practiseType
        cmp #MODE_CHECKERBOARD
        bne @skipChecker
        jsr initChecker
@skipChecker:
        jsr practiseEachPiece
        cmp #MODE_FLOOR
        bne @skipFloor
        jmp advanceGameFloor
@skipFloor:
        lda practiseType
        cmp #MODE_CRUNCH
        bne @skipCrunch
        jsr advanceGameCrunch
@skipCrunch:
        rts

practisePrepareNext:
        lda practiseType
        cmp #MODE_PACE
        bne @skipPace
        jmp prepareNextPace
@skipPace:
        cmp #MODE_GARBAGE
        bne @skipGarbo
        jmp prepareNextGarbage
@skipGarbo:
        cmp #MODE_PARITY
        bne @skipParity
        jmp prepareNextParity
@skipParity:
        jsr practiseEachPiece
        rts

practiseAdvanceGame:
        lda practiseType
        cmp #MODE_TSPINS
        bne @skipTSpins
        jmp advanceGameTSpins
@skipTSpins:
        rts

practiseEachPiece: ; only used in this file
        cmp #MODE_TAPQTY
        bne @skipTapQuantity
        jsr prepareNextTapQuantity
@skipTapQuantity:
        cmp #MODE_TAP
        bne @skipTap
        jmp advanceGameTap
@skipTap:
        cmp #MODE_PRESETS
        bne @skipPresets
        jmp advanceGamePreset
@skipPresets:
        rts

practiseGameHUD:
        lda inputDisplayFlag
        beq @noInput
        jsr controllerInputDisplay
@noInput:

        lda practiseType
        cmp #MODE_PACE
        bne @skipPace
        jsr gameHUDPace
@skipPace:

        lda practiseType
        cmp #MODE_TAPQTY
        bne @skipTapQuantity

        ldy #0
        ldx oamStagingLength
@drawQTY:
        ; taps
        tya
        asl
        asl
        asl
        adc #$34
        sta tmpY
        sta oamStaging, x
        inx
        lda tqtyCurrent, y
        cmp #5
        bmi @right0
        sbc #5
        jmp @left0
@right0:
        lda #6
        sbc tqtyCurrent, y
@left0:
        sta oamStaging, x
        inx
        lda #$02
        sta oamStaging, x
        inx
        lda #$64
        sta oamStaging, x
        inx

        ; direction
        lda tmpY
        sta oamStaging, x
        inx

        lda tqtyCurrent, y
        cmp #6
        bmi @right
        lda #$D6
        jmp @left
@right:
        lda #$D7
@left:
        sta oamStaging, x
        inx
        lda #$02
        sta oamStaging, x
        inx
        lda #$6E
        sta oamStaging, x
        inx

        ; $D6 / D7 for direction
        ; increase OAM index
        lda #$08
        clc
        adc oamStagingLength
        sta oamStagingLength
        iny
        cpy #2
        bmi @drawQTY

@skipTapQuantity:
        rts