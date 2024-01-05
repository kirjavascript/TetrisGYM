.macro changeCHRBanksMMC1
        RESET_MMC1
        sta MMC1_CHR0
        lsr a
        sta MMC1_CHR0
        lsr a
        sta MMC1_CHR0
        lsr a
        sta MMC1_CHR0
        lsr a
        sta MMC1_CHR0
        inc generalCounter
        lda generalCounter
        RESET_MMC1
        sta MMC1_CHR1
        lsr a
        sta MMC1_CHR1
        lsr a
        sta MMC1_CHR1
        lsr a
        sta MMC1_CHR1
        lsr a
        sta MMC1_CHR1
.endmacro

.macro changeCHRBanksCNRom
        lsr
        tax
        sta cnromBanks,x
.endmacro

_setMMC1Control:
        RESET_MMC1
        sta MMC1_Control
        lsr a
        sta MMC1_Control
        lsr a
        sta MMC1_Control
        lsr a
        sta MMC1_Control
        lsr a
        sta MMC1_Control
        rts

changeCHRBanks:
        ; accum should be 0 or 2 (CHRBankset0 or CHRBankset1)
        sta     generalCounter

; autodetect
.if INES_MAPPER = 255
        ldx     mapperId
        beq     @cnrom
        changeCHRBanksMMC1
        rts
@cnrom:
        changeCHRBanksCNRom

; NROM (no action)
.elseif INES_MAPPER = 0

; MMC1
.elseif INES_MAPPER = 1
        changeCHRBanksMMC1

; CNROM
.elseif INES_MAPPER = 3
        changeCHRBanksCNRom

; MMC3
.elseif INES_MAPPER = 4
        asl a
        asl a
        ldx #$00
        stx MMC3_BANK_SELECT
        sta MMC3_BANK_DATA
        inx
        clc
        adc #$02
        stx MMC3_BANK_SELECT
        sta MMC3_BANK_DATA
        inc generalCounter
        lda generalCounter
        asl a
        asl a
        ldx #$02
        stx MMC3_BANK_SELECT
        sta MMC3_BANK_DATA
        inx
        clc
        adc #$01
        stx MMC3_BANK_SELECT
        sta MMC3_BANK_DATA
        inx
        clc
        adc #$01
        stx MMC3_BANK_SELECT
        sta MMC3_BANK_DATA
        inx
        clc
        adc #$01
        stx MMC3_BANK_SELECT
        sta MMC3_BANK_DATA

; MMC5
.elseif INES_MAPPER = 5
        sta MMC5_CHR_BANK0
        inc generalCounter
        lda generalCounter
        sta MMC5_CHR_BANK1
.endif
        rts


setHorizontalMirroring:
; autodetect
.if INES_MAPPER = 255
        lda mapperId
        beq @cnrom
        lda #%10011
        jmp _setMMC1Control
@cnrom:

; NROM (no action)
.elseif INES_MAPPER = 0

; MMC1
.elseif INES_MAPPER = 1
        lda #%10011
        jmp _setMMC1Control

; CNROM (no action)
.elseif INES_MAPPER = 3

; MMC3
.elseif INES_MAPPER = 4
        lda #$1
        sta MMC3_MIRRORING

; MMC5
.elseif INES_MAPPER = 5
        lda #$50
        sta MMC5_NT_MAPPING
.endif
        rts

setVerticalMirroring:
; Unused except during mapper detect for INES_MAPPER 255

; autodetect
.if INES_MAPPER = 255
        lda mapperId
        beq @cnrom
        lda #%10010
        jmp _setMMC1Control
@cnrom:

; NROM (no action)
.elseif INES_MAPPER = 0

; MMC1
.elseif INES_MAPPER = 1
        lda #%10010
        jmp _setMMC1Control

; CNROM (no action)
.elseif INES_MAPPER = 3

; MMC3
.elseif INES_MAPPER = 4
        lda #$0
        sta MMC3_MIRRORING

; MMC5
.elseif INES_MAPPER = 5
        lda #$44
        sta MMC5_NT_MAPPING
.endif
        rts

.if INES_MAPPER = 3 .or INES_MAPPER = 255
; bus conflict workaround
cnromBanks:
        .byte $00,$01
.endif
