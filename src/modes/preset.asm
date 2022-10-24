advanceGamePreset:
        jsr clearPlayfield
        ; render layout
        ldx #0
        stx generalCounter
@drawNext:
        ; get layout offset
        ldy presetModifier
        lda presets, y

        ; add index
        adc generalCounter

        ; load byte from layout
        tax
        ldy presets, x

        ; check if finished
        cpy #$FF
        beq @skip

        ; draw from y
        lda #$7B
        sta $0400, y

        ; loop
        inc generalCounter
        jmp @drawNext
@skip:
        rts
