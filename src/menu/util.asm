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

; getMenuDataOffset
; in: menuIndex, menuItemIndex
; out: A = offset into menuData
; clobbers: X, Y, tmp1-3, tmpX, tmpY
getMenuDataOffset:
    lda #0
    sta tmp3
    sta tmpX

@menuLoop:
    lda tmpX
    cmp menuIndex
    bne @fullMenu
    lda menuItemIndex
    jmp @setCount
@fullMenu:
    ldx tmpX
    lda menuLengths,x
@setCount:
    beq @nextMenu
    sta tmpY

    lda tmpX
    asl
    tax
    lda menuList,x
    sta tmp1
    lda menuList+1,x
    sta tmp2

    ldy #0
@itemLoop:
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

    dec tmpY
    bne @itemLoop

@nextMenu:
    lda tmpX
    cmp menuIndex
    beq @done
    inc tmpX
    jmp @menuLoop

@done:
    lda tmp3
    rts
