; TODO: remove old menu RAM, rendering, constants, code, strings list, nametables, transplant menu call in gameModeState
; TODO: rename stuff
; TODO: show a direction icon on nav (other way on back??)
; TODO: render_mode_null

; SEED: gym v4+, hydrant, generate random

menuIndex := menuRAM+4
menuItemIndex := menuRAM+5
menuPrevItemIndex := menuRAM+6
menuCachedDataOff := menuRAM+7
menuData := menuRAM+8

menuRowItem := generalCounter
menuValueMax := generalCounter3
menuDataOff := generalCounter4
menuValueItem := generalCounter5
menuRenderIdx := generalCounter2
menuDataAccum := generalCounter3
menuItemPtr := tmp1
menuItemAddr := pointerAddr
menuItemType := tmpZ

MENU_BG_BASE_ROW = 9
MENU_TEXT_COL = 5
MENU_VALUE_COL = 26
MENU_CURSOR_COL = 3

.include "menu/definition.asm"
.include "menu/data.generated.asm"
.include "menu/util.asm"

coldMenuInit:
        ; zero out config memory
        lda #$0
        ldx #<($800 - menuRAM)
@loop:
        dex
        sta menuRAM, x
        bne @loop

        ; default pace to A
        ; lda #$A
        ; sta paceModifier

        ; lda #$10
        ; sta dasModifier

        ; lda #INITIAL_LINECAP_LEVEL
        ; sta linecapLevel
        ; lda #INITIAL_LINECAP_LINES
        ; sta linecapLines
        ; lda #INITIAL_LINECAP_LINES_1
        ; sta linecapLines+1
        rts

menu:
        jsr makeNotReady
        lda #0
        sta menuScrollY
        sta menuItemIndex
        sta menuPrevItemIndex
        sta menuIndex
        sta hideNextPiece

        lda #$1
        sta renderMode
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
        jsr bulkCopyToPpu
        .addr   title_palette

.if INES_MAPPER <> 0
        lda #CHRBankSet0
        jsr changeCHRBanks
.endif

        jsr menuRedrawBody

menuLoop:
        lda menuSeedCursorIndex
        bne @skipItemControls
        jsr menuItemControls
@skipItemControls:
        jsr menuValueControls

        lda newlyPressedButtons_player1
        and #(BUTTON_START | BUTTON_A)
        beq @noAction
        jsr menuAction
@noAction:

        jsr menuSeedCursorSprite
        jsr updateAudioWaitForNmiAndResetOamStaging
        jmp menuLoop

menuItemControls:
        lda #BUTTON_DOWN
        jsr menuThrottle
        beq @downEnd
        lda #$01
        sta soundEffectSlot1Init
        lda menuItemIndex
        sta menuPrevItemIndex
        inc menuItemIndex
        ldx menuIndex
        lda menuLengths,x
        cmp menuItemIndex
        bne @downEnd
        lda #0
        sta menuItemIndex
@downEnd:

        lda #BUTTON_UP
        jsr menuThrottle
        beq @upEnd
        lda #$01
        sta soundEffectSlot1Init
        lda menuItemIndex
        sta menuPrevItemIndex
        bne @noWrap
        ldx menuIndex
        lda menuLengths,x
        sta menuItemIndex
@noWrap:
        dec menuItemIndex
@upEnd:

        lda menuItemIndex
        cmp menuPrevItemIndex
        beq @noMove
        jsr cacheMenuDataOff
        lda renderFlags
        ora #1
        sta renderFlags
@noMove:
        rts

menuValueControls:
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
        cmp #MENU_TYPE_SEED
        bne @notSeed
        jmp menuSeedControls
@notSeed:
        cmp #MENU_TYPE_BOOL
        bne @notBoolMax
        lda #1
        jmp @gotMax
@notBoolMax:
        cmp #MENU_TYPE_ORD
        bne @notOrdMax
        ldy #MenuItem::settingsAddress
        lda (menuItemPtr),y
        pha
        iny
        lda (menuItemPtr),y
        sta menuItemPtr+1
        pla
        sta menuItemPtr
        ldy #0
        lda (menuItemPtr),y
        sec
        sbc #1
        jmp @gotMax
@notOrdMax:
        ldy #MenuItem::settingsAddress
        lda (menuItemPtr),y
@gotMax:
        sta menuValueMax

        ldx menuCachedDataOff
        stx menuDataOff

        lda #BUTTON_LEFT
        jsr menuThrottle
        beq @skipLeft
        ldx menuDataOff
        lda menuData,x
        beq @skipLeft
        dec menuData,x
        lda #$01
        sta soundEffectSlot1Init
        lda renderFlags
        ora #1
        sta renderFlags
@skipLeft:

        lda #BUTTON_RIGHT
        jsr menuThrottle
        beq @skipRight
        ldx menuDataOff
        lda menuData,x
        cmp menuValueMax
        bcs @skipRight
        inc menuData,x
        lda #$01
        sta soundEffectSlot1Init
        lda renderFlags
        ora #1
        sta renderFlags
