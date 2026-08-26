displayModeText:
        lda #$00
        sta anydasFlag
; set anydasFlag
        lda disableDasFlag
        bne @anydas
        lda noWallChargeFlag
        bne @anydas
        lda entryChargeModifier
        bne @anydas
        lda palFlag
        bne @pal

; set regional differences
        ldx #NTSC_DAS
        ldy #NTSC_ARR
        bne @testAnydas
@pal:
        ldx #PAL_DAS
        ldy #PAL_ARR

; test das & arr values
@testAnydas:
        cpx dasModifier
        bne @anydas

        cpy arrModifier
        beq @notanydas
@anydas:
        jsr @notanydas
        lda gameMode
        cmp #3
        bne @notMenu
        stagePatch menuAnydasPatch
        jmp render_mode_queue
@notMenu:
        lda gameModeState
        bne @ret
        stagePatch gameAnydasPatch
        jmp render_mode_queue

@notanydas:
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
@startLoop:
        ldy #6
@writeChar:
        lda modeText-6, x
        sta PPUDATA
        inx
        dey
        bne @writeChar

; cover TYPE with seed if seeded b type
        lda practiseType
        cmp #MODE_TYPEB
        bne @ret
        lda typeBSeedFlag
        beq @ret
        lda tmp1
        sta PPUADDR
        lda tmp2
        clc
        adc #2
        sta PPUADDR
        lda b_seed_input
        jsr twoDigsToPPU
        lda b_seed_input+1
        jsr twoDigsToPPU
@ret:
        rts

patchSeed:
        ; skip if not seeded
        lda seedEnabled
        beq @menuOnlyItems
        lda seededPieces
        beq @menuOnlyItems
        sty PPUADDR
        stx PPUADDR

        lda set_seed_input
        jsr twoDigsToPPU
        lda set_seed_input+1
        jsr twoDigsToPPU
        lda set_seed_input+2
        jsr twoDigsToPPU
        lda gameMode
        cmp #3
        bne @notMenu
        stagePatch menuSeedPatch
        jsr render_mode_queue
        jmp @menuOnlyItems
@notMenu:
        lda gameModeState
        bne @notVits
        stagePatch gameSeedPatch
        jmp render_mode_queue
@menuOnlyItems:

        lda gameMode
        cmp #3
        bne @notVits

        jsr drawCrashMode

        lda headStartFlag
        beq @notHeadStart
        stagePatch menuHeadStartPatch
@notHeadStart:
        lda sxtoklFlag
        beq @notSxtokl
        stagePatch menuSxtoklPatch
@notSxtokl:
        lda teppozFlag
        beq @notTeppoz
        stagePatch menuTeppozPatch
@notTeppoz:
        lda palpepFlag
        beq @notPalpep
        stagePatch menuPalpepPatch
@notPalpep:
        lda dasOnlyFlag
        beq @notDasOnly
        stagePatch menuDasOnlyPatch
@notDasOnly:
        lda vitsScoreFlag
        beq @notVits
        stagePatch menuVitsPatch
@notVits:
        jmp render_mode_queue


; this and the linecap display can be combined, with the string lists from menudata.asm used
crashStrings:
    .word STR_SHOW
    .word STR_TOP
    .word STR_CRASH
drawCrashMode:
    lda crashModifier
    beq @ret
    ldy #$21
    sty PPUADDR
    ldy #$35
    sty PPUADDR
    asl
    tay
    ; use offset, crashModifier will be 1,2 or 3, never 0
    ldx crashStrings-1,y
    lda crashStrings-2,y
    tay
    jsr stringBackgroundXY
    ldy strictFlag
    beq @ret
    ldy #$FF
    sty PPUDATA
    ldy #'S'
    sty PPUDATA
@ret:
    rts

menuSeedPatch:
    .byte $20,$B5,$0,$3B
    .byte $20,$BC,$0,$3C
    .byte $20,$D5,$7,$3D,$3E,$3E,$3E,$3E,$3E,$3E,$3F
    .byte $0

gameSeedPatch:
    .byte $20,$A2,$0,$35
    .byte $20,$A9,$0,$36
    .byte $20,$C2,$7,$76,$37,$37,$37,$37,$37,$37,$77
    .byte $0

menuAnydasPatch:
    .byte $20,$55,$7,$38,$39,$39,$39,$39,$39,$39,$3A
    .byte $20,$75,$7,$3B,"A","N","Y","D","A","S",$3C
    .byte $0

gameAnydasPatch:
    .byte $20,$42,$7,$74,$34,$34,$34,$34,$34,$34,$75
    .byte $20,$62,$7,$35,"A","N","Y","D","A","S",$36
    .byte $0

menuSxtoklPatch:
    .byte $20,$63,$5,"SXTOKL"
    .byte $0
menuPalpepPatch:
    .byte $20,$83,$5,"PALPEP"
    .byte $0
menuTeppozPatch:
    .byte $20,$A3,$5,"TEPPOZ"
    .byte $0
menuDasOnlyPatch:
    .byte $20,$C3,$7,"DAS",$FF,"ONLY"
    .byte $0
menuHeadStartPatch:
    .byte $20,$E3,$3,"HEAD"
    .byte $21,$03,$4,"START"
    .byte $0
menuVitsPatch:
    .byte $21,$23,$3,"VITS"
    .byte $0
