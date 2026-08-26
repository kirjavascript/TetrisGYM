gameModeState_handlePause:
        lda renderMode
        cmp #RENDER_PLAY
        bne @ret

        lda newlyPressedButtons_player1
        and #$10
        beq @ret

@startPressed:
        ; do nothing if curtain is being lowered
        lda disablePauseFlag
        bne @ret
        lda playState
        cmp #$0A
        beq @ret
        jsr pause

@ret:   inc gameModeState ; 8
        rts

pause:
        lda #$05
        sta musicStagingNoiseHi

        lda qualFlag
        beq @pauseSetupNotClassic

@pauseSetupClassic:
        lda #$16
        sta PPUMASK
@pauseSetupNotClassic:
        lda #RENDER_PAUSE
        sta renderMode

@pauseSetupPart2:
        jsr updateAudioWaitForNmiAndResetOamStaging

@pauseLoop:
        lda qualFlag
        beq @pauseLoopNotClassic

@pauseLoopClassic:
        lda #$70
        sta spriteXOffset
        lda #$77
        sta spriteYOffset
        jmp @pauseLoopCommon

@pauseLoopNotClassic:
        lda #PAUSE_SPRITE_X
        sta spriteXOffset
        lda #PAUSE_SPRITE_Y
        sta spriteYOffset

@pauseLoopCommon:
        ldx #>STR_PAUSE
        ldy #<STR_PAUSE
        lda debugFlag
        beq @notDebug
        ldx #>STR_BLOCK
        ldy #<STR_BLOCK
@notDebug:
        jsr stringSpriteXY

        ; block tool hud - X/Y/Piece
        lda debugFlag
        beq @noDebugHUD
        lda #$70
        sta spriteXOffset
        lda #$60
        sta spriteYOffset
        lda #tetriminoX
        sta byteSpriteAddr
        lda #0
        sta byteSpriteAddr+1
        lda #0
        sta byteSpriteTile
        lda #3
        sta byteSpriteLen
        jsr byteSprite
@noDebugHUD:

        lda qualFlag
        bne @pauseCheckStart

        jsr practiseGameHUD
        jsr debugMode
        ; debugMode calls stageSpriteForNextPiece, stageSpriteForCurrentPiece

@pauseCheckStart:
        lda newlyPressedButtons_player1
        cmp #$10
        beq @resume
        jsr updateAudioWaitForNmiAndResetOamStaging
        jmp @pauseLoop

@resume:
        lda #$1E
        sta PPUMASK
        lda #$00
        sta musicStagingNoiseHi
        sta vramRow
        lda #RENDER_PLAY
        sta renderMode
        rts
