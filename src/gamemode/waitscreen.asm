gameMode_waitScreen:
        lda #0
        sta screenStage
        jsr hideSpritesAndBackground
.if INES_MAPPER <> 0
; NROM (and possibly FDS in the future) won't load the 2nd bankset
; and will instead use the title/menu chrset letters.  This won't be noticeable
; unless a graphic is added
        lda #CHRBankSet1
        jsr changeCHRBanks
.endif
        stagePatchThenWaitForNmi waitPalettePatch

        ldx #RLE_NT_LEGAL
        jsr copyRleNametableToPpu

; reenable display
        jsr resetScroll
        lda #NMIEnable
        sta currentPpuCtrl
        lda #RENDER_IDLE
        sta renderMode
        jsr showSpriteAndBackground

@setSleepCounter:
        lda #$FF
        ldx palFlag
        ; cpx #0 ; ldx sets z flag
        beq @notPAL
        lda #$CC
@notPAL:
        sta sleepCounter
@loop:
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda screenStage
        bne @checkStart
        lda qualFlag
        beq @checkStart
        lda #$1A
        sta spriteXOffset
        lda #$20
        sta spriteYOffset
        lda #sleepCounter
        sta byteSpriteAddr
        lda #0
        sta byteSpriteAddr+1
        sta byteSpriteTile
        lda #1
        sta byteSpriteLen
        jsr byteSprite
        jsr showQualWait
        jmp @checkSleepCounter
@checkStart:
        lda newlyPressedButtons_player1
        and #BUTTON_START
        bne titleScreenSetup
@checkSleepCounter:
        lda sleepCounter
        bne @loop
@exitLoop:
        inc screenStage
        lda screenStage
        cmp #1
        beq @setSleepCounter
        cmp #2
        bne titleScreenSetup
        ; wait 4 additional frames before switching to title screen
        lda #4
        bne @notPAL
titleScreenSetup:
        ldx #$02
        stx soundEffectSlot1Init
        lda #1
        sta gameMode
; ignore inputs for 4 frames to line up with vanilla
        jsr waitForNmi
        jsr waitForNmi
        jsr waitForNmi
        jsr waitForNmi
        lda #0
        sta frameCounter+1
        stagePatchThenWaitForNmi titleNametablePatch
titleScreenLoop:
        lda newlyPressedButtons_player1
        cmp #BUTTON_START
        beq @exitTitle
        jsr updateAudioWaitForNmiAndResetOamStaging
        jmp titleScreenLoop
@exitTitle:
        ldx #$02
        stx soundEffectSlot1Init
        inc gameMode
        rts

showQualWait:
        lda heldButtons_player1
        and #BUTTON_START
        beq @ret

        lda #$70
        sta spriteXOffset
        lda #$80
        sta spriteYOffset
        lda #$01
        sta stringAttrib
        ldx #>STR_WAIT
        ldy #<STR_WAIT
        jsr stringSpriteXY
        dec stringAttrib
@ret:
        rts
