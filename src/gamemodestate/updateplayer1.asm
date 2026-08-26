gameModeState_updatePlayer1:
        ; copy controller from mirror
        lda newlyPressedButtons_player1
        sta newlyPressedButtons
        lda heldButtons_player1
        sta heldButtons

        jsr checkDebugGameplay
        jsr practiseAdvanceGame
        jsr practiseGameHUD
; do nothing while piece is active (playstate = 1)
        ldx playState
        dex
        beq @branchOnPlaystate
; do nothing if not kitaru charge
        lda entryChargeModifier
        cmp #2
        bne @branchOnPlaystate
; do nothing when down is held
        lda heldButtons
        and #BUTTON_DOWN
        bne @branchOnPlaystate
; reset das on new input
        lda newlyPressedButtons
        and #BUTTON_LEFT|BUTTON_RIGHT
        bne @resetDas
        lda heldButtons
        and #BUTTON_LEFT|BUTTON_RIGHT
        beq @branchOnPlaystate
; charge das (unless charged)
        ldx autorepeatX
        cpx dasModifier
        beq @branchOnPlaystate
        inc autorepeatX
        jmp @branchOnPlaystate
@resetDas:
        lda 0
        sta autorepeatX
@branchOnPlaystate:
        jsr branchOnPlayStatePlayer1
        jsr stageCurrentAndNextPieces

        inc gameModeState ; 5
        rts
