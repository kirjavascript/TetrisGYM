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

gameMode_playAndEndingHighScore_jmp:
        jsr gameMode_playAndEndingHighScore
        rts

.include "gamemode_bootscreen.asm"
.include "gamemode_waitscreen.asm"
.include "gamemode_gametypemenu.asm"
.include "gamemode_levelmenu.asm"
; play and ending
.include "gamemode_speedtest.asm"
