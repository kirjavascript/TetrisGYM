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


        ldx #<rocketNametablePatch
        ldy #>rocketNametablePatch
        jsr copyPatchAtXYToQueue
        jsr render_mode_queue

@stage2:
@rocketEnd:
        jsr resetScroll
        rts
