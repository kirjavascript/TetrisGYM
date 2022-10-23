playState_receiveGarbage:
        ldy pendingGarbage
        beq @ret
        lda multBy10Table,y
        sta generalCounter2
        lda #$00
        sta generalCounter
@shiftPlayfieldUp:
        ldy generalCounter2
        lda (playfieldAddr),y
        ldy generalCounter
        sta (playfieldAddr),y
        inc generalCounter
        inc generalCounter2
        lda generalCounter2
        cmp #$C8
        bne @shiftPlayfieldUp
        iny

        ldx #$00
@fillGarbage:
        cpx garbageHole
        beq @hole
        lda #BLOCK_TILES + 3
        jmp @set
@hole:
        lda #EMPTY_TILE ; was $FF ?
@set:
        sta (playfieldAddr),y
        inx
        cpx #$0A
        bne @inc
        ldx #$00
@inc:   iny
        cpy #$C8
        bne @fillGarbage
        lda #$00
        sta pendingGarbage
        sta vramRow
@ret:  inc playState
@delay:  rts


garbageLines:
        .byte   $00,$00,$01,$02,$04
