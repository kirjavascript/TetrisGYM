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

        lda renderFlags
        and #RENDER_LINES
        beq @renderLevel

        ldx #linesPrev-lines
        lda lagState
        and #$02
        bne @doLinesRender
        ldx #$00
@doLinesRender:
        lda #$20
        sta PPUADDR
        lda #$73
        sta PPUADDR
        lda lines+1,x
        sta PPUDATA
        lda lines,x
        jsr twoDigsToPPU
        jmp @doneRenderingLines

@modernLines:
        jsr renderModernLines
@doneRenderingLines:
        lda renderFlags
        and #~RENDER_LINES
        sta renderFlags

@renderLevel:
        lda renderFlags
        and #RENDER_LEVEL
        beq @renderScore

        lda practiseType
        cmp #MODE_TYPEB
        beq @renderLevelTypeB

        ; lda practiseType ; accumulator is still practiseType
        cmp #MODE_CHECKERBOARD
        beq @renderLevelCheckerboard

        lda #$22
        sta PPUADDR
        lda #$B9
        sta PPUADDR
        ldx #levelPrev-levelNumber
        lda lagState
        and #$01
        bne @doLevelRender
        ldx #$00
@doLevelRender:
        lda levelNumber,x
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
        lda renderFlags
        and #~RENDER_LEVEL
        sta renderFlags

@renderScore:
        lda renderFlags
        and #RENDER_SCORE
        beq @renderHz

        ; 7 safe tile writes freed from stats / hz
        ; (lazy render hz for 10 more)
        ; 1 added in level (3 total)
        ; 2 added in lines (5 total)
        ; 2 added on crash
        ; independent writes;
        ; 1 added in 7digit
        ; 3 added in float

        ; scorecap
        lda crashModifier
        cmp #CRASH_SHOW
        bne @noCrash
        lda crashState
        cmp #$F0
        bne @noCrash

        ; crash face
        lda #$20
        sta PPUADDR
        lda #$FD
        sta PPUADDR
        lda #$D8
        sta PPUDATA
        ; grey palette
        lda #$3F
        sta PPUADDR
        lda #$0D
        sta PPUADDR
        lda #$3D
        sta PPUDATA
@noCrash:
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
@noFloat:

        jsr renderClassicScore

@clearScoreRenderFlags:
        lda renderFlags
        and #~RENDER_SCORE
        sta renderFlags

@renderHz:
        lda hzFlag
        beq @renderStats
        lda renderFlags
        and #RENDER_HZ
        beq @renderStatsHz
        jsr renderHz
        lda renderFlags
        and #~RENDER_HZ
        sta renderFlags

        ; run a patched version of the stats
@renderStatsHz:
        lda renderFlags
        and #RENDER_STATS
        beq @renderTetrisFlashAndSound
        lda #$06
        sta tmpCurrentPiece
        jmp @renderPieceStat

@renderStats:
        lda renderFlags
        and #RENDER_STATS
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
        lda renderFlags
        and #~RENDER_STATS
        sta renderFlags
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
        ldx #levelPrev-levelNumber
        lda lagState
        and #$01
        bne @loadLevelNumber
        ldx #$00
@loadLevelNumber:
        lda levelNumber,x
@mod10: cmp #$0A
        bmi @copyPalettes ; bcc fixes the colour bug
        sec
        sbc #$0A
        jmp @mod10

@copyPalettes:
        and #$3F
        tax
        lda palFlag
        beq @renderPalettes
        cpx #$35 ; Level 181 & 245 and'd with $3F (level 53 & 117 are properly mod10'd)
        bne @renderPalettes
        ldx #$40
@renderPalettes:
        lda #$3F
        sta PPUADDR
        lda #$09
        sta PPUADDR
        lda colorTable0,x
        sta PPUDATA
        lda colorTable1,x
        sta PPUDATA
        lda colorTable2,x
        sta PPUDATA
        lda #$3F
        sta PPUADDR
        lda #$19
        sta PPUADDR
        lda colorTable0,x
        sta PPUDATA
        lda colorTable1,x
        sta PPUDATA
        lda colorTable2,x
        sta PPUDATA
@done:
        rts

; 3 bytes per level in separate tables
colorTable0:
        .byte   $30,$30,$30,$30
        .byte   $30,$30,$30,$30
        .byte   $30,$30,$E6,$C9
        .byte   $A9,$E6,$C9,$A9
        .byte   $60,$20,$BE,$20
        .byte   $00,$A4,$A5,$85
        .byte   $98,$B7,$A4,$30
        .byte   $A4,$41,$48,$40
        .byte   $56,$20,$BE,$07
        .byte   $BF,$20,$BF,$4E
        .byte   $C9,$A6,$BD,$4A
        .byte   $07,$99,$99,$A5
        .byte   $1A,$07,$BD,$19
        .byte   $17,$47,$29,$19
        .byte   $06,$4C,$BD,$19
        .byte   $00,$01,$03,$05
        .byte   $21 ; level 181/245 pal (different from NTSC)

colorTable1:
        .byte   $21,$29,$24,$2A
        .byte   $2B,$22,$00,$05
        .byte   $16,$27,$69,$14
        .byte   $20,$89,$14,$20
        .byte   $A5,$30,$C9,$A5
        .byte   $D0,$A5,$20,$A6
        .byte   $A5,$D0,$C9,$A9
        .byte   $85,$A9,$A9,$A6
        .byte   $99,$69,$C9,$A5
        .byte   $4C,$EB,$A9,$60
        .byte   $05,$D3,$00,$4A
        .byte   $AA,$60,$60,$17
        .byte   $29,$F0,$4E,$D0
        .byte   $A0,$AB,$07,$C9
        .byte   $38,$2A,$4E,$60
        .byte   $00,$01,$04,$05
        .byte   $2b ; level 181/245 pal (same as NTSC)

colorTable2:
        .byte   $12,$1A,$14,$12
        .byte   $15,$2B,$16,$13
        .byte   $12,$16,$A5,$30
        .byte   $85,$A5,$30,$85
        .byte   $49,$56,$01,$A4
        .byte   $0E,$B7,$EB,$4C
        .byte   $A5,$36,$1C,$00
        .byte   $45,$01,$05,$BF
        .byte   $85,$99,$01,$A6
        .byte   $E6,$98,$00,$A5
        .byte   $D0,$E6,$DF,$4A
        .byte   $BD,$20,$E6,$18
        .byte   $07,$08,$99,$1C
        .byte   $02,$A5,$18,$07
        .byte   $E9,$99,$99,$00
        .byte   $01,$02,$04,$05
        .byte   $25 ; level 181/245 pal (same as NTSC)

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
        lda renderFlags
        ora #RENDER_STATS
        sta renderFlags
        rts
