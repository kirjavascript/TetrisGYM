; Assisted with the following python:
; kbmap = """
; CloseBracket OpenBracket RETURN  F8        STOP    Yen     SHIFTRight   KANA
; Semicolon    Colon       atSign  F7        Caret   Dash    Slash        Underscore
; K            L           O       F6        0       P       Comma        Period
; J            U           I       F5        8       9       N            M
; H            G           Y       F4        6       7       V            B
; D            R           T       F3        4       5       C            F
; A            S           W       F2        3       E       Z            X
; CTR          Q           ESC     F1        2       1       GRPH         SHIFTLeft
; Left         Right       UP      CLR_HOME  INS     DEL     Space        Down
; """
; for row, keys in enumerate(kbmap.strip().splitlines()):
;     for mask, key in enumerate(keys.split()):
;         mask = 0x80 >> mask
;         print(f"key{key:<12} = ${row:02x}{mask:02x}")


; 2 bytes to represent each key
; hi byte is an index into keyboardInput and represents row
; lo byte is a bitmask to single out key's bit
; result is not zero if key pressed

.macro readKeyDirect keyMap
        lda keyboardInput+>keyMap
        and #<keyMap
.endmacro

keyF1           = $0710
keyF2           = $0610
keyF3           = $0510
keyF4           = $0410
keyF5           = $0310
keyF6           = $0210
keyF7           = $0110
keyF8           = $0010

keyStop         = $0008
keyReturn       = $0020

keyShiftRight   = $0002
keyShiftLeft    = $0701

keyESC          = $0720
keyCTR          = $0780
keyGRPH         = $0702

keyCLR_HOME     = $0810
keyINS          = $0808
keyDEL          = $0804

keyUp           = $0820
keyLeft         = $0880
keyRight        = $0840
keyDown         = $0801

keyCloseBracket = $0080 ; ]
keyOpenBracket  = $0040 ; [
keyYen          = $0004 ; ¥
keySemicolon    = $0180 ; ;
keyColon        = $0140 ; :
keyatSign       = $0120 ; @
keyCaret        = $0108 ; ^
keySlash        = $0102 ; /
keyUnderscore   = $0101 ; _
keyComma        = $0202 ; ,
keyPeriod       = $0201 ; .
keyDash         = $0104 ; -
keyKana         = $0001

keySpace        = $0802

key0            = $0208
key1            = $0704
key2            = $0708
key3            = $0608
key4            = $0508
key5            = $0504
key6            = $0408
key7            = $0404
key8            = $0308
key9            = $0304

keyA            = $0680
keyB            = $0401
keyC            = $0502
keyD            = $0580
keyE            = $0604
keyF            = $0501
keyG            = $0440
keyH            = $0480
keyI            = $0320
keyJ            = $0380
keyK            = $0280
keyL            = $0240
keyM            = $0301
keyN            = $0302
keyO            = $0220
keyP            = $0204
keyQ            = $0740
keyR            = $0540
keyS            = $0640
keyT            = $0520
keyU            = $0340
keyV            = $0402
keyW            = $0620
keyX            = $0601
keyY            = $0420
keyZ            = $0602
