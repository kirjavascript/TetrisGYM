kbAntiSocd:
        .byte BUTTON_UP | BUTTON_DOWN
        .byte BUTTON_LEFT | BUTTON_RIGHT

kbMappedKeyRows:
        expandKeyRow kbMappedRight
        expandKeyRow kbMappedLeft
        expandKeyRow kbMappedDown
        expandKeyRow kbMappedUp
        expandKeyRow kbMappedStart
        expandKeyRow kbMappedSelect
        expandKeyRow kbMappedB
        expandKeyRow kbMappedA

kbMappedKeyMasks:
        expandKeyMask kbMappedRight
        expandKeyMask kbMappedLeft
        expandKeyMask kbMappedDown
        expandKeyMask kbMappedUp
        expandKeyMask kbMappedStart
        expandKeyMask kbMappedSelect
        expandKeyMask kbMappedB
        expandKeyMask kbMappedA


seedEntryTable:
        .byte key0
        .byte key1
        .byte key2
        .byte key3
        .byte key4
        .byte key5
        .byte key6
        .byte key7
        .byte key8
        .byte key9
        .byte keyA
        .byte keyB
        .byte keyC
        .byte keyD
        .byte keyE
        .byte keyF
seedEntryTableEnd:
seedEntryCharCount = <(seedEntryTableEnd - seedEntryTable) - 1

scoreEntryTable:
        .byte keySpace
        .byte keyA
        .byte keyB
        .byte keyC
        .byte keyD
        .byte keyE
        .byte keyF
        .byte keyG
        .byte keyH
        .byte keyI
        .byte keyJ
        .byte keyK
        .byte keyL
        .byte keyM
        .byte keyN
        .byte keyO
        .byte keyP
        .byte keyQ
        .byte keyR
        .byte keyS
        .byte keyT
        .byte keyU
        .byte keyV
        .byte keyW
        .byte keyX
        .byte keyY
        .byte keyZ
        .byte key0
        .byte key1
        .byte key2
        .byte key3
        .byte key4
        .byte key5
        .byte key6
        .byte key7
        .byte key8
        .byte key9
        .byte keyComma
        .byte keySlash
        .byte keyOpenBracket
        .byte keyCloseBracket
        .byte keyKana          ; <3
        .byte keyPeriod
        .byte key1 | $80       ; !
        .byte keySlash | $80   ; ?
        .byte keyDash
        ; treated differently
        .byte keyRight
        .byte keyLeft
        .byte keyDEL
scoreEntryTableEnd:

scoreEntryCharCount         = <(scoreEntryTableEnd - scoreEntryTable) - 1

kbScoreDelete   = scoreEntryCharCount
kbScoreLeft     = scoreEntryCharCount - 1
kbScoreRight    = scoreEntryCharCount - 2

kbColumnMaskTable:
    .repeat 8,i
    .byte $80 >> i
    .endrepeat
