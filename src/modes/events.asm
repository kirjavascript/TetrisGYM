practiseInitGameState:
        lda practiseType
        cmp #MODE_TAP
        bne @skipTap
        jmp initGameTap
@skipTap:
        cmp #MODE_PRESETS
        bne @skipPresets
        jmp advanceGamePreset
@skipPresets:
        cmp #MODE_CHECKERBOARD
        beq @initChecker
        lda fillType
        cmp #FILL_CHECKER
        bne @skipChecker
@initChecker:
        lda fillType
        cmp #FILL_B
        beq @skipChecker
        jsr initChecker
@skipChecker:
        jsr initGameCrunch
        lda floorModifier
        beq @skipFloor
        jsr initGameFloor
@skipFloor:
        jmp practiseEachPiece

practiseAdvanceGame:
        lda practiseType
        cmp #MODE_TSPINS
        bne @skipTSpins
        jmp advanceGameTSpins
@skipTSpins:
        rts

practisePrepareNext:
        lda paceModifier
        bmi @skipPace
        jsr prepareNextPace
@skipPace:
        lda practiseType
        cmp #MODE_GARBAGE
        bne @skipGarbo
        jsr prepareNextGarbage
@skipGarbo:
        cmp #MODE_STACKING
        bne @skipParity
        jsr prepareNextParity
@skipParity:

practiseEachPiece: ; only used in this file
        lda practiseType
        cmp #MODE_TAPQTY
        bne @skipTapQuantity
        jsr prepareNextTapQuantity
@skipTapQuantity:
        rts

practiseGameHUD:
        lda inputDisplayFlag
        beq @noInput
        jsr controllerInputDisplay
@noInput:

        lda paceModifier
        bmi @skipPace
        jsr gameHUDPace
@skipPace:

        lda practiseType
        cmp #MODE_TAPQTY
        bne @skipTapQuantity

        lda #$34
        ldy mirrorVertFlag
        beq @drawTapQty
        lda #$B8
@drawTapQty:
        sta generalCounter
        ldy #0
        ldx oamStagingLength
@drawQTY:
        ; taps
        tya
        asl
        asl
        asl
        adc generalCounter
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
