displayModeText:

        lda #$00
        sta anydasFlag
; set anydasFlag
        lda entryDelayModifier
        bne @anydas
        lda palFlag
        bne @pal
        ldx #NTSC_DAS
        ldy #NTSC_ARR
        bne @testAnydas
@pal:
        ldx #PAL_DAS
        ldy #PAL_ARR
@testAnydas:
        cpx dasModifier
        bne @anydas

        cpy arrModifier
        bne @anydas
        beq @notanydas
@anydas:
        inc anydasFlag
@notanydas:
        ldx #MODE_ANYDAS*6
        lda anydasFlag
        bne @drawMode
        ; practiseType * 6
        lda practiseType
        asl
        sta generalCounter
        asl
        clc
        adc generalCounter
        tax
@drawMode:
        lda tmp1
        sta PPUADDR
        lda tmp2
        sta PPUADDR

        ldy #6
@writeChar:
        lda modeText-6, x
        sta PPUDATA
        inx
        dey
        bne @writeChar
        rts

patchSeed:
        ; skip if not seeded
        lda seedEnabled
        beq @ret
        lda seededPieces
        beq @ret
        sty PPUADDR
        stx PPUADDR
        lda gameMode
        cmp #3
        beq @setupGameTiles

; hack
        lda #$35
        sta PPUDATA
        lda set_seed_input
        jsr twoDigsToPPU
        lda set_seed_input+1
        jsr twoDigsToPPU
        lda set_seed_input+2
        jsr twoDigsToPPU
        lda #$36
        jmp @nextRow

@setupGameTiles:
        lda #$3B
        sta PPUDATA
        lda set_seed_input
        jsr twoDigsToPPU
        lda set_seed_input+1
        jsr twoDigsToPPU
        lda set_seed_input+2
        jsr twoDigsToPPU
        lda #$3C

@nextRow:
        sta PPUDATA
        sty PPUADDR
        txa
        clc
        adc #$20
        sta PPUADDR

        ldx #$07
        lda gameMode
        cmp #3
        beq @menuBoxLoop
@gameBoxLoop:
        lda bottomOfBoxGame,x
        sta PPUDATA
        dex
        bpl @gameBoxLoop
        rts


@menuBoxLoop:
        lda bottomOfBoxMenu,x
        sta PPUDATA
        dex
        bpl @menuBoxLoop
@ret:   rts


bottomOfBoxMenu:
        .byte $3F,$3E,$3E,$3E,$3E,$3E,$3E,$3D
bottomOfBoxGame:
        .byte $77,$37,$37,$37,$37,$37,$37,$76
