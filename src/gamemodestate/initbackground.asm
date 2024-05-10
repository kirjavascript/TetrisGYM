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
        jsr debugNametableUI

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
        ; hidden score
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
        ; 7 digit
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
        jsr bulkCopyToPpu
        .addr savestate_nametable
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
        .byte $20, $5F, $41, $75 ; -
        .byte $20, $7f, $C7, $36 ; |
        .byte $21, $5F, $41, $77 ; -
        .byte $20, $7E, $C7, $FF ; |
        .byte $20, $5E, $41, $34 ; -
        .byte $21, $5E, $41, $37 ; -
        .byte $21, $1E, $41, $0  ; 0
        .byte $FF

savestate_nametable:
        .byte   $22,$F7,$8,$74,$34,$34,$34,$34,$34,$34,$75
        .byte   $23,$17,$8,$35,$1C,$15,$18,$1D,$FF,$FF,$36
        .byte   $23,$37,$8,$35,$FF,$FF,$FF,$FF,$FF,$FF,$36
        .byte   $23,$57,$8,$76,$37,$37,$37,$37,$37,$37,$77
        .byte   $FF

NORMAL_CORNER_TILES := $70
DARK_CORNER_TILES := $80

drawDarkMode:

darkBuffer := playfield ; cleared right after in initGameState

        ; process the playfield in 60 chunks
        lda #60
        sta tmpZ

        lda #$20
        sta tmpX
        lda #$00
        sta tmpY

@processChunk: ; process 16 tiles at a time
        lda tmpX
        sta PPUADDR
        lda tmpY
        sta PPUADDR
        lda PPUDATA

        ldx #0
@copyToBuffer:
        lda PPUDATA
        sta darkBuffer, x
        inx
        cpx #16
        bne @copyToBuffer

        ; reset PPUADDR
        lda tmpX
        sta PPUADDR
        lda tmpY
        sta PPUADDR

        ldx #0
@copyToNametable:
        lda darkBuffer, x

        ; set pattern as blank
        cmp #$90
        bmi :+
        cmp #$A2
        bpl :+
        lda #$EF
:
        ; use rounded corners
        cmp #$70
        bmi :+
        cmp #$78
        bpl :+
        clc
        adc #$10
:

        sta PPUDATA
        inx
        cpx #16
        bne @copyToNametable

        clc
        lda tmpY
        adc #16
        sta tmpY
        bcc @noverflow
        inc tmpX
@noverflow:

        sec
        lda tmpZ
        sbc #1
        sta tmpZ
        bne @processChunk
        rts
