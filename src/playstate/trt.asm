trtCalculate:
        ldx     completedLines
        cpx     #$04
        bne     @notTetris
@addToLineCounter:
        inc     trtLineCounter
        lda     trtLineCounter
        and     #$0F
        cmp     #$0A
        bmi     @noCarry
        lda     trtLineCounter
        clc
        adc     #$06
        sta     trtLineCounter
        and     #$F0
        cmp     #$A0
        bcc     @noCarry
        lda     trtLineCounter
        and     #$0F
        sta     trtLineCounter
        inc     trtLineCounter+1
@noCarry:
        dex
        bne     @addToLineCounter
@notTetris:
        lda     #$00
        ldx     #$06
@zeroScratch:
        sta     trtLineCounter+1,x
        dex
        bne     @zeroScratch
        ldy     #$04
        lda     trtLineCounter
        sta     trtRam+2
        lda     trtLineCounter+1
        sta     trtRam+1
LFA41:  clc
        ldx     #$03
LFA44:  rol     trtRam,x
        dex
        bne     LFA44
        dey
        bne     LFA41
LFA4D:  jsr     LFADF
        lda     trtScratch+4
        cmp     trtRam
        bcc     LFA6C
        bne     LFA85
        lda     trtScratch+3
        cmp     trtRam+1
        bcc     LFA6C
        bne     LFA85
        lda     trtScratch+2
        cmp     trtRam+2
        bcs     LFA85
LFA6C:  ldx     #$03
LFA6E:  lda     trtScratch+1,x
        sta     trtRam+3,x
        dex
        bne     LFA6E
        lda     trtScratch+5
        adc     #$10
        sta     trtScratch+5
        cmp     #$A0
        bne     LFA4D
        beq     LFABD
LFA85:  ldx     #$03
LFA87:  lda     trtRam+3,x
        sta     trtScratch+1,x
        dex
        bne     LFA87
        ldy     #$04
LFA92:  asl     trtScratch+2
        rol     trtScratch+3
        rol     trtScratch+4
        dey
        bne     LFA92
LFA9E:  jsr     LFADF
        inc     trtScratch+5
        lda     trtScratch+4
        cmp     trtLineCounter+1
        bcc     LFAB6
        bne     LFABD
        lda     trtScratch+3
        cmp     trtLineCounter
        bcs     LFABD
LFAB6:  lda     trtScratch+5
        cmp     #$A0
        bne     LFA9E
LFABD:  lda     trtScratch+5
        and     #$0F
        cmp     #$0A
        bne     LFACE
        lda     trtScratch+5
        adc     #$05
        sta     trtScratch+5
LFACE:  lda     trtScratch+5
        cmp     #$01
        bne     LFADA
        lda     #$00
        sta     trtScratch+5
LFADA:
        ; lda     holdDownPoints
        ; cmp     #$02
        rts

LFADF:  lda     lines
        and     #$0F
        sta     trtScratch+1
        lda     trtScratch+2
        and     #$0F
        clc
        adc     trtScratch+1
        tax
        lda     trtScratch+2
        and     #$F0
        adc     trtBCDTable,x
        cmp     #$A0
        bcc     LFB01
        adc     #$5F
        inc     trtScratch+3
LFB01:  sta     trtScratch+2
        lda     lines
        and     #$F0
        sta     trtScratch+1
        lda     trtScratch+2
        clc
        adc     trtScratch+1
        bcc     LFB19
        inc     trtScratch+3
        adc     #$5F
LFB19:  cmp     #$A0
        bcc     LFB22
        adc     #$5F
        inc     trtScratch+3
LFB22:  sta     trtScratch+2
        lda     trtScratch+3
        clc
        adc     lines+1
        sta     trtScratch+3
        and     #$0F
        cmp     #$0A
        bcc     LFB3C
        lda     trtScratch+3
        adc     #$05
        sta     trtScratch+3
LFB3C:  lda     trtScratch+3
        cmp     #$A0
        bcc     LFB48
        adc     #$5F
        inc     trtScratch+4
LFB48:  sta     trtScratch+3
        rts

trtBCDTable:
        .byte   $00,$01,$02,$03,$04,$05,$06,$07
        .byte   $08,$09,$10,$11,$12,$13,$14,$15
        .byte   $16,$17,$18
