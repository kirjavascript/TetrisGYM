render_mode_speed_test:
        jsr renderHzInputRows
        lda renderFlags
        beq @noUpdate
        jsr renderHzSpeedTest
        lda #0
        sta renderFlags
@noUpdate:
        lda #$B0
        sta ppuScrollX
        lda #$0
        sta ppuScrollY
        rts
