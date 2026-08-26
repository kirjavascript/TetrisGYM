gameModeState_initGameBackground:
        jsr hideSpritesAndBackground
        jsr updateAudioWaitForNmiAndResetOamStaging
.if INES_MAPPER <> 0
        lda #CHRBankSet0
        jsr changeCHRBanks
.endif
        stagePatchThenWaitForNmi gamePalette

        ldx #RLE_NT_GAME
        jsr copyRleNametableToPpu

        jsr scoringBackground
        lda trtFlag
        beq @noTrtPatch
        stagePatch trtNametable
@noTrtPatch:

        lda dasMeterFlag
        beq @noDasMeter
        stagePatch dasMeterNametable
@noDasMeter:

        jsr debugNametableUI

        ldy #$20
        ldx #$A3
        jsr patchSeed

        lda splitSquareFlag
        beq @noSplitSquares

        stagePatch splitSquareNametable
@noSplitSquares:

        lda hzFlag
        beq @noHz
        stagePatch hzStats
@noHz:

; flush queue here
        lda #RENDER_QUEUE
        sta renderMode
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda #RENDER_DISABLE
        sta renderMode

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

; dark mode last to get all possible corner mods
        ldy darkModifier
        beq @notDarkMode

        ; skip NMI tasks during darkmode setup
        lda #RENDER_DISABLE
        sta renderMode
        jsr drawDarkMode
@notDarkMode:

; reenable display
        jsr resetScroll
        lda #NMIEnable|BGPattern1|SpritePattern1
        sta currentPpuCtrl
        lda #RENDER_PLAY
        sta renderMode
        jsr showSpriteAndBackground

        lda #$01
        sta playState
        inc gameModeState ; 1
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
        stagePatch sevenDigitNametable

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
        stagePatchThenWaitForNmi savestateNametable
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
        lda paceModifier
        bmi @done
        stagePatch paceDiffText
        lda #0
@done:
        rts

paceDiffText: ; stripe
        .byte $20, $98, $3, $D, $12, $F, $F, $0

hzStats: ; stripe
        .byte $21, $63, $2, $FF, $FF, $FF
        .byte $21, $83, $5, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $21, $C3, $5, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $21, $E3, $1, $FF, $FF
        .byte $22, $03, $5, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $22, $03, $5, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $22, $43, $5, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $22, $83, $5, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $22, $c3, $5, $FF, $FF, $FF, $FF, $FF, $FF
        .byte $21, $A8, $0, $EC ; hz
        .byte $21, $A5, $0, $ED ; .
        .byte $23, $D8, $1, $B7, $25 ; hz palette
        .byte $22, $23, $2, $1D, $A, $19 ; tap
        .byte $22, $63, $2, $D, $15, $22 ; dly
        .byte $22, $A3, $2, $D, $12, $1B ; dir
        .byte $0

sevenDigitNametable:
        .byte $20, $5E, $1, $34, $75 ; -
        .byte $20, $7E, $1, $FF, $36 ; |
        .byte $20, $9E, $1, $FF, $36 ; |
        .byte $20, $BE, $1, $FF, $36 ; |
        .byte $20, $DE, $1, $FF, $36 ; |
        .byte $20, $FE, $1, $FF, $36 ; |
        .byte $21, $1E, $1, $00, $36 ; 0
        .byte $21, $3E, $1, $FF, $36 ; |
        .byte $21, $5E, $1, $37, $77 ; -
        .byte $0

trtNametable:
        .byte   $23,$17,$3,$74,$34,$34,$75
        .byte   $23,$37,$3,$35,$00,$00,$36
        .byte   $23,$57,$3,$76,$37,$37,$77
        .byte   $0

splitSquareNametable:
        .byte   $22,$23,$1,$B0,$B1
        .byte   $22,$43,$1,$B2,$B3
        .byte   $0

savestateNametable:
        .byte   $22,$F7,$7,$74,$34,$34,$34,$34,$34,$34,$75
        .byte   $23,$17,$7,$35,$1C,$15,$18,$1D,$FF,$FF,$36
        .byte   $23,$37,$7,$35,$FF,$FF,$FF,$FF,$FF,$FF,$36
        .byte   $23,$57,$7,$76,$37,$37,$37,$37,$37,$37,$77
        .byte   $0

dasMeterNametable:
        .byte   $23,$6C,$8,$74,$34,$34,$34,$34,$34,$34,$34,$75
        .byte   $23,$8C,$8,$76,$37,$37,$37,$37,$37,$37,$37,$77
        .byte   $0

NORMAL_CORNER_TILES := $70
DARK_CORNER_TILES := $80

darkModeColors:
        .byte $2D,$3C,$10,$0C,$3C

drawDarkMode:

darkBuffer := playfield ; cleared right after in initGameState

        ; set the border colour
        lda #$3F
        sta PPUADDR
        lda #$D
        sta PPUADDR
        ldx darkModifier
        lda darkModeColors-1,x
        sta PPUDATA

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

        ldx #15
@copyToBuffer:
        lda PPUDATA
        sta darkBuffer, x
        dex
        bpl @copyToBuffer

        ; reset PPUADDR
        lda tmpX
        sta PPUADDR
        lda tmpY
        sta PPUADDR

        ldx #15
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
        dex
        bpl @copyToNametable

        clc
        lda tmpY
        adc #16
        sta tmpY
        bcc @noverflow
        inc tmpX
@noverflow:

        dec tmpZ
        bne @processChunk
        rts
