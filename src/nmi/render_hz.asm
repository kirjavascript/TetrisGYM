renderCTWCDAS:
        lda outOfDateRenderFlags
        and #$EF
        sta outOfDateRenderFlags
        lda #$27
        sta PPUADDR
        lda #$18
        sta PPUADDR
        lda hzResult
        jsr twoDigsToPPU
        lda #$27
        sta PPUADDR
        lda #$1b
        sta PPUADDR
        lda hzResult+1
        jsr twoDigsToPPU
        lda #$3F
        sta PPUADDR
        lda #$07
        sta PPUADDR
        lda hzPalette
        sta PPUDATA
        lda #$27
        sta PPUADDR
        lda #$3c
        sta PPUADDR
        lda hzTapCounter
        sta PPUDATA
        rts

renderHz:
        ; only set at game start and when player is controlling a piece
        ; during which, no other tile updates are happening
        ; this is pretty expensive and uses up $7 PPU tile writes and 1 palette write

        ; delay

        lda #$22
        sta PPUADDR
        lda #$68
        sta PPUADDR
        lda hzSpawnDelay
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
