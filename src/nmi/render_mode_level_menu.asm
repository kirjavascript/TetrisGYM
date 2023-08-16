render_mode_level_menu:
        lda outOfDateRenderFlags
        and #1
        beq @noCustomLevel
        lda #$2E
        sta PPUADDR
        lda #$B9
        sta PPUADDR
        lda customLevel
        jsr renderByteBCD
        lda #0
        sta outOfDateRenderFlags
@noCustomLevel:
