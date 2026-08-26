; ppu hi, ppu lo
; length
; palette data
; $FF

gamePalette:
        .byte   $3F,$00
        .byte   $1F
        .byte   $0F,$30,$12,$16 ; bg
        .byte   $0F,$20,$12,$00
        .byte   $0F,$2C,$16,$29
        .byte   $0F,$3C,$00,$30
        .byte   $0F,$16,$2A,$22 ; sprite
        .byte   $0F,$10,$16,$2D
        .byte   $0F,$2C,$16,$29
        .byte   $0F,$2A,$27,$16
        .byte   $00
titlePalette:
        .byte   $3F,$00
        .byte   $13
        .byte   $0F,$0F,$0F,$0F ; bg
        .byte   $0F,$17,$27,$37
        .byte   $0F,$30,MENU_HIGHLIGHT_COLOR,$00
        .byte   $0F,$22,$2A,$28
        .byte   $0F,$27,$29,$27 ; sprite
        .byte   $00
menuPalette:
        .byte   $3F,$00
        .byte   $15
        .byte   $0F,$30,$38,$26 ; bg
        .byte   $0F,$17,$27,$37
        .byte   $0F,$30,MENU_HIGHLIGHT_COLOR,$00
        .byte   $0F,$16,$2A,$28
        .byte   $0F,$16,$26,$27 ; sprite
        .byte   $0F,$2A
        .byte   $00
rocketPalette:
        .byte   $3F,$11
        .byte   $06
.if INES_MAPPER = 0             ; sprite
        .byte   $2D,$30,$27     ; Ufo colors
.else
        .byte   $16,$2A,$28     ; Cathedral colors
.endif
        .byte   $0F,$37,$18,$38
        .byte   $3F,$00
        .byte   $07
        .byte   $0F,$3C,$38,$00 ; bg
        .byte   $0F,$20,$12,$15
        .byte   $0

waitPalettePatch:
        .byte   $3F,$10
        .byte   $05
        .byte   $0F,$30,$12,$13             ; sprite
        .byte   $0F,$16
        .byte   $3F,$00
        .byte   $07
        .byte   $0F,$30,$38,$26 ; bg
        .byte   $0F,$17,$27,$37
        .byte   $00
