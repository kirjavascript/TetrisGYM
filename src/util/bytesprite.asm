byteSprite:
menuXTmp := tmp2
        ldy #0
@loop:
        tya
        asl
        asl
        asl
        asl
        adc spriteXOffset
        sta menuXTmp

        ldx oamStagingLength
        lda spriteYOffset
        sta oamStaging, x
        inx
        lda (byteSpriteAddr), y
        and #$F0
        lsr a
        lsr a
        lsr a
        lsr a
        adc byteSpriteTile
        sta oamStaging, x
        inx
        lda #$00
        sta oamStaging, x
        inx
        lda menuXTmp
        sta oamStaging, x
        inx

        lda spriteYOffset
        sta oamStaging, x
        inx
        lda (byteSpriteAddr), y
        and #$F
        adc byteSpriteTile
        sta oamStaging, x
        inx
        lda #$00
        sta oamStaging, x
        inx
        lda menuXTmp
        adc #$8
        sta oamStaging, x
        inx

        ; increase OAM index
        lda #$08
        clc
        adc oamStagingLength
        sta oamStagingLength

        iny
        cpy byteSpriteLen
        bne @loop

        rts
