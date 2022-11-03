; gets the x-pos of the next tetrimino, default if not in x-pos mode
getXPos: ; custom can be from 2-8
    lda practiseType
    cmp #MODE_XPOS
    bne @skipCustomXPos
    lda xposModifier
    beq @skipCustomXPos ; load as normal if x-pos = 0
    cmp #8
    beq @randXPos ; load random x-pos if setting = 8
    clc
    adc #1
    rts
@skipCustomXPos:
    lda #$05
    rts
@randXPos:
    ldx #rng_seed
    ldy #$02
    jsr generateNextPseudorandomNumber
    lda rng_seed
    and #$07
    beq @randXPos
    clc
    adc #1
    sta $00FA
    rts