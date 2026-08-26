initChecker:
CHECKERBOARD_TILE := BLOCK_TILES+3
CHECKERBOARD_FLIP := CHECKERBOARD_TILE ^ EMPTY_TILE
        lda #0
        sta vramRow
        lda heightOrRows
        bne @byRows
        ldx heightModifier
        bne @notZero
        ldy #1
        bne @load
@notZero:
        ldy heightToRows,x
        jmp @load
@byRows:
        ldy rowsModifier
@load:
        ldx typeBBlankInitCountByRowsTable,y
        lda seededPieces
        beq @random
        lda set_seed_input+1
        jmp @branch
@random:
        lda frameCounter
@branch:
        and #1
        beq @checkerStartA
        lda #CHECKERBOARD_TILE
        bne @checkerStart
@checkerStartA:
        lda #EMPTY_TILE
@checkerStart:
        ; hydrantdude found the short way to do this
        ldy #$B
@loop:
        dey
        bne @notA
        eor #CHECKERBOARD_FLIP
        ldy #$A
@notA:  sta playfield, x
        eor #CHECKERBOARD_FLIP
        inx
        cpx #200
        bcc @loop
        rts
