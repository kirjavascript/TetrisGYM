render_mode_level_menu:
        lda renderFlags
        and #RENDER_LINES
        beq @noCustomLevel
        lda #$21
        sta PPUADDR
        lda #$95
        sta PPUADDR
        lda customLevel
        jsr renderByteBCD
        lda #0
        sta renderFlags
@noCustomLevel:
