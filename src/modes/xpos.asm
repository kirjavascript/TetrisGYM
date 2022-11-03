; gets the x-pos of the next tetrimino, default if not in x-pos mode
getXPos:
    lda practiseType
    cmp #MODE_XPOS
    bne @skipCustomXPos
    lda xposModifier
    beq @skipCustomXPos ; load as normal if x-pos = 0
    clc
    adc #1
    rts
@skipCustomXPos:
    lda #$05
    rts