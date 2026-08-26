speedTestColorPatch:
        .byte $3f, $0b, $00, $30
        .byte $0

gameMode_speedTest:
        jsr hideSpritesAndBackground
        ; reset some stuff for input log rendering
        lda #$EF
        sta inputLogCounter
        lda #$1
        sta hzFrameCounter+1

        jsr hzStart
        jsr clearNametable

        stagePatch speedtestNametablePatch
        stagePatch gamePalette
        stagePatch speedTestColorPatch
        jsr render_mode_queue

.if INES_MAPPER <> 0
        lda #CHRBankSet0
        jsr changeCHRBanks
.endif

; reenable display
        lda #$B0
        sta ppuScrollX
        lda #$0
        sta ppuScrollY
        lda #NMIEnable|BGPattern1|SpritePattern1
        sta currentPpuCtrl
        lda #RENDER_SPEED_TEST
        sta renderMode
        jsr showSpriteAndBackground

@loop:
        lda heldButtons_player1
        cmp #BUTTON_A+BUTTON_B+BUTTON_START+BUTTON_SELECT
        beq @back

        lda #$50
        sta tmp3
        jsr controllerInputDisplayX
        jsr speedTestControl

        jsr updateAudioWaitForNmiAndResetOamStaging
        jmp @loop

@back:
        lda #RENDER_IDLE
        sta renderMode
        lda currentPpuMask
        and #$E7
        sta PPUMASK
        lda #$02
        sta soundEffectSlot1Init
        sta gameMode
        rts

speedTestControl:
        ; add sfx
        lda heldButtons_player1
        and #BUTTON_LEFT+BUTTON_RIGHT+BUTTON_B+BUTTON_A
        beq @noupdate
        lda #RENDER_HZ
        sta renderFlags
        lda newlyPressedButtons_player1
        and #BUTTON_LEFT+BUTTON_RIGHT
        beq @noupdate
        lda #$1
        sta soundEffectSlot1Init
@noupdate:
        ; use normal controls
        jsr hzControl
        rts
