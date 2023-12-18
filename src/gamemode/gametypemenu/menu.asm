.include "linecap.asm"

gameMode_gameTypeMenu:
.if NO_MENU
        inc gameMode
        rts
.endif
        jsr makeNotReady
        jsr calc_menuScrollY
        sta menuScrollY
        lda #0
        sta displayNextPiece
        RESET_MMC1
.if HAS_MMC
        ; switch to blank charmap
        ; (stops glitching when resetting)
        ; lda #$03
        ; jsr changeCHRBank1 ; should this be all or nothing?
.endif

.if INES_MAPPER = 4   ; centralize mirroring
        ; Horizontal mirroring
        lda #$1
        sta MMC3_MIRRORING
.elseif INES_MAPPER = 5
        ; Horizontal mirroring
        lda #$50
        sta MMC5_NT_MAPPING
.endif
        lda #%10011 ; used to be $10 (enable horizontal mirroring)
        jsr setMMC1Control
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
        lda #$00
        jsr changeCHRBanks
        lda #$80
        sta currentPpuCtrl
        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        jsr updateAudioWaitForNmiAndResetOamStaging

gameTypeLoop:
        ; memset FF-02 used to happen every loop
        ; but it's done in ResetOamStaging anyway?
        jmp seedControls

gameTypeLoopContinue:
        jsr menuConfigControls
        jsr practiseTypeMenuControls

gameTypeLoopCheckStart:
        lda newlyPressedButtons_player1
        cmp #BUTTON_START
        bne gameTypeLoopNext

        ; check double killscreen
        lda practiseType
        cmp #MODE_KILLX2
        bne @checkSpeedTest
        lda #$10
        jsr setMMC1Control
        lda #29
        sta startLevel
        sta levelNumber
        lda #$00
        sta gameModeState
        lda #$02
        sta soundEffectSlot1Init

        jsr bufferScreen ; hides glitchy scroll

        inc gameMode
        inc gameMode
        rts

@checkSpeedTest:
        ; check if speed test mode
        cmp #MODE_SPEED_TEST
        beq changeGameTypeToSpeedTest
        cmp #MODE_LINECAP
        beq gotoLinecapMenu

        ; check for seed of 0000XX
        cmp #MODE_SEED
        bne @checkSelectable
        lda set_seed_input
        bne @checkSelectable
        lda set_seed_input+1
        and #$FE ; treat 0001 like 0000
        beq gameTypeLoopNext

@checkSelectable:
        lda practiseType
        cmp #MODE_GAME_QUANTITY
        bpl gameTypeLoopNext

        lda #$02
        sta soundEffectSlot1Init
        inc gameMode
        rts

changeGameTypeToSpeedTest:
        lda #$02
        sta soundEffectSlot1Init
        lda #7
        sta gameMode
        rts

gotoLinecapMenu:
        jmp linecapMenu

gameTypeLoopNext:
        jsr renderMenuVars
        jsr updateAudioWaitForNmiAndResetOamStaging
        jmp gameTypeLoop

seedControls:
        lda practiseType
        cmp #MODE_SEED
        bne gameTypeLoopContinue

        lda newlyPressedButtons_player1
        cmp #BUTTON_SELECT
        bne @skipSeedSelect
        lda rng_seed
        sta set_seed_input
        lda rng_seed+1
        sta set_seed_input+1
        lda rng_seed+1
        eor #$77
        ror
        sta set_seed_input+2
@skipSeedSelect:

        lda #BUTTON_LEFT
        jsr menuThrottle
        beq @skipSeedLeft
        lda #$01
        sta soundEffectSlot1Init
        lda menuSeedCursorIndex
        bne @noSeedLeftWrap
        lda #7
        sta menuSeedCursorIndex
@noSeedLeftWrap:
        dec menuSeedCursorIndex
@skipSeedLeft:

        lda #BUTTON_RIGHT
        jsr menuThrottle
        beq @skipSeedRight
        lda #$01
        sta soundEffectSlot1Init
        inc menuSeedCursorIndex
        lda menuSeedCursorIndex
        cmp #7
        bne @skipSeedRight
        lda #0
        sta menuSeedCursorIndex
@skipSeedRight:

        lda menuSeedCursorIndex
        beq @skipSeedControl

        lda menuSeedCursorIndex
        sbc #1
        lsr
        tax ; save seed offset

        ; handle changing seed vals

        lda #BUTTON_UP
        jsr menuThrottle
        beq @skipSeedUp
        lda #$01
        sta soundEffectSlot1Init
        lda menuSeedCursorIndex
        and #1
        beq @lowNybbleUp

        lda set_seed_input, x
        clc
        adc #$10
        sta set_seed_input, x

        jmp @skipSeedUp
