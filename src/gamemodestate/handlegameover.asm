gameModeState_handleGameOver:
.if AUTO_WIN
        lda newlyPressedButtons_player1
        and #BUTTON_SELECT
        beq @continue
        lda #$0A ; playState_checkStartGameOver
        sta playState
        jmp @ret
@continue:
.endif
        lda #$05
        sta generalCounter2
        lda playState
        ; cmp #$00 ; lda sets z flag
        beq @gameOver
        jmp @ret
@gameOver:
        lda #RENDER_PLAY
        sta renderMode
        ; flag for keyboard poll to ignore mapped keys except start/return
        inc highScoreEntryActive
        jsr handleHighScoreIfNecessary
        dec highScoreEntryActive
        lda #$01
        sta playState
        jsr clearPlayfield
        lda #$00
        sta vramRow
        lda #$01
        sta playState
        jsr updateAudioWaitForNmiAndResetOamStaging
        ldx #3 ; levelMenu
        lda practiseType
        cmp #MODE_KILLX2
        bne @storeX
        dex
@storeX:
        stx gameMode
        rts

@ret:   inc gameModeState ; 4
        rts
