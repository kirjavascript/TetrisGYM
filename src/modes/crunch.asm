; crunch start variants:
; 0 - 0 left 0 right
; 1 - 0 left 1 right
; 2 - 0 left 2 right
; 3 - 0 left 3 right
; 4 - 1 left 0 right
; 5 - 1 left 1 right
; 6 - 1 left 2 right
; 7 - 1 left 3 right
; 8 - 2 left 0 right
; 9 - 2 left 1 right
; A - 2 left 2 right
; B - 2 left 3 right
; C - 3 left 0 right
; D - 3 left 1 right
; E - 3 left 2 right
; F - 3 left 3 right

advanceGameCrunch:
    lda #0
    sta vramRow
    lda crunchModifier
    lsr a
    lsr a
    ldx #0
    jsr advanceSide
    lda crunchModifier
    and #%00000011
    pha
    eor #$FF
    sec
    adc #0
    clc
    adc #10
    tax
    pla
    jsr advanceSide
    rts

advanceSide:
    cmp #0
    beq @end
    pha
    ldy #0
    txa
    clc
    adc #<playfield
    sta tmp1
    lda #>playfield
    sta tmp2
    lda #20
    sta tmp3
@rowLoop:
    pla
    pha
    tax
    beq @end
@blockLoop:
    lda #BLOCK_TILES
    sta (tmp1), y
    inc tmp1
    dex
    bne @blockLoop
    pla
    pha
    eor #$FF
    sec
    adc #0
    clc
    adc tmp1
    clc
    adc #10
    sta tmp1
    dec tmp3
    bne @rowLoop
    pla
@end:
    rts