@lowNybbleUp:
        lda set_seed_input, x
        clc
        tay
        and #$F
        cmp #$F
        bne @noWrapUp
        tya
        and #$F0
        sta set_seed_input, x
        jmp @skipSeedUp
@noWrapUp:
        tya
        adc #1
        sta set_seed_input, x
@skipSeedUp:

        lda #BUTTON_DOWN
        jsr menuThrottle
        beq @skipSeedDown
        lda #$01
        sta soundEffectSlot1Init
        lda menuSeedCursorIndex
        and #1
        beq @lowNybbleDown

        lda set_seed_input, x
        sbc #$10
        clc
        sta set_seed_input, x

        jmp @skipSeedDown
@lowNybbleDown:
        lda set_seed_input, x
        clc
        tay
        and #$F
        cmp #$0
        bne @noWrapDown
        tya
        and #$F0
        clc
        adc #$F
        sta set_seed_input, x
        jmp @skipSeedDown
@noWrapDown:
        tya
        sbc #1
        sta set_seed_input, x
@skipSeedDown:

        jmp gameTypeLoopCheckStart
@skipSeedControl:
        jmp gameTypeLoopContinue

menuConfigControls:
        ; account for 'gaps' in config items of size zero
        ; previously the offset was just set on X directly

        ldx #0 ; memory offset we want
        ldy #0 ; cursor
@searchByte:
        cpy practiseType
        bne @notYet
        lda menuConfigSizeLookup, y
        beq @configEnd
        ; if zero, caller will beq to skip the config
        jmp @searchEnd
@notYet:
        lda menuConfigSizeLookup, y
        beq @noMem
        inx
@noMem:
        iny
        jmp @searchByte
@searchEnd:

        ; actual offset now in Y
        ; RAM offset now in X

        ; check if pressing left
        lda #BUTTON_LEFT
        jsr menuThrottle
        beq @skipLeftConfig
        ; check if zero
        lda menuVars, x
        cmp #0
        beq @skipLeftConfig
        ; dec value
        dec menuVars, x
        lda #$01
        sta soundEffectSlot1Init
        jsr assertValues
@skipLeftConfig:

        ; check if pressing right
        lda #BUTTON_RIGHT
        jsr menuThrottle
        beq @skipRightConfig
        ; check if within the offset
        lda menuVars, x
        cmp menuConfigSizeLookup, y
        bpl @skipRightConfig
        inc menuVars, x
        lda #$01
        sta soundEffectSlot1Init
        jsr assertValues
@skipRightConfig:
@configEnd:
        rts

menuConfigSizeLookup:
        MENUSIZES

assertValues:
        ; make sure you can only have block or qual
        lda practiseType
        cmp #MODE_QUAL
        bne @noQual
        lda menuVars, x
        beq @noQual
        lda #0
        sta debugFlag
@noQual:
        lda practiseType
        cmp #MODE_DEBUG
        bne @noDebug
        lda menuVars, x
        beq @noDebug
        lda #0
        sta qualFlag
@noDebug:
        ; goofy
        lda practiseType
        cmp #MODE_GOOFY
        bne @noFlip
        lda heldButtons_player1
        asl
        and #$AA
        sta tmp3
        lda heldButtons_player1
        and #$AA
        lsr
        ora tmp3
        sta heldButtons_player1
@noFlip:
        rts

practiseTypeMenuControls:
        ; down
        lda #BUTTON_DOWN
        jsr menuThrottle
        beq @downEnd
        lda #$01
        sta soundEffectSlot1Init

        inc practiseType
        lda practiseType
        cmp #MODE_QUANTITY
        bne @downEnd
        lda #0
        sta practiseType
@downEnd:

        ; up
        lda #BUTTON_UP
        jsr menuThrottle
        beq @upEnd
        lda #$01
        sta soundEffectSlot1Init
        lda practiseType
        bne @noWrap
        lda #MODE_QUANTITY
        sta practiseType
@noWrap:
        dec practiseType
@upEnd:
        rts

renderMenuVars:

        ; playType / seed cursors

        lda menuSeedCursorIndex
        bne @seedCursor

        lda practiseType
        jsr menuItemY16Offset
        bne @cursorFinished
        stx spriteYOffset
        lda #$17
        sta spriteXOffset
        lda #$1D
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging
        jmp @cursorFinished

