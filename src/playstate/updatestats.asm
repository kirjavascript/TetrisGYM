playState_updateLinesAndStatistics:
        jsr updateMusicSpeed
        lda completedLines
        bne @linesCleared
        jmp addPoints

@linesCleared:
        tax
        dec     lineClearStatsByType-1,x
        bpl     @noCarry
        lda     #$09
        sta     lineClearStatsByType-1,x
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
        lda lines
        sta lines_old
        lda lines+1
        sta lines_old+1
incrementLines:
        inc lines
        lda lines
        and #$0F
        cmp #$0A
        bmi checkLevelUp
        inc crashFlag
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
        lda levelNumber
        sta level_old
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
        inc currentFloor
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
        lda crashMode
        cmp #CRASH_OFF
        beq @crashDisabled
        jsr testCrash
@crashDisabled:
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
        lda #$1C ; setting all cycles which always happen. for optimizing, this can be removed if all compared numbers are reduced by $6F1C.
        sta cycleCount
        lda #$6F
        sta cycleCount+1 ;low byte at +1

        lda completedLines ; checking if lines cleared
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
        lda displayNextPiece ;00 is nextbox enabled
        bne @nextOff
        lda #$8A ; add 394 cycles for nextbox
        adc cycleCount+1
        sta cycleCount+1
        lda cycleCount
        adc #$01 ; high byte of 18A
        sta cycleCount

@nextOff:
        lda allegroIndex ;the allegro checking routine uses offsets of 50-59 [0x32-0x3B], meaning even when the first block triggers allegro, the bne will work properly.
        bne @allegro
        lda #$95 ; 149 in decimal.
        clc
        ldx wasAllegro ; FF is allegro. 00 is no allegro. wasAllegro contains allegro status prior to this frame
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
        sbc #$32 ; subtract 50 from the index, as the offset is from the start of board data.
        asl
        asl
        asl
        asl ;multiply by 16 cycles per cell checked. 0-indexed.
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
        lda #$4F ; add 79 cycles for lines 10s place
        adc allegroIndex
        sta allegroIndex
@digit2:
        lda crashFlag
        and #$02
        beq @newLevel
        lda #$0C ; add 12 cycles for lines 100s place
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
        lda #$09 ; 1-6 pushdown costs 9 add'l cycles
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
        beq @dontClearCount
        tax
        ldy lineClearStatsByType-1,x
        beq @dontClearCount
        lda #$0B ; 11 cycles for clearcount 10s place
        adc allegroIndex
        sta allegroIndex
        txa
@dontClearCount:
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
        sta crashFlag ; unrelated to current routine, just needed to clear the flag and $00 was loaded.
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
        adc allegroIndex ; adds 8 cycles for current piece = 8 (horizontal Z)
        sta allegroIndex
@not8:	bcc @randomFactors ; adc above means branch always when entered after it. piece < 8 adds 0 cycles.
        lda #$0B ; would be 12 but carry is set. for piece > 8
        adc allegroIndex
        sta allegroIndex
@randomFactors:
        lda oneThirdPRNG ; RNG for which cycle of the last instruction the game returns to
        adc allegroIndex
        sta allegroIndex
        lda frameCounter
        and #$01 ; RNG for frame length
        ora startParity ; set to 0 or 1 at start of game, so result isn't always 0
        adc allegroIndex
        sta allegroIndex
        lda rng_seed ; checking whether PRNG had extra cycle
        asl
        bcc @newBit0
        inc allegroIndex
@newBit0:
        lda nmiReturnAddr
        cmp #<updateAudioWaitForNmiAndResetOamStaging+10
        beq @returnLate ; checking which instruction returned to. if so, add 3 cycles
        lda #$03
        clc
        adc allegroIndex
        sta allegroIndex
