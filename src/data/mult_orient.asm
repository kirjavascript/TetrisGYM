; multiplication and orientation tables
; Combined to share a common page.  Crossing page boundaries in table lookups
; costs an extra cycle and causes timing variance that can add up.  One advantage
; of these tables taking nearly a full page is being able to use the end of the
; page for lookups to the multBy10Table.  The game logic multiplies tetriminoY (or
; offsets determined by the orientation table) by 10 frequently. During these
; calculations, this value is never less than -2 and never greater than 20.  A 256
; byte lookup table would be mostly wasteful except the first 20 and last 2 bytes.
; The repeated calls to isPositionValid used for harddrop and 0 arr see a massive
; impact from these optimisations.

; mult10Tail at end of this page allows table lookup for all possible values of tetriminoY (-2..=20)
multOrientBegin:
.assert <multOrientBegin = 0, warning, "multOrientBegin not aligned to page boundary"


; multyBy10Table needs to be first in this page with mult10Tail last
multBy10Table:                                                  ; 20
        .byte   $00,$0A,$14,$1E,$28,$32,$3C,$46
        .byte   $50,$5A,$64,$6E,$78,$82,$8C,$96
        .byte   $A0,$AA,$B4,$BE

multBy32Table:                                                  ; 8
        .byte   0,32,64,96,128,160,192,224

multBy100Table:                                                 ; 10
        .byte   $00,$64,$C8,$2C,$90
        .byte   $F4,$58,$BC,$20,$84

spawnTable:                                                     ; 7
        .byte   $02,$07,$08,$0A,$0B,$0E,$12

tetriminoTypeFromOrientation:                                   ; 19
        .byte   $00,$00,$00,$00 ; t
        .byte   $01,$01,$01,$01 ; j
        .byte   $02,$02         ; z
        .byte   $03             ; o
        .byte   $04,$04         ; s
        .byte   $05,$05,$05,$05 ; l
        .byte   $06,$06         ; i

tetriminoTileFromOrientation:                                   ; 20
        .byte   $7B,$7B,$7B,$7B ; t
        .byte   $7D,$7D,$7D,$7D ; j
        .byte   $7C,$7C         ; z
        .byte   $7B             ; o
        .byte   $7D,$7D         ; s
        .byte   $7C,$7C,$7C,$7C ; l
        .byte   $7B,$7B         ; i
        .byte   $FF             ; hidden

orientationTableY:                                              ; 80
        .byte   $00,$00,$00,$FF ; $00 t up
        .byte   $FF,$00,$00,$01 ; $01 t right
        .byte   $00,$00,$00,$01 ; $02 t down
        .byte   $FF,$00,$00,$01 ; $03 t left
        .byte   $FF,$00,$01,$01 ; $04 j left
        .byte   $FF,$00,$00,$00 ; $05 j up
        .byte   $FF,$FF,$00,$01 ; $06 j right
        .byte   $00,$00,$00,$01 ; $07 j down
        .byte   $00,$00,$01,$01 ; $08 z horizontal
        .byte   $FF,$00,$00,$01 ; $09 z vertical
        .byte   $00,$00,$01,$01 ; $0a o
        .byte   $00,$00,$01,$01 ; $0b s horizontal
        .byte   $FF,$00,$00,$01 ; $0c s vertical
        .byte   $FF,$00,$01,$01 ; $0d l right
        .byte   $00,$00,$00,$01 ; $0e l down
        .byte   $FF,$FF,$00,$01 ; $0f l left
        .byte   $FF,$00,$00,$00 ; $10 l up
        .byte   $FE,$FF,$00,$01 ; $11 i vertical
        .byte   $00,$00,$00,$00 ; $12 i horizontal
        .byte   $00,$00,$00,$00 ; $13 hidden

orientationTableX:                                              ; 80
        .byte   $FF,$00,$01,$00 ; $00 t up
        .byte   $00,$00,$01,$00 ; $01 t right
        .byte   $FF,$00,$01,$00 ; $02 t down
        .byte   $00,$FF,$00,$00 ; $03 t left
        .byte   $00,$00,$FF,$00 ; $04 j left
        .byte   $FF,$FF,$00,$01 ; $05 j up
        .byte   $00,$01,$00,$00 ; $06 j right
        .byte   $FF,$00,$01,$01 ; $07 j down
        .byte   $FF,$00,$00,$01 ; $08 z horizontal
        .byte   $01,$00,$01,$00 ; $09 z vertical
        .byte   $FF,$00,$FF,$00 ; $0a o
        .byte   $00,$01,$FF,$00 ; $0b s horizontal
        .byte   $00,$00,$01,$01 ; $0c s vertical
        .byte   $00,$00,$00,$01 ; $0d l right
        .byte   $FF,$00,$01,$FF ; $0e l down
        .byte   $FF,$00,$00,$00 ; $0f l left
        .byte   $01,$FF,$00,$01 ; $10 l up
        .byte   $00,$00,$00,$00 ; $11 i vertical
        .byte   $FE,$FF,$00,$01 ; $12 i horizontal
        .byte   $00,$00,$00,$00 ; $13 hidden

; unused.  padding required for mult10Tail
.repeat 10
    .byte $00
.endrepeat

; needs to be last table in this page
mult10Tail:                                                     ; 2
    .byte $EC,$F6 ; -20,-10

.assert multBy10Table + $fe = mult10Tail, error, "mult10Tail is not multBy10Table + $FE"
