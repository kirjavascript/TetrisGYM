renderHz:
        ; only set at game start and when player is controlling a piece
        ; during which, no other tile updates are happening
        ; this is pretty expensive and uses up $8 PPU tile writes and 1 palette write

        ; delay

        lda #$22
        sta PPUADDR
        lda #$67
        sta PPUADDR
        ldx #$24 ; minus sign
        lda hzSpawnDelay
        and #$80
        bne @isNegative
        ldx #$FF ; blank tile
@isNegative:
        stx PPUDATA
        lda hzSpawnDelay
        and #$7F ; clear sign flag
        sta PPUDATA

renderHzSpeedTest:

        ; palette

        lda #$3F
        sta PPUADDR
        lda #$07
        sta PPUADDR
        lda hzPalette
        sta PPUDATA

        ; hz

        lda #$21
        sta PPUADDR
        lda #$A3
        sta PPUADDR
        lda hzResult
        jsr twoDigsToPPU
        lda #$21
        sta PPUADDR
        lda #$A6
        sta PPUADDR
        lda hzResult+1
        jsr twoDigsToPPU

        ; taps

        lda #$22
        sta PPUADDR
        lda #$28
        sta PPUADDR
        lda hzTapCounter
        ; and #$f
        sta PPUDATA

        ; direction

        lda #$22
        sta PPUADDR
        lda #$A8
        sta PPUADDR
        lda hzTapDirection
        clc
        adc #$D6
        sta PPUDATA
        rts
