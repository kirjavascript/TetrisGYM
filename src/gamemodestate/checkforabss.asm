; A+B+Select+Start
gameModeState_checkForResetKeyCombo:
        lda heldButtons_player1
        cmp #BUTTON_A+BUTTON_B+BUTTON_START+BUTTON_SELECT
        beq @reset
        inc gameModeState
        cmp #BUTTON_LEFT+BUTTON_DOWN+BUTTON_RIGHT
        bne @continue
        jsr updateAudioWaitForNmiAndResetOamStaging
@continue:
        rts

@reset: jsr updateAudio2
        lda #RENDER_IDLE
        sta renderMode
        lda qualFlag
        ; store 0 if qual, 2 if not
        eor #$01
        asl
        sta gameMode
        rts
