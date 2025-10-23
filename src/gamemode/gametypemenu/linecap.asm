linecapMenu:

linecapMenuCursorIndices := 3
        lda #$8
        sta renderMode
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi

        jsr clearNametable

        jsr bulkCopyToPpu
        .addr linecapMenuNametable

        lda #RENDER_LINES
        sta renderFlags

        lda #$02
        sta soundEffectSlot1Init

        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda #$10
        sta sleepCounter
@menuLoop:
        jsr updateAudioWaitForNmiAndResetOamStaging

        jsr linecapMenuRenderSprites
        jsr linecapMenuControls

        lda newlyPressedButtons_player1
        and #BUTTON_B
        bne @back
        beq @menuLoop
@back:

        lda #$02
        sta soundEffectSlot1Init
        jmp gameMode_gameTypeMenu

linecapMenuRenderSprites:
        ; when
        clc
        lda #LINECAP_WHEN_STRING_OFFSET
        adc linecapWhen
        sta spriteIndexInOamContentLookup
        lda #$6F
        sta spriteYOffset
        lda #$B0
        sta spriteXOffset
        jsr stringSpriteAlignRight

        ; how
        clc
        lda #LINECAP_HOW_STRING_OFFSET
        adc linecapHow
        sta spriteIndexInOamContentLookup
        lda #$8F
        sta spriteYOffset
        lda #$B0
        sta spriteXOffset
        jsr stringSpriteAlignRight

        ldx linecapCursorIndex
        lda linecapCursorYOffset, x
        sta spriteYOffset
        lda #$40
        sta spriteXOffset
        lda #$1D
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging
        rts

linecapMenuControls:
        lda #BUTTON_DOWN
        jsr menuThrottle
        beq @downEnd
        lda #$01
        sta soundEffectSlot1Init

        inc linecapCursorIndex
        lda linecapCursorIndex
        cmp #linecapMenuCursorIndices
        bne @downEnd
        lda #0
        sta linecapCursorIndex
@downEnd:

        lda #BUTTON_UP
        jsr menuThrottle
        beq @upEnd
        lda #$01
        sta soundEffectSlot1Init
        dec linecapCursorIndex
        lda linecapCursorIndex
        cmp #$FF
        bne @upEnd
        lda #linecapMenuCursorIndices-1
        sta linecapCursorIndex
@upEnd:

        jsr linecapMenuControlsLR
        rts

linecapMenuControlsLR:
        lda linecapCursorIndex
        jsr switch_s_plus_2a
        .addr   linecapMenuControlsWhen
        .addr   linecapMenuControlsLinesLevel
        .addr   linecapMenuControlsHow
linecapMenuControlsWhen:
        lda newlyPressedButtons_player1
        and #BUTTON_LEFT|BUTTON_RIGHT
        beq @ret
        lda #$01
        sta soundEffectSlot1Init
        lda #RENDER_LINES
        sta renderFlags
        lda linecapWhen
        eor #1
        sta linecapWhen
@ret:
        rts

linecapMenuControlsLinesLevel:
        lda #BUTTON_RIGHT
        jsr menuThrottle
        beq @notRight
        lda linecapWhen
        bne linecapMenuControlsAdjLinesUp
        lda #1
        jsr linecapMenuControlsAdjLevel
@notRight:

        lda #BUTTON_LEFT
        jsr menuThrottle
        beq @notLeft
        lda linecapWhen
        bne linecapMenuControlsAdjLinesDown
        lda #$FF
        jsr linecapMenuControlsAdjLevel
@notLeft:
        rts

linecapMenuControlsAdjLevel:
        sta tmpZ
        clc
        lda linecapLevel
        adc tmpZ
        sta linecapLevel

linecapMenuControlsBoopAndRender:
        lda #$01
        sta soundEffectSlot1Init
        lda #RENDER_LINES
        sta renderFlags
        rts

linecapMenuControlsAdjLinesUp:
        clc
        lda linecapLines
        adc #$10
        cmp #$A0
        beq @overflowLines
        sta linecapLines
        bne @noverflow
@overflowLines:
        lda #0
        sta linecapLines
        clc
        lda linecapLines+1
        adc #1
        and #$1F
        sta linecapLines+1
@noverflow:
        jmp linecapMenuControlsBoopAndRender

linecapMenuControlsAdjLinesDown:
        sec
        lda linecapLines
        beq @overflowLines
        sbc #$10
        sta linecapLines
        jmp @noverflow
@overflowLines:
        lda #$90
        sta linecapLines
        sec
        lda linecapLines+1
        sbc #1
        and #$1F
        sta linecapLines+1
@noverflow:
        jmp linecapMenuControlsBoopAndRender


linecapMenuControlsHow:
        lda #BUTTON_RIGHT
        jsr menuThrottle
        beq @notRight
        lda #$01
        sta soundEffectSlot1Init
        inc linecapHow
        lda linecapHow
        cmp #4
        bne @notRight
        lda #0
        sta linecapHow
@notRight:

        lda #BUTTON_LEFT
        jsr menuThrottle
        beq @notLeft
        lda #$01
        sta soundEffectSlot1Init
        dec linecapHow
        lda linecapHow
        cmp #$FF
        bne @notLeft
        lda #3
        sta linecapHow
@notLeft:
        rts

linecapMenuNametable: ; stripe
        .byte $21, $0A, 12, 'L','I','N','E','C','A','P',' ','M','E','N','U'
        .byte $21, $CA, 4, 'W','H','E','N'
        .byte $22, $4A, 3, 'H','O','W'
        .byte $21, $2A, $4C, $39
        .byte $FF

linecapCursorYOffsetOffset := $6F

linecapCursorYOffset:
        .byte 0+linecapCursorYOffsetOffset, 8+linecapCursorYOffsetOffset, 32+linecapCursorYOffsetOffset
