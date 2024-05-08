gameModeState_initGameBackground:
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
.if HAS_MMC
        lda #$01
        jsr changeCHRBank0
        lda #$01
        jsr changeCHRBank1
.endif
        jsr bulkCopyToPpu
        .addr   game_palette
        jsr copyRleNametableToPpu
        .addr   game_nametable
        jsr scoringBackground
        lda darkMode
        beq @notDarkMode
        jsr drawDarkMode
@notDarkMode:

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


.if INES_MAPPER = 3
        lda #%10011000
        sta PPUCTRL
        sta currentPpuCtrl
.elseif INES_MAPPER = 4
        ; Vertical mirroring (Prevents screen glitching)
        lda #$0
        sta MMC3_MIRRORING
.elseif INES_MAPPER = 5
        ; Single screen (Prevents screen glitching)
        lda #$0
        sta MMC5_NT_MAPPING
.endif
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

DARK_CORNER_TILES := $94
DARK_CORNER_TILES2 := $90

drawDarkMode:
        jsr bulkCopyToPpu
        .addr darkmode_stripes

        ldx #0
        lda darkCorners, x
@darkCornerLoop:
        stx tmpZ
        sta PPUADDR
        inx
        lda darkCorners, x
        sta PPUADDR
        inx
        clc
        lda #DARK_CORNER_TILES
        ldy tmpZ
        cpy #40
        bmi @notAlt
        lda #DARK_CORNER_TILES2
@notAlt:
        sta tmpX
        lda tmpZ
        lsr
        and #$3
        adc tmpX
        sta PPUDATA
        lda darkCorners, x
        bne @darkCornerLoop
@notDarkMode:
        rts

stripeHoriz = $40
stripeVert = $C0

darkmode_stripes:
        .byte  $20,$00
        .byte  $00|stripeHoriz,$FF
        .byte  $20,$40
        .byte  $0B|stripeHoriz,$FF
        .byte  $20,$60
        .byte  $18|stripeVert,$FF
        .byte  $20,$61
        .byte  $03|stripeVert,$FF
        .byte  $20,$6A
        .byte  $05|stripeVert,$FF
        .byte  $20,$5F
        .byte  $15|stripeVert,$FF
        .byte  $20,$C1
        .byte  $09|stripeHoriz,$FF
        .byte  $20,$E1
        .byte  $09|stripeHoriz,$FF
        .byte  $21,$77
        .byte  $08|stripeHoriz,$FF
        .byte  $21,$9D
        .byte  $07|stripeVert,$FF
        .byte  $21,$7E
        .byte  $0C|stripeVert,$FF
        .byte  $22,$F7
        .byte  $09|stripeHoriz,$FF
        .byte  $23,$17
        .byte  $09|stripeHoriz,$FF
        .byte  $23,$37
        .byte  $09|stripeHoriz,$FF
        .byte  $23,$57
        .byte  $00|stripeHoriz,$FF
        .byte  $23,$97
        .byte  $29|stripeHoriz,$FF
        .byte  $FF

darkCorners:
        ; mode
        .byte  $20,$62
        .byte  $20,$69
        .byte  $20,$A2
        .byte  $20,$A9
        ; stats
        .byte  $21,$01
        .byte  $21,$0A
        .byte  $23,$41
        .byte  $23,$4A
        ; lines
        .byte  $20,$4B
        .byte  $20,$56
        .byte  $20,$8B
        .byte  $20,$96
        ; score
        .byte  $20,$57
        .byte  $20,$5E
        .byte  $21,$57
        .byte  $21,$5E
        ; level
        .byte  $22,$77
        .byte  $22,$7D
        .byte  $22,$D7
        .byte  $22,$DD
        ; alt tiles
        ; next
        .byte  $21,$97
        .byte  $21,$9C
        .byte  $22,$57
        .byte  $22,$5c
        ; game
        .byte  $20,$AB
        .byte  $20,$B6
        .byte  $23,$4B
        .byte  $23,$56
        .byte  $0
