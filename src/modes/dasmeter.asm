Y_COORDINATE = 219
X_START = 100
stageDasMeterSprites:
@dasValue = generalCounter
@tile = generalCounter2
@redCompare = generalCounter3
@orangeCompare = generalCounter4
@dasMax = generalCounter5
@halfTile = tmpX
    lda #0
    sta @halfTile
    lda dasMeterFlag
    beq @noMeter
    lda playState
    bne @meter
@noMeter:
    rts
@meter:
    lda autorepeatX
    bpl @notNegative
    lda #0
@notNegative:
    sta @dasValue

    lda dasModifier
    sta @dasMax

    cmp #17
    bcc @setCompare

; half values for 17 or more (max 30 currently)
    lsr @dasMax
    lsr @dasValue

@setCompare:
    lda @dasMax
    lsr
    lsr
    sta @orangeCompare
    inc @orangeCompare ; 5 when ntsc vanilla
    lsr
    sta @redCompare
    inc @redCompare ; 3 when ntsc vanilla

    lda #$CE
    sta @tile
    lda @dasValue
    lsr
    sta @dasValue
    rol @halfTile
    cmp @orangeCompare
    bcs @stageSprites
    dec @tile
    cmp @redCompare
    bcs @stageSprites
    dec @tile
@stageSprites:
    ldx oamStagingLength
    ldy #X_START
    lda @dasValue
    beq @drawHalfTile
    cmp #9
    bcc @loop
    lda #8
    sta @dasValue
@loop:
    lda @tile
    sta oamStaging+1,x
    tya
    sta oamStaging+3,x
    lda #Y_COORDINATE
    sta oamStaging+0,x
    lda #$23
    sta oamStaging+2,x
    inx
    inx
    inx
    inx
    tya
    clc
    adc #8
    tay
    dec @dasValue
    stx oamStagingLength
    bne @loop

; check to see if carry was set for half width tile
    lda @halfTile
    beq @ret
@drawHalfTile:
    lda @tile
    sec
    sbc #16
    sta oamStaging+1,x
    tya
    sta oamStaging+3,x
    lda #$23
    sta oamStaging+2,x
    lda #Y_COORDINATE
    sta oamStaging+0,x
    inx
    inx
    inx
    inx
    stx oamStagingLength
@ret:
    rts
