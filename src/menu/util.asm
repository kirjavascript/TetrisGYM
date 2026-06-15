; mul by 5
getMenuItemOffset:
        sta tmpX
        asl
        asl
        clc
        adc tmpX
        tax
        rts

; menuDataOffsets[menuIndex] + ram data index from current menu
getMenuDataOffset:
        ldx menuIndex
        lda menuDataOffsets,x
        sta tmp3

        lda menuItemIndex
        beq @done
        sta tmpX

        txa
        asl
        tay
        lda menuList,y
        sta tmp1
        lda menuList+1,y
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

; set PPUADDR for tile row A, column X
setPPURowCol:
        stx tmpX
        ldx #$20
        cmp #30
        bcc @calc
        sbc #30
        ldx #$28
@calc:
        pha
        lsr
        lsr
        lsr
        stx tmp1
        clc
        adc tmp1
        sta PPUADDR
        pla
        and #$07
        asl
        asl
        asl
        asl
        asl
        clc
        adc tmpX
        sta PPUADDR
        rts

; ptr to current item in current menu
getItemPtr:
        jsr getMenuItemOffset
        lda menuIndex
        asl
        tay
        lda menuList,y
        sta menuItemPtr
        lda menuList+1,y
        sta menuItemPtr+1
        txa
        clc
        adc menuItemPtr
        sta menuItemPtr
        lda #0
        adc menuItemPtr+1
        sta menuItemPtr+1
        rts

renderMenuFull:
        lda #0
        sta menuRenderIdx
        ldx menuIndex
        lda menuDataOffsets,x
        sta menuDataAccum
@loop:
        lda menuRenderIdx
        jsr renderMenuRow
        inc menuRenderIdx
        ldx menuIndex
        lda menuLengths,x
        cmp menuRenderIdx
        bne @loop
        rts

renderMenuRow:
        sta menuRowItem

        clc
        adc #MENU_BG_BASE_ROW
        ldx #MENU_CURSOR_COL
        jsr setPPURowCol

        lda menuRowItem
        cmp menuItemIndex
        bne @noCursor
        lda #'>'
        bne @writeCursor
@noCursor:
        lda #' '
@writeCursor:
        sta PPUDATA

        lda menuRowItem
        clc
        adc #MENU_BG_BASE_ROW
        ldx #MENU_TEXT_COL
        jsr setPPURowCol
        lda menuRowItem
        jsr getItemPtr

        ldy #MenuItem::textAddress
        lda (menuItemPtr),y
        sta menuItemAddr
        iny
        lda (menuItemPtr),y
        sta menuItemAddr+1

        ldy #0
        lda (menuItemAddr),y
        tax
        iny
@textLoop:
        lda (menuItemAddr),y
        sta PPUDATA
        iny
        dex
        bne @textLoop

        lda menuRowItem
        jsr renderMenuValue
        rts

renderMenuValue:
        sta menuValueItem

        jsr getItemPtr

        ldy #MenuItem::type
        lda (menuItemPtr),y
        cmp #MENU_TYPE_NAV
        beq @done
        sta menuItemType

        cmp #MENU_TYPE_ORD
        bne @notOrd
        ldy #MenuItem::settingsAddress
        lda (menuItemPtr),y
        sta menuItemAddr
        iny
        lda (menuItemPtr),y
        sta menuItemAddr+1
        ldy #1
        lda #29
        sec
        sbc (menuItemAddr),y
        sta tmpX
@notOrd:

        ldx menuDataAccum
        ldy menuItemType
        lda menuTypeSizes,y
        clc
        adc menuDataAccum
        sta menuDataAccum

        lda menuValueItem
        jmp writeMenuValueTiles

@done:
        rts

; A = item index, X = data offset, menuItemType = type
writeMenuValueTiles:
        stx menuDataOff

        clc
        adc #MENU_BG_BASE_ROW

        ldx #MENU_VALUE_COL
        ldy menuItemType
        cpy #MENU_TYPE_SEED
        bne @notSeedCol
        ldx #(MENU_VALUE_COL - 3)
        jmp @setAddr
@notSeedCol:
        cpy #MENU_TYPE_ORD
        bne @setAddr
        ldx tmpX
@setAddr:
        jsr setPPURowCol

        ldx menuDataOff

        lda menuItemType
        cmp #MENU_TYPE_BOOL
        beq @boolValue
        cmp #MENU_TYPE_SEED
        beq @seedValue
        cmp #MENU_TYPE_ORD
        beq @ordValue
        lda menuData,x
        jsr renderByteBCD
        rts

@ordValue:
        lda menuData,x
        asl
        clc
        adc #2
        tay
        lda (menuItemAddr),y
        sta tmp1
        iny
        lda (menuItemAddr),y
        sta tmp1+1
        ldy #1
        lda (menuItemAddr),y
        ldy #0
        sec
        sbc (tmp1),y
        beq @ordText
        tax
@ordPad:
        lda #' '
        sta PPUDATA
        dex
        bne @ordPad
@ordText:
        ldy #0
        lda (tmp1),y
        tax
        iny
@ordLoop:
        lda (tmp1),y
        sta PPUDATA
        iny
        dex
        bne @ordLoop
        rts

@boolValue:
        lda menuData,x
        beq @boolOff
        lda #' '
        sta PPUDATA
        lda #'O'
        sta PPUDATA
        lda #'N'
        sta PPUDATA
        rts
@boolOff:
        lda #'O'
        sta PPUDATA
        lda #'F'
        sta PPUDATA
        lda #'F'
        sta PPUDATA
        rts

@seedValue:
        lda menuData,x
        jsr twoDigsToPPU
        lda menuData+1,x
        jsr twoDigsToPPU
        lda menuData+2,x
        jsr twoDigsToPPU
        rts
