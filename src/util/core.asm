clearPlayfield:
        lda #EMPTY_TILE
        ldx #$C8
@loop:
        sta $0400, x
        dex
        bne @loop
        rts

clearNametable:
        lda #$20
        sta PPUADDR
        lda #$0
        sta PPUADDR
        lda #EMPTY_TILE
        ldx #4
        ldy #$BF
@clearTile:
        sta PPUDATA
        dey
        bne @clearTile
        sta PPUDATA
        ldy #$FF
        dex
        bne @clearTile
        rts

drawBlackBGPalette:
        lda #$3F
        sta PPUADDR
        lda #$0
        sta PPUADDR
        ldx #$10
@loadPaletteLoop:
        lda #$F
        sta PPUDATA
        dex
        bne @loadPaletteLoop
        rts

resetScroll:
        lda #0
        sta ppuScrollX
        sta PPUSCROLL
        sta ppuScrollY
        sta PPUSCROLL
        rts

random10:
        ldx #rng_seed
        jsr generateNextPseudorandomNumber5x
        lda rng_seed
        and #$0F
        cmp #$0A
        bpl random10
        rts

; canon is waitForVerticalBlankingInterval
updateAudioWaitForNmiAndResetOamStaging:
        jsr updateAudio_jmp
        lda #$00
        sta verticalBlankingInterval
.if ED2NTC
        jsr sendNTCData
.endif
        nop
@checkForNmi:
        lda verticalBlankingInterval
        beq @checkForNmi

resetOAMStaging:
; Hide a sprite by moving it down offscreen, by writing any values between #$EF-#$FF here.
; Sprites are never displayed on the first line of the picture, and it is impossible to place
; a sprite partially off the top of the screen.
; https://www.nesdev.org/wiki/PPU_OAM
        ldx #$00
        lda #$FF
@hideY:
        sta oamStaging,x
        inx
        inx
        inx
        inx
        bne @hideY
        rts

updateAudioAndWaitForNmi:
        jsr updateAudio_jmp
        lda #$00
        sta verticalBlankingInterval
.if ED2NTC
        jsr sendNTCData
.endif
        nop
@checkForNmi:
        lda verticalBlankingInterval
        beq @checkForNmi
        rts

updateAudioWaitForNmiAndDisablePpuRendering:
        jsr updateAudioAndWaitForNmi
        lda currentPpuMask
        and #$E1
_updatePpuMask:
        sta PPUMASK
        sta currentPpuMask
        rts

updateAudioWaitForNmiAndEnablePpuRendering:
        jsr updateAudioAndWaitForNmi
        jsr copyCurrentScrollAndCtrlToPPU
        lda currentPpuMask
        ora #$1E
        bne _updatePpuMask
waitForVBlankAndEnableNmi:
        lda PPUSTATUS
        and #$80
        bne waitForVBlankAndEnableNmi
        lda currentPpuCtrl
        ora #$80
        bne _updatePpuCtrl
disableNmi:
        lda currentPpuCtrl
        and #$7F
_updatePpuCtrl:
        sta PPUCTRL
        sta currentPpuCtrl
        rts

copyCurrentScrollAndCtrlToPPU:
        lda ppuScrollX
        sta PPUSCROLL
        lda ppuScrollY
        sta PPUSCROLL
        lda currentPpuCtrl
        sta PPUCTRL
        rts

bulkCopyToPpu:
        jsr copyAddrAtReturnAddressToTmp_incrReturnAddrBy2
        jmp copyToPpu

LAA9E:  pha
        sta PPUADDR
        iny
        lda (tmp1),y
        sta PPUADDR
        iny
        lda (tmp1),y
        asl a
        pha
        lda currentPpuCtrl
        ora #$04
        bcs LAAB5
        and #$FB
LAAB5:  sta PPUCTRL
        sta currentPpuCtrl
        pla
        asl a
        php
        bcc LAAC2
        ora #$02
        iny
LAAC2:  plp
        clc
        bne LAAC7
        sec
LAAC7:  ror a
        lsr a
        tax
LAACA:  bcs LAACD
        iny
LAACD:  lda (tmp1),y
        sta PPUDATA
        dex
        bne LAACA
        pla
        cmp #$3F
        bne LAAE6
        sta PPUADDR
        stx PPUADDR
        stx PPUADDR
        stx PPUADDR