@returnLate:
        lda rng_seed+1 ; RNG for OAMDMA, add 1 cycle for syncing
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
;crash should occur on cycle count results 29739-29744, 29750-29768 = $742B-7430, $7436-7448 | red crash on 7448 7447 7446 7445 7444 7443
;x8 sw1 | x7 sw2 | x6 sw3 | x5 sw4 | x4 sw5 | x3 sw6 | x2 sw7 | x1 sw8
;switch routine is reversed.
;confettiA should occur on cycle count when switch1 = 29768+75 = 29843-30192
;level lag is +195 from line lag
;level lag to RTS is +70 rts +6 jsr +6 +41 to beginning of confettiA = 123 = 30315+ line lag
;line lag = 30510+
;confettiB = 30765-31193
        cmp #$74 ;high byte of cycle count is already loaded
        bne @nextSwitch
        lda cycleCount+1
        cmp #$2B ; minimum crash
        bcc @nextSwitch
        cmp #$31 ; gap
        bcs @continue
        lda #$F0
        sta crashFlag ; F0 means standard crash.
        jmp @crashGraphics ;too far to branch
@continue:
        cmp #$36
        bcc @nextSwitch
        cmp #$49
        bcs @nextSwitch ;between 7436 & 7448
        cmp #$43
        bcc @notRed ;checking if crash is during first crashable instruction
        cpx #$07 ; checking which switch routine is active.
        beq @nextSwitch ;continues crashless if sw2
        cpx #$03
        bne @notRed ; runs graphics corruption if sw6
        ldx #$FF ; these are normally set by the code it would jump to after NMI.
        ldy #$00
        lda #$81 ; value normally held at this point in sw6
        jsr satanSpawn
        jmp @allegroClear ;allegroClear is basically return, just clears the variable first.
@notRed:
        lda #$F0
        sta crashFlag
        jmp @crashGraphics ;triggering crash in all other cases

@nextSwitch:
        lda switchTable-2,x ; adding cycles to advance to next switch routine
        sta allegroIndex ; reusing code at the beginning of the loop that added the accumulated allegroIndex to the main cycle count
        dex
        bne @loop
        ;562 has been added to the cycle count
        ;confettiA at 30405-30754 76C5-7822
        lda displayNextPiece
        beq @nextOn
        lda cycleCount+1 ; add 394 cycles for nextbox if not added earlier. Necessary because we're checking for pre-nextbox NMI now.
        adc #$8A
        sta cycleCount+1
        lda cycleCount
        adc #$01 ; high byte of 18A
        sta cycleCount
        bne @nextCheck
@nextOn:
        lda cycleCount ;testing for limited confetti
        cmp #$76 ;high byte min
        bcc @allegroClear
        bne @not76
        lda cycleCount+1
        cmp #$C5 ;low byte min
        bcc @allegroClear
        bcs @confettiA
@not76: cmp #$78 ;high byte max
        bcc @confettiA
        bne @nextCheck
        lda cycleCount+1
        cmp #$23 ;low byte max
        bcs @nextCheck
@confettiA:
        lda #$E0 ;E0 = limited confetti
        sta crashFlag
        jmp confettiHandler
@nextCheck:
        ;levellag at 30877 = 0x789D
        lda cycleCount
        cmp #$78 ;high byte min
        bcc @allegroClear
        bne @levelLag
        lda cycleCount+1
        cmp #$9D;low byte min
        bcc @allegroClear
@levelLag:
        lda #$01
        sta lagFlag
        ;linelag at 31072 = 0x7960
        lda cycleCount
        cmp #$79;high byte min
        bcc @allegroClear
        bne @lineLag
        lda cycleCount+1
        cmp #$60;low byte min
        bcc @allegroClear
@lineLag:
        lda #$03
        sta lagFlag
        ;confettiB at 31327-31755 7A5F-7C0B
        lda cycleCount
        cmp #$7A ;high byte min
        bcc @allegroClear
        bne @not7A
        lda cycleCount+1
        cmp #$5F ;low byte min
        bcc @allegroClear
        bcs @confettiB
@not7A: cmp #$7C ;high byte max
        bcc @confettiB
        bne @allegroClear
        lda cycleCount+1
        cmp #$0C ;low byte max
        bcs @allegroClear
