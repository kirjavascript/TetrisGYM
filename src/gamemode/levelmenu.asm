gameMode_levelMenu:
        RESET_MMC1
        lda #$10
        jsr setMMC1Control
.if INES_MAPPER = 3
        lda currentPpuCtrl
        and #%10000000
        sta currentPpuCtrl
.endif
        jsr updateAudio2
        lda #$7
        sta renderMode
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
        lda #$00
        jsr changeCHRBank0
        lda #$00
        jsr changeCHRBank1
        jsr bulkCopyToPpu
        .addr   menu_palette
        jsr copyRleNametableToPpu
        .addr   level_menu_nametable
        lda #$20
        sta tmp1
        lda #$96 ; $6D is OEM position
        sta tmp2
        jsr displayModeText
        jsr showHighScores
        lda linecapFlag
        beq @noLinecapInfo
        jsr levelMenuLinecapInfo
@noLinecapInfo:
        ; render lines when loading screen
        lda #RENDER_LINES
        sta renderFlags
        jsr resetScroll
        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda #$00
        sta originalY
        sta dropSpeed
@forceStartLevelToRange:
        lda classicLevel
        cmp #$0A
        bcc gameMode_levelMenu_processPlayer1Navigation
        sec
        sbc #$0A
        sta classicLevel
        jmp @forceStartLevelToRange

levelMenuLinecapInfo:
        lda #$20
        sta PPUADDR
        lda #$F5
        sta PPUADDR
        clc
        lda #LINECAP_WHEN_STRING_OFFSET
        adc linecapWhen
        sta stringIndexLookup
        jsr stringBackground

        lda #$21
        sta PPUADDR
        lda #$15
        sta PPUADDR
        clc
        lda #LINECAP_HOW_STRING_OFFSET
        adc linecapHow
        sta stringIndexLookup
        jsr stringBackground

        lda #$20
        sta PPUADDR
        lda #$FA
        sta PPUADDR
        jsr render_linecap_level_lines
        rts

gameMode_levelMenu_processPlayer1Navigation:
        ; this copying is an artefact of the original
        lda newlyPressedButtons_player1
        sta newlyPressedButtons

.if SAVE_HIGHSCORES
        lda levelControlMode
        cmp #4
        bne @notClearingHighscores
        lda newlyPressedButtons_player1
        cmp #BUTTON_START
        bne @notClearingHighscores
        lda #$01
        sta soundEffectSlot1Init
        lda #0
        sta levelControlMode
        jsr resetScores
        jsr resetSavedScores
        jsr updateAudioWaitForNmiAndResetOamStaging
        jmp gameMode_levelMenu
@notClearingHighscores:
.endif

        jsr levelControl
        jsr levelMenuRenderHearts
        jsr levelMenuRenderReady

        lda levelControlMode
        cmp #2
        bcs levelMenuCheckGoBack

levelMenuCheckStartGame:
        lda newlyPressedButtons_player1
        cmp #BUTTON_START
        bne levelMenuCheckGoBack
        lda levelControlMode
        cmp #1 ; custom
        bne @normalLevel
        lda customLevel
        sta startLevel
        jmp @startGame
@normalLevel:
        lda heldButtons_player1
        and #BUTTON_A
        beq @noA
        lda classicLevel
        clc
        adc #$0A
        sta classicLevel
@noA:
        lda classicLevel
        sta startLevel
@startGame:
        ; lda startLevel
        ldy practiseType
        cpy #MODE_MARATHON
        bne @noLevelModification
        ldy marathonModifier
        cpy #2 ; marathon mode 2 starts at level 0
        bne @noLevelModification
        lda #0
@noLevelModification:
        sta levelNumber
        lda #$00
        sta gameModeState
        lda #$02
        sta soundEffectSlot1Init
        jsr makeNotReady
        inc gameMode
        rts

levelMenuCheckGoBack:
.if !NO_MENU
        lda newlyPressedButtons_player1
        cmp #BUTTON_B
        bne @continue
        lda #$02
        sta soundEffectSlot1Init
        ; jsr makeNotReady ; not needed, done on gametype screen
        dec gameMode
        rts
