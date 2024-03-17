render_mode_pause:
        lda pausedrenderFlags
        and #$02
        beq @skipSaveSlotPatch
        jsr saveSlotNametablePatch
@skipSaveSlotPatch:
        lda #0
        sta pausedrenderFlags

        lda playState
        cmp #$04
        beq @done
        jsr render_playfield
@done:
        jsr resetScroll
        rts
