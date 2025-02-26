advanceGameFloor:
        lda currentFloor
drawFloor:
        ; get correct offset
        sta tmp1
        lda #$D
        sec
        sbc tmp1
        tax
        ; x10
        lda multBy10Table, x
        tax
        ; draw block tiles+3 ($7E)
        lda #BLOCK_TILES+3
@loop:
        sta playfield+$46,X
        inx
        cpx #$82
        bmi @loop
@skip:
        rts
