; clobbers generalCounter3 & generalCounter4 (defined in playstate/util.asm)

initGameCrunch:
; ignore for garbage mode
    lda practiseType
    cmp #MODE_GARBAGE
    beq crunchReturn
    ldx crunchLeftModifier
    bne @crunch
    ldx crunchRightModifier
    beq crunchReturn
@crunch:
; initialize playfield row 19 to 0
    lda #$13
    sta generalCounter
@nextRow:
    ldx generalCounter
    ldy multBy10Table,x
    ldx #0
@loop:
    lda topRowBuffer,x
    bmi @noTile
    sta playfield,y
@noTile:
    iny
    inx
    cpx #$0A
    bne @loop
    dec generalCounter
    bpl @nextRow
    lda #0
    sta vramRow
crunchReturn:
    rts

refreshTopRow:
    lda practiseType ; ignore crunch for tap quantity
    cmp #MODE_TAPQTY
    beq @ret
    cmp #MODE_GARBAGE ; also for garbage
    beq @ret
    ldx #9
@loop:
    lda topRowBuffer,x
    sta playfield,x
    dex
    bpl @loop
@ret:
    rts

initializeTopRowBuffer:
    ldy #9
    lda #EMPTY_TILE
@initLoop:
    sta topRowBuffer,y
    dey
    bpl @initLoop

    jsr copyCrunchModifier
    lda #BLOCK_TILES+3
    ldy #$0
@leftLoop:
    dec crunchLeftColumns
    bmi @initRight
    sta topRowBuffer,y
    iny
    bpl @leftLoop ; unconditional
@initRight:
    ldy #$9
@rightLoop:
    dec crunchRightColumns
    bmi @ret
    sta topRowBuffer,y
    dey
    bpl @rightLoop ; unconditional
@ret:
    rts

copyCrunchModifier:
    lda crunchLeftModifier
    sta crunchLeftColumns ; generalCounter3
    lda crunchRightModifier
    sta crunchRightColumns ; generalCounter4
    rts

copyCrunchModifierMirrored:
    lda crunchRightModifier
    sta crunchLeftColumns ; generalCounter3
    lda crunchLeftModifier
    sta crunchRightColumns ; generalCounter4
    rts
