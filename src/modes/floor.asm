advanceGameFloor:
        lda floorModifier
drawFloor:
        ; get correct offset
        sta tmp1
        lda #$D
        sbc tmp1
        tax
        ; x10
        lda multBy10Table, x
        tax
        ; draw block tiles ($7B)
        lda #BLOCK_TILES
@loop:
        sta playfield+$46,X
        inx
        cpx #$82
        bmi @loop
@skip:
        rts
