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
; initialize vars
    lda crunchModifier
    lsr
    lsr
    sta crunchLeftColumns
    lda crunchModifier
    and #$03
    clc
    adc crunchLeftColumns ; carry still clear
    eor #$FF
    adc #$0B ; 10 + 1 to get two's complement.  result is playable column count
    sta crunchClearColumns

; initialize playfield row 19 to 0
    lda #$13
    sta generalCounter
@nextRow:
    jsr advanceSidesInit
    dec generalCounter
    bpl @nextRow

; restore playfieldAddr and set vramRow for rendering
    lda #$00
    sta vramRow
    sta playfieldAddr
crunchReturn:
    rts

; for init only.  row determined by generalCounter
advanceSidesInit:
    ldy generalCounter
    lda multBy10Table,y
    sta playfieldAddr

; after init, only top row is drawn.  using (playfieldAddr),y defaults to top row
; as playfieldAddr is 0 when this is called (and most of the time)
advanceSides:
    ldy #$00
    lda #BLOCK_TILES

; x controls left tile count.  x can start at 0,1,2 or 3.
    ldx crunchLeftColumns
@leftLoop:
    dex
    bmi @right
    sta (playfieldAddr),y
    iny
    bne @leftLoop ; unconditional

@right:
    tya
    clc
    adc crunchClearColumns
    tay
    lda #BLOCK_TILES

; y is replaced with crunchClearColumns + y and increments until y == 10.  y can start at 7,8,9 or 10.
@rightLoop:
    cpy #$0A
    beq crunchReturn
    sta (playfieldAddr),y
    iny
    bne @rightLoop ; unconditional
