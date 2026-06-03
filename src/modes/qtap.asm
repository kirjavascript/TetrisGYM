advanceGameTap:
        @leftSide = $BF
        @rightSide = $C6
        @secondLoop = generalCounter
        jsr clearPlayfield
        lda #$00
        sta @secondLoop
        ldx tapLeftModifier
        beq @checkRight
        ldy #@leftSide
@loop:
        lda #$7B
        sta $400, y
        ; add 10 to y
        tya
        sec ;important
        sbc #$A
        tay
        dex
        bne @loop
        lda @secondLoop
        bne @ret
@checkRight:
        inc @secondLoop
        ldx tapRightModifier
        beq @ret
        ldy #@rightSide
        bne @loop
@ret:
        rts