@seedCursor:
        clc
        lda #MENU_SPRITE_Y_BASE + 7
        sbc menuScrollY
        sta spriteYOffset
        lda menuSeedCursorIndex
        asl a
        asl a
        asl a
        adc #$B1
        sta spriteXOffset
        lda #$1B
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging

        ; indicator

        lda set_seed_input
        bne @renderIndicator
        lda set_seed_input+1
        and #$FE ; treat 0001 like 0000
        beq @cursorFinished
@renderIndicator:
        ldx #$E
        lda set_seed_input+2
        and #$F0
        beq @v5
        lda set_seed_input
        bne @v4
        lda set_seed_input+1
        beq @v5
        jmp @v4
@v5:
        ldx #$F
@v4:
        stx spriteIndexInOamContentLookup
        sec
        lda #(MODE_SEED*8) + MENU_SPRITE_Y_BASE + 1
        sbc menuScrollY
        sta spriteYOffset
        lda #$A0
        sta spriteXOffset
        jsr stringSprite

@cursorFinished:

menuCounter := tmp1
menuRAMCounter := tmp3
menuYTmp := tmp2

        ; render seed

        lda #$b8
        sta spriteXOffset
        lda #MODE_SEED
        jsr menuItemY16Offset
        bne @notSeed
        stx spriteYOffset
        lda #set_seed_input
        sta byteSpriteAddr
        lda #0
        sta byteSpriteAddr+1
        lda #0
        sta byteSpriteTile
        lda #3
        sta byteSpriteLen
        jsr byteSprite
@notSeed:

        ; render config vars

        ; YTAX
        lda #0
        sta menuCounter
        sta menuRAMCounter
@loop:
        ldy menuRAMCounter ; gap support

        ; handle boolean
        lda menuCounter
        tax ; used to get loaded into Y
        lda menuConfigSizeLookup, x

        beq @loopNext ; gap support
        inc menuRAMCounter ; only increment RAM when config size isnt zero

        cmp #1
        beq @renderBool

        lda menuCounter
        cmp #MODE_SCORE_DISPLAY
        beq @renderScoreName

        ldx oamStagingLength

        ; get Y offset
        lda menuCounter
        asl
        asl
        asl
        adc #MENU_SPRITE_Y_BASE + 1
        sbc menuScrollY
        sta oamStaging, x
        inx
        lda menuVars, y
        sta oamStaging, x
        inx
        lda #$00
        sta oamStaging, x
        inx
        lda #$E0
        sta oamStaging, x
        inx
        ; increase OAM index
        lda #$04
        clc
        adc oamStagingLength
        sta oamStagingLength

@loopNext:
        inc menuCounter
        lda menuCounter
        cmp #MODE_QUANTITY
        bne @loop
        rts

@renderBool:
        lda menuCounter
        jsr menuItemY16Offset
        bne @boolOutOfRange
        stx spriteYOffset
        lda #$E9
        sta spriteXOffset
        clc
        lda menuVars, y
        adc #$8
        sta spriteIndexInOamContentLookup
        jsr stringSpriteAlignRight
@boolOutOfRange:
        jmp @loopNext

@renderScoreName:
        lda scoringModifier
        sta spriteIndexInOamContentLookup
        lda #(MODE_SCORE_DISPLAY*8) + MENU_SPRITE_Y_BASE + 1
        sbc menuScrollY
        sta spriteYOffset
        lda #$e9
        sta spriteXOffset
        jsr stringSpriteAlignRight
        jmp @loopNext

; <- menu item index in A
; -> high byte of offset in A
; -> low byte in X
menuItemY16Offset:
        sta tmpY
        lda #8
        sta tmpX
        ; get 16bit menuitem * 8 in tmpX/tmpY
        lda #$0
        ldx #$8
        clc
@mulLoop:
        bcc @mulLoop1
        clc
        adc tmpY
@mulLoop1:
        ror
        ror tmpX
        dex
        bpl @mulLoop
        sta tmpY
        ; add offset
        clc
        lda tmpX
        adc #MENU_SPRITE_Y_BASE + 1
        sta tmpX
        lda tmpY
        adc #0
        sta tmpY
        ; remove menuscroll
        sec
        lda tmpX
        sbc menuScrollY
        sta tmpX
        tax
        lda tmpY
        sbc #0
        rts

bufferScreen:
        lda #$0
        sta renderMode
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
        jsr drawBlackBGPalette
        jsr resetScroll
        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda #$3
        sta sleepCounter
@endLoop:
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda sleepCounter
        bne @endLoop
        rts
