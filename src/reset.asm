; incremented to reset MMC1 reg
reset:  cld
        sei
        ldx #$00
        stx PPUCTRL
        stx PPUMASK

        ; init code from https://www.nesdev.org/wiki/Init_code
        bit PPUSTATUS
@vsyncWait1:
        bit PPUSTATUS
        bpl @vsyncWait1

        ; zero out pages 0 through 6 while waiting
        txa
@clrmem:
        sta $0000,x
        sta $0100,x
        sta $0200,x
        sta $0300,x
        sta $0400,x
        sta $0500,x
        sta $0600,x
        inx
        bne @clrmem

        bit PPUSTATUS
@vsyncWait2:
        bit PPUSTATUS
        bpl @vsyncWait2

        dex ; $FF for stack pointer
        txs
        jsr mapperInit
        jsr setHorizontalMirroring
        lda #CHRBankSet0
        jsr changeCHRBanks
        jmp initRam

.macro setMMC1PRG
        RESET_MMC1
        lda #$00
        sta MMC1_PRG
        lsr a
        sta MMC1_PRG
        lsr a
        sta MMC1_PRG
        lsr a
        sta MMC1_PRG
        lsr a
        sta MMC1_PRG
.endmacro

mapperInit:
; autodetect
.if INES_MAPPER = 255
        setMMC1PRG ; initialize mmc1 just in case
        ; cnrom can pass one of these tests but not both.
        ; Start with the one it's supposed to fail.
        jsr testVerticalMirroring
        bne not_mmc1
        jsr testHorizontalMirroring
        bne not_mmc1
        inc mapperId ; 1 for MMC1, otherwise 0 for CNROM
not_mmc1:

; MMC1
.elseif INES_MAPPER = 1
        setMMC1PRG

; CNROM (no init)
.elseif INES_MAPPER = 3

; MMC3
.elseif INES_MAPPER = 4
; https://www.nesdev.org/wiki/MMC3
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

; MMC5
.elseif INES_MAPPER = 5
; https://www.nesdev.org/wiki/MMC5
        ldx #$00
        stx MMC5_PRG_MODE ; 0: 1 32Kb bank
        inx
        stx MMC5_CHR_MODE ; 1: 4kb CHR pages
        stx MMC5_RAM_PROTECT2 ; 1: enable PRG RAM
        inx
        stx MMC5_RAM_PROTECT1 ; 2: enable PRG RAM
.endif
        rts
