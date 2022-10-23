; A+B+Select+Start
gameModeState_checkForResetKeyCombo:
        lda heldButtons_player1
        cmp #BUTTON_A+BUTTON_B+BUTTON_START+BUTTON_SELECT
        beq @reset
        inc gameModeState
        ; acc has to be heldButtons_player1 here
        rts

@reset: jsr updateAudio2
        lda #$2 ; straight to menu screen
        sta gameMode
        lda qualFlag
        beq @skipLegal
        dec gameMode ; gameMode_waitScreen
@skipLegal:
        rts
