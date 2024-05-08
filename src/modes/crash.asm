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
        lda hideNextPiece
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
        lda crashState
        and #$01
        beq @digit2
        lda #$4F ; add 79 cycles for lines 10s place
        adc allegroIndex
        sta allegroIndex
@digit2:
        lda crashState
        and #$02
        beq @newLevel
        lda #$0C ; add 12 cycles for lines 100s place
        adc allegroIndex
        sta allegroIndex
@newLevel:
        lda crashState
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
        bne @dontClearCount
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
        sta crashState ; unrelated to current routine, just needed to clear the flag and $00 was loaded.
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
@not8:	bcc @palCycles ; adc above means branch always when entered after it. piece < 8 adds 0 cycles.
        lda #$0B ; would be 12 but carry is set. for piece > 8
        adc allegroIndex
        sta allegroIndex
@palCycles:
        lda palFlag ; if pal, move thresholds for crashes 3467 cycles away
        beq @randomFactors
        sec
        lda cycleCount+1
        sbc #$8B
        sta cycleCount+1
        lda cycleCount
        sbc #$0D
        sta cycleCount
        clc
@randomFactors:
        lda strictFlag
        bne @noDMA ;for strict crash, do not add random cycles.
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
        lda strictFlag
        beq @normalChecks ;special conditions for "strict" mode. crash on 7423-7442, check red on 7443-7448.
        lda cycleCount+1
        cmp #$23 ;up to 8 cycles could have been added, but weren't, so our low bound is 8 below the typical.
        bcc @nextSwitch ;if too low, exit
        bcs @highBoundary ;otherwise, check high bound and skip check for gap.
@normalChecks:
        lda cycleCount+1
        cmp #$2B ; minimum crash
        bcc @nextSwitch
        cmp #$31 ; gap
        bcs @continue
        lda #$F0
        sta crashState ; F0 means standard crash.
        jmp @crashGraphics ;too far to branch
@continue:
        cmp #$36
        bcc @nextSwitch
@highBoundary:
        cmp #$49
        bcs @nextSwitch ;between 7436 & 7448
        cmp #$43
        bcc @notRed ;checking if crash is during first crashable instruction
        txa
        lsr ;all odd switches on PAL result in no crash.
        bcs @oddSwitch
        lda palFlag
        bne @nextSwitch ;if PAL, no crash.
@oddSwitch:
        cpx #$07 ; checking which switch routine is active.
        beq @isPal ;checks version if sw2
        cpx #$03
        bne @notRed ; runs graphics corruption if sw6
        ldx #$FF ; these are normally set by the code it would jump to after NMI.
        ldy #$00
        lda #$81 ; value normally held at this point in sw6
        jsr satanSpawn
        jmp @allegroClear ;allegroClear is basically return, just clears the variable first.
@isPal:
		lda palFlag
		beq @nextSwitch ;if NTSC, continue, no crash.
		jsr blackBox
@allegroJump:
		jmp @allegroClear
        lda palFlag
        beq @nextSwitch ;if NTSC, continue, no crash.
        jsr blackBox
        jmp @allegroClear
@notRed:
        lda #$F0
        sta crashState
        jmp @crashGraphics ;triggering crash in all other cases

@nextSwitch:
        lda switchTable-2,x ; adding cycles to advance to next switch routine
        sta allegroIndex ; reusing code at the beginning of the loop that added the accumulated allegroIndex to the main cycle count
        dex
        bne @loop
        ;562 has been added to the cycle count
        ;confettiA at 30405-30754 76C5-7822
        lda hideNextPiece
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
        bcc @allegroJump
        bne @not76
        lda cycleCount+1
		ldx strictFlag
		beq @notStrict_confetti
		cmp #$BD
		bcc @allegroJump
		bcs @confettiA
@notStrict_confetti:
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
        sta crashState
        jmp confettiHandler
