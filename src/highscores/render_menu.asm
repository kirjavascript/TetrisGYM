showHighScores:
        ldy #0
        lda #0
        sta generalCounter2
@copyEntry:
        lda generalCounter2
        asl a
        tax
        lda highScorePpuAddrTable,x
        sta PPUADDR
        inx
        lda highScorePpuAddrTable,x
        sta PPUADDR

        ; name
        ldx #highScoreNameLength
@copyChar:
        lda highscores,y
        sty generalCounter
        tay
        lda highScoreCharToTile,y
        ldy generalCounter
        sta PPUDATA
        iny
        dex
        bne @copyChar

        lda #$FF
        sta PPUDATA

        lda #0 ; 8 digit flag
        sta tmpZ

        ; score
        lda highscores,y
        cmp #$A
        bmi @scoreHighWrite
        jsr twoDigsToPPU
        lda #1
        sta tmpZ
        jmp @scoreEnd
@scoreHighWrite:
        sta PPUDATA
@scoreEnd:
        iny
        lda highscores,y
        jsr twoDigsToPPU
        iny
        lda highscores,y
        jsr twoDigsToPPU
        iny
        lda highscores,y
        jsr twoDigsToPPU
        iny

        lda #$FF
        sta PPUDATA

        ; lines
        lda highscores,y
        sta PPUDATA
        iny
        lda highscores,y
        jsr twoDigsToPPU
        iny

        lda #$FF
        sta PPUDATA

        ; update PPUADDR for start lines
        lda generalCounter2
        asl a
        tax
        lda highScorePpuAddrTable,x
        sta PPUADDR
        inx
        lda highScorePpuAddrTable,x
        adc #$29
        sta PPUADDR

        ; levels
        lda highscores,y ; startlevel
        jsr renderByteBCD
        iny

        ; level
        lda highscores,y
        jsr renderByteBCD
        iny

        inc generalCounter2
        lda generalCounter2
        cmp #highScoreQuantity
        beq showHighScores_ret
        jmp @copyEntry

showHighScores_ret:  rts
