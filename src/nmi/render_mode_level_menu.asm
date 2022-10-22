render_mode_level_menu:
        lda outOfDateRenderFlags
        and #1
        beq @noCustomLevel
        lda #$21
        sta PPUADDR
        lda #$95
        sta PPUADDR
        lda customLevel
        jsr renderByteBCD
        lda #0
        sta outOfDateRenderFlags
@noCustomLevel:
