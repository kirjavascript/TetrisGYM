byteSprite:
        ldy #0
@loop:
        ldx oamStagingLength
        tya
        asl
        asl
        asl
        asl
        adc spriteXOffset
        sta oamStaging+3,x
        adc #$8
        sta oamStaging+7,x
        lda spriteYOffset
        sta oamStaging+0,x
        sta oamStaging+4,x
        lda (byteSpriteAddr), y
        and #$F0
        lsr a
        lsr a
        lsr a
        lsr a
        adc byteSpriteTile
        sta oamStaging+1,x
        lda #$00
        sta oamStaging+2,x
        sta oamStaging+6,x
        lda (byteSpriteAddr), y
        and #$F
        adc byteSpriteTile
        sta oamStaging+5, x
        txa
        clc
        adc #$08
        sta oamStagingLength
        iny
        cpy byteSpriteLen
        bne @loop

        rts
