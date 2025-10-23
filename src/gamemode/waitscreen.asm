gameMode_waitScreen:
        lda #0
        sta screenStage
waitScreenLoad:
        lda #$0
        sta renderMode
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
        lda #NMIEnable
        sta currentPpuCtrl
.if INES_MAPPER <> 0
; NROM (and possibly FDS in the future) won't load the 2nd bankset
; and will instead use the title/menu chrset letters.  This won't be noticeable
; unless a graphic is added 
        lda #CHRBankSet1
        jsr changeCHRBanks
.endif
        jsr bulkCopyToPpu
        .addr wait_palette
        jsr copyRleNametableToPpu
        .addr legal_nametable

        lda screenStage
        cmp #2
        bne @justLegal
        ; jsr bulkCopyToPpu
        ; .addr title_nametable_patch
@justLegal:

        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        jsr updateAudioWaitForNmiAndResetOamStaging

        ; if title, skip wait
        lda screenStage
        cmp #2
        beq waitLoopCheckStart

        lda #$FF
        ldx palFlag
        ; cpx #0 ; ldx sets z flag
        beq @notPAL
        lda #$CC
@notPAL:
        sta sleepCounter
@loop:
        ; if second wait, skip render loop
        lda screenStage
        cmp #1
        beq waitLoopCheckStart

        jsr updateAudioWaitForNmiAndResetOamStaging
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
        lda sleepCounter
        bne @loop
        inc screenStage
        jmp @justLegal

waitLoopCheckStart:
        lda screenStage
        cmp #1
        bne @title
        lda sleepCounter
        beq waitLoopNext
@title:
        lda newlyPressedButtons_player1
        cmp #BUTTON_START
        beq waitLoopNext
        jsr updateAudioWaitForNmiAndResetOamStaging
        jmp waitLoopCheckStart
waitLoopNext:
        ldx #$02
        lda screenStage
        cmp #2
        beq waitLoopContinue
        stx soundEffectSlot1Init
        inc screenStage
        jmp waitScreenLoad
waitLoopContinue:
        stx soundEffectSlot1Init
        inc gameMode
        rts
