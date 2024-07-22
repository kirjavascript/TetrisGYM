render_mode_level_menu:
        lda renderFlags
        and #RENDER_LINES
        beq @noCustomLevel
        lda #$2E
        sta PPUADDR
        lda #$B9
        sta PPUADDR
        lda customLevel
        jsr renderByteBCD
        lda #0
        sta renderFlags
@noCustomLevel:
