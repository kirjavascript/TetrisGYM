secretGradeGrading:
    @sgRow = generalCounter ; 19 to 1
    @sgCol = generalCounter2 ; 0 to 9 to 0
    @sgAdjust = generalCounter3 ; 1 until row 10, then -1
    lda #19
    sta @sgRow
    ldx #0
    stx @sgCol
    stx secretGrade
    ldy secretGradingFlag
    beq @notGood
    inx
    stx @sgAdjust
@rowLoop:
    ldy @sgRow
    ldx multBy10Table,y
    ldy #0
@colLoop:
    cpy @sgCol
    bne @fillCheck
; emptyCheck
    lda playfield,x
    bpl @notGood
; check tile above
    lda playfield-10,x
    bmi @notGood
    bpl @nextTile
@fillCheck:
    lda playfield,x
    bmi @notGood
@nextTile:
    inx
    iny
    cpy #10
    bne @colLoop
    lda @sgCol
    clc
    adc @sgAdjust
    sta @sgCol
    cmp #9
    bne @noFlip
    lda #$FF
    sta @sgAdjust
@noFlip:
    inc secretGrade
    dec @sgRow
    bne @rowLoop
@notGood:
    ldy secretGrade
    lda levelDisplayTable,y
    sta secretGrade
    rts
secretGradeSprite:
    lda secretGradingFlag
    beq secretGradeSprite-1
    lda #$E0
    ldy scoringModifier
    cpy #SCORING_SEVENDIGIT
    bne @noShift
    clc
    adc #$8
@noShift:
    sta spriteXOffset
    lda #$47
    sta spriteYOffset
    lda #<secretGrade
    sta byteSpriteAddr
    lda #>secretGrade
    sta byteSpriteAddr+1
    lda #0
    sta byteSpriteTile
    lda #1
    sta byteSpriteLen
    jmp byteSprite
