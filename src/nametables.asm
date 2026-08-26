.enum
    RLE_NT_ROCKET
    RLE_NT_GAME
    RLE_NT_GAME_MENU
    RLE_NT_LEGAL
    RLE_NT_LEVEL_MENU
    RLE_NT_HIGH_SCORE
.endenum

rleNametables:
    .addr rocket_nametable
    .addr game_nametable
    .addr game_type_menu_nametable
    .addr legal_nametable
    .addr level_menu_nametable
    .addr enter_high_score_nametable

loadRleNametableXToTmp:
        txa
        asl
        tax
        lda rleNametables,x
        sta tmp1
        lda rleNametables+1,x
        sta tmp2
        rts

game_type_menu_nametable: ; RLE
        .incbin "nametables/game_type_menu_nametable_practise.bin"
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
titleNametablePatch: ; stripe
        .byte $21, $69, $4, $1D, $12, $1D, $15, $E
        .byte $0
rocketNametablePatch: ; stripe
        .byte $20, $83, 4, $19, $1B, $E, $1c, $1c
        .byte $20, $A3, 4, $1c, $1d, $a, $1b, $1d
        .byte $0

speedtestNametablePatch:
        ; tiles
        .byte $21,$A3,$5,0,0,$ED,0,0,$EC
        .byte $22,$23,$2,'T','A','P'
        .byte $22,$A3,$2,'D','I','R'
        .byte $22,$28,$0,0
        ;attrs
        .byte $23,$E2,$0,0
        .byte $23,$EA,$0,0
        .byte $23,$D8,$2,$55,$55,$55
        .byte $23,$C6,$0,$AA
        .byte $23,$CE,$0,$AA
        .byte $0


.include "nametables/rle.asm"
