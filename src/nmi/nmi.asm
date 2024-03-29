nmi:    pha
        txa
        pha
        tya
        pha
; tmp1, tmp2, tmp3, tmpX, tmpY, and tmpZ are shared
        ldx #$05
@backupSharedVars:
        lda tmp1,x
        pha
        dex
        bpl @backupSharedVars

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
        jsr generateNextPseudorandomNumber
        jsr copyCurrentScrollAndCtrlToPPU
        jsr pollControllerButtons
        lda #$00
        sta lagState ; clear flag after lag frame achieved
.if KEYBOARD
; Read Family BASIC Keyboard
        jsr pollKeyboard
.endif
        lda #$01
        sta verticalBlankingInterval

        ; restore shared variables
        ldx #$00
@restoreShared:
        pla
        sta tmp1,x
        inx
        cpx #$06
        bne @restoreShared

        pla
        tay
        tsx
        lda stack+4,x
        sta nmiReturnAddr
        pla
        tax
        pla
irq:    rti
