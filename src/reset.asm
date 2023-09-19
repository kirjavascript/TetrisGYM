; incremented to reset MMC1 reg
reset:  cld
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
.if INES_MAPPER = 1
        inc reset
.elseif INES_MAPPER = 4 
        jsr mmc3Init
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

.if INES_MAPPER = 4
; https://www.nesdev.org/wiki/MMC3
mmc3Init:
        ; 110: R6: Select 8 KB PRG ROM bank at $8000-$9FFF (or $C000-$DFFF)
        ldx     #$06
        ldy     #$00
        stx     MMC3_BANK_SELECT
        sty     MMC3_BANK_DATA

        ; 111: R7: Select 8 KB PRG ROM bank at $A000-$BFFF
        inx
        iny
        stx     MMC3_BANK_SELECT
        sty     MMC3_BANK_DATA
        lda     #$80 ; enable PRG RAM
        sta     MMC3_PRG_RAM
        rts
.endif


MMC1_PRG:
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00
        .byte   $00
