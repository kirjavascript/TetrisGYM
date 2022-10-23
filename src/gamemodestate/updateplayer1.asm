gameModeState_updatePlayer1:
        lda #$04
        sta playfieldAddr+1
        ; copy controller from mirror
        lda newlyPressedButtons_player1
        sta newlyPressedButtons
        lda heldButtons_player1
        sta heldButtons

        jsr checkDebugGameplay
        jsr practiseAdvanceGame
        jsr practiseGameHUD
        jsr branchOnPlayStatePlayer1
        jsr stageSpriteForCurrentPiece
        jsr stageSpriteForNextPiece

        inc gameModeState ; 5
        lda #$FF ; acc from stateSpriteForNextPiece
        rts