.endif
@continue:

shredSeedAndContinue:
        ; seed shredder
@chooseRandomHole_player1:
        ldx #rng_seed
        jsr generateNextPseudorandomNumber
        lda rng_seed
        and #$0F
        cmp #$0A
        bpl @chooseRandomHole_player1
@chooseRandomHole_player2:
        ldx #rng_seed
        jsr generateNextPseudorandomNumber
        lda rng_seed
        and #$0F
        cmp #$0A
        bpl @chooseRandomHole_player2

        jsr updateAudioWaitForNmiAndResetOamStaging
        jmp gameMode_levelMenu_processPlayer1Navigation

makeNotReady:
        lda heartsAndReady
        and #$F
        sta heartsAndReady
        rts

levelControl:
        lda levelControlMode
        jsr switch_s_plus_2a
        .addr   levelControlNormal
        .addr   levelControlCustomLevel
        .addr   levelControlHearts
        .addr   levelControlClearHighScores
        .addr   levelControlClearHighScoresConfirm

.if SAVE_HIGHSCORES
levelControlClearHighScores:
        lda #$20
        sta spriteXOffset
        lda #$C8
        sta spriteYOffset
        lda #$C
        sta spriteIndexInOamContentLookup
        jsr stringSprite

        jsr highScoreClearUpOrLeave

        lda newlyPressedButtons_player1
        cmp #BUTTON_START
        bne @notStart
        lda #$01
        sta soundEffectSlot1Init
        lda #4
        sta levelControlMode
@notStart:
        rts

levelControlClearHighScoresConfirm:
        lda #$20
        sta spriteXOffset
        lda #$C8
        sta spriteYOffset
        lda #$D
        sta spriteIndexInOamContentLookup
        jsr stringSprite

highScoreClearUpOrLeave:
        lda newlyPressedButtons_player1
        cmp #BUTTON_B
        bne @notB
        lda #$0
        sta levelControlMode
@notB:
        lda newlyPressedButtons
        cmp #BUTTON_UP
        bne @ret
        lda #$01
        sta soundEffectSlot1Init
        lda #$2
        sta levelControlMode
@ret:
        rts
.else
levelControlClearHighScores:
levelControlClearHighScoresConfirm:
        lda #0
        sta levelControlMode
        rts
.endif

levelControlCustomLevel:
        jsr handleReadyInput
        lda frameCounter
        and #$03
        beq @indicatorEnd
        lda #$4E
        sta spriteYOffset
        lda #$B0
        sta spriteXOffset
        lda #$21
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging
@indicatorEnd:

        ; lda #BUTTON_RIGHT
        ; jsr menuThrottle
        ; beq @checkUpPressed
        ; clc
        ; lda customLevel
        ; adc #$A
        ; sta customLevel
        ; jsr @changeLevel
; @checkUpPressed:
        lda #BUTTON_UP
        jsr menuThrottle
        beq @checkDownPressed
        inc customLevel
        jsr @changeLevel
@checkDownPressed:
        lda #BUTTON_DOWN
        jsr menuThrottle
        beq @checkLeftPressed
        dec customLevel
        jsr @changeLevel
@checkLeftPressed:

        lda newlyPressedButtons
        cmp #BUTTON_LEFT
        bne @ret
        lda #$01
        sta soundEffectSlot1Init
        lda #$0
        sta levelControlMode
@ret:
        rts

@changeLevel:
        lda #$1
        sta soundEffectSlot1Init
        lda renderFlags
        ora #RENDER_LINES
        sta renderFlags
        rts

levelControlHearts:
MAX_HEARTS := 7
        lda #BUTTON_LEFT
        jsr menuThrottle
        beq @checkRightPressed
        lda heartsAndReady
        and #$F
        beq @checkRightPressed
        lda #$01
        sta soundEffectSlot1Init
        dec heartsAndReady
        jsr @changeHearts
@checkRightPressed:
        lda #BUTTON_RIGHT
        jsr menuThrottle
        beq @checkUpPressed
        lda heartsAndReady
        and #$F
        cmp #MAX_HEARTS
        bpl @checkUpPressed
        inc heartsAndReady
        jsr @changeHearts
