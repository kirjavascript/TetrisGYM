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
        .byte stringLevelO-stringLookup
        .byte stringLinesO-stringLookup
        .byte stringKSX2O-stringLookup
        .byte stringFromBelowO-stringLookup
        .byte stringInvizO-stringLookup
        .byte stringHaltO-stringLookup
        .byte stringPauseO-stringLookup
        .byte stringBlockO-stringLookup
        .byte stringClearO-stringLookup
        .byte stringSureO-stringLookup
        .byte stringConfettiO-stringLookup
stringLevelO:
        .byte $5,"LEVEL"
stringLinesO:
        .byte $5,"LINES"
stringKSX2O:
        .byte $4,"KS",$69,"2"
stringFromBelowO:
        .byte $5,"FLOOR"
stringInvizO:
        .byte $5,"INVIZ"
stringHaltO:
        .byte $4,"HALT"
stringPauseO:
        .byte $5, "PAUSE"
stringBlockO:
        .byte $5, "BLOCK"
stringClearO:
    .byte $06,"CLEAR?"
stringSureO:
    .byte $06,"SURE?!"
stringConfettiO:
    .byte $08,"CONFETTI"
.enum
STRING_LEVEL_O
STRING_LINES_O
STRING_KSX2_O
STRING_FLOOR_O
STRING_INVIZ_O
STRING_HALT_O
STRING_PAUSE_O
STRING_BLOCK_O
STRING_CLEAR_O
STRING_SURE_O
STRING_CONFETTI_O
.endenum
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
