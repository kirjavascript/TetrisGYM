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
            gameMode_speedTest, \
            gameMode_calibrate

.enum
GAMEMODE_BOOTSCREEN
GAMEMODE_WAITSCREEN
GAMEMODE_GAMETYPEMENU
GAMEMODE_LEVELMENU
GAMEMODE_PLAY
GAMEMODE_UNUSED1
GAMEMODE_UNUSED2
GAMEMODE_SPEEDTEST
GAMEMODE_CALIBRATE
.endenum



.include "bootscreen.asm"
.include "waitscreen.asm"
.include "../menu/menu.asm"
.include "levelmenu.asm"

gameMode_playAndEndingHighScore_jmp:
        jsr branchOnGameModeState
        rts

.include "speedtest.asm"
