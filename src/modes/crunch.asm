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

; clobbers generalCounter3 & generalCounter4 (defined in playstate/util.asm)

advanceGameCrunch:
; initialize playfield row 19 to 0
    ldx #$13
@nextRow:
    lda multBy10Table,x
    sta playfieldAddr ; restored to 0 at end of loop
    jsr advanceSides
    dex
    bpl @nextRow
    inx ; x is FF, increase to store 0 in vramRow
    stx vramRow
crunchReturn:
    rts

advanceSides:
    ; called in playState_checkForCompletedRows and in advanceGameCrunch
    ; draws to row defined in playfieldAddr, which defaults to 0
    jsr unpackCrunchModifier

    lda #BLOCK_TILES

    ldy #$0
@leftLoop:
    dec crunchLeftColumns
    bmi @initRight
    sta (playfieldAddr),y
    iny
    bpl @leftLoop ; unconditional

@initRight:
    ldy #$9
@rightLoop:
    dec crunchRightColumns
    bmi crunchReturn
    sta (playfieldAddr),y
    dey
    bpl @rightLoop ; unconditional


unpackCrunchModifier:
    lda crunchModifier
    lsr
    lsr
    sta crunchLeftColumns ; generalCounter3
    lda crunchModifier
    and #$03
    sta crunchRightColumns ; generalCounter4
    rts
