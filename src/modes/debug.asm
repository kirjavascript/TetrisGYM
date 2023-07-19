; debugMode is called in gameModeState_handlePause
; checkDebugGameplay is called in gameModeState_updatePlayer1

checkDebugGameplay:
        lda debugFlag
        cmp #0
        beq @done

        ; sprite
        jsr renderDebugHUD

        ; controls
        lda heldButtons_player1
        and #BUTTON_SELECT
        beq @done

        lda newlyPressedButtons_player1
        and #BUTTON_B
        beq @done
        ldy #0
        jsr getSlotPointer
        lda (pointerAddr), y ; check slot is empty
        beq @done
        jsr loadState
        jsr renderStateGameplay
        jmp @done
@done:
        rts

debugSelectMenuControls:
        lda heldButtons_player1
        and #BUTTON_SELECT
        beq debugContinue

        lda newlyPressedButtons_player1
        and #BUTTON_LEFT+BUTTON_RIGHT
        beq @skipDebugType
        ; toggle mode
        lda debugLevelEdit
        eor #1
        sta debugLevelEdit
@skipDebugType:

        jsr checkSaveStateControlsDebug

        ; fallthrough

debugDrawPieces:
        jsr renderDebugHUD

        ; handle pieces / X
        jsr stageSpriteForNextPiece

        lda debugLevelEdit
        and #1
        bne @handleX
        jsr stageSpriteForCurrentPiece
        rts

@handleX:
        ; load X
        lda tetriminoX
        asl
        asl
        asl
        clc
        adc #$60
        sta spriteXOffset

        ; load Y
        lda tetriminoY
        asl
        asl
        asl
        clc
        adc #$2F
        sta spriteYOffset

        lda #$16
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging
        rts
debugPauseDrawPieces:
        jsr stageSpriteForNextPiece
        jsr stageSpriteForCurrentPiece
        rts

debugMode:

DEBUG_ORIGINAL_Y := tmp1
DEBUG_ORIGINAL_CURRENT_PIECE := tmp2

        lda debugFlag
        cmp #0
        beq debugPauseDrawPieces

        jmp debugSelectMenuControls
debugContinue:
        lda tetriminoX
        sta originalY
        lda tetriminoY
        sta DEBUG_ORIGINAL_Y
        lda currentPiece
        sta DEBUG_ORIGINAL_CURRENT_PIECE

        ; update position
        lda #BUTTON_UP
        jsr menuThrottle
        beq @notPressedUp
        dec tetriminoY
@notPressedUp:
        lda #BUTTON_DOWN
        jsr menuThrottle
        beq @notPressedDown
        inc tetriminoY
@notPressedDown:
        lda #BUTTON_LEFT
        jsr menuThrottle
        beq @notPressedLeft
        dec tetriminoX
@notPressedLeft:
        lda #BUTTON_RIGHT
        jsr menuThrottle
        beq @notPressedRight
        inc tetriminoX
@notPressedRight:

        ; check mode
        lda debugLevelEdit
        and #1
        bne handleLevelEditor

        ; handle next piece
        lda heldButtons_player1
        and #BUTTON_B
        beq @notPressedBothB
        lda newlyPressedButtons_player1
        and #BUTTON_A
        beq @notPressedBothB
        jmp @changeNext
@notPressedBothB:
        lda heldButtons_player1
        and #BUTTON_A
        beq @notPressedBothA
        lda newlyPressedButtons_player1
        and #BUTTON_B
        beq @notPressedBothA
        jmp @changeNext
@notPressedBothA:

        ; change current piece
        lda #BUTTON_B
        jsr menuThrottle
        beq @notPressedB
        dec currentPiece
        bpl @notPressedB
        lda #$12
        sta currentPiece
@notPressedB:

        lda #BUTTON_A
        jsr menuThrottle
        beq @notPressedA
        inc currentPiece
        lda currentPiece
        cmp #$13
        bne @notPressedA
        lda #$00
        sta currentPiece
@notPressedA:

        ; handle piece
        jsr isPositionValid
        bne @restore_
        jmp debugDrawPieces

@restore_:
        lda originalY
        sta tetriminoX
        lda DEBUG_ORIGINAL_Y
        sta tetriminoY
        lda DEBUG_ORIGINAL_CURRENT_PIECE
        sta currentPiece
        jmp debugDrawPieces

@changeNext:
        lda debugNextCounter
        and #7
        cmp #7
        bne @notDupe
        inc debugNextCounter
@notDupe:
        tax
        lda spawnTable,x
        sta nextPiece

        inc debugNextCounter
        jmp debugDrawPieces


handleLevelEditor:
        jsr debugDrawPieces

        ; handle editing

        lda newlyPressedButtons_player1
        and #BUTTON_B
        beq @notPressedB
        jsr @getPos
        ldx tmp3
        lda #EMPTY_TILE
        sta playfield, x
        jmp renderDebugPlayfield

@notPressedB:

        lda newlyPressedButtons_player1
        and #BUTTON_A
        beq @notPressedA
        jsr @getPos
        ldx tmp3
        lda #$7B
        sta playfield, x
        jmp renderDebugPlayfield

@notPressedA:

        rts

@getPos:
        ; multiply by 10
        ldx tetriminoY
        lda multBy10Table,x

        ; add X
        adc tetriminoX
        sta tmp3
        dec tmp3
        rts

checkSaveStateControlsDebug:
        ; load / save
        lda newlyPressedButtons_player1
        and #BUTTON_B
        beq @notPressedB
        ldy #0
        jsr getSlotPointer
        lda (pointerAddr), y ; check slot is empty
        beq @notPressedB
        jsr loadState
        jsr renderDebugPlayfield
        jmp @notPressedA ; dont allow both actions to happen at once
@notPressedB:
        lda newlyPressedButtons_player1
        and #BUTTON_A
        beq @notPressedA
        jsr saveState
@notPressedA:
        ; save slot
        lda newlyPressedButtons_player1
        and #BUTTON_UP
        beq @notPressedUp
        jsr renderDebugSaveSlot
        inc saveStateSlot
        lda saveStateSlot
        cmp #$A
        bne @notPressedUp
        lda #0
        sta saveStateSlot
@notPressedUp:
        lda newlyPressedButtons_player1
        and #BUTTON_DOWN
        beq @notPressedDown
        lda saveStateSlot
        bne @noWrap
        lda #$A
        sta saveStateSlot
@noWrap:
        dec saveStateSlot
        jsr renderDebugSaveSlot
@notPressedDown:
        rts

renderDebugPlayfield:
        lda #$00
        sta vramRow
        rts

renderStateGameplay:
        lda #$03
        sta playState
        lda #1
        sta saveStateDirty ; cleared in game init
        lda #$20
        sta spawnDelay
        lda #$00
        sta tetriminoY
        lda #$05
        sta tetriminoX
        rts

renderDebugSaveSlot:
        lda pausedOutOfDateRenderFlags
        ora #$2
        sta pausedOutOfDateRenderFlags
        rts

renderDebugHUD:
        ; savestates
        lda saveStateSpriteDelay
        beq @noSprite
        dec saveStateSpriteDelay
        lda #$C0
        sta spriteXOffset
        lda #$C8
        sta spriteYOffset
        lda saveStateSpriteType
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging
@noSprite:
        rts
