render_mode_menu:
        lda currentPpuCtrl
        and #$FC
        sta currentPpuCtrl
        lda #0
        sta ppuScrollX

        jsr calc_newMenuScrollY
        cmp menuScrollY
        beq @endscroll
        bcc @lessThan
        inc menuScrollY
        jmp @endscroll
@lessThan:
        dec menuScrollY
@endscroll:
        ldx menuIndex
        lda menuLengths,x
        sec
        sbc #(30 - MENU_BG_BASE_ROW - 3)
        bcs @hasScroll
        lda #0
@hasScroll:
        asl
        asl
        asl
        cmp menuScrollY
        bcs @uncapped
        sta menuScrollY
@uncapped:
        lda menuScrollY
        sta ppuScrollY

        lda renderFlags
        and #1
        beq @done
        jsr nmiRenderMenuUpdate
        lda #0
        sta renderFlags
@done:
        rts

calc_newMenuScrollY:
        lda menuItemIndex
        cmp #MENU_TOP_MARGIN_SCROLL
        bcs @ok
        lda #MENU_TOP_MARGIN_SCROLL+1
@ok:
        sbc #MENU_TOP_MARGIN_SCROLL
        asl
        asl
        asl
        rts

nmiRenderMenuUpdate:
        lda menuPrevItemIndex
        clc
        adc #MENU_BG_BASE_ROW
        ldx #MENU_CURSOR_COL
        jsr setPPURowCol
        lda #' '
        sta PPUDATA

        lda menuItemIndex
        clc
        adc #MENU_BG_BASE_ROW
        ldx #MENU_CURSOR_COL
        jsr setPPURowCol
        lda #'>'
        sta PPUDATA

        lda menuItemIndex
        sta menuPrevItemIndex

        lda menuItemIndex
        jsr getItemPtr

        ldy #MenuItem::type
        lda (menuItemPtr),y
        cmp #MENU_TYPE_NAV
        beq @done
        cmp #MENU_TYPE_JMP
        beq @done
        cmp #MENU_TYPE_JSR
        beq @done
        cmp #MENU_TYPE_RTS
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

        ldx menuCachedDataOff
        lda menuItemIndex
        jmp writeMenuValueTiles

@done:
        rts
