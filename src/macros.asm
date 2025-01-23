.macro _makeRtsTable byte,  a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15
    .if .strat (byte, 0) = '>'
        .byte >(a0-1)
    .elseif .strat (byte, 0) = '<'
        .byte <(a0-1)
    .endif
    .ifnblank a1 ; recurse until end of argument list
        _makeRtsTable byte, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15
    .endif
.endmacro

.macro branchTo dest, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15
    ; uses each destination-1 and rts to branch
    ; add additional arguments as needed, max a255
    .scope
        ldx dest
        lda hiBytes,x
        pha
        lda loBytes,x
        pha
        rts

    hiBytes:
        _makeRtsTable ">", a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15
    loBytes:
        _makeRtsTable "<", a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15
    .endscope
.endmacro
