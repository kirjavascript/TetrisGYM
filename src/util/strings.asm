stringLineCapWhen:
        ldx linecapWhen
        lda choiceSetOfflineslevel, x
        jmp stringBackground
stringLineCapHow:
        ldx linecapHow
        lda choiceSetKs2floorinvizhalt, x
stringBackground:
        tax
        lda choiceSetTable,x
        beq @ret
        tay
        inx
@loop:
        lda choiceSetTable, x
        sta PPUDATA
        inx
        dey
        bne @loop
@ret:
        rts

stringSprite:
        ldx spriteIndexInOamContentLookup
        lda stringTable, x
        sta tmpZ
        inx
        lda spriteXOffset
        sta tmpX
        jmp stringSpriteLoop

stringSpriteAlignRight:
        ldx spriteIndexInOamContentLookup
stringSpriteAlignRightA:
        tax
        lda stringTable, x
        inx
        sta tmpZ
        lda tmpZ
        asl
        asl
        asl
        sta tmpX
        clc
        lda spriteXOffset
        sbc tmpX
        sta tmpX

stringSpriteLoop:
        ldy oamStagingLength
        sec
        lda spriteYOffset
        sta oamStaging, y
        lda stringTable, x
        inx
        sta oamStaging+1, y
        lda #$00
        sta oamStaging+2, y
        lda tmpX
        sta oamStaging+3, y
        clc
        adc #$8
        sta tmpX
        ; increase OAM index
        lda #$04
        clc
        adc oamStagingLength
        sta oamStagingLength

        dec tmpZ
        lda tmpZ
        bne stringSpriteLoop
        rts
