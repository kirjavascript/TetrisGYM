branchOnGameMode:
        lda gameMode
        jsr switch_s_plus_2a
        .addr   gameMode_bootScreen
        .addr   gameMode_waitScreen
        .addr   gameMode_gameTypeMenu
        .addr   gameMode_levelMenu
        .addr   gameMode_playAndEndingHighScore_jmp
        .addr   gameMode_playAndEndingHighScore_jmp
        .addr   gameMode_playAndEndingHighScore_jmp ; used to be startDemo
        .addr   gameMode_speedTest

.include "bootscreen.asm"
.include "waitscreen.asm"
.include "gametypemenu/menu.asm"
.include "levelmenu.asm"

gameMode_playAndEndingHighScore_jmp:
        jsr branchOnGameModeState
        rts

.include "speedtest.asm"
