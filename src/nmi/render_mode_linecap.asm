render_linecap_level_lines:
        lda linecapWhen
        cmp #LINECAP_LINES
        beq @linecapLines
        cmp #LINECAP_LEVEL
        bne @ret
        lda linecapLevel
        jmp renderByteBCD

@linecapLines:
        lda linecapLines
        sta PPUDATA
        lda linecapLines+1
        jsr twoDigsToPPU
@ret:
        rts
