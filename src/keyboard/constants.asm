; each key is represented by a byte 0RRRRCCC
; row is 0-8
; col is byte position from left to right

keyF1           = $0B
keyF2           = $13
keyF3           = $1B
keyF4           = $23
keyF5           = $2B
keyF6           = $33
keyF7           = $3B
keyF8           = $43

keyStop         = $44
keyReturn       = $42

keyShiftRight   = $46
keyShiftLeft    = $0F

keyESC          = $0A
keyCTR          = $08
keyGRPH         = $0E

keyCLR_HOME     = $03
keyINS          = $04
keyDEL          = $05

keyUp           = $02
keyLeft         = $00
keyRight        = $01
keyDown         = $07

keyCloseBracket = $40 ; ]
keyOpenBracket  = $41 ; [
keyYen          = $45 ; ¥
keySemicolon    = $38 ; ;
keyColon        = $39 ; :
keyatSign       = $3A ; @
keyCaret        = $3C ; ^
keySlash        = $3E ; /
keyUnderscore   = $3F ; _
keyComma        = $36 ; ,
keyPeriod       = $37 ; .
keyDash         = $3D ; -
keyKana         = $47

keySpace        = $06

key0            = $34
key1            = $0D
key2            = $0C
key3            = $14
key4            = $1C
key5            = $1D
key6            = $24
key7            = $25
key8            = $2C
key9            = $2D

keyA            = $10
keyB            = $27
keyC            = $1E
keyD            = $18
keyE            = $15
keyF            = $1F
keyG            = $21
keyH            = $20
keyI            = $2A
keyJ            = $28
keyK            = $30
keyL            = $31
keyM            = $2F
keyN            = $2E
keyO            = $32
keyP            = $35
keyQ            = $09
keyR            = $19
keyS            = $11
keyT            = $1A
keyU            = $29
keyV            = $26
keyW            = $12
keyX            = $17
keyY            = $22
keyZ            = $16


KB_DISABLE = $00
KB_INIT = $05
KB_COL_0 = $04
KB_COL_1 = $06
KB_MASK  = $1E

UPDOWN = BUTTON_UP | BUTTON_DOWN
LEFTRIGHT = BUTTON_LEFT | BUTTON_RIGHT

.macro readKeyDirect keyMap
; not zero - key is pressed
        lda kbRawInput + (keyMap >> 3)
        and #$80 >> (keyMap & 7)
.endmacro

.macro expandKeyRow keyMap
        .byte keyMap >> 3
.endmacro

.macro expandKeyMask keyMap
        .byte $80 >> (keyMap & 7)
.endmacro
