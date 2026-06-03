gameModeState_updateCountersAndNonPlayerState:
        ; CHR bank used to be reset to 0 here
        lda #$00
        sta oamStagingLength
        inc fallTimer
        lda newlyPressedButtons_player1
        and #BUTTON_SELECT
        beq @ret
        lda hideNextPiece
        eor #$01
        sta hideNextPiece
@ret:   inc gameModeState ; 3
        rts
