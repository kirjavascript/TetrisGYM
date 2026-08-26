controllerInputTiles:
        ; .byte "RLDUSSBA"
        .byte $D5, $D5, $D4, $D4
        .byte $D3, $D2, $D1, $D0
controllerInputX:
        .byte $31, $28, $14, $1D
        .byte $05, $05, $00, $09
controllerInputY:
        .byte $FF, $FF, $00, $00
        .byte $FB, $05, $00, $00

controllerInputDisplay: ; called in events, speedtest
        lda #0
        sta tmp3
controllerInputDisplayX:
        lda heldButtons_player1
        sta tmp1
        ldy #7
@inputLoop:
        lda tmp1
        and #1
        beq @inputContinue
        ldx oamStagingLength
        clc
        lda controllerInputY, y
        adc #$4C
        sta oamStaging, x
        inx
        lda controllerInputTiles, y
        sta oamStaging, x
        inx
        lda #$01
        sta oamStaging, x
        inx
        lda controllerInputX, y
        clc
        adc #$13
        adc tmp3
        sta oamStaging, x
        inx
        ; increase OAM index
        lda #$04
        clc
        adc oamStagingLength
        sta oamStagingLength
@inputContinue:
        ror tmp1
        dey
        bpl @inputLoop
        rts
