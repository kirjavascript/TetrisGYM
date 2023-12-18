render_mode_play_and_demo:
        lda playState
        cmp #$04
        bne @playStateNotDisplayLineClearingAnimation
        lda #$04
        sta playfieldAddr+1
        jsr updateLineClearingAnimation
        lda #$00
        sta vramRow
        jmp @renderLines

@playStateNotDisplayLineClearingAnimation:
        jsr render_playfield
@renderLines:

        lda scoringModifier
        bne @modernLines

        lda outOfDateRenderFlags
        and #$01
        beq @renderLevel

        lda #$20
        sta PPUADDR
        lda #$73
        sta PPUADDR
        lda lines+1
        sta PPUDATA
        lda lines
        jsr twoDigsToPPU
        jmp @doneRenderingLines

@modernLines:
        jsr renderModernLines
@doneRenderingLines:
        lda outOfDateRenderFlags
        and #$FE
        sta outOfDateRenderFlags

@renderLevel:
        lda outOfDateRenderFlags
        and #$02
        beq @renderScore

        lda practiseType
        cmp #MODE_TYPEB
        beq @renderLevelTypeB

        lda practiseType
        cmp #MODE_CHECKERBOARD
        beq @renderLevelCheckerboard

        lda #$22
        sta PPUADDR
        lda #$B9
        sta PPUADDR
        lda levelNumber
        jsr renderByteBCD
        jmp @renderLevelEnd

@renderLevelCheckerboard:
        jsr renderLevelDash
        lda checkerModifier
        sta PPUDATA
        jmp @renderLevelEnd

@renderLevelTypeB:
        jsr renderLevelDash
        lda typeBModifier
        sta PPUDATA
        ; jmp @renderLevelEnd

@renderLevelEnd:
        jsr updatePaletteForLevel
        lda outOfDateRenderFlags
        and #$FD
        sta outOfDateRenderFlags

@renderScore:
        lda outOfDateRenderFlags
        and #$04
        beq @renderHz

        ; 8 safe tile writes freed from stats / hz
        ; (lazy render hz for 10 more)
        ; 1 added in level (3 total)
        ; 2 added in lines (5 total)
        ; independent writes;
        ; 1 added in 7digit
        ; 3 added in float

        ; scorecap
        lda scoringModifier
        cmp #SCORING_HIDDEN
        bne @notHidden
        lda playState
        cmp #$0A
        beq @noFloat ; render classic score at game over
        jmp @clearScoreRenderFlags
@notHidden:
        cmp #SCORING_SCORECAP
        bne @noScoreCap
        jsr renderScoreCap
        jmp @clearScoreRenderFlags
@noScoreCap:

        lda scoringModifier
        cmp #SCORING_LETTERS
        bne @noLetters
        jsr renderLettersScore
        jmp @clearScoreRenderFlags
@noLetters:

        lda scoringModifier
        cmp #SCORING_SEVENDIGIT
        bne @noSevenDigit
        jsr renderSevenDigit
        jmp @clearScoreRenderFlags
@noSevenDigit:

        ; millions
        lda scoringModifier
        cmp #SCORING_FLOAT
        bne @noFloat
        jsr renderFloat
        jmp @clearScoreRenderFlags
@noFloat:

        jsr renderClassicScore

@clearScoreRenderFlags:
        lda outOfDateRenderFlags
        and #$FB
        sta outOfDateRenderFlags

@renderHz:
        lda hzFlag
        beq @renderStats
        lda outOfDateRenderFlags
        and #$10
        beq @renderStatsHz
        jsr renderHz
        lda outOfDateRenderFlags
        and #$EF
        sta outOfDateRenderFlags

        ; run a patched version of the stats
@renderStatsHz:
        lda outOfDateRenderFlags
        and #$40
        beq @renderTetrisFlashAndSound
        lda #$06
        sta tmpCurrentPiece
        jmp @renderPieceStat

@renderStats:
        lda outOfDateRenderFlags
        and #$40
        beq @renderTetrisFlashAndSound
        ldx currentPiece
        lda tetriminoTypeFromOrientation, x
        sta tmpCurrentPiece
@renderPieceStat:
        lda tmpCurrentPiece
        asl a
        tax
        lda pieceToPpuStatAddr,x
        sta PPUADDR
        lda pieceToPpuStatAddr+1,x
        sta PPUADDR
        lda statsByType+1,x
        sta PPUDATA
        lda statsByType,x
        jsr twoDigsToPPU
        lda outOfDateRenderFlags
        and #$BF
        sta outOfDateRenderFlags
@renderTetrisFlashAndSound:
        lda #$3F
        sta PPUADDR
        lda #$0E
        sta PPUADDR
        ldx #$00
        lda completedLines
        cmp #$04
        bne @setPaletteColor
        lda frameCounter
        and #$03
        bne @setPaletteColor
        ldx #$30
        lda frameCounter
        and #$07
        bne @setPaletteColor
        lda #$09
        sta soundEffectSlot1Init
@setPaletteColor:
        lda disableFlashFlag
        bne @noFlash
        stx PPUDATA
