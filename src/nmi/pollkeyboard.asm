.include "keyboardmap.asm"

; for remapping, see above map file for full list
kbMappedUp     = keyK
kbMappedDown   = keyJ
kbMappedLeft   = keyH
kbMappedRight  = keyL
kbMappedB      = keyD
kbMappedA      = keyF
kbMappedSelect = keyShiftLeft
kbMappedStart  = keyReturn


; https://www.nesdev.org/wiki/Family_BASIC_Keyboard

; Input ($4016 write)

; 7  bit  0
; ---- ----
; xxxx xKCR
;       |||
;       ||+-- Reset the keyboard to the first row.
;       |+--- Select column, row is incremented if this bit goes from high to low.
;       +---- Enable keyboard matrix (if 0, all voltages inside the keyboard will be 5V, reading back as logical 0 always)

; Incrementing the row from the (keyless) 10th row will cause it to wrap back to the first row.

; Output ($4017 read)

; 7  bit  0
; ---- ----
; xxxK KKKx
;    | |||
;    +-+++--- Receive key status of currently selected row/column.

; Any key that is held down, will read back as 0.

; ($4016 reads from the data recorder.)

; Similar to the Family Trainer Mat, there are parasitic capacitances that the program must wait for to get a valid result. Family
; BASIC waits approximately 50 cycles after advancing rows before assuming the output is valid.
; Usage

; Family BASIC reads the keyboard state with the following procedure:

;     Write $05 to $4016 (reset to row 0, column 0)
;     Write $04 to $4016 (select column 0, next row if not just reset)
;     Read column 0 data from $4017
;     Write $06 to $4016 (select column 1)
;     Read column 1 data from $4017
;     Repeat steps 2-5 eight more times

; Note that Family BASIC never writes to $4016 with bit 2 clear, there is no need to disable the keyboard matrix.


pollKeyboard:
@upDown = BUTTON_UP|BUTTON_DOWN
@leftRight = BUTTON_LEFT|BUTTON_RIGHT


        lda #KB_INIT
        sta JOY1

        ; wait 12 cycles before first row
        lda #$00
        sta newlyPressedKeys
        ldx #8
        nop
        nop
        nop
@rowLoop:
        ; start first column read
        ldy #KB_COL_0
        sty JOY1

        ldy #6
        jsr @keyboardReadWait
        lda JOY2_APUFC

        ; start second column read
        ldy #KB_COL_1
        sty JOY1

        ; make good use of wait time
        and #KB_MASK
        asl
        asl
        asl
        beq @ret ; assume 4 simultaneously pressed keys in one row indicates no keyboard
        sta generalCounter

        ldy #3
        jsr @keyboardReadWait
        lda JOY2_APUFC

        and #KB_MASK
        lsr
        ora generalCounter
        eor #$FF
        sta keyboardInput,x
        dex
        bpl @rowLoop

; map keys to buttons
        lda #$00
        sta newlyPressedKeys
        ldx #7

; build a byte that looks like controller input
@readKeyLoop:
        clc
        ldy @mappedRows,x
        lda keyboardInput,y
        and @mappedMasks,x
        beq @notPressed
        sec
@notPressed:
        rol newlyPressedKeys
        dex
        bpl @readKeyLoop

