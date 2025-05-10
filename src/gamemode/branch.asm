; 2nd and 3rd instances of playAndEndingHighScore_jmp used to be demo and startDemo respectively
branchOnGameMode:
        branchTo gameMode, \
            gameMode_bootScreen, \
            gameMode_waitScreen, \
            gameMode_gameTypeMenu, \
            gameMode_levelMenu, \
            gameMode_playAndEndingHighScore_jmp, \
            gameMode_playAndEndingHighScore_jmp, \
            gameMode_playAndEndingHighScore_jmp, \
            gameMode_speedTest

.include "bootscreen.asm"
.include "waitscreen.asm"
.include "gametypemenu/menu.asm"
.include "levelmenu.asm"

gameMode_playAndEndingHighScore_jmp:
        jsr branchOnGameModeState
        rts

.include "speedtest.asm"
