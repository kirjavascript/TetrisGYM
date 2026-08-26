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
        ldx #menuRAMLength
@loop:
        sta menuRAM-1, x
        dex
        bne @loop

        jsr resetScores

.if SAVE_HIGHSCORES
        jsr detectSRAM
        beq @noSRAM
        jsr checkSavedInit
        jsr copyScoresFromSRAM
        jsr copyVarsFromSRAM
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

        lda #INITIAL_CUSTOM_LEVEL
        sta customLevel

@continueWarmBootInit:
        ldx #$89
        stx rng_seed
        dex
        stx rng_seed+1
        ; only one byte needed to init b_seed
        ; b_seed initialized to add entropy for oneThirdPRNG
        ; b_seed is overwritten at the beginning of b games with either seed or rng_seed
        stx b_seed+1
        jsr LE006
        jsr updateAudio2
        lda #$00
        sta gameModeState
        sta gameMode
        lda #$00
        sta frameCounter+1
        sta frameCounter

        jsr pollControllerButtons
        ; hold select to start in qual mode
        lda heldButtons_player1
        and #BUTTON_SELECT
        beq @nonQualBoot
        lda #1
        sta qualFlag
@nonQualBoot:
        ldy #0
        sty classicLevel
