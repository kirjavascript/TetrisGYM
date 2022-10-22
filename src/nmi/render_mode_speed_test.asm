render_mode_speed_test:
        jsr renderHzInputRows
        lda outOfDateRenderFlags
        beq @noUpdate
        jsr renderHzSpeedTest
        lda #0
        sta outOfDateRenderFlags
@noUpdate:
        lda #$B0
        sta ppuScrollX
        lda #$0
        sta ppuScrollY
        rts