LAAE6:  sec
        tya
        adc tmp1
        sta tmp1
        lda #$00
        adc tmp2
        sta tmp2
; Address to read from stored in tmp1/2
copyToPpu:
        ldx PPUSTATUS
        ldy #$00
        lda (tmp1),y
        bpl LAAFC
        rts

LAAFC:  cmp #$60
        bne LAB0A
        pla
        sta tmp2
        pla
        sta tmp1
        ldy #$02
        bne LAAE6
LAB0A:  cmp #$4C
        bne LAA9E
        lda tmp1
        pha
        lda tmp2
        pha
        iny
        lda (tmp1),y
        tax
        iny
        lda (tmp1),y
        sta tmp2
        stx tmp1
        bcs copyToPpu
copyAddrAtReturnAddressToTmp_incrReturnAddrBy2:
        tsx
        lda stack+3,x
        sta tmpBulkCopyToPpuReturnAddr
        lda stack+4,x
        sta tmpBulkCopyToPpuReturnAddr+1
        ldy #$01
        lda (tmpBulkCopyToPpuReturnAddr),y
        sta tmp1
        iny
        lda (tmpBulkCopyToPpuReturnAddr),y
        sta tmp2
        clc
        lda #$02
        adc tmpBulkCopyToPpuReturnAddr
        sta stack+3,x
        lda #$00
        adc tmpBulkCopyToPpuReturnAddr+1
        sta stack+4,x
        rts

;reg x: zeropage addr of seed
generateNextPseudorandomNumber5x:
        jsr generateNextPseudorandomNumber
generateNextPseudorandomNumber4x:
        jsr generateNextPseudorandomNumber
generateNextPseudorandomNumber3x:
        jsr generateNextPseudorandomNumber
generateNextPseudorandomNumber2x:
        jsr generateNextPseudorandomNumber
generateNextPseudorandomNumber:
        lda tmp1,x
        eor tmp2,x
        lsr
        lsr
        ror tmp1,x
        ror tmp2,x
        lda oneThirdPRNG
        sbc #$00
        bpl @noReset
        lda #$2
@noReset:
        sta oneThirdPRNG
        rts

; canon is initializeOAM
copyOamStagingToOam:
        lda #$00
        sta OAMADDR
        lda #$02
        sta OAMDMA
        rts


; reg a: value; reg x: start page; reg y: end page (inclusive)
memset_page:
        pha
        txa
        sty tmp2
        clc
        sbc tmp2
        tax
        pla
        ldy #$00
        sty tmp1
@setByte:
        sta (tmp1),y
        dey
        bne @setByte
        dec tmp2
        inx
        bne @setByte
        rts

switch_s_plus_2a:
        asl a
        tay
        iny
        pla
        sta switchTmp1
        pla
        sta switchTmp2
        lda (switchTmp1),y
        tax
        iny
        lda (switchTmp1),y
        sta switchTmp2
        stx switchTmp1
        jmp (switchTmp1)

        sei
        RESET_MMC1
        lda #$1A
        jsr setMMC1Control
        rts

setMMC1Control:
.if INES_MAPPER = 1
        sta MMC1_Control
        lsr a
        sta MMC1_Control
        lsr a
        sta MMC1_Control
        lsr a
        sta MMC1_Control
        lsr a
        sta MMC1_Control
.endif
        rts

changeCHRBank0:
.if INES_MAPPER = 1
        sta MMC1_CHR0
        lsr a
        sta MMC1_CHR0
        lsr a
        sta MMC1_CHR0
        lsr a
        sta MMC1_CHR0
        lsr a
        sta MMC1_CHR0
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
.elseif INES_MAPPER = 5
        sta MMC5_CHR_BANK0
.endif
        rts

changeCHRBank1:
.if INES_MAPPER = 1
        sta MMC1_CHR1
        lsr a
        sta MMC1_CHR1
        lsr a
        sta MMC1_CHR1
        lsr a
        sta MMC1_CHR1
        lsr a
        sta MMC1_CHR1
.elseif INES_MAPPER = 4
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
.elseif INES_MAPPER = 5
        sta MMC5_CHR_BANK1
.endif
        rts

changePRGBank:
.if INES_MAPPER = 1
        sta MMC1_PRG
        lsr a
        sta MMC1_PRG
        lsr a
        sta MMC1_PRG
        lsr a
        sta MMC1_PRG
        lsr a
        sta MMC1_PRG
.endif
        rts
