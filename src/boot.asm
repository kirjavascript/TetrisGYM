        ; $0000 through $06FF cleared during vblank wait
        lda initMagic
        cmp #$54
        bne @coldBoot
        lda initMagic+1
        cmp #$2D
        bne @coldBoot
        lda initMagic+2
        cmp #$47
        bne @coldBoot
        lda initMagic+3
        cmp #$59
        bne @coldBoot
        lda initMagic+4
        cmp #$4D
        bne @coldBoot
        jmp @continueWarmBootInit

@coldBoot:
        ; zero out config memory
        lda #$0
        ldx #$A0
@loop:
        dex
        sta menuRAM, x
        ; cpx #0 ; dex sets z flag
        bne @loop

        ; default pace to A
        lda #$A
        sta paceModifier

        lda #$10
        sta dasModifier

        lda #INITIAL_LINECAP_LEVEL
        sta linecapLevel
        lda #INITIAL_LINECAP_LINES
        sta linecapLines
        lda #INITIAL_LINECAP_LINES_1
        sta linecapLines+1

        jsr resetScores

.if SAVE_HIGHSCORES
        jsr detectSRAM
        beq @noSRAM
        jsr checkSavedInit
        jsr copyScoresFromSRAM
@noSRAM:
.endif

        lda #$54
        sta initMagic
        lda #$2D
        sta initMagic+1
        lda #$47
        sta initMagic+2
        lda #$59
        sta initMagic+3
        lda #$4D
        sta initMagic+4
@continueWarmBootInit:
        ldx #$89
        stx rng_seed
        dex
        stx rng_seed+1
        ldy #$00
        sty PPUSCROLL
        ldy #$00
        sty PPUSCROLL
        lda #$90
        sta currentPpuCtrl
        sta PPUCTRL
        lda #$06
        sta PPUMASK
        jsr LE006
        jsr updateAudio2
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
        jsr drawBlackBGPalette
        ; instead of clearing vram like the original, blank out the palette
        lda #$EF
        ldx #$04
        ldy #$04 ; used to be 5, but we dont need to clear 2p playfield
        jsr memset_page
        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda #$00
        sta gameModeState
        sta gameMode
        lda #$00
        sta frameCounter+1
