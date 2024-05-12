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
        ; cpx #0
        txa ; either branch clobbers accumulator.  txa sets z, saves 1 byte.
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
        lda practiseType
        cmp #MODE_LOWSTACK
        bne @ret
        jmp copyLowStackRowToVram
@ret:   rts

vramPlayfieldRows:
        .word   $20CC,$20EC,$210C,$212C
        .word   $214C,$216C,$218C,$21AC
        .word   $21CC,$21EC,$220C,$222C
        .word   $224C,$226C,$228C,$22AC
        .word   $22CC,$22EC,$230C,$232C

copyLowStackRowToVram:
        sec
        lda #19
        sbc lowStackRowModifier
        ; lda lowStackRowModifier
        asl
        tax
        lda vramPlayfieldRows+1,x
        sta PPUADDR
        lda vramPlayfieldRows,x
        sta PPUADDR
        ldx #$0A
        lda #LOW_STACK_LINE
@drawLine:
        sta PPUDATA
        dex
        bne @drawLine
        rts

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
