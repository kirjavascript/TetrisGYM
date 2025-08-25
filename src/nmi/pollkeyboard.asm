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

kbReadWait:
        ldy #$08
@avoidParasiticCapacitance:              ; wait approx 50 cycles after advancing rows
        dey
        bne @avoidParasiticCapacitance
        rts

pollKeyboard:
        ldx #$00
        stx newlyPressedKeys
        lda #KB_INIT
        sta JOY1
        jsr @ret                         ; wait 12 cycles before first row
@rowLoop:
        lda #KB_COL_0
        sta JOY1
        jsr kbReadWait
        lda JOY2_APUFC
        and #KB_MASK
        sta generalCounter
        lda #KB_COL_1
        sta JOY1
        jsr kbReadWait
        lda JOY2_APUFC
        and #KB_MASK
        lsr
        sta keyboardInput,x
        lda generalCounter
        asl
        asl
        asl
        ora keyboardInput,x
        eor #$FF
        cmp #$FF
        beq @ret   ; Assume 8 simultaneously pressed keys means there's no keyboard to be read
        sta keyboardInput,x
        inx
        cpx #$09
        bne @rowLoop
        jsr mapKeysToButtons
@ret:   rts


;     Bit0  Bit1    Bit2    Bit3      Bit4    Bit5    Bit6     Bit7
; 0   ]     [       RETURN  F8        STOP    ¥       RSHIFT   KANA
; 1   ;     :       @       F7        ^       -       /        _
; 2   K     L       O       F6        0       P       ,        .
; 3   J     U       I       F5        8       9       N        M
; 4   H     G       Y       F4        6       7       V        B
; 5   D     R       T       F3        4       5       C        F
; 6   A     S       W       F2        3       E       Z        X
; 7   CTR   Q       ESC     F1        2       1       GRPH     LSHIFT
; 8   LEFT  RIGHT   UP      CLR HOME  INS     DEL     SPACE    DOWN

kbUp = $0820
kbDown = $0801
kbLeft = $0880
kbRight = $0840
kbB = $0702      ; grph -> B
kbA = $0802      ; space -> A
kbSelect = $0002 ; right shift -> select0
kbStart = $0020  ; return -> start


mapKeysToButtons:
        lda keyboardInput+>kbUp
        and #<kbUp
        beq @upNotPressed
        lda newlyPressedKeys
        ora #BUTTON_UP
        sta newlyPressedKeys
        bne @skipDownRead
@upNotPressed:

        lda keyboardInput+>kbDown
        and #<kbDown
        beq @downNotPressed
        lda newlyPressedKeys
        ora #BUTTON_DOWN
        sta newlyPressedKeys
@skipDownRead:
@downNotPressed:
        lda keyboardInput+>kbLeft
        and #<kbLeft
        beq @leftNotPressed
        lda newlyPressedKeys
        ora #BUTTON_LEFT
        sta newlyPressedKeys
        bne @skipRightRead
@leftNotPressed:

        lda keyboardInput+>kbRight
        and #<kbRight
        beq @rightNotPressed
        lda newlyPressedKeys
        ora #BUTTON_RIGHT
        sta newlyPressedKeys
@skipRightRead:
@rightNotPressed:

        lda keyboardInput+>kbB
        and #<kbB
        beq @bNotPressed
        lda newlyPressedKeys
        ora #BUTTON_B
        sta newlyPressedKeys
@bNotPressed:

        lda keyboardInput+>kbA
        and #<kbA
        beq @aNotPressed
        lda newlyPressedKeys
        ora #BUTTON_A
        sta newlyPressedKeys
@aNotPressed:

        lda keyboardInput+>kbSelect
        and #<kbSelect
        beq @selectNotPressed
        lda newlyPressedKeys
        ora #BUTTON_SELECT
        sta newlyPressedKeys
@selectNotPressed:

        lda keyboardInput+>kbStart
        and #<kbStart
        beq @startNotPressed
        lda newlyPressedKeys
        ora #BUTTON_START
        sta newlyPressedKeys
@startNotPressed:


; Separate Newly Pressed from Held
        lda newlyPressedKeys
        tay
        eor heldKeys
        and newlyPressedKeys
        sta newlyPressedKeys
        sty heldKeys

; Copy to buttons
        lda newlyPressedButtons_player1
        ora newlyPressedKeys
        sta newlyPressedButtons_player1

        lda heldButtons_player1
        ora heldKeys
        sta heldButtons_player1
        rts

shiftFlag := $08
charToKbMap:
        .byte $86 ; Space
        .byte $60 ; A
        .byte $47 ; B
        .byte $56 ; C
        .byte $50 ; D
        .byte $65 ; E
        .byte $57 ; F
        .byte $41 ; G
        .byte $40 ; H
        .byte $32 ; I
        .byte $30 ; J
        .byte $20 ; K
        .byte $21 ; L
        .byte $37 ; M
        .byte $36 ; N
        .byte $22 ; O
        .byte $25 ; P
        .byte $71 ; Q
        .byte $51 ; R
        .byte $61 ; S
        .byte $52 ; T
        .byte $31 ; U
        .byte $46 ; V
        .byte $62 ; W
        .byte $67 ; X
        .byte $42 ; Y
        .byte $66 ; Z
        .byte $24 ; 0
        .byte $75 ; 1
        .byte $74 ; 2
        .byte $64 ; 3
        .byte $54 ; 4
        .byte $55 ; 5
        .byte $44 ; 6
        .byte $45 ; 7
        .byte $34 ; 8
        .byte $35 ; 9
        .byte $26 ; ,
        .byte $16 ; /
        .byte $01 ; (
        .byte $00 ; )
        .byte $07 ; <3
        .byte $27 ; .
        .byte $75 | shiftFlag ; !
        .byte $16 | shiftFlag ; ?
        .byte $15 ; -
        .byte $85 ; del ; treated differently

charToKbMapEnd:

kbChars = <(charToKbMapEnd - charToKbMap) - 1
kbInputThrottle := generalCounter4

readKbScoreInput:
; n - no input or throttled
; z - ready to shift
; 7F - backspace
; new char otherwise

; check if shift flag is set
        lda kbShiftFlag ; 1 when ready to shift
        beq @noShift
        dec kbShiftFlag
        beq @noBackspace
        dec kbShiftFlag
        lda #$7F
@noBackspace:
        rts

@noShift:
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
        cmp #kbChars
        bne @notBackspace
        lda #$00
        inc kbShiftFlag ; +1 to indicate backspace
@notBackspace:
        sta highscores,y
.if SAVE_HIGHSCORES
        tax
        jsr detectSRAM
        beq @noSRAM
        txa
        sta SRAM_highscores,y
@noSRAM:
.endif
; causes next frame to trigger shift ; clears z & n flags
        inc kbShiftFlag
        rts

shiftCounter := generalCounter5

readKey:
; RRRRSCCC  - Row, Shift, Column
        pha
        lsr
        lsr
        lsr
        lsr
        tay
        pla
        pha
        and #$07
        sta shiftCounter
        pla
        and #$08
        beq @checkInput

; left shift
        lda keyboardInput+7
        and #$01
        bne @checkInput

; right shift
        lda keyboardInput+0
        and #$02
        beq @ret

@checkInput:
        lda keyboardInput,y
@shiftLoop:
        asl
        dec shiftCounter
        bpl @shiftLoop
        lda #$00
        rol
@ret:
        rts
