playState_updateLinesAndStatistics:
        jsr updateMusicSpeed
        lda completedLines
        bne @linesCleared
        jmp addPoints

@linesCleared:
        tax
        dex
        lda lineClearStatsByType,x
        clc
        adc #$01
        sta lineClearStatsByType,x
        and #$0F
        cmp #$0A
        bmi @noCarry
		lda crashFlag
		ora #$04
		sta crashFlag
        lda lineClearStatsByType,x
        clc
        adc #$06
        sta lineClearStatsByType,x
@noCarry:
        lda outOfDateRenderFlags
        ora #$01
        sta outOfDateRenderFlags

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
incrementLines:
        inc lines
        lda lines
        and #$0F
        cmp #$0A
        bmi checkLevelUp
		lda crashFlag
		ora #$01
		sta crashFlag
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
		lda crashFlag
		ora #$02
		sta crashFlag

checkLevelUp:
        jsr calcBCDLinesAndTileQueue

        lda lines
        and #$0F
        bne @lineLoop

        lda practiseType
        cmp #MODE_TAPQTY
        beq @lineLoop
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
        inc levelNumber
		lda crashFlag
		ora #$08
		sta crashFlag
        lda #$06 ; checked in floor linecap stuff, just below
        sta soundEffectSlot1Init
        lda outOfDateRenderFlags
        ora #$02
        sta outOfDateRenderFlags

@lineLoop:  dex
        bne incrementLines


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
        ; check level up sound is happening
        lda soundEffectSlot1Init
        cmp #6
        bne @floorLinecapEnd
        lda #$A
        sta garbageHole
        lda #1
        sta pendingGarbage
@floorLinecapEnd:

addPoints:
        inc playState
addPointsRaw:
.if NO_SCORING
        rts
.endif
        lda practiseType
        cmp #MODE_CHECKERBOARD
        beq handlePointsCheckerboard
        cmp #MODE_TAPQTY
        bne @notTapQuantity
        lda completedLines
        ; cmp #0 ; lda sets z flag
        bne @continueStreak
        jsr clearPoints
        lda outOfDateRenderFlags
        ora #$04
        sta outOfDateRenderFlags
        rts
@continueStreak:
        lda #4
        sta completedLines
@notTapQuantity:
        jsr testCrash
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
        lda outOfDateRenderFlags
        ora #$04
        sta outOfDateRenderFlags
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
        cmp #$FF
        bne @noverflow
        lda #1
        sta factorA24+1
        lda #0
        sta factorA24+0
        jmp @multSetupEnd
@noverflow:
        adc #1
        sta factorA24
@multSetupEnd:

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
        lda outOfDateRenderFlags
        ora #$04
        sta outOfDateRenderFlags
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
testCrash:
		lda #$1C ; setting all cycles which always happen
		sta cycleCount
		lda #$6F
		sta cycleCount+1 ;low byte at +1
	
		lda completedLines
		beq @linesNotCleared
		ldx #$04 ;setting loop to run 4x
@clearedLine:
		lda completedRow-1, x
		beq @noneThisRow ; adds no cycles if lines not cleared
		cmp #$0B
		lda #$00
		bcc @sub11
		lda #$02 ;97 cycles if row is below 11; higher numbers are lower on the board
		clc
@sub11: adc #$5F ;95 cycles
		adc cycleCount+1
		sta cycleCount+1
		lda cycleCount
		adc #$00 ; dealing with carry
		sta cycleCount
@noneThisRow:
		dex
		bne @clearedLine 
		
@linesNotCleared:
		lda displayNextPiece
		bne @nextOff
		lda #$8A ; add 394 cycles for nextbox
		adc cycleCount+1
		sta cycleCount+1
		lda cycleCount
		adc #$01 ; high byte of 18A
		sta cycleCount
		
@nextOff:
		lda allegroIndex
		bne @allegro
		lda #$95 ; 149 in decimal.
		clc
		ldx wasAllegro ; FF is allegro. 00 is no allegro.
		beq @addMusicCycles
		adc #$26 ;add 38 cycles for disabling allegro
@addMusicCycles:
		adc cycleCount+1
		sta cycleCount+1
		lda cycleCount
		adc #$00
		sta cycleCount
		bne @linesCycles
@allegro:
		sec 
		sbc #$32 ; subtract 50, allegro index already loaded
		asl
		asl
		asl
		asl ;multiply by 16
		tax ; save low byte result
		lda cycleCount
		adc #$00 ; add high byte carry
		sta cycleCount
		txa
		adc cycleCount+1
		sta cycleCount+1
		lda cycleCount
		adc #$00 ; add carry again
		sta cycleCount
		lda wasAllegro
		bne @linesCycles ; FF is allegro
		lda #$29 ; add 41 cycles for changing to allegro
		adc cycleCount+1
		sta cycleCount+1
		lda cycleCount
		adc #$00
		sta cycleCount
		
@linesCycles:

		lda #$00
		sta allegroIndex ;will be reusing to store small amounts of cycles and add at the end.
	
		lda newlyPressedButtons_player1
		and #BUTTON_SELECT
		beq @digit1
		lda #$07 ; add 7 cycles for select
		adc allegroIndex
		sta allegroIndex
