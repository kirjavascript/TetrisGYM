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
        ldx #$00
        stx newlyPressedKeys
        lda #KB_INIT
        sta JOY1
@rowLoop:
        lda #KB_COL_0
        sta JOY1
        ldy #$0A
@avoidParasiticCapacitance:              ; wait approx 50 cycles after advancing rows
        dey                 
        bne @avoidParasiticCapacitance
        lda JOY2_APUFC
        and #KB_MASK
        sta generalCounter
        lda #KB_COL_1
        sta JOY1
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

; Bit0  Bit1    Bit2    Bit3      Bit4    Bit5    Bit6     Bit7
; ] 	[ 	RETURN 	F8 	  STOP 	  ¥ 	  RSHIFT   KANA
; ; 	: 	@ 	F7 	  ^ 	  - 	  / 	   _
; K 	L 	O 	F6 	  0 	  P 	  , 	   .
; J 	U 	I 	F5 	  8 	  9 	  N 	   M
; H 	G 	Y 	F4 	  6 	  7 	  V 	   B
; D 	R 	T 	F3 	  4 	  5 	  C 	   F
; A 	S 	W 	F2 	  3 	  E 	  Z 	   X
; CTR 	Q 	ESC 	F1 	  2 	  1 	  GRPH 	   LSHIFT
; LEFT 	RIGHT 	UP 	CLR HOME  INS 	  DEL 	  SPACE    DOWN

; Read keys.  up/down/left/right are mapped directly


mapKeysToButtons:
        ldy #$08
        ldx #$02
        jsr readKey
        beq @upNotPressed
        lda newlyPressedKeys
        ora #BUTTON_UP
        sta newlyPressedKeys
        bne @skipDownRead
@upNotPressed:

        ldy #$08
        ldx #$07
        jsr readKey
        beq @downNotPressed
        lda newlyPressedKeys
        ora #BUTTON_DOWN
        sta newlyPressedKeys
@skipDownRead:
@downNotPressed:

        ldy #$08
        ldx #$00
        jsr readKey
        beq @leftNotPressed
        lda newlyPressedKeys
        ora #BUTTON_LEFT
        sta newlyPressedKeys
        bne @skipRightRead
@leftNotPressed:

        ldy #$08
        ldx #$01
        jsr readKey
        beq @rightNotPressed
        lda newlyPressedKeys
        ora #BUTTON_RIGHT
        sta newlyPressedKeys
@skipRightRead:
@rightNotPressed: 

        ldy #$07     ; grph -> B
        ldx #$06
        jsr readKey
        beq @bNotPressed
        lda newlyPressedKeys
        ora #BUTTON_B
        sta newlyPressedKeys
@bNotPressed:

        ldy #$08     ; space -> A
        ldx #$06
        jsr readKey
        beq @aNotPressed
        lda newlyPressedKeys
        ora #BUTTON_A
        sta newlyPressedKeys
@aNotPressed:

        ldy #$00     ; right shift -> select
        ldx #$06
        jsr readKey
        beq @selectNotPressed
        lda newlyPressedKeys
        ora #BUTTON_SELECT
        sta newlyPressedKeys
@selectNotPressed:

        ldy #$00     ; return -> start
        ldx #$02
        jsr readKey
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

keyMask:
        .byte $80,$40,$20,$10,$08,$04,$02,$01
readKey:
	lda keyboardInput,y
	and keyMask,x
	rts
