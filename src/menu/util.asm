; isAddrNull:
;     lda $0
;     ora $1
;     ; beq
;     rts

; mul by 5
getMenuItemOffset:
    sta tmpX
    asl
    asl
    clc
    adc tmpX
    tax
    rts
