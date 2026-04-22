stageDasMeterSprites:
@dasValue = generalCounter
@tile = generalCounter2
    lda #$CE
    sta @tile
    lda autorepeatX
    lsr
    php
    sta @dasValue
    cmp #5
    bcs @stageSprites
    dec @tile
    cmp #3
    bcs @stageSprites
    dec @tile
@stageSprites:
    ldx oamStagingLength
    lda #0
    ldy #103

@loop:
    lda @tile
    sta oamStaging+1,x
    tya
    sta oamStaging+3,x
    lda #35
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
    sbc #16
    sta oamStaging+1,x
    tya
    sta oamStaging+3,x
    lda #3
    sta oamStaging+2,x
    lda #35
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