@checkUpPressed:

.if SAVE_HIGHSCORES
        ; to clear mode
        jsr detectSRAM
        beq @notClearMode
        lda newlyPressedButtons
        cmp #BUTTON_DOWN
        bne @notClearMode
        lda #$01
        sta soundEffectSlot1Init
        lda #$3
        sta levelControlMode
@notClearMode:
.endif

        ; to normal mode
        lda newlyPressedButtons
        cmp #BUTTON_UP
        bne @ret
        lda #$01
        sta soundEffectSlot1Init
        lda #$0
        sta levelControlMode
@ret:
        rts

@changeHearts:
        lda #$01
        sta soundEffectSlot1Init
        rts

handleReadyInput:
        lda newlyPressedButtons
        cmp #BUTTON_SELECT
        bne @notSelect
        lda #$01
        sta soundEffectSlot1Init
        lda heartsAndReady
        eor #$80
        sta heartsAndReady
@notSelect:
        rts

levelControlNormal:
        jsr handleReadyInput
        ; normal ctrl
        lda newlyPressedButtons
        cmp #BUTTON_RIGHT
        bne @checkLeftPressed
        lda #$01
        sta soundEffectSlot1Init
        lda classicLevel
        cmp #$9
        beq @toCustomLevel
        inc classicLevel
@checkLeftPressed:
        lda newlyPressedButtons
        cmp #BUTTON_LEFT
        bne @checkDownPressed
        lda #$01
        sta soundEffectSlot1Init
        lda classicLevel
        beq @checkDownPressed
        dec classicLevel
@checkDownPressed:
        lda newlyPressedButtons
        cmp #BUTTON_DOWN
        bne @checkUpPressed
        lda #$01
        sta soundEffectSlot1Init
        lda classicLevel
        cmp #$05
        bpl @toHearts
        clc
        adc #$05
        sta classicLevel
        jmp @checkUpPressed

@toHearts:
        jsr makeNotReady
        inc levelControlMode
@toCustomLevel:
        inc levelControlMode
        rts

@checkUpPressed:
        lda newlyPressedButtons
        cmp #BUTTON_UP
        bne @checkAPressed
        lda #$01
        sta soundEffectSlot1Init
        lda classicLevel
        cmp #$05
        bmi @checkAPressed
        sec
        sbc #$05
        sta classicLevel
        jmp @checkAPressed

@checkAPressed:
        lda frameCounter
        and #$03
        beq @ret
; @showSelectionLevel:
        ldx classicLevel
        lda levelToSpriteYOffset,x
        sta spriteYOffset
        lda #$00
        sta spriteIndexInOamContentLookup
        ldx classicLevel
        lda levelToSpriteXOffset,x
        sta spriteXOffset
        jsr loadSpriteIntoOamStaging
@ret:
        rts

levelMenuRenderHearts:
        lda #$1E
        sta spriteIndexInOamContentLookup
        lda #$7A
        sta spriteYOffset
        lda #$38
        sta spriteXOffset
        lda heartsAndReady
        and #$F
        sta tmpZ
@heartLoop:
        lda tmpZ
        beq @heartEnd
        jsr loadSpriteIntoOamStaging
        lda spriteXOffset
        adc #$A
        sta spriteXOffset
        dec tmpZ
        bcc @heartLoop
@heartEnd:

        lda levelControlMode
        cmp #2
        bne @skipCursor
        lda frameCounter
        and #$03
        beq @skipCursor
        lda #$1F
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging
@skipCursor:
        rts

levelMenuRenderReady:
        lda heartsAndReady
        and #$F0
        beq @notReady
        lda #$4f
        sta spriteYOffset
        lda #$88
        sta spriteXOffset
        lda #$20
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging
@notReady:
        rts

levelToSpriteYOffset:
        .byte   $53,$53,$53,$53,$53,$63,$63,$63
        .byte   $63,$63
levelToSpriteXOffset:
        .byte   $34,$44,$54,$64,$74,$34,$44,$54
        .byte   $64,$74
musicSelectionTable:
        .byte   $03,$04,$05,$FF,$06,$07,$08,$FF
