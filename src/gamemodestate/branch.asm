; the return value of this routine dictates if we should wait for nmi or not right after

branchOnGameModeState:
        lda gameModeState
        jsr switch_s_plus_2a
        .addr   gameModeState_initGameBackground ; gms: 1 acc: 0 - ne
        .addr   gameModeState_initGameState ; gms: 2 acc: 4/0 - ne
        .addr   gameModeState_updateCountersAndNonPlayerState ; gms: 3 acc: 0/1 - ne
        .addr   gameModeState_handleGameOver ; gms: 4 acc: eq (set to $9) if gameOver, $1 otherwise (ne)
        .addr   gameModeState_updatePlayer1 ; gms: 5 acc: $FF - ne
        .addr   gameModeState_next ; gms: 6 acc: $1 ne
        .addr   gameModeState_checkForResetKeyCombo ; gms: 7 acc: 0 or heldButtons - eq if holding down, left and right
        .addr   gameModeState_handlePause ; gms: 8 acc: 0/3 - ne
        .addr   gameModeState_vblankThenRunState2 ; gms: 2 acc eq (set to $2)

gameModeState_next: ; used to be updatePlayer2
        inc gameModeState
        lda #$1 ; acc should not be equal
        rts

gameModeState_vblankThenRunState2:
        lda #$02
        sta gameModeState
        rts

.include "initbackground.asm"
.include "initstate.asm"
.include "handlegameover.asm"
.include "updatecounters.asm"
.include "updateplayer1.asm"
.include "checkforabss.asm"
.include "pause.asm"