@confettiB:
        lda #$D0 ;D0 = infinite confetti
        sta crashFlag
        jmp confettiHandler
@allegroClear:
        lda #$00 ;reset allegro flag and return to program execution, no crash
        sta allegroIndex
        lda lagFlag
        beq @noLag ;if lag should happen, wait a frame here so that sprite staging doesn't happen.
        lda #$00
        sta verticalBlankingInterval
@checkForNmi:
        lda verticalBlankingInterval ;busyloop
        beq @checkForNmi
@noLag:	rts
@crashGraphics:
        lda #$00
        sta allegroIndex ; resetting variable
        lda crashMode
        bne @otherMode
        lda outOfDateRenderFlags ; if mode = 0, tell score to update (might not be necessary?) so that crash info is printed
        ora #$04
        sta outOfDateRenderFlags
        lda #$02
        sta soundEffectSlot0Init ; play topout sfx
        rts
@otherMode:
        cmp #CRASH_CRASH ;if crash mode, crash
        bcc @topout
        bne @allegroClear
        .byte 02 ; stp
@topout:
        lda #LINECAP_HALT ;if topout, activate linecap
        sta linecapState
        rts
factorTable:
    .byte $53, $88, $7D, $7D, $7D ;0 single double triple tetris
sumTable:
    .byte $E1, $1C, $38, $54, $80 ; 0 single double triple tetris. tetris is 4*28+16 = 128
switchTable:
    .byte $3C, $77, $3C, $65, $3C, $66, $3C;60 119 60 101 60 102 60 gets read in reverse
confettiHandler:
        lda crashFlag ;E0 = confetti exits if [framecounter = 255 && controller != BDLR] or controller = AS
        cmp #$E0
        bne @infiniteConfetti
        lda heldButtons_player1
        and #$A0 ; A, Select
        bne @endConfetti
        lda frameCounter ;use framecounter for Y coordinate of text, like original confetti but without the offset
        cmp #$FF
        bne @drawConfetti
        lda heldButtons_player1
        and #$47 ; B, Down, Left, Right
        beq @endConfetti
@drawConfetti:
        sta spriteYOffset ;either frameCounter or 80 loaded to A depending on confetti type
        lda #$A8 ;center of playfield
        sta spriteXOffset
        lda #$19 ;ID for "confetti" text
        sta spriteIndexInOamContentLookup
        jsr stringSpriteAlignRight ;draw to screen
        lda #$00
        sta verticalBlankingInterval ;wait until next frame
@checkForNmi:
        lda verticalBlankingInterval ;busyloop
        beq @checkForNmi
        jmp confettiHandler
@infiniteConfetti:
        lda heldButtons_player1
        adc #$80 ; loading 80 as Y coordinate of confetti text if nothing is held.
        cmp #$80
        beq @drawConfetti ; if any button is pressed, exit confetti
@endConfetti:
        lda #$00
        sta allegroIndex
        rts
satanSpawn: ; copied from routine vanilla game's memset_ppu_page_and_more which is no longer present in gym
        sta     tmp1
        stx     tmp2
        sty     tmp3
        lda     PPUSTATUS
        lda     currentPpuCtrl
        and     #$FB
        sta     PPUCTRL
        sta     currentPpuCtrl
        lda     tmp1
        sta     PPUADDR
        ldy     #$00
        sty     PPUADDR
        ldx     #$04
        cmp     #$20
        bcs     LAC40
        ldx     tmp3
LAC40:  ldy     #$00
        lda     tmp2
LAC44:  sta     PPUDATA
        dey
        bne     LAC44
        dex
        bne     LAC44
        ldy     tmp3
        lda     tmp1
        cmp     #$20
        bcc     LAC67
        adc     #$02
        sta     PPUADDR
        lda     #$C0
        sta     PPUADDR
        ldx     #$40
LAC61:  sty     PPUDATA
        dex
        bne     LAC61
LAC67:  ldx     tmp2
        rts
