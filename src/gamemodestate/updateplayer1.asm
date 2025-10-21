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
.if ANYDAS = 1
; do nothing while piece is active (playstate = 1)
        ldx playState
        dex
        beq @stageSprite
; do nothing if not kitaru charge
        lda anydasARECharge
        cmp #2
        bne @stageSprite
; do nothing when down is held
        lda heldButtons
        and #BUTTON_DOWN
        bne @stageSprite
; reset das on new input
        lda newlyPressedButtons
        and #BUTTON_LEFT|BUTTON_RIGHT
        bne @resetDas
        lda heldButtons
        and #BUTTON_LEFT|BUTTON_RIGHT
        beq @stageSprite
; charge das (unless charged)
        ldx autorepeatX
        dex
        beq @stageSprite
        dec autorepeatX ; will clear zero flag
        bne @stageSprite
@resetDas:
        lda anydasDASValue
        sta autorepeatX
@stageSprite:
.endif
        jsr stageSpriteForCurrentPiece
        jsr stageSpriteForNextPiece

        inc gameModeState ; 5
        lda #$FF ; acc from stateSpriteForNextPiece
        rts
