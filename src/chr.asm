.segment "CHR"

.if INES_MAPPER = 1
    .incbin "chr/title_menu_tileset.chr"
    .incbin "chr/game_tileset.chr"
    .incbin "chr/rocket_tileset.chr"
.elseif INES_MAPPER = 3
    .incbin "chr/rocket_tileset.chr"
    .repeat $1000
    .byte $0
    .endrepeat
    .incbin "chr/title_menu_tileset.chr"
    .incbin "chr/game_tileset.chr"
.endif
