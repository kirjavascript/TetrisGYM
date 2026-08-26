checkIfSeeded:
        lda #$00
        sta seededPieces
        lda seedEnabled
        beq @noSeed
        lda practiseType
        cmp #MODE_TSPINS
        beq @noSeed
        cmp #MODE_TAPQTY
        beq @noSeed
        cmp #MODE_TAP
        beq @noSeed
        cmp #MODE_PRESETS
        beq @noSeed
        inc seededPieces
@noSeed:
        rts
