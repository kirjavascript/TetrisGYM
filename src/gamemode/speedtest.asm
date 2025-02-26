gameMode_speedTest:
        lda #$6
        sta renderMode
        ; reset some stuff for input log rendering
        lda #$EF
        sta inputLogCounter
        lda #$1
        sta hzFrameCounter+1

        jsr hzStart
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
        jsr clearNametable
        jsr bulkCopyToPpu
        .addr speedtest_nametable_patch
        jsr bulkCopyToPpu
        .addr game_palette
        ; patch color
        lda #$3f
        sta PPUADDR
        lda #$b
        sta PPUADDR
        lda #$30
        sta PPUDATA
        lda #NMIEnable|BGPattern1|SpritePattern1
        sta currentPpuCtrl
.if INES_MAPPER <> 0
        lda #CHRBankSet0
        jsr changeCHRBanks
.endif

        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        jsr updateAudioWaitForNmiAndResetOamStaging

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
