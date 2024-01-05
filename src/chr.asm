.segment "CHR"
; CHRBankSet0:
    .incbin "chr/title_menu_tileset.chr"
    .incbin "chr/game_tileset.chr"
; CHRBankSet1:
.if INES_MAPPER <> 0 ; exclude for NROM
    .incbin "chr/rocket_tileset.chr"
.endif
