gameMode_bootScreen: ; boot
        ; ABSS goes to gameTypeMenu instead of here

        ; reset cursors
        lda #$0
        sta practiseType
        sta menuSeedCursorIndex

        ; levelMenu stuff
        sta levelControlMode
        lda #INITIAL_CUSTOM_LEVEL
        sta customLevel

        ; detect region
        jsr updateAudioAndWaitForNmi
        jsr checkRegion

.if !QUAL_BOOT
        ; check if qualMode is already set
        lda qualFlag
        bne @qualBoot
        ; hold select to start in qual mode

        lda heldButtons_player1
        and #BUTTON_SELECT
        beq @nonQualBoot
.endif
@qualBoot:
        lda #1
        sta gameMode
        lda #1
        sta qualFlag
        jmp gameMode_waitScreen

@nonQualBoot:
        ; set start level to 8/18
        lda #$8
        sta classicLevel
        lda #2
        sta gameMode
        rts
