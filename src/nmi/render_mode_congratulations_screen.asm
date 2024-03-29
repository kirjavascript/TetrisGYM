render_mode_congratulations_screen:
        lda renderFlags
        and #RENDER_HIGH_SCORE_LETTER
        beq @ret
        lda highScoreEntryRawPos
        asl a
        tax
        lda highScorePpuAddrTable,x
        sta PPUADDR
        lda highScoreEntryRawPos
        asl a
        tax
        inx
        lda highScorePpuAddrTable,x
        ; sta generalCounter ; unnecessary?
        clc
        adc highScoreEntryNameOffsetForLetter
        sta PPUADDR
        ldx highScoreEntryCurrentLetter
        lda highScoreCharToTile,x
        sta PPUDATA
        lda #0
        sta renderFlags
@ret:
        jsr resetScroll
        rts
