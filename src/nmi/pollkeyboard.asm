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
        sta keyboardInput,x
        inx
        cpx #$09
        bne @rowLoop
        rts
