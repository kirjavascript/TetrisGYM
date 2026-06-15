render_mode_scroll:
        ; handle scroll
        lda currentPpuCtrl
        and #$FC
        sta currentPpuCtrl
        lda #0
        sta ppuScrollX

        jsr calc_menuScrollY
        cmp menuScrollY
        beq @endscroll
        ; not equal
        cmp menuScrollY
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
        rts

calc_menuScrollY:
        lda practiseType
        cmp #MENU_TOP_MARGIN_SCROLL
        bcs @underflow
        lda #MENU_TOP_MARGIN_SCROLL+1
@underflow:
        sbc #MENU_TOP_MARGIN_SCROLL
        asl
        asl
        asl
        rts
