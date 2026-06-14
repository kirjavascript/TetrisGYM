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

; in: menuIndex, menuItemIndex
; out: X = offset into menuData
; clobbers: X, Y, tmp1-3, tmpX
; eg. lda menuData,x
getMenuDataOffset:
    lda #0
    sta tmp3
    tax

    cpx menuIndex
    beq @counted
@countLoop:
    clc
    adc menuLengths,x
    inx
    cpx menuIndex
    bne @countLoop
@counted:
    clc
    adc menuItemIndex
    beq @done
    sta tmpX

    lda menuList
    sta tmp1
    lda menuList+1
    sta tmp2

    ldy #0
@loop:
    lda (tmp1),y
    tax
    lda menuTypeSizes,x
    clc
    adc tmp3
    sta tmp3

    tya
    clc
    adc #.sizeof(MenuItem)
    tay

    dec tmpX
    bne @loop

@done:
    ldx tmp3
    rts
