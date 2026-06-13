stageDasMeterSprites:
    lda dasMeterFlag
    beq @ret
    lda playState
    beq @ret

@dasValue = generalCounter
@tile = generalCounter2
@redCompare = generalCounter3
@orangeCompare = generalCounter4
@yCoordinate = 211
@xStart = 103
    lda dasModifier
    lsr
    lsr
    sta @orangeCompare
    inc @orangeCompare ; 5 when ntsc vanilla
    lsr
    sta @redCompare
    inc @redCompare ; 3 when ntsc vanilla

    lda #$FE
    sta @tile
    lda autorepeatX
    lsr
    php
    sta @dasValue
    cmp @orangeCompare
    bcs @stageSprites
    dec @tile
    cmp @redCompare
    bcs @stageSprites
    dec @tile
@stageSprites:
    ldx oamStagingLength
    lda #0
    ldy #@xStart

@loop:
    lda @tile
    sta oamStaging+1,x
    tya
    sta oamStaging+3,x
    lda #@yCoordinate
    sta oamStaging+0,x
    lda #3
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
    bpl @loop
    plp
    bcc @ret
    lda @tile
    sec
    sbc #32
    sta oamStaging+1,x
    tya
    sta oamStaging+3,x
    lda #3
    sta oamStaging+2,x
    lda #@yCoordinate
    sta oamStaging+0,x
    inx
    inx
    inx
    inx
    stx oamStagingLength
@ret:
    rts

; render_mode_play_and_demo_then_dasmeter:
;     lda #$23
;     sta PPUADDR
;     lda #$89
;     sta PPUADDR
;     ldx autorepeatX
;     beq @ret
;     lda dasMeterTile
; @drawDas:
;     sta PPUDATA
;     dex
;     bne @drawDas
;     ldx dasValue
;     beq @ret
;     lda #$FF
; @drawNonDas:
;     sta PPUDATA
;     dex
;     bne @drawNonDas
; @ret:
;     jsr render_mode_play_and_demo
;     rts
