nmi:    pha
        txa
        pha
        tya
        pha
        lda #$00
        sta oamStagingLength
        jsr render
        dec sleepCounter
        lda sleepCounter
        cmp #$FF
        bne @jumpOverIncrement
        inc sleepCounter
@jumpOverIncrement:
        jsr copyOamStagingToOam
        lda frameCounter
        clc
        adc #$01
        sta frameCounter
        lda #$00
        adc frameCounter+1
        sta frameCounter+1
        ldx #rng_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        jsr copyCurrentScrollAndCtrlToPPU
        jsr pollControllerButtons
.if KEYBOARD
; Read Family BASIC Keyboard
        jsr pollKeyboard
.endif
        lda #$01
        sta verticalBlankingInterval
        pla
        tay
        pla
        tax
        pla
irq:    rti
