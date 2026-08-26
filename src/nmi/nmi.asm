nmi:    pha
        lda renderMode
        beq restoreA
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
        ldx #b_seed
        jsr generateNextPseudorandomNumber

        jsr pollControllerButtons

        ; advance game timer
        lda gameTimerStop
        bne nmiFinish
        inc gameTimer+1
        bne nmiFinish
        inc gameTimer
nmiFinish:
        lda #$00
        sta oamStagingLength
        sta lagState ; clear flag after lag frame achieved
        tsx
        lda stack+5,x
        sta nmiReturnAddr
        pla
        tay
        pla
        tax
restoreA:
        lda #$01
        sta verticalBlankingInterval
        pla
irq:    rti
