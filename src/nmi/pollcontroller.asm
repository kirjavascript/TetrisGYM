pollControllerButtons:
        ; demo stuff used to live here
        jmp pollController

pollController_actualRead:
        ldx joy1Location
        inx
        stx JOY1
        dex
        stx JOY1
        ldx #$08
@readNextBit:
        lda JOY1
        lsr a
        rol newlyPressedButtons_player1
        lsr a
        rol tmp1
        lda JOY2_APUFC
        lsr a
        rol newlyPressedButtons_player2
        lsr a
        rol tmp2
        dex
        bne @readNextBit
        rts

addExpansionPortInputAsControllerInput:
        lda tmp1
        ora newlyPressedButtons_player1
        sta newlyPressedButtons_player1
        lda tmp2
        ora newlyPressedButtons_player2
        sta newlyPressedButtons_player2
        rts

        jsr pollController_actualRead
        beq diffOldAndNewButtons
pollController:
        jsr pollController_actualRead
        jsr addExpansionPortInputAsControllerInput
        lda newlyPressedButtons_player1
        sta generalCounter2
        lda newlyPressedButtons_player2
        sta generalCounter3
        jsr pollController_actualRead
        jsr addExpansionPortInputAsControllerInput
        lda newlyPressedButtons_player1
        and generalCounter2
        sta newlyPressedButtons_player1
        lda newlyPressedButtons_player2
        and generalCounter3
        sta newlyPressedButtons_player2

        lda goofyFlag
        beq @noGoofy
        lda newlyPressedButtons_player1
        asl
        and #$AA
        sta tmp3
        lda newlyPressedButtons_player1
        and #$AA
        lsr
        ora tmp3
        sta newlyPressedButtons_player1
@noGoofy:

diffOldAndNewButtons:
        ldx #$01
.if KEYBOARD = 1
; clear controller input when keyboard is active
; disable keyboard when reset sequence is pressed
        lda keyboardFlag
        beq @diffForPlayer
        lda newlyPressedButtons_player1
        and #BUTTON_B|BUTTON_A|BUTTON_SELECT|BUTTON_START
        cmp #BUTTON_B|BUTTON_A|BUTTON_SELECT|BUTTON_START
        php
        lda #$00
        sta newlyPressedButtons_player1
        plp
        bne @ret
        sta keyboardFlag
.endif
@diffForPlayer:
        lda newlyPressedButtons_player1,x
        tay
        eor heldButtons_player1,x
        and newlyPressedButtons_player1,x
        sta newlyPressedButtons_player1,x
        sty heldButtons_player1,x
        dex
        bpl @diffForPlayer
@ret:   rts
