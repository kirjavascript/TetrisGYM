render_mode_pause:
        lda renderFlags
        and #RENDER_DEBUG
        beq @skipSaveSlotPatch
        jsr saveSlotNametablePatch
        lda renderFlags
        and #<~RENDER_DEBUG
        sta renderFlags
@skipSaveSlotPatch:
        lda playState
        cmp #$04
        beq @done
        jsr render_playfield
@done:
        jsr resetScroll
        rts
