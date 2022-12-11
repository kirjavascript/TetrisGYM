playState_spawnNextTetrimino:
        lda vramRow
        cmp #$20
        bmi @ret

.if PRACTISE_MODE
        lda spawnDelay
        beq @notDelaying
        dec spawnDelay
        jmp @ret
.endif

@notDelaying:
        lda #$01
        sta playState

.if PRACTISE_MODE
        ; savestate patch
        lda saveStateDirty
        beq @noSaveState
        lda #0
        sta saveStateDirty
        rts
@noSaveState:
.endif

        jsr hzStart
        lda #$00
        sta fallTimer
        sta tetriminoY
        lda #$05
        sta tetriminoX
        ldx nextPiece
        lda spawnOrientationFromOrientation,x
        sta currentPiece
        jsr incrementPieceStat
        jsr chooseNextTetrimino
        sta nextPiece
@resetDownHold:
        lda #$00
        sta autorepeatY
@ret:   rts

chooseNextTetrimino:
        jmp pickTetriminoPre

pickRandomTetrimino:
        inc spawnCount
        lda rng_seed
        clc
        adc spawnCount
        and #$07
        cmp #$07
        beq @invalidIndex
        tax
        lda spawnTable,x
        cmp spawnID
        bne useNewSpawnID
@invalidIndex:
        ldx #rng_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        lda rng_seed
        and #$07
        clc
        adc spawnID
L992A:  cmp #$07
        bcc L9934
        sec
        sbc #$07
        jmp L992A

L9934:  tax
        lda spawnTable,x
useNewSpawnID:
        sta spawnID
        jsr pickTetriminoPost
        rts

pickTetriminoPre:
        lda practiseType
        cmp #MODE_TSPINS
        beq pickTetriminoT
        lda practiseType
        cmp #MODE_SEED
        beq pickTetriminoSeed
        lda practiseType
        cmp #MODE_TAPQTY
        beq pickTetriminoLongbar
        lda practiseType
        cmp #MODE_TAP
        beq pickTetriminoQuickTap
        lda practiseType
        cmp #MODE_PRESETS
        beq pickTetriminoPreset
        jmp pickRandomTetrimino
		
pickTetriminoQuickTap:
		lda quicktapAllPiecesFlag
		cmp #$00
		beq pickTetriminoLongbar
		bne pickTetriminoSeed
		rts
		
pickTetriminoT:
        lda #$2
        sta spawnID
        rts

pickTetriminoLongbar:
        lda #$12
        sta spawnID
        rts

pickTetriminoSeed:
        jsr setSeedNextRNG

        ; SPSv3

        lda set_seed_input+2
        ror
        ror
        ror
        ror
        and #$F
        ; v3
        cmp #0
        bne @notZero
        lda #$10
@notZero:
        ; v2
        ; cmp #0
        ; beq @compatMode

        adc #1
        sta tmp3 ; step + 1 in tmp3
@loop:
        jsr setSeedNextRNG
        dec tmp3
        lda tmp3
        bne @loop
@compatMode:

        inc set_seed+2 ; 'spawnCount'
        lda set_seed
        clc
        adc set_seed+2
        and #$07
        cmp #$07
        beq @invalidIndex
        tax
        lda spawnTable,x
        cmp spawnID
        bne @useNewSpawnID
@invalidIndex:
        ldx #set_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        lda set_seed
        and #$07
        clc
        adc spawnID
@L992A:
        cmp #$07
        bcc @L9934
        sec
        sbc #$07
        jmp @L992A

@L9934:
        tax
        lda spawnTable,x
@useNewSpawnID:
        sta spawnID
        rts

setSeedNextRNG:
        ldx #set_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        rts

pickTetriminoPreset:
presetBitmask := tmp2
@start:
        inc presetIndex
        lda presetIndex
        and #$07
        cmp #$07
        beq pickTetriminoPreset
        sta presetIndex
        tax ; RNG in x
        ; store piece bitmask
        ldy presetModifier
        lda presets, y ; offset of preset in A
        tay
        lda presets, y
        sta presetBitmask
        ; create bit to compare with mask from RNG
        lda #1
@shiftBit:
        cpx #0
        beq @doneShifting
        asl
        dex
        jmp @shiftBit
@doneShifting:
        and presetBitmask
        bne @start
        ldx presetIndex ; restore RNG
        lda spawnTable,x
        sta spawnID
        rts

pickTetriminoPost:
        lda practiseType
        cmp #MODE_DROUGHT
        beq pickTetriminoDrought
        lda spawnID ; restore A
        rts

pickTetriminoDrought:
        lda spawnID ; restore A
        cmp #$12
        bne @droughtDone
        lda rng_seed+1
        and #$F
        adc #1 ; always adds 1 so code continues as normal if droughtModifier is 0
        cmp droughtModifier
        bmi @pickRando
        lda spawnID ; restore A
@droughtDone:
        rts
@pickRando:
        jmp pickRandomTetrimino
