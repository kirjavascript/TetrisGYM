.ifndef INES_MAPPER ; is set via ca65 flags
INES_MAPPER := 1 ; supports 1 and 3 (MMC1 / CNROM)
.endif

PRACTISE_MODE := 1
NO_MUSIC := 1
SAVE_HIGHSCORES := 1

; dev flags
AUTO_WIN := 0 ; press select to end game
NO_SCORING := 0 ; breaks pace
NO_SFX := 0
NO_MENU := 0
ALWAYS_CURTAIN := 0

INITIAL_CUSTOM_LEVEL := 29
INITIAL_LINECAP_LEVEL := 39
INITIAL_LINECAP_LINES := $30 ; bcd
INITIAL_LINECAP_LINES_1 := 3 ; hex (lol)
BTYPE_START_LINES := $25 ; bcd
MENU_HIGHLIGHT_COLOR := $12 ; $12 in gym, $16 in original
BLOCK_TILES := $7B
EMPTY_TILE := $EF
INVISIBLE_TILE := $43
TETRIMINO_X_HIDE := $EF

PAUSE_SPRITE_X := $74
PAUSE_SPRITE_Y := $58
; yobi-style
; PAUSE_SPRITE_X := $C4
; PAUSE_SPRITE_Y := $16

BUTTON_DOWN := $4
BUTTON_UP := $8
BUTTON_RIGHT := $1
BUTTON_LEFT := $2
BUTTON_B := $40
BUTTON_A := $80
BUTTON_SELECT := $20
BUTTON_START := $10
BUTTON_DPAD := BUTTON_UP | BUTTON_DOWN | BUTTON_LEFT | BUTTON_RIGHT

MODE_TETRIS := 0
MODE_TSPINS := 1
MODE_SEED := 2
MODE_PARITY := 3
MODE_PACE := 4
MODE_PRESETS := 5
MODE_TYPEB := 6
MODE_FLOOR := 7
MODE_TAP := 8
MODE_TRANSITION := 9
MODE_TAPQTY := 10
MODE_CHECKERBOARD := 11
MODE_GARBAGE := 12
MODE_DROUGHT := 13
MODE_DAS := 14
MODE_KILLX2 := 15
MODE_INVISIBLE := 16
MODE_HARDDROP := 17
MODE_SPEED_TEST := 18
MODE_SCORE_DISPLAY := 19
MODE_HZ_DISPLAY := 20
MODE_INPUT_DISPLAY := 21
MODE_DISABLE_FLASH := 22
MODE_DISABLE_PAUSE := 23
MODE_GOOFY := 24
MODE_DEBUG := 25
MODE_LINECAP := 26
MODE_DASONLY := 27
MODE_QUAL := 28
MODE_PAL := 29
MODE_QTAPALLPIECES := 30

MODE_QUANTITY := 31
MODE_GAME_QUANTITY := 18

SCORING_CLASSIC := 0 ; for scoringModifier
SCORING_LETTERS := 1
SCORING_SEVENDIGIT := 2
SCORING_FLOAT := 3
SCORING_SCORECAP := 4

LINECAP_KILLX2 := 1
LINECAP_FLOOR := 2
LINECAP_INVISIBLE := 3
LINECAP_HALT := 4

LINECAP_WHEN_STRING_OFFSET := $10
LINECAP_HOW_STRING_OFFSET := $12

MENU_SPRITE_Y_BASE := $47
MENU_MAX_Y_SCROLL := $70
MENU_TOP_MARGIN_SCROLL := 7 ; in blocks

; menuConfigSizeLookup
; menu ram is defined at menuRAM in ./ram.asm
.define MENUSIZES $0, $0, $0, $0, $F, $7, $8, $C, $20, $10, $1F, $8, $4, $12, $10, $0, $0, $0, $0, $4, $1, $1, $1, $1, $1, $1, $1, $1, $1, $1, $1

.macro MODENAMES
    .byte   "TETRIS"
    .byte   "TSPINS"
    .byte   " SEED "
    .byte   "STACKN"
    .byte   " PACE "
    .byte   "SETUPS"
    .byte   "B-TYPE"
    .byte   "FLOOR "
    .byte   "QCKTAP"
    .byte   "TRNSTN"
    .byte   "TAPQTY"
    .byte   "CKRBRD"
    .byte   "GARBGE"
    .byte   "LOBARS"
    .byte   "DASDLY"
    .byte   "KILLX2"
    .byte   "INVZBL"
    .byte   "HRDDRP"
.endmacro