@nextCheck:
        ;levellag at 30877 = 0x789D
        lda cycleCount
        cmp #$78 ;high byte min
        bcc @allegroClear
        bne @levelLag
        lda cycleCount+1
		ldx strictFlag
		beq @notStrict_level
		cmp #$95
		bcc @allegroClear
		bcs @levelLag
@notStrict_level:
        cmp #$9D;low byte min
        bcc @allegroClear
@levelLag:
        lda #$01
        sta lagState
        ;linelag at 31072 = 0x7960
        lda cycleCount
        cmp #$79;high byte min
        bcc @allegroClear
        bne @lineLag
        lda cycleCount+1
		ldx strictFlag
		beq @notStrict_lines
		cmp #$58
		bcc @allegroClear
		bcs @lineLag
@notStrict_lines:
        cmp #$60;low byte min
        bcc @allegroClear
@lineLag:
        lda #$03
        sta lagState
        ;confettiB at 31327-31755 7A5F-7C0B
        lda cycleCount
        cmp #$7A ;high byte min
        bcc @allegroClear
        bne @not7A
        lda cycleCount+1
		ldx strictFlag
		beq @notStrict_B
		cmp #$57
		bcc @allegroClear
		bcs @confettiB
@notStrict_B:
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
        sta crashState
        jmp confettiHandler
@allegroClear:
        lda #$00 ;reset allegro flag and return to program execution, no crash
        sta allegroIndex
        lda lagState
        beq @noLag ;if lag should happen, wait a frame here so that sprite staging doesn't happen.
        lda #$00
        sta verticalBlankingInterval
		sta lagState ;clear lagstate for next
@checkForNmi:
        lda verticalBlankingInterval ;busyloop
        beq @checkForNmi
@noLag:	rts
@crashGraphics:
        lda #$00
        sta allegroIndex ; resetting variable
        lda crashModifier
        bne @otherMode
        lda renderFlags ; if mode = 0, tell score to update (might not be necessary?) so that crash info is printed
        ora #RENDER_SCORE
        sta renderFlags
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
        lda crashState ;E0 = confetti exits if [framecounter = 255 && controller != BDLR] or controller = AS
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
        lda palFlag
        bne @endConfetti ;infinite confetti does not exist on PAL
        lda heldButtons_player1
        adc #$80 ; loading 80 as Y coordinate of confetti text if nothing is held.
        cmp #$80
        beq @drawConfetti ; if any button is pressed, exit confetti
@endConfetti:
        lda #$00
        sta allegroIndex
        rts
satanSpawn: ; copied from routine vanilla game's memset_ppu_page_and_more which is no longer present in gym
        lda palFlag
        beq @ntsc
        lda #$00
        sta verticalBlankingInterval
@checkForNmi:
        lda verticalBlankingInterval ;busyloop
        beq @checkForNmi
        ldx #$FF
        ldy #$00

@ntsc:
        lda #$AA
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
blackBox: ;copied from patchToPpu from original game as it's no longer present in gym
        lda #$00
        sta verticalBlankingInterval
@checkForNmi:
        lda verticalBlankingInterval ;busyloop
        beq @checkForNmi
        ldy     #$00
@patchAddr:
        lda     patchData,y
        sta     PPUADDR
        iny
        lda     patchData,y
        sta     PPUADDR
        iny
@patchValue:
        lda     patchData,y
        iny
        cmp     #$FE
        beq     @patchAddr
        cmp     #$FD
        beq     @ret
        sta     PPUDATA
        jmp     @patchValue

@ret:   rts
patchData:
        .byte   $22,$58,$FF,$FE,$22,$75,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FE,$22,$94,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FE
        .byte   $22,$B4,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FE,$22,$D4,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FE,$22,$F4
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FE,$23,$14,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FE,$23,$34,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FE,$22
        .byte   $CA,$46,$47,$FE,$22,$EA,$56,$57
        .byte   $FD
