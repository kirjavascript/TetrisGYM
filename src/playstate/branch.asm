; prepareNext used to be bTypeGoalCheck
branchOnPlayStatePlayer1:
        branchTo playState, \
            playState_unassignOrientationId, \
            playState_playerControlsActiveTetrimino, \
            playState_lockTetrimino, \
            playState_checkForCompletedRows, \
            playState_noop, \
            playState_updateLinesAndStatistics, \
            playState_prepareNext , \
            playState_receiveGarbage, \
            playState_spawnNextTetrimino, \
            playState_noop, \
            playState_checkStartGameOver, \
            playState_incrementPlayState

playState_unassignOrientationId:
        lda #$13
        sta currentPiece
        rts

playState_incrementPlayState:
        inc playState
playState_noop:
        rts

.include "active.asm"
.include "lock.asm"
.include "completedrows.asm"
.include "updatestats.asm"
.include "preparenext.asm"
.include "garbage.asm"
.include "spawnnext.asm"
.include "gameover_rocket.asm"

.include "util.asm"
