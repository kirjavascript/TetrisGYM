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
.scope
    ; add additional arguments as needed, max a255

    .if .blank(a1)
        ; single destination.  3 cycles.
        .warning "branchTo defined with single destination, converting to jmp"
        jmp a0

    .elseif .blank(a4)
        ; 2-4 destinations use branching.  8-19 cycles
        ldx dest
        beq addr0
        .ifnblank a2
            dex
            beq addr1
            .ifnblank a3
                dex
                beq addr2
                addr3:
                    jmp a3
            .endif
             addr2:
                jmp a2
        .endif
         addr1:
             jmp a1
         addr0:
             jmp a0

    .else
        ; 5+ destinations, use rts branch.  23-26 cycles
        ; uses each destination-1 and rts to branch
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
    .endif
.endscope
.endmacro
