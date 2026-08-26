initGameTap:
        @secondLoop = generalCounter
        lda #$00
        sta @secondLoop
        ldx tapLeftModifier
        beq @checkRight
        lda #190
        clc
        adc tapLeftColumn
@startLoop:
        tay
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
        lda #190
        clc
        adc tapRightColumn
        ldx tapRightModifier
        beq @ret
        bne @startLoop
@ret:
        rts
