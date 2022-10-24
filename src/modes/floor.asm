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
        ; tile to draw is $7B
        lda #$7B
@loop:
        sta $0446,X
        inx
        cpx #$82
        bmi @loop
@skip:
        rts