@digit1:		
		lda crashFlag
		and #$01
		beq @digit2
		lda #$4F ; add 79 cycles for 10s place
		adc allegroIndex
		sta allegroIndex
@digit2:
		lda crashFlag
		and #$02
		beq @clearStats
		lda #$0C ; add 12 cycles for 100s place
		adc allegroIndex
		sta allegroIndex
@clearStats:
		lda crashFlag
		and #$04
		beq @newLevel
		lda #$0B ; 11 cycles for clearcount 10s place
		adc allegroIndex
		sta allegroIndex
@newLevel:
		lda crashFlag
		and #$08
		beq @pushDown
		lda #$12 ; 18 cycles for levelup
		adc allegroIndex
		sta allegroIndex
@pushDown:
		lda holdDownPoints
		cmp #$02
		bcc @single
		cmp #$08
		bcs @over7
		lda #$09 ; 1-6 costs 9 
		adc allegroIndex
		sta allegroIndex
@over7: 
		clc
		lda #$5A ; add 90 cycles for pushdown
		adc allegroIndex
		sta allegroIndex
		bcc @scoreCycles
@single: 
		lda completedLines
		cmp #$01
		bne @notsingle
		lda #$34 ; 53 for singles, carry is set
		adc allegroIndex
		sta allegroIndex
@notsingle:
		bcc @scoreCycles
		lda #$29 ; 42 for clears over a single, carry is set
		adc allegroIndex
		sta allegroIndex
@scoreCycles:
		ldx completedLines
		bne @not0
		inc cycleCount ; no cleared lines is +737, adding 256 twice and rest is covered by sumTable
		inc cycleCount		
@not0:	lda sumTable, x ; constant amount of cycles added for each line clear
		clc
		adc cycleCount+1
		sta cycleCount+1
		lda cycleCount
		adc #$00
		sta cycleCount
		lda factorTable,x ; linear amount of cycles added for each line clear
		sta factorB24
		lda levelNumber 
		sta factorA24
		lda #$00
		sta factorA24+1 ;overkill 24-bit multiplication, both factors are 8 bit.
		sta factorA24+2
		sta factorB24+1
		sta factorB24+2
		sta crashFlag ; done with flags and can now reuse variable
		jsr unsigned_mul24 ; result in product24
		clc
		lda product24
		adc cycleCount+1
		sta cycleCount+1
		lda product24+1
		adc cycleCount
		sta cycleCount
		lda completedLines
		cmp #$04
		bne @currentPieceCheck
		lda frameCounter
		and #$07 ; check if frame counter is 0%8
		bne @currentPieceCheck
		lda #$04 ; would be 5, but carry is set by cmp #$04
		adc allegroIndex
		sta allegroIndex
@currentPieceCheck:
		lda currentPiece
		cmp #$08
		bne @not8
		clc
		adc allegroIndex
		sta allegroIndex
@not8:	bcc @randomFactors
		lda #$0B ; would be 12 but carry is set
		adc allegroIndex
		sta allegroIndex
@randomFactors:
		lda oneThirdPRNG ; RNG for which cycle of the last instruction the game returns to
		adc allegroIndex
		sta allegroIndex
		lda frameCounter
		and #$01 ; RNG for frame length
		adc allegroIndex
		sta allegroIndex
		lda rng_seed ; RNG for RNG
		asl
		bcc @newBit0
		inc allegroIndex
@newBit0:
		lda nmiReturnAddr
		cmp #<updateAudioWaitForNmiAndResetOamStaging+10
		beq @returnLate ; RNG for which instruction returned to
		lda #$03
		clc
		adc allegroIndex
		sta allegroIndex
@returnLate:
		lda rng_seed+1 ; RNG for OAMDMA
		lsr
		bcc @noDMA
		inc allegroIndex
@noDMA:	
		ldx #$08
@loop:	lda cycleCount+1 ; adding stockpiled
		clc
		adc allegroIndex
		sta cycleCount+1
		lda cycleCount
		adc #$00
		sta cycleCount
;crash should occur on cycle count results 29739-29744, 29750-29768 = $742B-7430, $7436-7448
		cmp #$74 ;high byte of cycle count is already loaded
		bne @nextSwitch
		lda cycleCount+1
		cmp #$2B ; minimum crash
		bcc @nextSwitch
		cmp #$31 ; gap
		bcs @continue
		lda #$F0
		sta crashFlag
		bne @allegroClear
@continue:
		cmp #$36
		bcc @nextSwitch
		cmp #$49
		bcs @nextSwitch
		lda #$F0
		sta crashFlag
		bne @allegroClear
		
@nextSwitch:
		lda switchTable-2,x ; adding cycles to advance to next switch routine
		sta allegroIndex
		dex 
		bne @loop
		
@allegroClear:
		lda #$00
		sta allegroIndex
		rts
	
factorTable:
	.byte $53, $88, $7D, $7D, $7D
sumTable:
	.byte $E1, $1C, $38, $54, $80 ; tetris is 4*28+16 = 128
switchTable:
	.byte $3C, $77, $3C, $65, $3C, $66, $3C;60 119 60 101 60 102 60 gets read in reverse