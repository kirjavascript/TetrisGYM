; y reg tracks lines crossing multiple of 10 from @linesCleared until addPoints

playState_updateLinesAndStatistics:
        jsr updateMusicSpeed
        lda completedLines
        bne @linesCleared
        jmp addPoints

@linesCleared:
        ldy #$00
        tax
        dec lineClearStatsByType-1,x
        bpl @noCarry
        lda #$09
        sta lineClearStatsByType-1,x
@noCarry:
        lda renderFlags
        ora #RENDER_LINES
        sta renderFlags

; type-b lines decrement
        lda practiseType
        cmp #MODE_TYPEB
        bne @notTypeB
        lda completedLines
        sta generalCounter
        lda lines
        sec
        sbc generalCounter
        sta lines
        bpl @checkForBorrow
        lda #$00
        sta lines
        jmp addPoints
@checkForBorrow:
        and #$0F
        cmp #$0A
        bmi @addPoints_jmp
        lda lines
        sec
        sbc #$06
        sta lines
@addPoints_jmp:
        jmp addPoints
@notTypeB:

        ldx completedLines
        lda lines
        sta linesPrev
        lda lines+1
        sta linesPrev+1
incrementLines:
        inc lines
        lda lines
        and #$0F
        cmp #$0A
        bmi checkLevelUp
        inc crashState
        lda lines
        clc
        adc #$06
        sta lines
        and #$F0
        cmp #$A0
        bcc checkLevelUp
        lda lines
        and #$0F
        sta lines
        inc lines+1
        lda crashState
        ora #$02
        sta crashState

checkLevelUp:
        jsr calcBCDLinesAndTileQueue

        lda lines
        and #$0F
        bne @lineLoop

        iny ; used by floorcap check below
        lda practiseType
        cmp #MODE_TAPQTY
        beq @lineLoop
        cmp #MODE_MARATHON
        bne @notMarathon
        lda marathonModifier
        beq @lineLoop ; marathon mode 0 does not transition
        bne @notSXTOKL
@notMarathon:
        cmp #MODE_TRANSITION
        bne @notSXTOKL
        lda transitionModifier
        cmp #$10
        bne @notSXTOKL
        jmp @nextLevel
@notSXTOKL:

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
        lda levelNumber
        sta levelPrev
        inc levelNumber
        lda crashState
        ora #$08
        sta crashState
        lda #$06
        sta soundEffectSlot1Init
        lda renderFlags
        ora #RENDER_LEVEL
        sta renderFlags

@lineLoop:  dex
        beq checkLinecap
        jmp incrementLines

checkLinecap: ; set linecapState
        ; check if enabled
        lda linecapFlag
        beq @linecapEnd
        ; skip check if already set
        lda linecapState
        bne @linecapEnd

        lda linecapWhen
        beq @linecapLevelCheck

;linecapLinesCheck

        lda lines+1
        cmp linecapLines+1
        bcc @linecapEnd
        lda lines
        cmp linecapLines
        bcc @linecapEnd
        bcs @linecapApply

@linecapLevelCheck:
        lda levelNumber
        cmp linecapLevel
        bcc @linecapEnd

@linecapApply:
        clc
        lda linecapHow
        adc #1
        sta linecapState

        cmp #LINECAP_INVISIBLE
        bne @linecapEnd
        sta invisibleFlag

@linecapEnd:

        ; floor linecap effect
        lda linecapState
        cmp #LINECAP_FLOOR
        bne @floorLinecapEnd
        ; check level up was possible
        tya
        beq @floorLinecapEnd
        lda #$A
        sta garbageHole
        lda #1
        sta pendingGarbage
        inc currentFloor
@floorLinecapEnd:

addPoints:
        inc playState
        lda practiseType
        cmp #MODE_CHECKERBOARD
        beq handlePointsCheckerboard
        cmp #MODE_TAPQTY
        bne @notTapQuantity
        lda completedLines
        ; cmp #0 ; lda sets z flag
        bne @continueStreak
        jsr clearPoints
        lda renderFlags
        ora #RENDER_SCORE
        sta renderFlags
        rts
@continueStreak:
        lda #4
        sta completedLines
@notTapQuantity:

        lda crashModifier
        cmp #CRASH_OFF
        beq @crashDisabled
        jsr testCrash
@crashDisabled:

addPointsRaw:
.if NO_SCORING
        rts
.endif

        lda holdDownPoints
        cmp #$02
        bmi @noPushDown
        jsr addPushDownPoints
