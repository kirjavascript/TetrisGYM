render_mode_rocket:
        lda screenStage
        bne @stage1
        lda #$20
        sta PPUADDR
        lda #$83
        sta PPUADDR
        lda endingSleepCounter
        sta PPUDATA
        lda endingSleepCounter+1
        jsr twoDigsToPPU
        jmp @rocketEnd
@stage1:
        cmp #1
        bne @stage2
        inc screenStage
        jsr bulkCopyToPpu
        .addr rocket_nametable_patch
@stage2:
@rocketEnd:
        jsr resetScroll
        rts
