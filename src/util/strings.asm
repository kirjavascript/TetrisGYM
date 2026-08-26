stringUnpackXY:
        txa
        lsr
        lsr
        lsr
        lsr
        sta stringLength
        tya
        clc
        adc #<strTable
        sta tmp1
        txa
        and #$F
        adc #>strTable
        sta tmp2
        ldy #0
        rts

stringSpriteXY:
        jsr stringUnpackXY
        ldx oamStagingLength
@loop:
        lda spriteYOffset
        sta oamStaging,x
        lda (tmp1),y
        sta oamStaging+1,x
        lda stringAttrib
        sta oamStaging+2,x
        lda spriteXOffset
        sta oamStaging+3,x
        clc
        adc #$8
        sta spriteXOffset
        ; increase OAM index
        inx
        inx
        inx
        inx
        stx oamStagingLength
        iny
        dec stringLength
        bpl @loop
        rts

stringBackgroundXY:
        jsr stringUnpackXY
@loop:
        lda (tmp1),y
        sta PPUDATA
        iny
        dec stringLength
        bpl @loop
        rts
