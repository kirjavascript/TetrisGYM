render_playfield:
        lda #$04
        sta playfieldAddr+1
        jsr copyPlayfieldRowToVRAM
        jsr copyPlayfieldRowToVRAM
        jsr copyPlayfieldRowToVRAM
        jsr copyPlayfieldRowToVRAM
        rts

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
.if INES_MAPPER = 3
        lda #%10011000
        sta PPUCTRL
        sta currentPpuCtrl
.endif
        jsr resetScroll
        rts

pieceToPpuStatAddr:
        .dbyt   $2186,$21C6,$2206,$2246
        .dbyt   $2286,$22C6,$2306
