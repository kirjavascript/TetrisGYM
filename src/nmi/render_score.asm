scoreSetupPPU:
        lda #$21
        sta PPUADDR
        lda #$18
        sta PPUADDR
        rts
renderBCDScore:
        jsr scoreSetupPPU
renderBCDScoreData:
        lda score+2
        jsr twoDigsToPPU
        jmp renderLowScore
renderClassicScore:
        jsr scoreSetupPPU
        ldx score+3
        ldy score+2
        jsr renderClassicHighByte
renderLowScore:
        lda score+1
        jsr twoDigsToPPU
        lda score
        jsr twoDigsToPPU
        rts

renderLettersScore:
        jsr scoreSetupPPU
        ldx score+3
        ldy score+2
        jsr renderLettersHighByte
        jmp renderLowScore

renderScoreCap:
        lda score+3
        beq renderBCDScore
        jsr scoreSetupPPU
        lda #$99
        jsr twoDigsToPPU
        lda #$99
        jsr twoDigsToPPU
        lda #$99
        jsr twoDigsToPPU
        rts

renderSevenDigit:
        jsr scoreSetupPPU
        lda score+3
        and #$F
        sta PPUDATA
        jsr renderBCDScoreData
        rts

renderFloat:
        lda #$21
        sta PPUADDR
        lda #$39
        sta PPUADDR
        lda score+3
        cmp #$A
        bcc @notTen
        lda score+3
        jsr twoDigsToPPU
        jmp @hundredThousands
@notTen:
        lda #$FF
        sta PPUDATA
        lda score+3
        and #$F
        sta PPUDATA
@hundredThousands:

        lda #$21
        sta PPUADDR
        lda #$3c
        sta PPUADDR
        clc
        lda score+2
        and #$F0
        ror
        ror
        ror
        ror
        sta PPUDATA
        jsr renderBCDScore
        rts

renderLevelDash:
        lda #$22
        sta PPUADDR
        lda #$B8
        sta PPUADDR
        lda levelNumber
        jsr renderByteBCD
        lda #'-'
        sta PPUDATA
        rts

renderModernLines:
        ; 'lines-' tile queue
        ; could lazy render this to make it 'free'
        lda linesTileQueue
        beq @endLinesTileQueue
        cmp #$86
        beq @endLinesTileQueue
        lda #$20
        sta PPUADDR
        lda linesTileQueue
        and #$F
        sta tmpZ
        adc #$6C
        sta PPUADDR
        ldx tmpZ
        lda linesDash, x
        sta PPUDATA
        inc linesTileQueue
@endLinesTileQueue:

        lda outOfDateRenderFlags
        and #$01
        beq @doneRenderLines

        ; 'normal' line drawing
        lda linesBCDHigh
        cmp #$A
        bcs @extraLines
        lda #$20
        sta PPUADDR
        lda #$73
        sta PPUADDR
        lda lines+1
        sta PPUDATA
        lda lines
        jsr twoDigsToPPU
        jmp @doneRenderLines
@extraLines:
        lda #$20
        sta PPUADDR
        lda #$72
        sta PPUADDR
        lda linesBCDHigh
        jsr twoDigsToPPU
        lda lines
        jsr twoDigsToPPU
@doneRenderLines:
        rts

; X - score+3 Y = score+2

; h = (0|score/100000)
; offset = (0|h /16) << 4
; output = h - offset
renderClassicHighByte:
        stx tmpX
        sty tmpY

        ; cpx #0
        txa ; either branch clobbers accumulator.  txa sets z, saves 1 byte.
        bne @startWrap
        lda tmpY ; score+2
        jsr twoDigsToPPU
        rts
@startWrap:

        jsr getScoreDiv100k

        and #$F0 ; /16 << 4
        sta tmpX
        sec
        lda tmpZ
        sbc tmpX

        sta PPUDATA

        lda tmpY ; score+2
        and #$F
        sta PPUDATA
        rts

getScoreDiv100k:
        lda tmpY ; score+2
        lsr
        lsr
        lsr
        lsr
        sta tmpZ

        clc
        lda tmpX ; score+3
        and #$F
        tax
        lda multBy10Table, x
        adc tmpZ
        sta tmpZ

        lda tmpX ; score+3
        lsr
        lsr
        lsr
        lsr
        clc
        tax
        lda multBy100Table, x
        adc tmpZ
        sta tmpZ ; (0|score/100000)
        rts

; X - score+3 Y = score+2
renderLettersHighByte:
        stx tmpX
        sty tmpY

        ; cpx #0
        txa ; either branch clobbers accumulator.  txa sets z, saves 1 byte.
        bne @startWrap
        lda tmpY ; score+2
        jsr twoDigsToPPU
        rts
@startWrap:

        jsr getScoreDiv100k

        sec
@mod40:
        sbc #36 ; loop body is ~20 cycles for worst case?
        bcs @mod40
        adc #36

        sta PPUDATA

        lda tmpY ; score+2
        and #$F
        sta PPUDATA

        rts

linesDash:
        .byte $15, $12, $17, $E, $1C, $24
