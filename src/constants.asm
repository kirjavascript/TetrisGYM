.ifndef INES_MAPPER ; is set via ca65 flags
INES_MAPPER := 1000 ; 0 (NROM), 1 (MMC1), 3 (CNROM), 4 (MMC3), 5 (MMC5), and 1000 (autodetect 1/3)
.endif

.ifndef SAVE_HIGHSCORES
SAVE_HIGHSCORES := 1
.endif

.ifndef AUTO_WIN
; faster aeppoz + press select to end game
AUTO_WIN := 0
.endif

.ifndef KEYBOARD
KEYBOARD := 0
.endif

.ifndef CNROM_OVERRIDE
CNROM_OVERRIDE := 0
.endif

.ifndef ANYDAS
ANYDAS = 0
.endif

NO_MUSIC := 1

; dev flags
NO_SCORING := 0 ; breaks pace
NO_SFX := 0
NO_MENU := 0
ALWAYS_CURTAIN := 0
QUAL_BOOT := 0
SWAP_DUTY_CYCLES := 0 ; counters the duty cycle swap present in some clone consoles

INITIAL_CUSTOM_LEVEL := 29
INITIAL_LINECAP_LEVEL := 39
INITIAL_LINECAP_LINES := $30 ; bcd
INITIAL_LINECAP_LINES_1 := 3 ; hex (lol)
BTYPE_START_LINES := $25 ; bcd
MENU_HIGHLIGHT_COLOR := $12 ; $12 in gym, $16 in original
BLOCK_TILES := $7B
EMPTY_TILE := $EF
LOW_STACK_LINE := $DF
TETRIMINO_X_HIDE := $EF

PAUSE_SPRITE_X := $74
PAUSE_SPRITE_Y := $58
; jazzthief-style
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

RENDER_LINES = $01
RENDER_LEVEL = $02
RENDER_SCORE = $04
RENDER_DEBUG = $08
RENDER_HZ = $10
RENDER_STATS = $40
RENDER_HIGH_SCORE_LETTER = $80

.enum
MODE_TETRIS
MODE_TSPINS
MODE_SEED
MODE_PARITY
MODE_PACE
MODE_PRESETS
MODE_TYPEB
MODE_FLOOR
MODE_CRUNCH
MODE_TAP
MODE_TRANSITION
MODE_MARATHON
MODE_TAPQTY
MODE_CHECKERBOARD
MODE_GARBAGE
MODE_DROUGHT
.if ANYDAS <> 1
MODE_DAS
.endif
MODE_LOWSTACK
MODE_KILLX2
MODE_INVISIBLE
MODE_HARDDROP
MODE_SPEED_TEST
MODE_SCORE_DISPLAY
MODE_CRASH
MODE_STRICT
MODE_HZ_DISPLAY
MODE_INPUT_DISPLAY
MODE_DISABLE_FLASH
MODE_DISABLE_PAUSE
MODE_DARK
MODE_GOOFY
MODE_DEBUG
MODE_LINECAP
.if ANYDAS <> 1
MODE_DASONLY
.endif
MODE_QUAL
MODE_PAL
.if ANYDAS = 1
MODE_DAS_VALUE
MODE_ARR_VALUE
MODE_ARE_CHARGE
.endif
MODE_QUANTITY
.endenum

MODE_GAME_QUANTITY = MODE_HARDDROP + 1

SCORING_CLASSIC := 0 ; for scoringModifier
SCORING_LETTERS := 1
SCORING_SEVENDIGIT := 2
SCORING_FLOAT := 3
SCORING_SCORECAP := 4
SCORING_HIDDEN := 5

LINECAP_KILLX2 := 1
LINECAP_FLOOR := 2
LINECAP_INVISIBLE := 3
LINECAP_HALT := 4

CRASH_OFF := 0
CRASH_SHOW := 1
CRASH_TOPOUT := 2
CRASH_CRASH := 3

LINECAP_WHEN_STRING_OFFSET := $10
LINECAP_HOW_STRING_OFFSET := $12

MENU_SPRITE_Y_BASE := $46
MENU_MAX_Y_SCROLL := $A0
MENU_TOP_MARGIN_SCROLL := 7 ; in blocks

; menuConfigSizeLookup
; menu ram is defined at menuRAM in ./ram.asm
.macro MENUSIZES
    .byte $0    ; MODE_TETRIS
    .byte $0    ; MODE_TSPINS
    .byte $0    ; MODE_SEED
    .byte $0    ; MODE_PARITY
    .byte $F    ; MODE_PACE
    .byte $7    ; MODE_PRESETS
    .byte $8    ; MODE_TYPEB
    .byte $C    ; MODE_FLOOR
    .byte $F    ; MODE_CRUNCH
    .byte $20   ; MODE_TAP
    .byte $10   ; MODE_TRANSITION
    .byte $2    ; MODE_MARATHON
    .byte $1F   ; MODE_TAPQTY
    .byte $8    ; MODE_CHECKERBOARD
    .byte $4    ; MODE_GARBAGE
    .byte $12   ; MODE_DROUGHT
.if ANYDAS <> 1
    .byte $10   ; MODE_DAS
.endif
    .byte $12   ; MODE_LOWSTACK
    .byte $0    ; MODE_KILLX2
    .byte $0    ; MODE_INVISIBLE
    .byte $0    ; MODE_HARDDROP
    .byte $0    ; MODE_SPEED_TEST
    .byte $5    ; MODE_SCORE_DISPLAY
    .byte $3	; MODE_CRASH
    .byte $1	; MODE_STRICT
    .byte $1    ; MODE_HZ_DISPLAY
    .byte $1    ; MODE_INPUT_DISPLAY
    .byte $1    ; MODE_DISABLE_FLASH
    .byte $1    ; MODE_DISABLE_PAUSE
    .byte $5    ; MODE_DARK
    .byte $1    ; MODE_GOOFY
    .byte $1    ; MODE_DEBUG
    .byte $1    ; MODE_LINECAP
.if ANYDAS <> 1
    .byte $1    ; MODE_DASONLY
.endif
    .byte $1    ; MODE_QUAL
    .byte $1    ; MODE_PAL
.if ANYDAS = 1
    .byte $40   ; MODE_DAS_VALUE
    .byte $40   ; MODE_ARR_VALUE
    .byte $1    ; MODE_ARE_CHARGE
.endif
.endmacro

.macro MODENAMES
    .byte   "TETRIS"
    .byte   "TSPINS"
    .byte   " SEED "
    .byte   "STACKN"
    .byte   " PACE "
    .byte   "SETUPS"
    .byte   "B-TYPE"
    .byte   "FLOOR "
    .byte   "CRUNCH"
    .byte   "QCKTAP"
    .byte   "TRNSTN"
    .byte   "MARTHN"
    .byte   "TAPQTY"
    .byte   "CKRBRD"
    .byte   "GARBGE"
    .byte   "LOBARS"
.if ANYDAS <> 1
    .byte   "DASDLY"
.endif
    .byte   "LOWSTK"
    .byte   "KILLX2"
    .byte   "INVZBL"
    .byte   "HRDDRP"
.endmacro
