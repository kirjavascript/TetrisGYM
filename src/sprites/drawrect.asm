spriteCathedral:
        .byte $20, $0, $1, $1, $20, $30
        .byte $8, $8, $7, $1, $20, $31
        .byte $0, $10, $8, $6, $20, $40
        .byte $FF

spriteCathedralFire0:
        .byte $8, $0, $2, $1, $1, $A0, $FF

spriteCathedralFire1:
        .byte $0, $0, $4, $2, $1, $A2, $FF

rectBuffer := generalCounter
rectX := rectBuffer+0
rectY := rectBuffer+1
rectW := rectBuffer+2
rectH := rectBuffer+3
rectAttr := rectBuffer+4
rectAddr := rectBuffer+5 ; positionValidTmp

; <addr in tmp1 >addr in tmp2
; .byte [x, y, width, height, attr, addr]+ $FF
loadRectIntoOamStaging:
        ldy #0
@copyRect:
        ldx #0
@copyRectLoop:
        lda ($0), y
        cmp #$FF
        beq @ret
        sta rectBuffer, x
        iny
        inx
        cpx #6
        bne @copyRectLoop

@writeLine:
        lda rectX
        sta tmpX
        lda rectW
        sta tmpY

@writeTile:
        ; YTAX
        ldx oamStagingLength

        lda rectY
        adc spriteYOffset
        sta oamStaging,x
        lda rectAddr
        sta oamStaging+1,x
        lda rectAttr
        sta oamStaging+2,x
        lda rectX
        adc spriteXOffset
        sta oamStaging+3,x

        ; increase OAM index
        lda #$4
        clc
        adc oamStagingLength
        sta oamStagingLength

        ; next rightwards tile
        lda #$8
        adc rectX
        sta rectX
        inc rectAddr

        dec rectW
        lda rectW
        bne @writeTile

        ; start a new line
        lda tmpX
        sta rectX
        lda tmpY
        sta rectW

        lda rectAddr
        sbc rectW
        adc #$10
        sta rectAddr

        lda #$8
        adc rectY
        sta rectY

        dec rectH
        lda rectH
        bne @writeLine

        ; do another rect
        jmp @copyRect
@ret:
        rts
