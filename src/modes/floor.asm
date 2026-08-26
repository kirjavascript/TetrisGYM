initGameFloor:
        lda practiseType
        cmp #MODE_GARBAGE
        beq initFloorRet
        lda #0
        sta vramRow
        lda currentFloor
drawFloor:
        ; get correct offset
        tax
        ; x10
        lda #0
        sec
        sbc multBy10Table,x
        tax
        beq initFloorRet
        ; draw block tiles+3 ($7E)
        lda #BLOCK_TILES+3
@loop:
        sta playfield-56,x
        inx
        bne @loop
initFloorRet:
        rts

drawFloorTopRow:
        lda practiseType
        cmp #MODE_GARBAGE
        beq initFloorRet
        lda #$14
        sec
        sbc currentFloor
        cmp #$14  ; skip floor 0
        beq @ret
        tax
        ldy multBy10Table,x
        ldx #$0A
        lda #BLOCK_TILES+3
@drawFloorSurface:
        sta playfield,y
        iny
        dex
        bne @drawFloorSurface
@ret:
        rts
