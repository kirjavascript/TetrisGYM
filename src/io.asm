SRAM        := $6000 ; 8kb
SRAM_states := SRAM
SRAM_hsMagic := SRAM+$A00
SRAM_highscores := SRAM_hsMagic+$4

PPUCTRL     := $2000
PPUMASK     := $2001
PPUSTATUS   := $2002
OAMADDR     := $2003
OAMDATA     := $2004
PPUSCROLL   := $2005
PPUADDR     := $2006
PPUDATA     := $2007
SQ1_VOL     := $4000
SQ1_SWEEP   := $4001
SQ1_LO      := $4002
SQ1_HI      := $4003
SQ2_VOL     := $4004
SQ2_SWEEP   := $4005
SQ2_LO      := $4006
SQ2_HI      := $4007
TRI_LINEAR  := $4008
TRI_LO      := $400A
TRI_HI      := $400B
NOISE_VOL   := $400C
NOISE_LO    := $400E
NOISE_HI    := $400F
DMC_FREQ    := $4010
DMC_RAW     := $4011
DMC_START   := $4012                        ; start << 6 + $C000
DMC_LEN     := $4013                        ; len << 4 + 1
OAMDMA      := $4014
SND_CHN     := $4015
JOY1        := $4016
JOY2_APUFC  := $4017                        ; read: bits 0-4 joy data lines (bit 0 being normal controller), bits 6-7 are FC inhibit and mode

; Used by Family Basic Keyboard
.if KEYBOARD
KB_INIT := $05
KB_COL_0 := $04
KB_COL_1 := $06
KB_MASK  := $1E
.endif

MMC1_Control := $8000
MMC1_CHR0   := $BFFF
MMC1_CHR1   := $DFFF
MMC1_PRG    := $FFFF

MMC3_BANK_SELECT := $8000
MMC3_BANK_DATA := $8001
MMC3_MIRRORING := $A000
MMC3_PRG_RAM := $A001

; https://www.nesdev.org/wiki/MMC5#Configuration
MMC5_PRG_MODE := $5100
MMC5_CHR_MODE := $5101
MMC5_RAM_PROTECT1 := $5102
MMC5_RAM_PROTECT2 := $5103
MMC5_NT_MAPPING := $5105 ; $50 horizontal, $44 vertical, $00 single
MMC5_CHR_BANK0 := $5123 ; 4kb page index
MMC5_CHR_BANK1 := $5127

.macro RESET_MMC1
.if INES_MAPPER = 0 .or INES_MAPPER = 1
:       inc :-  ; increments inc ($aa), writing a negative value to prg
                ; https://www.nesdev.org/wiki/MMC1#Reset
.endif
.endmacro

NMIEnable = $80
BGPattern1 = $10
SpritePattern1 = $08

CHRBankSet0 = $00
CHRBankSet1 = $02
