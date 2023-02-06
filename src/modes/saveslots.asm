SLOT_SIZE := $100 ; ~$CC used, the rest free

saveslots:
        .word SRAM
        .word SRAM+SLOT_SIZE
        .word SRAM+(SLOT_SIZE*2)
        .word SRAM+(SLOT_SIZE*3)
        .word SRAM+(SLOT_SIZE*4)
        .word SRAM+(SLOT_SIZE*5)
        .word SRAM+(SLOT_SIZE*6)
        .word SRAM+(SLOT_SIZE*7)
        .word SRAM+(SLOT_SIZE*8)
        .word SRAM+(SLOT_SIZE*9)

getSlotPointer:
        lda saveStateSlot
        asl
        tax
        lda saveslots,x
        sta pointerAddr
        lda saveslots+1,x
        sta pointerAddr+1
        rts

saveState:
        jsr getSlotPointer

        ldy #0
@copy:
        lda playfield,y
        sta (pointerAddr), y
        iny
        cpy #$c8
        bcc @copy

        lda tetriminoX
        sta (pointerAddr), y
        iny
        lda tetriminoY
        sta (pointerAddr), y
        iny
        lda currentPiece
        sta (pointerAddr), y
        iny
        lda nextPiece
        sta (pointerAddr), y

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

loadState:
        jsr getSlotPointer

        ldy #0
@copy:
        lda (pointerAddr), y
        sta playfield,y
        iny
        cpy #$c8
        bcc @copy

        lda (pointerAddr), y
        sta tetriminoX
        iny
        lda (pointerAddr), y
        sta tetriminoY
        iny
        lda (pointerAddr), y
        sta currentPiece
        iny
        lda (pointerAddr), y
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