; prevent SOCD (Simultaneous Opposite Cardinal Direction
        ldx #$01
@antiSocd:
        lda newlyPressedKeys
        and @antiSocdMatch,x
        cmp @antiSocdMatch,x
        bne @noMatch
        eor #$FF
        and newlyPressedKeys
        sta newlyPressedKeys
@noMatch:
        dex
        bpl @antiSocd

; determine which are new
        lda newlyPressedKeys

; ignore everything except start during score entry
        ldy entryActive
        beq @entryNotActive
        and #BUTTON_START
@entryNotActive:

        tay
        eor heldKeys
        and newlyPressedKeys
        sta newlyPressedKeys
        sty heldKeys

; Copy to controller buttons
        lda newlyPressedButtons_player1
        ora newlyPressedKeys
        sta newlyPressedButtons_player1

        lda heldButtons_player1
        ora heldKeys
        sta heldButtons_player1
@ret:   rts

@keyboardReadWait:
    ; consumes (y * 5) + 16
        dey
        bpl @keyboardReadWait
        rts

@antiSocdMatch:
        .byte @upDown,@leftRight

@mappedRows:
        expandKeyRow kbMappedRight
        expandKeyRow kbMappedLeft
        expandKeyRow kbMappedDown
        expandKeyRow kbMappedUp
        expandKeyRow kbMappedStart
        expandKeyRow kbMappedSelect
        expandKeyRow kbMappedB
        expandKeyRow kbMappedA
@mappedMasks:
        expandKeyMask kbMappedRight
        expandKeyMask kbMappedLeft
        expandKeyMask kbMappedDown
        expandKeyMask kbMappedUp
        expandKeyMask kbMappedStart
        expandKeyMask kbMappedSelect
        expandKeyMask kbMappedB
        expandKeyMask kbMappedA


;     Bit0  Bit1    Bit2    Bit3      Bit4    Bit5    Bit6     Bit7
; 0   ]     [       RETURN  F8        STOP    ¥       RSHIFT   KANA
; 1   ;     :       @       F7        ^       -       /        _
; 2   K     L       O       F6        0       P       ,        .
; 3   J     U       I       F5        8       9       N        M
; 4   H     G       Y       F4        6       7       V        B
; 5   D     R       T       F3        4       5       C        F
; 6   A     S       W       F2        3       E       Z        X
; 7   CTR   Q       ESC     F1        2       1       GRPH     LSHIFT
; 8   LEFT  RIGHT   UP      CLR_HOME  INS     DEL     SPACE    DOWN

; each byte represents row, column and if shift should be read
; only keys supported by the score entry routine are included

charToSeedMap:
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
charToSeedMapEnd:

seedChars = <(charToSeedMapEnd - charToSeedMap) - 1

readKbSeedEntry:
        ldx #seedChars
@readLoop:
        lda charToSeedMap,x
        jsr readKey
        bne @seedEntered
        dex
        bpl @readLoop
@seedEntered:
        txa
        cmp kbHeldInput
        beq @noInput
        sta kbHeldInput
        lda kbHeldInput
        rts
@noInput:
        lda #$FF
        rts


charToKbMap:
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
charToKbMapEnd:

kbChars         = <(charToKbMapEnd - charToKbMap) - 1
kbScoreDelete   = kbChars
kbScoreLeft     = kbChars - 1
kbScoreRight    = kbChars - 2

kbInputThrottle := generalCounter4

readKbScoreInput:
; 2 frames to complete action
; first reads key, determines action and stores key (unless key is action only)
; second returns cursor action

; return values
; >$80 - do nothing (flag)
;  $00 - move cursor right (flag)
;  $7F - move cursor left
;    default action is to set render flags for new letter

; kbReadState set in frame 1 for action in frame 2
; 0 - read input
; 1 - signal cursor right
; 2 - signal cursor left

; check if shift flag is set
        lda kbReadState
        beq @readScoreInput
        dec kbReadState
        beq @signalRight
        dec kbReadState ; reset to 0
        ; signal left
        lda #$7F
@signalRight:
        rts

@readScoreInput:
        ldx #kbChars

@checkNextChar:
        lda charToKbMap,x
        jsr readKey
        bne @keyPressed
        dex
        bpl @checkNextChar
        stx kbHeldInput

@noKeyPressed:
; n flag set due to heldInput no keys byte or active throttle
        rts

@keyPressed:
        cpx kbHeldInput
        bne @newInput

        inc kbInputThrottle
        bne @noKeyPressed

        lda #-4
        bne @storeThrottle

@newInput:
        stx kbHeldInput
        lda #-16

@storeThrottle:
        sta kbInputThrottle

@placeInput:
        lda highScoreEntryNameOffsetForLetter
        clc
        adc highScoreEntryNameOffsetForRow
        tay
        txa

        cmp #kbScoreDelete
        beq @delete

        cmp #kbScoreLeft
        bne @checkRight

        inc kbReadState
        bne @signalCursorShift

@checkRight:
        cmp #kbScoreRight
        beq @signalCursorShift
        bne @normal

@delete:
        lda #$00
        inc kbReadState ; +1 to indicate backspace
@normal:
        sta highscores,y
.if SAVE_HIGHSCORES
        tax
        jsr detectSRAM
        beq @signalCursorShift
        txa
        sta SRAM_highscores,y
@signalCursorShift:
.endif
        inc kbReadState
        rts


readKey:
; clobbers y & generalCounter5

@readKeyMask := generalCounter5
; SRRRRCCC  - Shift, Row, Column
        php     ; store shift (negative) flag
        pha     ; store byte

; extract mask
        and #07
        tay
        lda @readKeyMasks,y
        sta @readKeyMask

; extract row index
        pla
        lsr
        lsr
        lsr
        and #$0F
        tay

; determine if char is shifted
        plp
        bpl @readKey

; if so, read both shift keys
        readKeyDirect keyShiftLeft
        bne @readKey

        readKeyDirect keyShiftRight
        beq @ret

@readKey:
        lda keyboardInput,y
        and @readKeyMask
@ret:
        rts

@readKeyMasks:
    .byte $80,$40,$20,$10,$08,$04,$02,$01
