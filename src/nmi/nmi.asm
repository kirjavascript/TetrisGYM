nmi:    pha
        txa
        pha
        tya
        pha
        jsr render
        lda ppuScrollX
        sta PPUSCROLL
        lda ppuScrollY
        sta PPUSCROLL
        lda currentPpuCtrl
        sta PPUCTRL
        lda #$00
        sta OAMADDR
        lda #$02
        sta OAMDMA

renderComplete:
        lda sleepCounter
        beq @noSleep
        dec sleepCounter
@noSleep:

        inc frameCounter
        bne @noCarry
        inc frameCounter+1
@noCarry:

        ldx #rng_seed
        jsr generateNextPseudorandomNumber

        jsr pollControllerButtons

        lda #$00
        sta oamStagingLength
        sta lagState ; clear flag after lag frame achieved
        lda #$01
        sta verticalBlankingInterval

        pla
        tay
        tsx
        lda stack+4,x
        sta nmiReturnAddr
        pla
        tax
        pla
irq:    rti
