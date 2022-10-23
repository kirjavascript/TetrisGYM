game_type_menu_nametable: ; RLE
        .incbin "nametables/game_type_menu_nametable_practise.bin"
game_type_menu_nametable_extra: ; RLE
        .incbin "nametables/game_type_menu_nametable_extra.bin"
level_menu_nametable: ; RLE
        .incbin "nametables/level_menu_nametable_practise.bin"
game_nametable: ; RLE
        .incbin "nametables/game_nametable_practise.bin"
enter_high_score_nametable: ; RLE
        .incbin "nametables/enter_high_score_nametable_practise.bin"
rocket_nametable: ; RLE
        .incbin "nametables/rocket_nametable.bin"
legal_nametable: ; RLE
        .incbin "nametables/legal_nametable.bin"
speedtest_nametable: ; RLE
        .incbin "nametables/speedtest_nametable.bin"
title_nametable_patch: ; stripe
        .byte $21, $69, $5, $1D, $12, $1D, $15, $E
        .byte $FF
rocket_nametable_patch: ; stripe
        .byte $20, $83, 5, $19, $1B, $E, $1c, $1c
        .byte $20, $A3, 5, $1c, $1d, $a, $1b, $1d
        .byte $FF


.include "nametables/rle.asm"
