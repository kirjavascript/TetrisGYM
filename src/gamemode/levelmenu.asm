gameMode_levelMenu:
        ; lag frame for tas compatibility
        lda #RENDER_DISABLE
        sta renderMode
        jsr waitForNmi
        jsr hideSpritesAndBackground
.if INES_MAPPER <> 0
        lda #CHRBankSet0
        jsr changeCHRBanks
.endif
        stagePatchThenWaitForNmi menuPalette

        ldx #RLE_NT_LEVEL_MENU
        jsr copyRleNametableToPpu

        lda #$20
        sta tmp1
        lda #$96 ; $6D is OEM position
        sta tmp2
        jsr displayModeText
        jsr showHighScores
        lda linecapWhen
        beq @noLinecapInfo
        jsr levelMenuLinecapInfo
@noLinecapInfo:
        ; patch if seeded
        ldy #$20
        ldx #$B6
        jsr patchSeed

        ; render lines when loading screen
        lda #RENDER_LINES
        sta renderFlags

; reenable display
        jsr resetScroll
        lda #NMIEnable
        sta currentPpuCtrl
        lda #RENDER_LEVEL_MENU
        sta renderMode
        jsr showSpriteAndBackground

        ; set sleep counter to wait 1 frame before shredding seed (tas compatibility)
        lda #1
        sta sleepCounter
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

linecapWhenStrings:
        .word STR_LEVEL
        .word STR_LINES

linecapHowStrings:
        .word STR_KS2
        .word STR_FLOOR
        .word STR_INVIZ
        .word STR_HALT

levelMenuLinecapInfo:
        lda #$20
        sta PPUADDR
        lda #$F5
        sta PPUADDR
        lda linecapWhen
        asl
        tay
        ; use offset, linecapWhen will be 1 or 2, never 0
        ldx linecapWhenStrings-1,y
        lda linecapWhenStrings-2,y
        tay
        jsr stringBackgroundXY

        lda #$21
        sta PPUADDR
        lda #$15
        sta PPUADDR
        lda linecapHow
        asl
        tay
        ldx linecapHowStrings+1,y
        lda linecapHowStrings+0,y
        tay
        jsr stringBackgroundXY

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
.if SAVE_HIGHSCORES
        jsr detectSRAM
        beq @notResettingSavedScores
        jsr resetSavedScores
@notResettingSavedScores:
.endif
        jsr updateAudioWaitForNmiAndResetOamStaging
        jmp gameMode_levelMenu
@notClearingHighscores:

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
        ldy marathonLevelModifier
        cpy #2
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
        lda sleepCounter
        bne @noShred ; skip first frame of seed shredding for tas compatibility
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
@noShred:
        jsr updateAudioWaitForNmiAndResetOamStaging
        jmp gameMode_levelMenu_processPlayer1Navigation

makeNotReady:
        lda heartsAndReady
        and #$F
        sta heartsAndReady
        rts

levelControl:
        branchTo levelControlMode, \
            levelControlNormal, \
            levelControlCustomLevel, \
            levelControlHearts, \
            levelControlClearHighScores, \
            levelControlClearHighScoresConfirm

levelControlClearHighScores:
        lda #$20
        sta spriteXOffset
        lda #$C8
        sta spriteYOffset
        ldx #>STR_CLEAR
        ldy #<STR_CLEAR
        jsr stringSpriteXY

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
        ldx #>STR_SURE
        ldy #<STR_SURE
        jsr stringSpriteXY

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


levelControlCustomLevel:
        jsr handleReadyInput
        lda frameCounter
        and #$03
        beq @indicatorEnd
        lda #$4E
        sta spriteYOffset
        lda #$B0
        sta spriteXOffset
        lda #SPRITE_CUSTOMLEVELCURSOR
        sta spriteIndex
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
        beq @checkRightPressed
        dec customLevel
        jsr @changeLevel
@checkRightPressed:
        lda #BUTTON_RIGHT
        jsr menuThrottle
        beq @checkLeftPressed
        lda #$0
        sta levelControlMode
        sta classicLevel
        jsr @changeLevel
@checkLeftPressed:

        lda newlyPressedButtons
        cmp #BUTTON_LEFT
        bne @ret
        lda #$01
        sta soundEffectSlot1Init
        lda #$0
        sta levelControlMode
        lda #$9
        sta classicLevel
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

        ; to clear mode
        lda newlyPressedButtons
        cmp #BUTTON_DOWN
        bne @notClearMode
        lda #$01
        sta soundEffectSlot1Init
        lda #$3
        sta levelControlMode
@notClearMode:

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
        beq @toCustomLevel
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
        lda #SPRITE_LEVELSELECTCURSOR
        sta spriteIndex
        ldx classicLevel
        lda levelToSpriteXOffset,x
        sta spriteXOffset
        jsr loadSpriteIntoOamStaging
@ret:
        rts

levelMenuRenderHearts:
        lda #SPRITE_HEARTCURSOR
        sta spriteIndex
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
        lda #SPRITE_HEART
        sta spriteIndex
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
        lda #SPRITE_READY
        sta spriteIndex
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
