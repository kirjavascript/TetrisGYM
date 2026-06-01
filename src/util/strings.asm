; stringLineCapWhen:
;         ldx linecapWhen
;         lda choiceSetOfflineslevel, x
;         jmp stringBackground
; stringLineCapHow:
;         ldx linecapHow
;         lda choiceSetKs2floorinvizhalt, x

stringBackground:
        ldx stringIndexLookup
        lda stringLookup, x
        tax
        lda stringLookup, x
        sta tmpZ
        inx
        ldy #0
@loop:
        lda stringLookup, x
        sta PPUDATA
        inx
        iny
        cpy tmpZ
        bne @loop
        rts

stringSprite:
        ldx spriteIndexInOamContentLookup
        lda stringLookup, x
        tax
        lda stringLookup, x
        sta tmpZ
        inx
        lda spriteXOffset
        sta tmpX
        jmp stringSpriteLoop

stringSpriteAlignRight:
        ldx spriteIndexInOamContentLookup
        lda stringLookup, x
        tax
        lda stringLookup, x
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
        lda stringLookup, x
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

stringLookup:
        .byte stringLinesO-stringLookup
        .byte stringLevelO-stringLookup
        .byte stringKSX2O-stringLookup
        .byte stringFromBelowO-stringLookup
        .byte stringInvizO-stringLookup
        .byte stringHaltO-stringLookup
stringLevelO:
        .byte $5,'L','E','V','E','L'
stringLinesO:
        .byte $5,'L','I','N','E','S'
stringKSX2O:
        .byte $4,'K','S',$69,'2'
stringFromBelowO:
        .byte $5,'F','L','O','O','R'
stringInvizO:
        .byte $5,'I','N','V','I','Z'
stringHaltO:
        .byte $4,'H','A','L','T'
; stringBackgroundNotGood:
;         tax
;         lda choiceSetTable,x
;         beq @ret
;         tay
;         inx
; @loop:
;         lda choiceSetTable, x
;         sta PPUDATA
;         inx
;         dey
;         bne @loop
; @ret:
;         rts
;
; stringSpriteNotGood:
;         ldx spriteIndexInOamContentLookup
;         lda stringTable, x
;         sta tmpZ
;         inx
;         lda spriteXOffset
;         sta tmpX
;         jmp stringSpriteLoop
;
; stringSpriteAlignRightNotGood:
;         ldx spriteIndexInOamContentLookup
; stringSpriteAlignRightANotGood:
;         tax
;         lda stringTable, x
;         inx
;         sta tmpZ
;         lda tmpZ
;         asl
;         asl
;         asl
;         sta tmpX
;         clc
;         lda spriteXOffset
;         sbc tmpX
;         sta tmpX
;
; stringSpriteLoopNotGood:
;         ldy oamStagingLength
;         sec
;         lda spriteYOffset
;         sta oamStaging, y
;         lda stringTable, x
;         inx
;         sta oamStaging+1, y
;         lda #$00
;         sta oamStaging+2, y
;         lda tmpX
;         sta oamStaging+3, y
;         clc
;         adc #$8
;         sta tmpX
;         ; increase OAM index
;         lda #$04
;         clc
;         adc oamStagingLength
;         sta oamStagingLength
;
;         dec tmpZ
;         lda tmpZ
;         bne stringSpriteLoop
;         rts
