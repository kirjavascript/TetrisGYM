; the return value of this routine dictates if we should wait for nmi or not right after
; initGameBackground               gms: 1 acc: 0 - ne
; initGameState                    gms: 2 acc: 4/0 - ne
; updateCountersAndNonPlayerState  gms: 3 acc: 0/1 - ne
; handleGameOver                   gms: 4 acc: eq (set to $9) if gameOver, $1 otherwise (ne)
; updatePlayer1                    gms: 5 acc: $FF - ne
; next                             gms: 6 acc: $1 ne
; checkForResetKeyCombo            gms: 7 acc: 0 or heldButtons - eq if holding down, left and right
; handlePause                      gms: 8 acc: 0/3 - ne
; vblankThenRunState2              gms: 2 acc eq (set to $2)

branchOnGameModeState:
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