@noPushDown:
        lda #$0
        sta holdDownPoints
        jsr addLineClearPoints
        rts

handlePointsCheckerboard:
        lda score+1
        bne @handlePoints
        lda score+2
        beq @end
@handlePoints:
        ldx completedLines
        lda checkerboardPoints, x
        sta tmpZ
        sec
        lda binScore
        sbc tmpZ
        sta binScore
        lda binScore+1
        sbc #0
        sta binScore+1
        jsr setupScoreForRender
        lda renderFlags
        ora #RENDER_SCORE
        sta renderFlags
@end:
        lda #$0
        sta completedLines
        lda #$0
        sta holdDownPoints
        rts

checkerboardPoints:
        .byte 0, 10, 20, 30, 40

ones := tmpX
hundredths := tmpY
low := tmpZ
high := tmp3

addPushDownPoints:
        clc
        lda score
        and #$F
        sta ones

        lda score
        jsr div16mul10
        adc ones
        sta hundredths

        lda holdDownPoints
        sbc #1
        adc ones
        sta holdDownPoints

        and #$F
        cmp #$A
        bcc @pdp2
        lda holdDownPoints
        adc #5
        sta holdDownPoints
@pdp2:

        lda holdDownPoints
        and #$f
        sta low

        lda holdDownPoints
        jsr div16mul10
        sta high

        lda hundredths
        sbc ones
        sec
        adc high
        sta holdDownPoints

        clc
        adc low
        cmp #101
        bcs @noLow
        sta holdDownPoints
@noLow:

        sec
        lda binScore
        sbc hundredths
        sta binScore
        lda binScore+1
        sbc #0
        sta binScore+1
        lda binScore+2
        sbc #0
        sta binScore+2
        lda binScore+3
        sbc #0
        sta binScore+3

        clc
        lda binScore
        adc holdDownPoints
        sta binScore
        lda binScore+1
        adc #0
        sta binScore+1
        lda binScore+2
        adc #0
        sta binScore+2
        lda binScore+3
        adc #0
        sta binScore+3
        rts

div16mul10:
        and #$f0
        ror
        ror
        ror
        ror
        tax
        lda multBy10Table,x
        rts

addLineClearPoints:
        lda #0
        sta factorA24+1
        sta factorA24+2
        lda levelNumber
        ldy practiseType
        cpy #MODE_MARATHON
        bne @notMarathon
        lda startLevel
@notMarathon:
        sta factorA24+0
        inc factorA24+0
        bne @noverflow
        inc factorA24+1
@noverflow:

        lda completedLines
        beq addLineClearPoints_end ; skip with 0 completed lines
        asl
        tax
        lda pointsTable, x
        sta factorB24+0
        lda pointsTable+1, x
        sta factorB24+1
        lda #0
        sta factorB24+2

        jsr unsigned_mul24 ; points to add in product24

        clc
        lda binScore
        adc product24
        sta binScore
        lda binScore+1
        adc product24+1
        sta binScore+1
        lda binScore+2
        adc product24+2
        sta binScore+2
        lda binScore+3
        adc #0
        sta binScore+3

addLineClearPoints_end:
        lda renderFlags
        ora #RENDER_SCORE
        sta renderFlags
        lda #$00
        sta completedLines

setupScoreForRender:
        lda binScore
        sta binary32
        lda binScore+1
        sta binary32+1
        lda binScore+2
        sta binary32+2
        lda binScore+3
        sta binary32+3
        jsr BIN_BCD
        lda bcd32
        sta score
        lda bcd32+1
        sta score+1
        lda bcd32+2
        sta score+2
        lda bcd32+3
        sta score+3
        rts

clearPoints:
        lda #0
        sta score
        sta score+1
        sta score+2
        sta score+3
        sta binScore
        sta binScore+1
        sta binScore+2
        sta binScore+3
        rts

pointsTable:
        .word   0,40,100,300,1200
        .word   1000 ; used in btype score calc

calcBCDLinesAndTileQueue:
        lda #0
        sta tmp3
        lda lines+1
@modLoop:
        cmp #10
        bcc @modEnd
        sbc #10
        inc tmp3
        jmp @modLoop
@modEnd:
        sta linesBCDHigh

        lda tmp3
        rol
        rol
        rol
        rol
        adc linesBCDHigh
        sta linesBCDHigh

        ; setup tile queue
        lda linesBCDHigh
        cmp #$A
        bcc @ret
        lda linesTileQueue
        bne @ret
        lda #$80
        sta linesTileQueue
@ret:
        rts
