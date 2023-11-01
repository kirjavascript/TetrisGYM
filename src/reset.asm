; incremented to reset MMC1 reg
reset:  
.if INES_MAPPER = 4
        ldy #$00
        ldx #$06
        stx MMC3_BANK_SELECT
        sty MMC3_BANK_DATA
        inx
        iny
        stx MMC3_BANK_SELECT
        sty MMC3_BANK_DATA
        lda #$00
        stx MMC3_BANK_SELECT
.endif
        cld
        sei
        ldx #$00
        stx PPUCTRL
        stx PPUMASK
@vsyncWait1:
        lda PPUSTATUS
        bpl @vsyncWait1
@vsyncWait2:
        lda PPUSTATUS
        bpl @vsyncWait2
        dex
        txs
.if INES_MAPPER <> 4
        inc reset
.endif
        lda #$10
        jsr setMMC1Control
        lda #$00
        jsr changeCHRBank0
        lda #$00
        jsr changeCHRBank1
        lda #$00
        jsr changePRGBank
        jmp initRam

MMC1_PRG:
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00
        .byte   $00