@skipRight:
@done:
        rts

menuAction:
        lda menuItemIndex
        jsr getItemPtr
        ldy #MenuItem::type
        lda (menuItemPtr),y
        cmp #MENU_TYPE_NAV
        bne @notNav
        ldy #MenuItem::settingsAddress
        lda (menuItemPtr),y
        sta menuIndex
        jmp @navigate
@notNav:
        cmp #MENU_TYPE_JMP
        bne @notJmp
        ldy #MenuItem::settingsAddress
        lda (menuItemPtr),y
        sta menuItemAddr
        iny
        lda (menuItemPtr),y
        sta menuItemAddr+1
        pla
        pla
        jmp (menuItemAddr)
@notJmp:
        cmp #MENU_TYPE_JSR
        bne @notJsr
        ldy #MenuItem::settingsAddress
        lda (menuItemPtr),y
        sta menuItemAddr
        iny
        lda (menuItemPtr),y
        sta menuItemAddr+1
        lda #$02
        sta soundEffectSlot1Init
        jsr @jsrTrampoline
        jsr menuRedraw
        rts
@jsrTrampoline:
        jmp (menuItemAddr)
@notJsr:
        cmp #MENU_TYPE_RTS
        bne @notRts
        pla
        pla
        rts
@notRts:
        rts

@navigate:
        lda #0
        sta menuItemIndex
        sta menuPrevItemIndex
        sta menuScrollY
        sta menuSeedCursorIndex
        lda #$02
        sta soundEffectSlot1Init
        jsr cacheMenuDataOff
        jsr menuRedraw
        rts

menuSeedControls:
        lda #BUTTON_LEFT
        jsr menuThrottle
        beq @skipLeft
        lda #$01
        sta soundEffectSlot1Init
        lda menuSeedCursorIndex
        bne @noLeftWrap
        lda #7
        sta menuSeedCursorIndex
@noLeftWrap:
        dec menuSeedCursorIndex
@skipLeft:

        lda #BUTTON_RIGHT
        jsr menuThrottle
        beq @skipRight
        lda #$01
        sta soundEffectSlot1Init
        inc menuSeedCursorIndex
        lda menuSeedCursorIndex
        cmp #7
        bne @skipRight
        lda #0
        sta menuSeedCursorIndex
@skipRight:

        lda menuSeedCursorIndex
        bne @editDigits
        rts
@editDigits:

        sec
        sbc #1
        lsr
        clc
        adc menuCachedDataOff
        tax

        lda #BUTTON_UP
        jsr menuThrottle
        beq @skipUp
        lda #$01
        sta soundEffectSlot1Init
        lda menuSeedCursorIndex
        and #1
        beq @lowNybbleUp
        lda menuData,x
        clc
        adc #$10
        sta menuData,x
        jmp @upDone
@lowNybbleUp:
        lda menuData,x
        tay
        and #$0F
        cmp #$0F
        bne @noWrapUp
        tya
        and #$F0
        sta menuData,x
        jmp @upDone
@noWrapUp:
        tya
        clc
        adc #1
        sta menuData,x
@upDone:
        lda renderFlags
        ora #1
        sta renderFlags
@skipUp:

        lda #BUTTON_DOWN
        jsr menuThrottle
        beq @skipDown
        lda #$01
        sta soundEffectSlot1Init
        lda menuSeedCursorIndex
        and #1
        beq @lowNybbleDown
        lda menuData,x
        sec
        sbc #$10
        sta menuData,x
        jmp @downDone
@lowNybbleDown:
        lda menuData,x
        tay
        and #$0F
        bne @noWrapDown
        tya
        and #$F0
        clc
        adc #$0F
        sta menuData,x
        jmp @downDone
@noWrapDown:
        tya
        sec
        sbc #1
        sta menuData,x
@downDone:
        lda renderFlags
        ora #1
        sta renderFlags
@skipDown:
@done:
        rts

menuSeedCursorSprite:
        lda menuSeedCursorIndex
        beq @done
        asl
        asl
        asl
        clc
        adc #((MENU_VALUE_COL - 4) * 8 + 1)
        sta spriteXOffset
        lda menuItemIndex
        clc
        adc #MENU_BG_BASE_ROW
        asl
        asl
        asl
        sec
        sbc menuScrollY
        sec
        sbc #11
        sta spriteYOffset
        lda #$1B
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging
@done:
        rts

cacheMenuDataOff:
        jsr getMenuDataOffset
        stx menuCachedDataOff
        rts

menuRedraw:
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
menuRedrawBody:
        jsr copyRleNametableToPpu
        .addr   game_type_menu_nametable
        lda #$28
        sta tmp3
        jsr copyRleNametableToPpuOffset
        .addr   game_type_menu_nametable_extra
        jsr renderMenuFull
        lda #NMIEnable
        sta currentPpuCtrl
        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda #9
        sta renderMode
        rts
