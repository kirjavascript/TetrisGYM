;
; iNES header
;

; This iNES header is from Brad Smith (rainwarrior)
; https://github.com/bbbradsmith/NES-ca65-example

.segment "HEADER"

.include "constants.asm" ; for INES_HEADER

INES_MIRROR = 0 ; 0 = horizontal mirroring, 1 = vertical mirroring (ignored in MMC1)
INES_SRAM   = 1 ; 1 = battery backed SRAM at $6000-7FFF

; Override INES_MAPPER for mode 0 (auto detect)
.if INES_MAPPER = 0
    .if CNROM_OVERRIDE
    _INES_MAPPER = 3 ; Test CNROM on Emulator/Flashcart
    .else
    _INES_MAPPER = 1 ; MMC1 for Emulator/Flashcart
    .endif
.else
_INES_MAPPER = INES_MAPPER ; use actual INES_MAPPER otherwise
.endif

.byte 'N', 'E', 'S', $1A ; ID
.byte $02 ; 16k PRG chunk count
.byte $02 ; 8k CHR chunk count
.byte INES_MIRROR | (INES_SRAM << 1) | ((_INES_MAPPER & $f) << 4)
.byte (_INES_MAPPER & %11110000)
.byte $0, $0, $0, $0, $0, $0, $0, $0 ; padding
