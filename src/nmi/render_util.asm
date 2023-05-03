renderByteBCDNoPad:
        ldx #1
        jmp renderByteBCDStart
renderByteBCD:
        ldx #$0
renderByteBCDStart:
        sta tmpZ
        cmp #200
        bcc @maybe100
        lda #2
        sta PPUDATA
        lda tmpZ
        sbc #200
        jmp @byte
@maybe100:
        cmp #100
        bcc @not100
        lda #1
        sta PPUDATA
        lda tmpZ
        sbc #100
        jmp @byte
@not100:
        cpx #0
        bne @main
        lda #$EF
        sta PPUDATA
@main:
        lda tmpZ
@byte:
        tax
        lda byteToBcdTable, x

twoDigsToPPU:
        sta generalCounter
        and #$F0
        lsr a
        lsr a
        lsr a
        lsr a
        sta PPUDATA
        lda generalCounter
        and #$0F
        sta PPUDATA
        rts

render_playfield:
        lda #$04
        sta playfieldAddr+1
        jsr copyPlayfieldRowToVRAM
        jsr copyPlayfieldRowToVRAM
        jsr copyPlayfieldRowToVRAM
        jsr copyPlayfieldRowToVRAM
        rts

vramPlayfieldRows:
        .word   $20C6,$20E6,$2106,$2126
        .word   $2146,$2166,$2186,$21A6
        .word   $21C6,$21E6,$2206,$2226
        .word   $2246,$2266,$2286,$22A6
        .word   $22C6,$22E6,$2306,$2326

copyPlayfieldRowToVRAM:
        ldx vramRow
        cpx #$15
        bpl @ret
        lda multBy10Table,x
        tay
        txa
        asl a
        tax
        inx
        lda vramPlayfieldRows,x
        sta PPUADDR
        dex

        lda vramPlayfieldRows,x
        clc
        adc #$06
        sta PPUADDR
@copyRow:
        ldx #$0A
        lda invisibleFlag
        bne @copyRowInvisible
@copyByte:
        lda (playfieldAddr),y
        sta PPUDATA
        iny
        dex
        bne @copyByte
@rowCopied:
        inc vramRow
        lda vramRow
        cmp #$14
        bmi @ret
        lda #$20
        sta vramRow
@ret:   rts

@copyRowInvisible:
        lda #EMPTY_TILE
@copyByteInvisible:
        sta PPUDATA
        dex
        bne @copyByteInvisible
        jmp @rowCopied
