advanceGameTSpins:
        ; track the tspin quantity on the first tspin attempt
        lda tspinQuantity
        bne @qtyEnd
        lda tetriminoX
        cmp #$EF
        beq @qtyEnd
        lda statsByType
        sta tspinQuantity
@qtyEnd:
        ; reset score if tspinQuantity doesnt match
        lda score
        bne @scrub
        lda score+1
        bne @scrub
        lda score+2
        bne @scrub
        jmp @continue
@scrub:
        lda tspinQuantity
        beq @continue
        cmp statsByType
        beq @continue

        jsr clearPoints

        lda outOfDateRenderFlags
        ora #$04
        sta outOfDateRenderFlags
@continue:

advanceGameTSpins_actual:
        ; see if the sprite has reached the right position
        lda #8
        sbc tspinX
        cmp tetriminoX
        bne @notSuccessful
        lda #18
        sbc tspinY
        cmp tetriminoY
        bne @notSuccessful
        ; check the orientation
        lda currentPiece
        cmp #2
        bne @notSuccessful

        ; set successful tspin vars
        lda #$3
        sta playState
        lda #0
        sta tspinX
        sta vramRow ; shorter to do it here than in rendering

        ; add score
        lda #$2
        sta completedLines
        jsr addPointsRaw

        ; TODO: copy score to top
        lda #$20
        sta spawnDelay
        lda #TETRIMINO_X_HIDE
        sta tetriminoX

@notSuccessful:
        ; check if a tspin is setup
        lda tspinX
        ; cmp #0 ; lda sets z flag
        bne renderTSpin

generateNewTSpin:
        ldx #rng_seed
        ldy #$2
        jsr generateNextPseudorandomNumber
        lda rng_seed
        tax
        ; lower nybble
        and #$7
        sta tspinX
        ; high nybbleish
        txa
        ror
        ror
        ror
        ror
        and #3
        sta tspinY
        ; some other bit
        txa
        and #1
        sta tspinType

        lda #0
        sta tspinQuantity

renderTSpin:
        jsr clearPlayfield

        lda tspinY
        clc
        adc #2
        jsr drawFloor

        ; get tspin offset
        ldx tspinY
        lda multBy10Table, x
        sta tmp1

        lda #$FF
        sbc tspinX ; sub X
        sbc tmp1 ; sub Y
        tax
        ; draw tspin
        lda #EMPTY_TILE
        sta $03bc, x
        sta $03bd, x
        sta $03be, x
        sta $03c7, x
        sta $03b3, x
        ldy tspinType
        ; cpy #0 ; ldy sets z flag
        bne @noInc
        inx
        inx
@noInc:
        sta $03b2, x

        rts
