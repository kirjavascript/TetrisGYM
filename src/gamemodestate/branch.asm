branchOnGameModeState:
        lda #0
        sta mainLoopWait
        branchTo gameModeState, \
            gameModeState_initGameBackground, \
            gameModeState_initGameState, \
            gameModeState_updateCountersAndNonPlayerState, \
            gameModeState_handleGameOver, \
            gameModeState_updatePlayer1, \
            gameModeState_next, \
            gameModeState_checkForResetKeyCombo, \
            gameModeState_handlePause, \
            gameModeState_vblankThenRunState2

gameModeState_next: ; used to be updatePlayer2
        inc gameModeState
        rts

gameModeState_vblankThenRunState2:
        lda #$02
        sta gameModeState
        jmp updateAudioWaitForNmiAndResetOamStaging

.include "initbackground.asm"
.include "initstate.asm"
.include "handlegameover.asm"
.include "updatecounters.asm"
.include "updateplayer1.asm"
.include "checkforabss.asm"
.include "pause.asm"
