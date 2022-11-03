;  _____     _       _     _____ __ __ _____
; |_   _|___| |_ ___|_|___|   __|  |  |     |
;   | | | -_|  _|  _| |_ -|  |  |_   _| | | |
;   |_| |___|_| |_| |_|___|_____| |_| |_|_|_|
;
; TetrisGYM - A Tetris Practise ROM

.include "charmap.asm"
.include "constants.asm"
.include "io.asm"
.include "ram.asm"
.include "chr.asm"

.setcpu "6502"

.segment    "PRG_chunk1": absolute

initRam:

.include "boot.asm"

mainLoop:
        jsr branchOnGameMode
        cmp gameModeState
        bne @continue
        jsr updateAudioWaitForNmiAndResetOamStaging
@continue:
        jmp mainLoop

.include "nmi/nmi.asm"
.include "nmi/render.asm"
.include "nmi/pollcontroller.asm"

.include "gamemode/branch.asm"
    ; -> playAndEnding
.include "gamemodestate/branch.asm"
    ; -> updatePlayer1
.include "playstate/branch.asm"

.include "highscores/data.asm"
.include "highscores/util.asm"
.include "highscores/render_menu.asm"
.include "highscores/entry_screen.asm"

.include "util/core.asm"
.include "util/check_region.asm"
.include "util/bytesprite.asm"
.include "util/strings.asm"
.include "util/math.asm"
.include "util/menuthrottle.asm"
.include "util/modetext.asm"

.include "sprites/loadsprite.asm"
.include "sprites/drawrect.asm"
.include "sprites/piece.asm"

.include "data/bytebcd.asm"
.include "data/orientation.asm"
.include "data/mult.asm"

.include "palettes.asm"
.include "nametables.asm"
.include "presets/presets.asm"

; the modes/ folder contains large supplimentary routines used elsewhere
; the full mode code can be found by globally searching `MODE_` for each

.include "modes/hz.asm"
.include "modes/pace.asm"
.include "modes/debug.asm"
.include "modes/saveslots.asm"

.code

.segment    "PRG_chunk2": absolute

.include "data/demo.asm"
.include "audio.asm"

.include "modes/events.asm"
.include "modes/controllerinput.asm"
.include "modes/tapqty.asm"
.include "modes/initchecker.asm"
.include "modes/tspins.asm"
.include "modes/parity.asm"
.include "modes/preset.asm"
.include "modes/floor.asm"
.include "modes/crunch.asm"
.include "modes/qtap.asm"
.include "modes/garbage.asm"

.code

.segment    "PRG_chunk3": absolute

.include "reset.asm"

.code

.segment    "VECTORS": absolute

        .addr   nmi
        .addr   reset
        .addr   irq

.code
