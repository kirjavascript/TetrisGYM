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
        .byte stringClassic-stringLookup
        .byte stringLetters-stringLookup
        .byte stringSevenDigit-stringLookup
        .byte stringFloat-stringLookup
        .byte stringScorecap-stringLookup
        .byte stringHidden-stringLookup
        .byte stringNull-stringLookup ; reserved for future use
        .byte stringNull-stringLookup
        .byte stringOff-stringLookup ; 8
        .byte stringOn-stringLookup
        .byte stringPause-stringLookup
        .byte stringDebug-stringLookup
        .byte stringClear-stringLookup
        .byte stringConfirm-stringLookup
        .byte stringV4-stringLookup
        .byte stringV5-stringLookup ; F
        .byte stringLevel-stringLookup
        .byte stringLines-stringLookup
        .byte stringKSX2-stringLookup
        .byte stringFromBelow-stringLookup
        .byte stringInviz-stringLookup
        .byte stringHalt-stringLookup
		.byte stringShown-stringLookup ;16
		.byte stringTopout-stringLookup
		.byte stringCrash-stringLookup
		.byte stringConfetti-stringLookup ;19
stringClassic:
        .byte $7,'C','L','A','S','S','I','C'
stringLetters:
        .byte $7,'L','E','T','T','E','R','S'
stringSevenDigit:
        .byte $6,'7','D','I','G','I','T'
stringFloat:
        .byte $1,'M'
stringScorecap:
        .byte $6,'C','A','P','P','E','D'
stringHidden:
        .byte $6,'H','I','D','D','E','N'
stringOff:
        .byte $3,'O','F','F'
stringOn:
        .byte $2,'O','N'
stringPause:
        .byte $5,'P','A','U','S','E'
stringDebug:
        .byte $5,'B','L','O','C','K'
stringClear:
.if SAVE_HIGHSCORES
        .byte $6,'C','L','E','A','R','?'
.endif
stringConfirm:
.if SAVE_HIGHSCORES
        .byte $6,'S','U','R','E','?','!'
.endif
stringV4:
        .byte $2,'V','4'
stringV5:
        .byte $2,'V','5'
stringLines:
        .byte $5,'L','I','N','E','S'
stringLevel:
        .byte $5,'L','E','V','E','L'
stringKSX2:
        .byte $4,'K','S',$69,'2'
stringFromBelow:
        .byte $5,'F','L','O','O','R'
stringInviz:
        .byte $5,'I','N','V','I','Z'
stringHalt:
        .byte $4,'H','A','L','T'
stringNull:
        .byte $0
stringShown:
		.byte $5,'S','H','O','W','N'
stringTopout:
		.byte $6,'T','O','P','O','U','T'
stringCrash:
		.byte $5,'C','R','A','S','H'
stringConfetti:
		.byte $8,'C','O','N','F','E','T','T','I'