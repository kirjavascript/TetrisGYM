showHighScores:
        ldy #0
        lda #0
        sta tmpY
@copyEntry:
        lda tmpY
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
        sty tmpX
        tay
        lda highScoreCharToTile,y
        ldy tmpX
        sta PPUDATA
        iny
        dex
        bne @copyChar

        lda #$FF
        sta PPUDATA

        ; score
        lda highscores,y
        cmp #$A
        bmi @scoreHighWrite
        jsr twoDigsToPPU
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

        ; levels
        lda highscores,y ; startlevel
        jsr renderByteBCD
        iny

        ; update PPUADDR for start level
        lda tmpY
        asl a
        tax
        lda highScorePpuAddrTable,x
        sta PPUADDR
        inx
        lda highScorePpuAddrTable,x
        adc #$35
        sta PPUADDR

        ; level
        lda highscores,y
        jsr renderByteBCD
        iny

        inc tmpY
        lda tmpY
        cmp #highScoreQuantity
        beq showHighScores_ret
        jmp @copyEntry

showHighScores_ret:  rts
