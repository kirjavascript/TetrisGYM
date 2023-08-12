; hz stuff

; hz = 60.098 * (taps - 1) / (frames - 1)
; PAL is 50.006
;
; HydrantDude explains how and why the formula works here: https://discord.com/channels/374368504465457153/405470199400235013/867156217259884574

hzDebounceThreshold := $10

hzStart: ; called in playState_spawnNextTetrimino, gameModeState_initGameState, gameMode_gameTypeMenu
        lda #0
        sta hzSpawnDelay
        sta hzTapCounter
        lda #hzDebounceThreshold
        sta hzDebounceCounter
        ; frame counter is reset on first tap
        rts

hzControl: ; called in playState_playerControlsActiveTetrimino, gameTypeLoopContinue, speedTestControl
        lda hzTapCounter
        beq @notTapping
        ; tick frame counter
        lda hzFrameCounter
        clc
        adc #$01
        sta hzFrameCounter
        lda #$00
        adc hzFrameCounter+1
        sta hzFrameCounter+1
@notTapping:

        ; tick debounce counter
        lda hzDebounceCounter
        cmp #hzDebounceThreshold
        beq @elapsed
        inc hzDebounceCounter
@elapsed:

        ; detect inputs
        lda newlyPressedButtons_player1
        and #BUTTON_DPAD
        cmp #BUTTON_LEFT
        beq hzTap
        lda newlyPressedButtons_player1
        and #BUTTON_DPAD
        cmp #BUTTON_RIGHT
        beq hzTap

        lda hzTapCounter
        bne @noDelayInc
        lda hzSpawnDelay
        cmp #$F
        beq @noDelayInc
        inc hzSpawnDelay
@noDelayInc:
        rts

hzTap:
        tax ; button direction
        dex ; normalize to 1/0
        cpx hzTapDirection
        bne @fresh
        ; if debouncing meets threshold, this is a fresh tap
        lda hzDebounceCounter
        cmp #hzDebounceThreshold
        bne @within
@fresh:
        stx hzTapDirection
@wrap:
        lda #0
        sta hzTapCounter
        sta hzFrameCounter+1
        ; 0 is the first frame (4 means 5 frames)
        sta hzFrameCounter
@within:

        ; increment taps, reset debounce
        inc hzTapCounter
        lda hzTapCounter
        cmp #$10
        bcs @wrap
        lda #0
        sta hzDebounceCounter

        lda dasOnlyFlag
        beq :+
        lda #0
        sta dasOnlyShiftDisabled

        ldx hzTapCounter
        cpx #$A
        bcs @disableShift
        lda palFlag
        beq @NTSCDASOnly
        clc
        txa
        adc #$A
        tax
@NTSCDASOnly:
        lda dasLimitLookup, x
        sta tmpZ
        lda hzFrameCounter
        cmp tmpZ
        bpl :+
@disableShift:
        lda #1
        sta dasOnlyShiftDisabled
:

        ; ignore 1 tap
        lda hzTapCounter
        cmp #2
        bcc @calcEnd

        lda #$7A
        sta factorB24
        lda #$17
        sta factorB24+1
        lda #0
        sta factorA24+1
        sta factorA24+2
        sta factorB24+2

        lda hzTapCounter
        sbc #1
        sta factorA24

        lda palFlag
        beq @notPAL
        lda #$89
        sta factorB24
        lda #$13
        sta factorB24+1
@notPAL:

        jsr unsigned_mul24

        ; taps-1 * 6010 now in product24

        lda product24
        sta dividend
        lda product24+1
        sta dividend+1
        lda product24+2
        sta dividend+2

        ; then divide by the hzFrameCounter, which should be frames-1

        lda hzFrameCounter
        sta divisor
        lda hzFrameCounter+1
        sta divisor+1
        lda #0
        sta divisor+2

        jsr unsigned_div24 ; hz*100 in dividend

        ; ldx dividend+1 ; get hz for palette
        ; lda hzPaletteGradient, x
        ; sta hzPalette

        lda dividend
        sta binary32
        lda dividend+1
        sta binary32+1
        lda dividend+2
        sta binary32+2
        lda #0
        sta binary32+3

        jsr BIN_BCD ; hz*100 as BCD in bcd32

        lda bcd32
        sta hzResult+1
        lda bcd32+1
        sta hzResult

@calcEnd:

        ; CTWCDAS palette
        lda dasOnlyFlag
        beq :+
        lda #$30
        sta hzPalette

        ldx hzTapCounter
        lda palFlag
        beq @ntsc
        clc
        txa
        adc #$A
        tax
@ntsc:
        lda dasLimitLookup, x
        sta $10
        lda hzFrameCounter
        cmp $10
        bpl :+
        lda #$16
        sta hzPalette
:

        ; update game UI
        lda outOfDateRenderFlags
        ora #$10 ; @renderHz
        sta outOfDateRenderFlags
        rts

dasLimitLookup:
        .byte 0, 0, 4, 11, 18, 24, 30, 36, 42 , 48; , 54, 60
        .byte 0, 0, 3, 7, 12, 16, 20, 24, 28, 32 ; PAL

; Kitaru on reddit - Thankfully, the same "round-down" effect also benefits DAS speed. Whereas the NTSC DAS timings were 16f start-up and 6f period, PAL DAS timings are 12f start-up and 4f period. Accounting for framerate, this is an improvement from NTSC DAS's real-time rate of 10Hz vs. PAL's real-time rate of 12.5Hz. So, although PAL hits its max gravity at Level 19 instead of Level 29, the boosted DAS makes it a bit more survivable. PAL DAS can still be out-tapped, albeit at a slimmer margin.

hzPaletteGradient: ; goes up to B
        .byte $16, $26, $27, $28, $29, $2a, $2c, $22, $23, $24, $14, $15
