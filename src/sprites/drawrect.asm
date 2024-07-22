.if INES_MAPPER = 0
; compact graphic for smaller tileset capacity
spriteCathedral: ; top of UFO
        .byte $00, $00, $02, $01, $00, $94, $FF

spriteCathedralFire0: ; bottom of UFO 1
        .byte $00, $08, $02, $01, $00, $A4, $FF

spriteCathedralFire1: ; bottom of UFO 2
        .byte $00, $08, $02, $01, $00, $64, $FF

.else

spriteCathedral:
        .byte $15, $0, $3, $7, $20, $38
        .byte $FF

spriteCathedralFire0:
        .byte $8, $F0, $2, $1, $1, $A0, $FF

spriteCathedralFire1:
        .byte $0, $F0, $4, $2, $1, $A2, $FF
.endif

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
        clc
        adc spriteYOffset
        sta oamStaging,x
        lda rectAddr
        sta oamStaging+1,x
        lda rectAttr
        sta oamStaging+2,x
        lda rectX
        clc
        adc spriteXOffset
        sta oamStaging+3,x

        ; increase OAM index
        lda #$4
        clc
        adc oamStagingLength
        sta oamStagingLength

        ; next rightwards tile
        lda #$8
        clc
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
        sec
        sbc rectW
        clc
        adc #$10
        sta rectAddr

        lda #$8
        clc
        adc rectY
        sta rectY

        dec rectH
        lda rectH
        bne @writeLine

        ; do another rect
        jmp @copyRect
@ret:
        rts
