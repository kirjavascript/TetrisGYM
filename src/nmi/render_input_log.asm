getInputAddr:
        clc
        lda inputLogCounter
        and #$18
        lsr
        lsr
        lsr
        adc #$20
        and #$23
        tay ; high

        clc
        ldx inputLogCounter
        txa
        and #$7
        tax
        lda multBy32Table, x
        clc
        adc #$19
        tax ; low
        rts

renderHzInputRows:
        ; if hzFrameCounter == 0, reset rows
        lda hzFrameCounter+1
        bne @checkLimit
        lda hzFrameCounter
        bne @checkLimit

        lda #2
        sta inputLogCounter

        ; enable vertical drawing
        lda PPUCTRL
        ora #%100
        sta PPUCTRL

        jsr getInputAddr
        tya
        sta PPUADDR
        txa
        sta PPUADDR

        jsr clearInputLine

        jsr getInputAddr
        inx
        tya
        sta PPUADDR
        txa
        sta PPUADDR

        jsr clearInputLine

        lda PPUCTRL
        and #%11111011
        sta PPUCTRL


@checkLimit:
        lda inputLogCounter
        cmp #28
        bcc @tickCounter
        rts
@tickCounter:
        jsr getInputAddr
        tya
        sta PPUADDR
        txa
        sta PPUADDR

        lda heldButtons_player1
        ora newlyPressedButtons_player1
        sta tmpZ
        and #BUTTON_RIGHT|BUTTON_LEFT
        tax
        lda inputLogTiles, x
        sta PPUDATA

        ; print A/B
        lda tmpZ
        and #BUTTON_A|BUTTON_B
        lsr
        lsr
        lsr
        lsr
        lsr
        lsr
        tax
        lda inputLogTiles+3, x
        sta PPUDATA

        inc inputLogCounter
        rts

clearInputLine:
        lda #$FF
        ldx #26
@clearRow:
        sta PPUDATA
        dex
        bne @clearRow
        rts

inputLogTiles:
        .byte $24, $1B, $15
        .byte $24, $B, $A
