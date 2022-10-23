gameModeState_initGameState:
        lda #$EF
        ldx #$04
        ldy #$04
        jsr memset_page
        ldx #$0F
        lda #$00
; statsByType
@initStatsByType:
        sta $03EF,x
        dex
        bne @initStatsByType
        lda #$05
        sta tetriminoX

        ; set seed init
        lda set_seed_input
        sta set_seed
        lda set_seed_input+1
        sta set_seed+1
        lda set_seed_input+2
        sta set_seed+2

        ; paceResult init
        lda #$B0
        sta paceResult
        lda #$00
        sta paceSign
        sta paceResult+1
        sta paceResult+2

        ; misc
        sta spawnDelay
        sta saveStateSpriteDelay
        sta saveStateDirty
        sta completedLines ; reset during tetris bugfix
        sta presetIndex ; actually for tspinQuantity
        sta linesTileQueue
        sta linesBCDHigh
        sta linecapState
        sta dasOnlyShiftDisabled

        lda practiseType
        cmp #MODE_TAPQTY
        bne @noTapQty
        jsr random10
        sta tqtyNext
        sta tqtyCurrent
@noTapQty:

        jsr clearPoints
        ; 0 in A

        ; OEM stuff (except score stuff now)
        sta tetriminoY
        sta vramRow
        sta fallTimer
        sta pendingGarbage
        sta lines
        sta lines+1
        sta lineClearStatsByType
        sta lineClearStatsByType+1
        sta lineClearStatsByType+2
        sta lineClearStatsByType+3
        sta allegro
        sta demo_heldButtons
        sta demo_repeats
        sta demoIndex
        sta demoButtonsAddr
        sta spawnID
        lda #>demoButtonsTable
        sta demoButtonsAddr+1
        lda #$03
        sta renderMode
        ldx #$A0
        lda palFlag
        beq @ntsc
        ldx #$B4
@ntsc:
        stx autorepeatY
        jsr chooseNextTetrimino
        sta currentPiece
        jsr incrementPieceStat
        ldx #rng_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        jsr chooseNextTetrimino
        sta nextPiece

        lda practiseType
        cmp #MODE_TRANSITION
        bne @notTransition
        jsr transitionModeSetup
@notTransition:

        lda practiseType
        cmp #MODE_TYPEB
        bne @notTypeB
        lda #BTYPE_START_LINES
        sta lines
@notTypeB:

        lda practiseType
        cmp #MODE_CHECKERBOARD
        bne @noChecker
        lda checkerModifier
        rol
        rol
        rol
        rol
        and #$F0
        sta bcd32+1
        lda #0
        sta bcd32
        sta bcd32+2
        sta bcd32+3
        jsr presetScoreFromBCD
@noChecker:

        lda #$57
        sta outOfDateRenderFlags
        jsr updateAudioWaitForNmiAndResetOamStaging

        lda practiseType
        cmp #MODE_TYPEB
        bne @noTypeBPlayfield
        jsr initPlayfieldForTypeB
@noTypeBPlayfield:

        jsr hzStart
        jsr practiseInitGameState
        jsr resetScroll

        ldx musicType
        lda musicSelectionTable,x
        jsr setMusicTrack
        inc gameModeState ; 2
        lda #4 ; acc should not be equal

initGameState_return:
        rts

transitionModeSetup:
        lda transitionModifier
        cmp #$10 ; (SXTOKL compat)
        beq initGameState_return
        ; set score
        rol
        rol
        rol
        rol
        sta bcd32+2
        lda #0
        sta bcd32
        sta bcd32+1
        sta bcd32+3
        jsr presetScoreFromBCD

        lda levelNumber
        cmp #129 ; everything after 128 transitions immediately
        bpl initGameState_return

@addLinesLoop:
        ldx #$A
        lda lines
        sta tmpX
        lda lines+1
        sta tmpY
@incrementLines:
        inc lines
        lda lines
        and #$0F
        cmp #$0A
        bmi @checkTransition
        lda lines
        clc
        adc #$06
        sta lines
        and #$F0
        cmp #$A0
        bcc @checkTransition
        lda lines
        and #$0F
        sta lines
        inc lines+1

@checkTransition:
        lda lines
        and #$0F
        bne @lineLoop

        lda lines+1
        sta generalCounter2
        lda lines
        sta generalCounter
        lsr generalCounter2
        ror generalCounter
        lsr generalCounter2
        ror generalCounter
        lsr generalCounter2
        ror generalCounter
        lsr generalCounter2
        ror generalCounter
        lda levelNumber
        cmp generalCounter
        bpl @lineLoop

@nextLevel:
        lda tmpX
        sta lines
        lda tmpY
        sta lines+1
        rts
@lineLoop:  dex
        bne @incrementLines
        jmp @addLinesLoop

presetScoreFromBCD:
        jsr BCD_BIN
        lda binary32
        sta binScore
        lda binary32+1
        sta binScore+1
        lda binary32+2
        sta binScore+2
        jsr setupScoreForRender
        rts

initPlayfieldForTypeB:
        lda typeBModifier
        cmp #$6
        bmi @normalStart
        sbc #$5
        asl
        adc #$0c
        jmp @abnormalStart
@normalStart:
        lda #$0C
@abnormalStart:
        sta generalCounter
L87E7:  lda generalCounter
        beq L884A
        lda #$14
        sec
        sbc generalCounter
        sta generalCounter2
        lda #$00
        sta vramRow
        lda #$09
        sta generalCounter3
L87FC:  ldx #$17
        ldy #$02
        jsr generateNextPseudorandomNumber
        lda rng_seed
        and #$07
        tay
        lda rngTable,y
        sta generalCounter4
        ldx generalCounter2
        lda multBy10Table,x
        clc
        adc generalCounter3
        tay
        lda generalCounter4
        sta playfield,y
        lda generalCounter3
        beq L8824
        dec generalCounter3
        jmp L87FC

L8824:  ldx #$17
        ldy #$02
        jsr generateNextPseudorandomNumber
        lda rng_seed
        and #$0F
        cmp #$0A
        bpl L8824
        sta generalCounter5
        ldx generalCounter2
        lda multBy10Table,x
        clc
        adc generalCounter5
        tay
        lda #EMPTY_TILE
        sta playfield,y
        jsr updateAudioWaitForNmiAndResetOamStaging
        dec generalCounter
        bne L87E7
L884A:
        ldx typeBModifier
        lda typeBBlankInitCountByHeightTable,x
        tay
        lda #EMPTY_TILE
L885D:  sta playfield,y
        dey
        cpy #$0
        bne L885D
        lda #$00
        sta vramRow
        rts

        ; 0 3 5 8 10 12 -> 14 16 18
typeBBlankInitCountByHeightTable:
        .byte $C8,$AA,$96,$78,$64,$50,$3C,$28,$14
rngTable:
        .byte EMPTY_TILE,BLOCK_TILES,EMPTY_TILE,BLOCK_TILES+1
        .byte BLOCK_TILES+2,BLOCK_TILES+2,EMPTY_TILE,EMPTY_TILE
