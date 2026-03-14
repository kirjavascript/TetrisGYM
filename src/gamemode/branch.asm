; 2nd and 3rd instances of playAndEndingHighScore_jmp used to be demo and startDemo respectively
branchOnGameMode:
        branchTo gameMode, \
            gameMode0, \
            gameMode1, \
            gameMode2, \
            gameMode_levelMenu, \
            gameMode_playAndEndingHighScore_jmp, \
            gameMode_playAndEndingHighScore_jmp, \
            gameMode_playAndEndingHighScore_jmp, \
            gameMode_speedTest

.include "bootscreen.asm"
.include "waitscreen.asm"
.include "gametypemenu/menu.asm"
.include "levelmenu.asm"

gameMode0:
        lda #$00
        sta renderMode

        ; reset cursors
        lda #$0
        sta practiseType
        sta menuSeedCursorIndex

        ; levelMenu stuff
        sta levelControlMode
        lda #INITIAL_CUSTOM_LEVEL
        sta customLevel

        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr checkRegion
.if KEYBOARD = 1
        ; todo test timing for keyboard
        jsr detectKeyboard
.endif
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

        jsr bulkCopyToPpu
        .addr legal_nametable_patch

        jsr waitForVBlankAndEnableNmi

        jsr stageBootSprites
        jsr updateAudioWaitForNmiAndResetOamStaging

        dec sleepCounter
        jsr stageBootSprites
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        lda #$01
        sta qualFlag

        lda #$00
        sta frameCounter+1
gameMode0Loop:
        lda qualFlag
        bne @wait

        lda newlyPressedButtons_player1
        and #BUTTON_START
        bne @goToGameMode1
@wait:
        jsr stageBootSprites
        jsr updateAudioWaitForNmiAndResetOamStaging

        lda sleepCounter
        bne gameMode0Loop

        lda frameCounter+1
        cmp #$02
        beq @goToGameMode1

        ; this is the point where start can be pressed
        lda #$00
        sta qualFlag

        dec sleepCounter
        bne gameMode0Loop
@goToGameMode1:
        inc gameMode
        rts


gameMode1:
        lda #$00
        sta renderMode

        ; reset cursors
        lda #$0
        sta practiseType
        sta menuSeedCursorIndex

        ; levelMenu stuff
        sta levelControlMode
        lda #INITIAL_CUSTOM_LEVEL
        sta customLevel

        jsr updateAudioWaitForNmiAndDisablePpuRendering
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

        jsr bulkCopyToPpu
        .addr title_nametable_patch

        jsr waitForVBlankAndEnableNmi
        jsr stageBootSprites
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr stageBootSprites
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        lda #$00
        sta frameCounter+1

gameMode1Loop:
        jsr stageBootSprites
        jsr updateAudioWaitForNmiAndResetOamStaging

        lda newlyPressedButtons_player1
        and #BUTTON_START
        bne @goToGameMode2

; this is the point vanilla enters demo mode
; go to game select menu page instead
        lda frameCounter+1
        cmp #$05
        bne gameMode1Loop

        ; use this for now to signal demo start
        lda #$01
        sta qualFlag

@goToGameMode2:
        inc gameMode
        rts

gameMode2:
        lda #$00
        sta renderMode

        ; reset cursors
        lda #$0
        sta practiseType
        sta menuSeedCursorIndex

        ; levelMenu stuff
        sta levelControlMode
        lda #INITIAL_CUSTOM_LEVEL
        sta customLevel

        jsr updateAudioWaitForNmiAndDisablePpuRendering
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

        jsr bulkCopyToPpu
        .addr menu_nametable_patch

        jsr waitForVBlankAndEnableNmi
        jsr stageBootSprites
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr stageBootSprites
        jsr updateAudioWaitForNmiAndEnablePpuRendering


        lda qualFlag
        beq @skipDemoShuffle
        ldx #rng_seed
        jsr generateNextPseudorandomNumber
        lda qualFlag ; temporary use to signal demo start
@skipDemoShuffle:

gameMode2Loop:
        lda newlyPressedButtons_player1
        and #BUTTON_START
        bne @goToGameMode3

        jsr stageBootSprites
        jsr updateAudioWaitForNmiAndResetOamStaging
        jmp gameMode2Loop

@goToGameMode3:
        inc gameMode
        rts

gameMode_playAndEndingHighScore_jmp:
        jsr branchOnGameModeState
        rts

.include "speedtest.asm"

stageBootSprites:
        ldx #frameCounter+1
        jsr stageZeroPage
        ldx #frameCounter
        jsr stageZeroPage

        ldx #rng_seed+1
        jsr stageZeroPage
        ldx #rng_seed
        jsr stageZeroPage

        ldx #sleepCounter
        jsr stageZeroPage
        ldx #generalCounter
        jsr stageZeroPage

        ldx #gameMode
        jsr stageZeroPage

        rts

stageZeroPage:
        lda oamStagingLength
        and #$0F
        asl
        clc
        adc #$1A
        sta spriteXOffset
        lda oamStagingLength
        and #$F0
        clc
        adc #$20
        sta spriteYOffset
        stx byteSpriteAddr
        lda #0
        sta byteSpriteAddr+1
        sta byteSpriteTile
        lda #1
        sta byteSpriteLen
        jmp byteSprite

render_mode_0:
; rustico's run_until_vblank stops a few cycles into scanline 242 where nmi
; business is being done and messes up tests.  for testing purposes while nothing
; is needed in nmi, a minimum amount of wait time is needed so that test polling
; always reads after game logic but before the nmi affects memory values,
; specifically the frame counter and rng
    ldx #$40
@wait:
    dex
    bne @wait
    rts
