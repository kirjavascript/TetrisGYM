game_palette:
        .byte   $3F,$00,$20,$0F,$30,$12,$16,$0F
        .byte   $20,$12,$00,$0F,$2C,$16,$29,$0F
        .byte   $3C,$00,$30,$0F,$16,$2A,$22,$0F
        .byte   $10,$16,$2D,$0F,$2C,$16,$29,$0F
        .byte   $3C,$00,$30,$FF
title_palette:
        .byte   $3F,$00,$14,$0F,$3C,$38,$00,$0F
        .byte   $17,$27,$37,$0F,$30,MENU_HIGHLIGHT_COLOR,$00,$0F
        .byte   $22,$2A,$28,$0F,$30,$29,$27,$FF
menu_palette:
        .byte   $3F,$00,$16,$0F,$30,$38,$26,$0F
        .byte   $17,$27,$37,$0F,$30,MENU_HIGHLIGHT_COLOR,$00,$0F
        .byte   $16,$2A,$28,$0F,$16,$26,$27,$0f,$2A,$FF
rocket_palette:
        .byte   $3F,$11,$7
.if INES_MAPPER = 0
        .byte   $2D,$30,$27 ; Ufo colors
.else
        .byte   $16,$2A,$28 ; Cathedral colors
.endif
        .byte   $0f,$37,$18,$38 ; sprite
        .byte   $3F,$00,$8,$0f,$3C,$38,$00,$0F,$20,$12,$15 ; bg
        .byte   $FF
wait_palette:
        .byte   $3F,$11,$1,$30
        .byte   $3F,$00,$8,$f,$30,$38,$26,$0F,$17,$27,$37
        .byte   $FF
