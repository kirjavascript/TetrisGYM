;
; NES2.0 header
; https://www.nesdev.org/wiki/NES_2.0
;

; iNES header adapted from Brad Smith (rainwarrior)
; https://github.com/bbbradsmith/NES-ca65-example

.segment "HEADER"

.include "constants.asm" ; for INES_HEADER

INES_MIRROR = 0 ; 0 = horizontal mirroring, 1 = vertical mirroring (ignored in MMC1)
INES_SRAM = HAS_SRAM ; 1 = battery backed SRAM at $6000-7FFF
NES2_SRAM_SHIFT = HAS_SRAM * 7 ; if SRAM present, set shift to 7 for (64 << 7) = 8KiB size
NES2_REGION = 2 ; 0 = NTSC, 1 = PAL, 2 = multi-region, 3 = UA6538 ("Dendy")
NES2_INPUT = 0 ; 0 = unspecified, 1 = standard NES/FC controllers, $23 = Family BASIC Keyboard

; Override INES_MAPPER for mode 1000 (auto detect)
.if INES_MAPPER = 1000
    .if CNROM_OVERRIDE
    _INES_MAPPER = 3 ; Test CNROM on Emulator/Flashcart
    .else
    _INES_MAPPER = 1 ; MMC1 for Emulator/Flashcart
    .endif
.else
    _INES_MAPPER = INES_MAPPER ; use actual INES_MAPPER otherwise
.endif

; Pick the appropriate NES2_SUBMAPPER
.if _INES_MAPPER = 1
    NES2_SUBMAPPER = 5 ; MMC1 fixed PRG
.elseif _INES_MAPPER = 3
    NES2_SUBMAPPER = 2 ; CNROM bus conflicts
.else
    NES2_SUBMAPPER = 0 ; otherwise don't specify submapper
.endif

; Construct header
.byte 'N', 'E', 'S', $1A ; ID
.byte $02 ; 16k PRG chunk count
.byte $02 ; 8k CHR chunk count
.byte INES_MIRROR | (INES_SRAM << 1) | ((_INES_MAPPER & $f) << 4)

.if INES_OVERRIDE = 0
    .byte (_INES_MAPPER & %11110000) | %00001000 ; NES2.0 header identifier
    .byte ((NES2_SUBMAPPER & $f) << 4) | ((_INES_MAPPER & $f00) >> 8) ; submapper/mapper MSB
    .byte $0, (NES2_SRAM_SHIFT << 4) ; PRG MSB, SRAM shift count
    .byte $0, NES2_REGION, $0, $0, NES2_INPUT ; misc. fields, region, input device
.else
    .byte (_INES_MAPPER & %11110000)
    .byte $0, $0, $0, $0, $0, $0, $0, $0 ; padding
.endif

