gameModeState_initGameBackground:
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
        lda #CHRBankSet1
        jsr changeCHRBanks
        jsr bulkCopyToPpu
        .addr   game_palette
        jsr copyRleNametableToPpu
        .addr   game_nametable
        jsr scoringBackground

        lda hzFlag
        beq @noHz
        jsr bulkCopyToPpu
        .addr hzStats
@noHz:

        lda #$20
        sta tmp1
        lda #$83
        sta tmp2
        jsr displayModeText
        jsr statisticsNametablePatch ; for input display
        jsr debugNametableUI

        ; ingame hearts
        lda heartsAndReady
        and #$F
        sta tmpZ
        beq @heartEnd
        lda #$20
        sta PPUADDR
        lda #$9C
        sta PPUADDR
        lda #$2C
        sta PPUDATA
        lda tmpZ
        sta PPUDATA
@heartEnd:

        lda #NMIEnable
        sta PPUCTRL
        sta currentPpuCtrl
        jsr setVerticalMirroring
        jsr resetScroll
        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda #$01
        sta playState
        inc gameModeState ; 1
        lda #0 ; acc should not be equal
        rts

scoringBackground:
        ; draw dot and M
        lda scoringModifier
        cmp #SCORING_FLOAT
        bne @noFloat
        lda #$21
        sta PPUADDR
        lda #$3b
        sta PPUADDR
        lda #$2D
        sta PPUDATA
        lda #$21
        sta PPUADDR
        lda #$3D
        sta PPUADDR
        lda #$16
        sta PPUDATA
        jmp @noSevenDigit
@noFloat:
        cmp #SCORING_HIDDEN
        bne @notHidden
        jsr scoreSetupPPU
        lda #$FF
        ldx #$6
@hiddenScoreLoop:
        sta PPUDATA
        dex
        bne @hiddenScoreLoop
        jmp @noSevenDigit
@notHidden:
        cmp #SCORING_SEVENDIGIT
        bne @noSevenDigit
        jsr bulkCopyToPpu
        .addr seven_digit_nametable
@noSevenDigit:

        jsr showPaceDiffText
        beq @skipTop
        lda #$20
        sta PPUADDR
        lda #$B8
        sta PPUADDR

        lda scoringModifier
        cmp #SCORING_SEVENDIGIT
        bne @otherTopScore

        lda highscores+highScoreNameLength
        and #$F
        sta PPUDATA
        lda highscores+highScoreNameLength+1
        jsr twoDigsToPPU
        lda highscores+highScoreNameLength+2
        jsr twoDigsToPPU
        lda highscores+highScoreNameLength+3
        jsr twoDigsToPPU

        rts

@otherTopScore:
        ldx highscores+highScoreNameLength
        ldy highscores+highScoreNameLength+1
        cmp #SCORING_LETTERS
        bne @classicTopScore
        jsr renderLettersHighByte
        jmp @otherTopScoreLow
@classicTopScore:
        jsr renderClassicHighByte
@otherTopScoreLow:
        lda highscores+highScoreNameLength+2
        jsr twoDigsToPPU
        lda highscores+highScoreNameLength+3
        jsr twoDigsToPPU
@skipTop:
        rts

modeText:
MODENAMES

debugNametableUI:
        lda debugFlag
        beq @notDebug
        jsr saveStateNametableUI
        jsr saveSlotNametablePatch
@notDebug:
        rts

saveSlotNametablePatch:
        lda #$23
        sta PPUADDR
        lda #$1D
        sta PPUADDR
        lda saveStateSlot
        sta PPUDATA
        rts

saveStateNametableUI:
        ; todo: replace with stripe
        ldx #$00
@nextPpuAddress:
        lda savestate_nametable_patch,x
        inx
        sta PPUADDR
        lda savestate_nametable_patch,x
        inx
        sta PPUADDR
@nextPpuData:
        lda savestate_nametable_patch,x
        inx
        cmp #$FE
        beq @nextPpuAddress
        cmp #$FD
        beq @endOfPpuPatching
        sta PPUDATA
        jmp @nextPpuData
@endOfPpuPatching:
        rts

statisticsNametablePatch:
        lda #$21
        sta PPUADDR
        lda #$22
        sta PPUADDR
        ldx #8
        ldy #$68
@loop:
        lda inputDisplayFlag
        beq @show
        ldy #$FF
@show:
        sty PPUDATA
        iny
        dex
        bne @loop
        rts

showPaceDiffText:
        lda practiseType
        cmp #MODE_PACE
        bne @done
        jsr bulkCopyToPpu
        .addr paceDiffText
        lda #0
@done:
        rts

paceDiffText: ; stripe
        .byte $20, $98, $4, $D, $12, $F, $F, $FF

hzStats: ; stripe
        .byte $21, $63, $43, $FF
        .byte $21, $83, $46, $FF
        .byte $21, $C3, $46, $FF
        .byte $21, $E3, $42, $FF
        .byte $22, $03, $46, $FF
        .byte $22, $03, $46, $FF
        .byte $22, $43, $46, $FF
        .byte $22, $83, $46, $FF
        .byte $22, $c3, $46, $FF
        .byte $21, $A8, $1, $EC ; hz
        .byte $21, $A5, $1, $ED ; .
        .byte $23, $D8, $2, $B7, $25 ; hz palette
        .byte $22, $23, $3, $1D, $A, $19 ; tap
        .byte $22, $63, $3, $D, $15, $22 ; dly
        .byte $22, $A3, $3, $D, $12, $1B ; dir
        .byte $FF

seven_digit_nametable:
        .byte $20, $5F, $41, $3a ; -
        .byte $20, $7f, $C7, $3c ; |
        .byte $21, $5F, $41, $3F ; -
        .byte $20, $7E, $C7, $FF ; |
        .byte $20, $5E, $41, $39 ; -
        .byte $21, $5E, $41, $3E ; -
        .byte $21, $1E, $41, $0  ; 0
        .byte $FF

savestate_nametable_patch:
        .byte   $22,$F7,$38,$39,$39,$39,$39,$39,$39,$3A,$FE
        .byte   $23,$17,$3B,$1C,$15,$18,$1D,$FF,$FF,$3C,$FE
        .byte   $23,$37,$3B,$FF,$FF,$FF,$FF,$FF,$FF,$3C,$FE
        .byte   $23,$57,$3D,$3E,$3E,$3E,$3E,$3E,$3E,$3F,$FD
