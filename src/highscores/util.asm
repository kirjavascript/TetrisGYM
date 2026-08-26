resetScores:
        ldx #highScoreLength * highScoreQuantity - 1
        lda #$0
@initHighScoreTable:
        sta highscores,x
        dex
        bpl @initHighScoreTable
@continue:
        rts


resetMenuVars:
        ldx #sramVariableLength -1
        lda #$0
@loop:
        sta menuVars,x
        dex
        bpl @loop
        jsr detectKeyboard

        lda #$FF
        sta paceModifier

; set das/arr based on detected region at bootup
        ldx #NTSC_DAS
        ldy #NTSC_ARR
        lda detectedRegion
        sta palFlag
        beq @storeDas
        ; pal
        ldx #PAL_DAS
        ldy #PAL_ARR
@storeDas:
        stx dasModifier
        sty arrModifier

@continue:
        lda #MODE_TETRIS
        sta practiseType

        lda #INITIAL_LINECAP_LEVEL
        sta linecapLevel
        lda #INITIAL_LINECAP_LINES_LO
        sta linecapLines+1
        lda #INITIAL_LINECAP_LINES_HI
        sta linecapLines

        lda #BTYPE_START_LINES
        sta bTypeLines
        lda #1
        sta tapLeftColumn
        lda #8
        sta tapRightColumn
        lda #6
        sta practisePiece
        lda #5
        sta startScore
        lda #12
        sta startLines

resetVanillaPalette:
        ldx #9
resetPaletteAtX:
        ldy #27
@palette:
        lda colorTable0,x
        sta customLevel0+0,y
        lda colorTable1,x
        sta customLevel0+1,y
        lda colorTable2,x
        sta customLevel0+2,y
        dex
        dey
        dey
        dey
        bpl @palette
        rts



.if SAVE_HIGHSCORES
detectSRAM:
        lda #HIGH_SCORE_MAGIC0
        sta SRAM_hsMagic
        lda #HIGH_SCORE_MAGIC1
        sta SRAM_hsMagic+1
        lda SRAM_hsMagic
        cmp #HIGH_SCORE_MAGIC0
        bne @noSRAM
        lda SRAM_hsMagic+1
        cmp #HIGH_SCORE_MAGIC1
        bne @noSRAM
        lda #1
        rts
@noSRAM:
        lda #0
        rts

checkSavedInit:
        lda SRAM_hsMagic+2
        cmp #HIGH_SCORE_MAGIC2
        bne @resetSaved
        lda SRAM_hsMagic+3
        cmp #HIGH_SCORE_MAGIC3
        beq @checkMenuVars
@resetSaved:
        jsr resetSavedScores
@checkMenuVars:
        lda SRAM_varMagic+0
        cmp #HIGH_SCORE_MAGIC0
        bne @resetSavedVars
        lda SRAM_varMagic+1
        cmp #HIGH_SCORE_MAGIC1
        bne @resetSavedVars
        lda SRAM_varMagic+2
        cmp #HIGH_SCORE_MAGIC2
        bne @resetSavedVars
        lda SRAM_varMagic+3
        cmp #HIGH_SCORE_MAGIC3
        beq @ret
@resetSavedVars:
        jsr resetSavedVars
@ret:
        rts

resetSavedScores:
        lda #HIGH_SCORE_MAGIC2
        sta SRAM_hsMagic+2
        lda #HIGH_SCORE_MAGIC3
        sta SRAM_hsMagic+3

        ldx #highScoreLength * highScoreQuantity - 1
        lda #$0
@copyLoop:
        sta SRAM_highscores,x
        dex
        bpl @copyLoop
        rts


resetSavedVars:
        lda #HIGH_SCORE_MAGIC0
        sta SRAM_varMagic+0
        lda #HIGH_SCORE_MAGIC1
        sta SRAM_varMagic+1
        lda #HIGH_SCORE_MAGIC2
        sta SRAM_varMagic+2
        lda #HIGH_SCORE_MAGIC3
        sta SRAM_varMagic+3
        jsr resetMenuVars
copyVarsToSram:
        ldx #sramVariableLength - 1
@varsLoop:
        lda menuVars,x
        sta SRAM_variables,x
        dex
        bpl @varsLoop
@continue:
        rts


copyScoresFromSRAM:
        ldx #highScoreLength * highScoreQuantity - 1
@copyLoop:
        lda SRAM_highscores,x
        sta highscores,x
        dex
        bpl @copyLoop
@continue:
        rts

copyScoresToSRAM:
        ldx #highScoreLength * highScoreQuantity - 1
@copyLoop:
        lda highscores,x
        sta SRAM_highscores,x
        dex
        bpl @copyLoop
@continue:
        rts

copyVarsFromSRAM:
        ldx #sramVariableLength - 1
@copyLoop:
        lda SRAM_variables,x
        sta menuVars,x
        dex
        bpl @copyLoop
@continue:
        rts

.endif
