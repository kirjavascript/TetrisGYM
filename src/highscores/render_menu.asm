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

        ; levels
        lda tmpZ
        beq @normalLevel
        lda highscores,y
        cmp #100
        bpl @normalLevel
        tax
        lda byteToBcdTable, x
        jsr twoDigsToPPU
        jmp @levelContinue
@normalLevel:
        lda highscores,y ; startlevel
        jsr renderByteBCD
@levelContinue:
        iny

        ; update PPUADDR for start level
        lda generalCounter2
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

        inc generalCounter2
        lda generalCounter2
        cmp #highScoreQuantity
        beq showHighScores_ret
        jmp @copyEntry

showHighScores_ret:  rts
