SLOT_SIZE := $100 ; ~$CC used, the rest free

; some repeated code here, could replace it with an address pointer

saveslots:
        .addr saveslot0
        .addr saveslot1
        .addr saveslot2
        .addr saveslot3
        .addr saveslot4
        .addr saveslot5
        .addr saveslot6
        .addr saveslot7
        .addr saveslot8
        .addr saveslot9
saveslot0:
        sta SRAM,y
        rts
saveslot1:
        sta SRAM+SLOT_SIZE,y
        rts
saveslot2:
        sta SRAM+(SLOT_SIZE*2),y
        rts
saveslot3:
        sta SRAM+(SLOT_SIZE*3),y
        rts
saveslot4:
        sta SRAM+(SLOT_SIZE*4),y
        rts
saveslot5:
        sta SRAM+(SLOT_SIZE*5),y
        rts
saveslot6:
        sta SRAM+(SLOT_SIZE*6),y
        rts
saveslot7:
        sta SRAM+(SLOT_SIZE*7),y
        rts
saveslot8:
        sta SRAM+(SLOT_SIZE*8),y
        rts
saveslot9:
        sta SRAM+(SLOT_SIZE*9),y
        rts

saveSlot:
        sta tmp3 ; save a copy of A
        lda saveStateSlot
        asl
        tax
        lda saveslots,x
        sta tmp1
        lda saveslots+1,x
        sta tmp1+1
        lda tmp3 ; restore it
        jmp (tmp1)

saveState:
        ldy #0
@copy:
        lda playfield,y
        jsr saveSlot
        iny
        cpy #$c8
        bcc @copy

        lda tetriminoX
        jsr saveSlot
        iny
        lda tetriminoY
        jsr saveSlot
        iny
        lda currentPiece
        jsr saveSlot
        iny
        lda nextPiece
        jsr saveSlot

        ; level/lines/score
        ; iny
        ; lda levelNumber
        ; jsr saveSlot
        ; iny
        ; lda lines
        ; jsr saveSlot
        ; iny
        ; lda score
        ; jsr saveSlot
        ; iny
        ; lda score+1
        ; jsr saveSlot
        ; iny
        ; lda score+2
        ; jsr saveSlot


        lda #$17
        sta saveStateSpriteType
        lda #$20
        sta saveStateSpriteDelay
        rts

loadslots:
        .addr loadslot0
        .addr loadslot1
        .addr loadslot2
        .addr loadslot3
        .addr loadslot4
        .addr loadslot5
        .addr loadslot6
        .addr loadslot7
        .addr loadslot8
        .addr loadslot9
loadslot0:
        lda SRAM,y
        rts
loadslot1:
        lda SRAM+SLOT_SIZE,y
        rts
loadslot2:
        lda SRAM+(SLOT_SIZE*2),y
        rts
loadslot3:
        lda SRAM+(SLOT_SIZE*3),y
        rts
loadslot4:
        lda SRAM+(SLOT_SIZE*4),y
        rts
loadslot5:
        lda SRAM+(SLOT_SIZE*5),y
        rts
loadslot6:
        lda SRAM+(SLOT_SIZE*6),y
        rts
loadslot7:
        lda SRAM+(SLOT_SIZE*7),y
        rts
loadslot8:
        lda SRAM+(SLOT_SIZE*8),y
        rts
loadslot9:
        lda SRAM+(SLOT_SIZE*9),y
        rts

loadSlot:
        lda saveStateSlot
        asl
        tax
        lda loadslots,x
        sta tmp1
        lda loadslots+1,x
        sta tmp1+1
        jmp (tmp1)

loadState:
        ldy #0
@copy:
        jsr loadSlot
        sta playfield,y
        iny
        cpy #$c8
        bcc @copy

        jsr loadSlot
        sta tetriminoX
        iny
        jsr loadSlot
        sta tetriminoY
        iny
        jsr loadSlot
        sta currentPiece
        iny
        jsr loadSlot
        sta nextPiece

        ; level/lines/score
        ; iny
        ; jsr loadSlot
        ; sta levelNumber
        ; iny
        ; jsr loadSlot
        ; sta lines
        ; iny
        ; jsr loadSlot
        ; sta score
        ; iny
        ; jsr loadSlot
        ; sta score+1
        ; iny
        ; jsr loadSlot
        ; sta score+2
        ; ; mark for update
        ; lda #7
        ; sta outOfDateRenderFlags

        lda #$18
        sta saveStateSpriteType
        lda #$20
        sta saveStateSpriteDelay
@done:
        rts
