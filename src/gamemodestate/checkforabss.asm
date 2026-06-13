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
        lda #0
        sta renderMode
        lda #$2 ; straight to menu screen
        sta gameMode
        lda qualFlag
        beq @skipLegal
        dec gameMode ; gameMode_waitScreen
@skipLegal:
        rts
