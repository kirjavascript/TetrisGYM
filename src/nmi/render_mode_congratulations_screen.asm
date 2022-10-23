render_mode_congratulations_screen:
        lda outOfDateRenderFlags
        and #$80
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
        sta generalCounter
        clc
        adc highScoreEntryNameOffsetForLetter
        sta PPUADDR
        ldx highScoreEntryCurrentLetter
        lda highScoreCharToTile,x
        sta PPUDATA
        sta outOfDateRenderFlags
@ret:
        jsr resetScroll
        rts