@noFlash:
; .if INES_MAPPER = 3
        lda #%10000000
        sta PPUCTRL
        sta currentPpuCtrl
; .endif
        jsr resetScroll
        rts

pieceToPpuStatAddr:
        .dbyt   $2186,$21C6,$2206,$2246
        .dbyt   $2286,$22C6,$2306


updateLineClearingAnimation:
.if AUTO_WIN
        inc playState
        rts
.endif
        lda frameCounter
        and #$03
        bne @ret
        ; invisible mode show blocks intead of empty
        ldy #$FF
        lda invisibleFlag
        beq @notInvisible
        ldy #BLOCK_TILES
@notInvisible:
        sty tmp3

        lda #$00
        sta generalCounter3
@whileCounter3LessThan4:
        ldx generalCounter3
        lda completedRow,x
        beq @nextRow
        asl a
        tay
        lda vramPlayfieldRows,y
        sta generalCounter
        lda generalCounter
        clc
        adc #$06
        sta generalCounter

        iny
        lda vramPlayfieldRows,y
        sta generalCounter2
        sta PPUADDR
        ldx rowY
        lda leftColumns,x
        clc
        adc generalCounter
        sta PPUADDR
        lda tmp3 ; #$FF
        sta PPUDATA
        lda generalCounter2
        sta PPUADDR
        ldx rowY
        lda rightColumns,x
        clc
        adc generalCounter
        sta PPUADDR
        lda tmp3 ; #$FF
        sta PPUDATA
@nextRow:
        inc generalCounter3
        lda generalCounter3
        cmp #$04
        bne @whileCounter3LessThan4
        inc rowY
        lda rowY
        cmp #$05
        bmi @ret
        inc playState
@ret:   rts

leftColumns:
        .byte   $04,$03,$02,$01,$00
rightColumns:
        .byte   $05,$06,$07,$08,$09
; Set Background palette 2 and Sprite palette 2
updatePaletteForLevel:
        lda levelNumber
@mod10: cmp #$0A
        bmi @copyPalettes ; bcc fixes the colour bug
        sec
        sbc #$0A
        jmp @mod10

@copyPalettes:
        asl a
        asl a
        tax
        lda #$00
        sta generalCounter
@copyPalette:
        lda #$3F
        sta PPUADDR
        lda #$08
        clc
        adc generalCounter
        sta PPUADDR
        lda colorTable,x
        sta PPUDATA
        lda colorTable+1,x
        sta PPUDATA
        lda colorTable+1+1,x
        sta PPUDATA
        lda colorTable+1+1+1,x
        sta PPUDATA
        lda generalCounter
        clc
        adc #$10
        sta generalCounter
        cmp #$20
        bne @copyPalette
        rts

; 4 bytes per level (bg, fg, c3, c4)
colorTable:
        .dbyt   $0F30,$2112,$0F30,$291A,$0F30,$2414,$0F30,$2A12
        .dbyt   $0F30,$2B15,$0F30,$222B,$0F30,$0016,$0F30,$0513
        .dbyt   $0F30,$1612,$0F30,$2716,$60E6,$69A5,$69C9,$1430
        .dbyt   $04A9,$2085,$69E6,$89A5,$89C9,$1430,$04A9,$2085
        .dbyt   $8960,$A549,$C920,$3056,$A5BE,$C901,$F020,$A5A4
        .dbyt   $C900,$D00E,$E6A4,$A5B7,$85A5,$20EB,$9885,$A64C
        .dbyt   $EA98,$A5A5,$C5B7,$D036,$A5A4,$C91C,$D030,$A900
        .dbyt   $85A4,$8545,$8541,$A901,$8548,$A905,$8540,$A6BF
        .dbyt   $BD56,$9985,$4220,$6999,$A5BE,$C901,$F007,$A5A6
        .dbyt   $85BF,$4CE6,$9820,$EB98,$85BF,$A900,$854E,$60A5
        .dbyt   $C0C9,$05D0,$12A6,$D3E6,$D3BD,$00DF,$4A4A,$4A4A
        .dbyt   $2907,$AABD,$4E99,$6020,$0799,$60E6,$1AA5,$1718
        .dbyt   $651A,$2907,$C907,$F008,$AABD,$4E99,$C519,$D01C
        .dbyt   $A217,$A002,$2047,$ABA5,$1729,$0718,$6519,$C907
        .dbyt   $9006,$38E9,$074C,$2A99,$AABD,$4E99,$8519,$6000
        .dbyt   $0000,$0001,$0101,$0102,$0203,$0404,$0505,$0505

incrementPieceStat:
        tax
        lda tetriminoTypeFromOrientation,x
        asl a
        tax
        lda statsByType,x
        clc
        adc #$01
        sta generalCounter
        and #$0F
        cmp #$0A
        bmi L9996
        lda generalCounter
        clc
        adc #$06
        sta generalCounter
        cmp #$A0
        bcc L9996
        clc
        adc #$60
        sta generalCounter
        lda statsByType+1,x
        clc
        adc #$01
        sta statsByType+1,x
L9996:  lda generalCounter
        sta statsByType,x
        lda outOfDateRenderFlags
        ora #$40
        sta outOfDateRenderFlags
        rts
