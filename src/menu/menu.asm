; TODO: remove old menu RAM, constants, code, strings list, nametables
; TODO: rename stuff

; reset menuIndex, etc (if not already in boot)
; reuse menuRAM

menuIndex := menuRAM

; (!) figure out ram allocation from type alone

RENDER_MENU_ITEM := 1
RENDER_MENU_FULL := 2

.include "menu/definition.asm"
.include "menu/util.asm"

menu:
        jsr makeNotReady
        lda #0
        sta menuScrollY
        lda #0
        sta hideNextPiece

        lda #RENDER_MENU_FULL
        sta renderFlags

        lda #$1
        sta renderMode
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
        jsr bulkCopyToPpu
        .addr   title_palette
        jsr copyRleNametableToPpu
        .addr   game_type_menu_nametable
        lda #$28
        sta tmp3
        jsr copyRleNametableToPpuOffset
        .addr   game_type_menu_nametable_extra

.if INES_MAPPER <> 0
        lda #CHRBankSet0
        jsr changeCHRBanks
.endif

        lda #NMIEnable
        sta currentPpuCtrl
        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        jsr updateAudioWaitForNmiAndResetOamStaging

menuLoop:
        jsr updateAudioWaitForNmiAndResetOamStaging
        jmp menuLoop
