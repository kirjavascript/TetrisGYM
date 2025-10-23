.segment "CHR"

.if HAS_MMC
    .incbin "chr/CTEC2024_chr_27C512_x4.bin"
    ; .incbin "chr/title_menu_tileset.chr"
    ; .incbin "chr/game_tileset.chr"
    ; .incbin "chr/rocket_tileset.chr"
.elseif INES_MAPPER = 3
    ; .incbin "chr/rocket_tileset.chr"
    ; .repeat $1000
    ; .byte $0
    ; .endrepeat
    ; .incbin "chr/title_menu_tileset.chr"
    ; .incbin "chr/game_tileset.chr"
.endif
