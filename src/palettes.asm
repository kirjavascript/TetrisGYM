; ppu hi, ppu lo
; length
; palette data
; $FF

game_palette:
        .byte   $3F,$00
        .byte   $20
        .byte   $0F,$30,$12,$16 ; bg
        .byte   $0F,$20,$12,$00
        .byte   $0F,$2C,$16,$29
        .byte   $0F,$3C,$00,$30
        .byte   $0F,$16,$2A,$22 ; sprite
        .byte   $0F,$10,$16,$2D
        .byte   $0F,$2C,$16,$29
        .byte   $0F,$3C,$00,$30
        .byte   $FF
title_palette:
        .byte   $3F,$00
        .byte   $14
        .byte   $0F,$3C,$38,$00 ; bg
        .byte   $0F,$17,$27,$37
        .byte   $0F,$30,MENU_HIGHLIGHT_COLOR,$00
        .byte   $0F,$22,$2A,$28
        .byte   $0F,$30,$29,$27 ; sprite
        .byte   $FF
menu_palette:
        .byte   $3F,$00
        .byte   $16
        .byte   $0F,$30,$38,$26 ; bg
        .byte   $0F,$17,$27,$37
        .byte   $0F,$30,MENU_HIGHLIGHT_COLOR,$00
        .byte   $0F,$16,$2A,$28
        .byte   $0F,$16,$26,$27 ; sprite
        .byte   $0F,$2A
        .byte   $FF
rocket_palette:
        .byte   $3F,$11
        .byte   $07
        .byte   $16,$2A,$28     ; sprite
        .byte   $0F,$37,$18,$38
        .byte   $3F,$00
        .byte   $08
        .byte   $0F,$3C,$38,$00 ; bg
        .byte   $0F,$20,$12,$15
        .byte   $FF
wait_palette:
        .byte   $3F,$11
        .byte   $01
        .byte   $30             ; sprite
        .byte   $3F,$00
        .byte   $08
        .byte   $0F,$30,$38,$26 ; bg
        .byte   $0F,$17,$27,$37
        .byte   $FF
