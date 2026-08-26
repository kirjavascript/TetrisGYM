render_mode_speed_test:
        jsr renderHzInputRows
        lda renderFlags
        beq @noUpdate
        jsr renderHzSpeedTest
        lda #0
        sta renderFlags
@noUpdate:
        rts
