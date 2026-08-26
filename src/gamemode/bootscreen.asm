gameMode_bootScreen: ; boot
        ; ABSS goes to gameTypeMenu instead of here

        ; reset cursors
        lda #MODE_TETRIS
        sta practiseType

        ; levelMenu stuff
        lda #0
        sta levelControlMode

        ; detect region
        jsr updateAudioAndWaitForNmi
        jsr checkRegion

        jsr detectKeyboard
        jmp gameMode_waitScreen
