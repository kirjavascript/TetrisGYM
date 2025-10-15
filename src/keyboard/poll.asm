; https://www.nesdev.org/wiki/Family_BASIC_Keyboard
.include "keyboard/constants.asm"
.include "keyboard/buttonmap.asm"
.include "keyboard/tables.asm"

pollKeyboard:
        lda keyboardFlag
        bne pollKeyboardInit
        rts
pollKeyboardInit:
        lda #KB_INIT
        sta JOY1

        ; wait 12 cycles before first row
        lda #$00
        sta kbNewKeys
        ldx #8
        nop
        nop
        nop
@rowLoop:
        ; start first column read
        ldy #KB_COL_0
        sty JOY1

        ldy #6
        jsr keyboardReadWait
        lda JOY2_APUFC

        ; start second column read
        ldy #KB_COL_1
        sty JOY1

        ; make good use of wait time
        and #KB_MASK
        asl
        asl
        asl
        beq @disconnected
        sta generalCounter

        ldy #3
        jsr keyboardReadWait
        lda JOY2_APUFC

        and #KB_MASK
        lsr
        ora generalCounter
        eor #$FF
        sta kbRawInput,x
        dex
        bpl @rowLoop

; map keys to buttons
        lda #$00
        sta kbNewKeys
        ldx #7

; build a byte that looks like controller input
@readKeyLoop:
        clc
        ldy kbMappedKeyRows,x
        lda kbRawInput,y
        and kbMappedKeyMasks,x
        beq @notPressed
        sec
@notPressed:
        rol kbNewKeys
        dex
        bpl @readKeyLoop

; prevent SOCD (Simultaneous Opposite Cardinal Direction
        ldx #$01
@antiSocd:
        lda kbHeldKeys
        and kbAntiSocd,x
        sta generalCounter
        lda kbNewKeys
        and kbAntiSocd,x
        cmp kbAntiSocd,x
        bne @noMatch
        eor #$FF
        and kbNewKeys
        ; allow previously held input to continue to be held, prevents yutaps
        ora generalCounter
        sta kbNewKeys
@noMatch:
        dex
        bpl @antiSocd

; determine which are new
        lda kbNewKeys

; ignore everything except start during score entry
        ldy highScoreEntryActive
        beq @entryNotActive
        and #BUTTON_START
@entryNotActive:

        tay
        eor kbHeldKeys
        and kbNewKeys
        sta kbNewKeys
        sty kbHeldKeys

; Copy to controller buttons
        lda newlyPressedButtons_player1
        ora kbNewKeys
        sta newlyPressedButtons_player1

        lda heldButtons_player1
        ora kbHeldKeys
        sta heldButtons_player1
@ret:   rts

@disconnected:
        ldy #8
        lda #$00
        sta keyboardFlag
@clearInput:
        sta kbRawInput,y
        dey
        bpl @clearInput
        rts

keyboardReadWait:
    ; consumes (y * 5) + 16
        dey
        bpl keyboardReadWait
        rts

detectKeyboard:
; read 10th row, expect 1E
; disable keyboard, expect 00
; see https://www.nesdev.org/wiki/Family_BASIC_Keyboard#Keyboard_detection_in_other_games
        jsr pollKeyboardInit
        ldy #KB_COL_0
        sty JOY1
        ldy #6
        jsr keyboardReadWait
        lda JOY2_APUFC
        and #KB_MASK
        cmp #KB_MASK
        bne @noKeyboard
        ldy #6
        jsr keyboardReadWait
        lda #KB_DISABLE
        sta JOY1
        ldy #6
        jsr keyboardReadWait
        lda JOY2_APUFC
        and #KB_MASK
        bne @noKeyboard
        inc keyboardFlag
@noKeyboard:
        rts

; Seed Entry


readKbSeedEntry:
        ldx #seedEntryCharCount
@readLoop:
        lda seedEntryTable,x
        jsr readKey
        bne @seedEntered
        dex
        bpl @readLoop
@seedEntered:
        cpx kbHeldInput
        beq @noInput
        stx kbHeldInput
        txa
        rts
@noInput:
        lda #$FF
        rts


; high score entry


readKbHighScoreEntry:
@kbInputThrottle := generalCounter4
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
        beq @readChar
        dec kbReadState
        beq @signalRight
        dec kbReadState ; reset to 0
        ; signal left
        lda #$7F
@signalRight:
        rts

@readChar:
        ldx #scoreEntryCharCount

@checkNextChar:
        lda scoreEntryTable,x
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

        inc @kbInputThrottle
        bne @noKeyPressed

        lda #<-4
        bne @storeThrottle

@newInput:
        stx kbHeldInput
        lda #<-16

@storeThrottle:
        sta @kbInputThrottle

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
        lda kbColumnMaskTable,y
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
        lda kbRawInput,y
        and @readKeyMask
@ret:
        rts
