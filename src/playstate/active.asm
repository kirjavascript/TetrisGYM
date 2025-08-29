playState_playerControlsActiveTetrimino:
        lda practiseType
        cmp #MODE_HARDDROP
        bne @notHard
        jsr harddrop_tetrimino
        lda playState
        cmp #8
        beq playState_playerControlsActiveTetrimino_return
@notHard:
        jsr hzControl ; and dasOnly control

        jsr shift_tetrimino
        jsr rotate_tetrimino

        jsr drop_tetrimino

playState_playerControlsActiveTetrimino_return:
        rts

harddrop_tetrimino:
        lda newlyPressedButtons
        and #BUTTON_UP+BUTTON_SELECT
        beq playState_playerControlsActiveTetrimino_return
        lda tetriminoY
        sta tmpY
@loop:
        inc tetriminoY
        jsr isPositionValid
        beq @loop
        dec tetriminoY

        ; sonic drop
        lda newlyPressedButtons
        and #BUTTON_SELECT
        beq @noSonic
        lda tetriminoY
        cmp tmpY
        bne @sonic
        rts
@sonic:
        lda #$D0
        sta autorepeatY
        rts
@noSonic:

        ; hard drop
        lda #1
        sta playState
        lda #0
        sta autorepeatY
        sta completedLines

        ldy #$13
@clearBuffer:
        sta harddropBuffer,y
        dey
        bpl @clearBuffer

        jsr playState_lockTetrimino

        ; check for gameOver
        lda playState
        cmp #$A
        bne @continueDropping
        rts
@continueDropping:


        ; hard drop line clear algorithm (kinda);

        ; completedLines = 0

        ; for (i = 19; i >= completedLines; i--) {
        ;     if (rowIsFull(i)) {
        ;         completedLines++
        ;     }

        ;     lineOffset = 0
        ;     completedLinesCopy = completedLines

        ;     for (lineIndex = i - 1; completedLinesCopy > 0; lineIndex--) {
        ;         if (!rowIsFull(lineIndex)) {
        ;             completedLinesCopy--
        ;         }
        ;         lineOffset++
        ;     }

        ;     if (completedLines > 0) {
        ;         for (j = 0; j < 10 ; j++) {
        ;             index = (i * 10) + j
        ;             copyPlayfield(index - (lineOffset * 10), index)
        ;         }
        ;     }
        ; }

        ; for (i = 0; i < completedLines; i++ {
        ;     clearRow(i)
        ; }

harddropAddr = pointerAddr

        lda #$04
        sta harddropAddr+1
        sta harddropAddr+3

harddropMarkCleared:
        sec
        lda tetriminoY
        sbc #3
        sta tmpX
        clc
        adc #4
        sta tmpY ; row
@lineLoop:
        ; A should always be tmpY

        tax
        lda multBy10Table, x
        sta harddropAddr

        ; check for empty row
        ldy #$0
@minoLoop:
        lda (harddropAddr), y
        cmp #EMPTY_TILE
        beq @noLineClear

        iny
        cpy #$A
        beq @lineClear
        jmp @minoLoop

@lineClear:
        lda #1
        jmp @write
@noLineClear:
        lda #0
@write:
        ; X should be tmpY
        sta harddropBuffer, x

        dec tmpY

        lda tmpY
        cmp tmpX
        bne @lineLoop

harddropShift:
        clc
        lda tetriminoY
        adc #1
        sta tmpY ; row
@lineLoop:
        ; A should always be tmpY

        tax
        lda harddropBuffer, x
        beq @noLineClear

@lineClear:
        inc completedLines
@noLineClear:
        lda completedLines
        beq @nextLine

        ; get line offset
        lda #0
        sta lineOffset
        lda completedLines
        sta completedLinesCopy

        ldx tmpY
@offsetLoop:
        dex

        lda harddropBuffer, x
        bne @lineIsFull
        dec completedLinesCopy
@lineIsFull:
        inc lineOffset

        lda completedLinesCopy
        bne @offsetLoop

        lda lineOffset
        beq @nextLine

        tax
        lda multBy10Table, x
        sta lineOffset ; reuse for lineOffset * 10

        ldx tmpY
        lda multBy10Table, x
        sta harddropAddr+0
        sec
        sbc lineOffset
        sta harddropAddr+2

        ldy #0
@shiftLineLoop:
        lda (harddropAddr+2), y
        sta (harddropAddr), y

        iny
        cpy #$A
        bne @shiftLineLoop

@nextLine:
        dec tmpY
        lda tmpY
        beq @addScore
        jmp @lineLoop



@addScore:
        lda completedLines
        beq @noScore
        jsr playState_updateLinesAndStatistics
        lda #0
        sta vramRow
        sta completedLines
        ; emty top row
        lda #EMPTY_TILE
        ldx #0
@topRowLoop:
        sta playfield, x
        inx
        cpx #$A
        bne @topRowLoop
        ; lda #TETRIMINO_X_HIDE
        ; sta tetriminoX

@noScore:

        lda #8 ; jump straight to spawnTetrimino
        sta playState
        lda dropSpeed
        sta fallTimer
        lda #$7
        sta soundEffectSlot1Init
@ret:
        rts

rotate_tetrimino:
        lda currentPiece
        sta originalY
        clc
        lda currentPiece
        asl a
        tax
        lda newlyPressedButtons
        and #BUTTON_A
        cmp #BUTTON_A
        bne @aNotPressed
        inx
        lda rotationTable,x
        sta currentPiece
        jsr isPositionValid
        bne @restoreOrientationID
        lda #$05
        sta soundEffectSlot1Init
        jmp @ret

@aNotPressed:
        lda newlyPressedButtons
        and #BUTTON_B
        cmp #BUTTON_B
        bne @ret
        lda rotationTable,x
        sta currentPiece
        jsr isPositionValid
        bne @restoreOrientationID
        lda #$05
        sta soundEffectSlot1Init
        jmp @ret

@restoreOrientationID:
        lda originalY
        sta currentPiece
@ret:   rts

rotationTable:
        .dbyt   $0301,$0002,$0103,$0200
        .dbyt   $0705,$0406,$0507,$0604
        .dbyt   $0909,$0808,$0A0A,$0C0C
        .dbyt   $0B0B,$100E,$0D0F,$0E10
        .dbyt   $0F0D,$1212,$1111
drop_tetrimino:
        lda linecapState
        cmp #LINECAP_KILLX2
        beq @killX2
        lda practiseType
        cmp #MODE_KILLX2
        bne @normal
@killX2:
        jsr lookupDropSpeed
        sta tmpY
        sta fallTimer
        jsr drop_tetrimino_actual
        lda tmpY
        sta fallTimer
        jsr drop_tetrimino_actual
@normal:
        jsr drop_tetrimino_actual
        rts

drop_tetrimino_actual:
        lda autorepeatY
        bpl @notBeginningOfGame
        lda newlyPressedButtons
        and #BUTTON_DOWN
        beq @incrementAutorepeatY
        lda #$00
        sta autorepeatY
@notBeginningOfGame:
        bne @autorepeating
@playing:
        lda heldButtons
        and #$03
        bne @lookupDropSpeed
        lda newlyPressedButtons
        and #$0F
        cmp #BUTTON_DOWN
        bne @lookupDropSpeed
        lda #$01
        sta autorepeatY
        jmp @lookupDropSpeed

@autorepeating:
        lda heldButtons
        and #$0F
        cmp #BUTTON_DOWN
        beq @downPressed
        lda #$00
        sta autorepeatY
        sta holdDownPoints
        jmp @lookupDropSpeed

@downPressed:
        inc autorepeatY
        lda autorepeatY
        cmp #$03
        bcc @lookupDropSpeed
        lda #$01
        sta autorepeatY
        inc holdDownPoints
@drop:  lda #$00
        sta fallTimer
        lda tetriminoY
        sta originalY
        inc tetriminoY
        jsr isPositionValid
        beq @ret
        lda originalY
        sta tetriminoY
        lda #$02
        sta playState
        jsr updatePlayfield
@ret:   rts

@incrementAutorepeatY:
        inc autorepeatY
        jmp @ret

@lookupDropSpeed:
        jsr lookupDropSpeed
        sta dropSpeed
        lda fallTimer
        cmp dropSpeed
        bpl @drop
        jmp @ret

lookupDropSpeed:
        lda #$01
        ldx levelNumber
        ldy practiseType
        cpy #MODE_MARATHON
        bne @notMarathon
        ldx startLevel
@notMarathon:
        cpx #$1D
        bcs @noTableLookup
        lda framesPerDropTableNTSC,x
        ldy palFlag
        ; cpy #0 ; ldy sets z flag
        beq @noTableLookup
        lda framesPerDropTablePAL,x
@noTableLookup:
        rts

framesPerDropTableNTSC:
        .byte   $30,$2B,$26,$21,$1C,$17,$12,$0D
        .byte   $08,$06,$05,$05,$05,$04,$04,$04
        .byte   $03,$03,$03,$02,$02,$02,$02,$02
        .byte   $02,$02,$02,$02,$02,$01
framesPerDropTablePAL:
        .byte   $24,$20,$1d,$19,$16,$12,$0f,$0b
        .byte   $07,$05,$04,$04,$04,$03,$03,$03
        .byte   $02,$02,$02,$01,$01,$01,$01,$01
        .byte   $01,$01,$01,$01,$01,$01
shift_tetrimino:
.if ANYDAS <> 1
        ; dasOnlyFlag
        lda dasOnlyShiftDisabled
        beq @dasOnlyEnd
        lda heldButtons
        and #BUTTON_LEFT|BUTTON_RIGHT
        beq @dasOnlyEnd
        inc dasOnlyShiftDisabled
        lda dasOnlyShiftDisabled
        cmp #4
        bne :+
        lda #0
        sta dasOnlyShiftDisabled
        jsr shift_tetrimino
        jsr shift_tetrimino
        jsr shift_tetrimino
:
        rts
@dasOnlyEnd:

        lda practiseType
        cmp #MODE_DAS
        bne @normalDAS
        lda dasModifier
        sta dasValueDelay
        lda palFlag
        eor #1
        asl
        adc #$8
        sta dasValuePeriod
        jmp @shiftTetrimino
@normalDAS:

        ; region stuff
        lda #$10
        sta dasValueDelay
        lda #$A
        sta dasValuePeriod
        ldy palFlag
        ; cpy #0 ; ldy sets z flag
        beq @shiftTetrimino
        lda #$0C
        sta dasValueDelay
        lda #$08
        sta dasValuePeriod
@shiftTetrimino:
.endif

        lda tetriminoX
        sta originalY
        lda heldButtons
        and #BUTTON_DOWN
        bne @ret
        lda newlyPressedButtons
        and #$03
        bne @resetAutorepeatX
        lda heldButtons
        and #$03
        beq @ret
.if ANYDAS = 1
        dec autorepeatX
        lda autorepeatX
        cmp #$01
        bpl @ret
@zeroDas:
        lda anydasARRValue
        sta autorepeatX
        beq @zeroArr
        bne @buttonHeldDown
@resetAutorepeatX:
        lda anydasDASValue
        beq @zeroDas
.else
        inc autorepeatX
        lda autorepeatX
        cmp dasValueDelay
        bmi @ret
        lda dasValuePeriod
        sta autorepeatX
        jmp @buttonHeldDown

@resetAutorepeatX:
        lda #$00
.endif
        sta autorepeatX
@buttonHeldDown:
        lda heldButtons
        and #BUTTON_RIGHT
        beq @notPressingRight
        inc tetriminoX
        jsr isPositionValid
        bne @restoreX
        lda #$03
        sta soundEffectSlot1Init
        jmp @ret

@notPressingRight:
        lda heldButtons
        and #BUTTON_LEFT
        beq @ret
        dec tetriminoX
        jsr isPositionValid
        bne @restoreX
        lda #$03
        sta soundEffectSlot1Init
        jmp @ret

@restoreX:
        lda originalY
        sta tetriminoX
.if ANYDAS = 1
        lda #$01
.else
        lda dasValueDelay
.endif
        sta autorepeatX
@ret:   rts

.if ANYDAS = 1
@zeroArr:
        lda heldButtons
        and #BUTTON_RIGHT
        beq @checkLeftPressed
@shiftRight:
        inc tetriminoX
        jsr isPositionValid
        bne @shiftBackToLeft
        lda #$03
        sta soundEffectSlot1Init
        jmp @shiftRight
@checkLeftPressed:
        lda heldButtons
        and #BUTTON_LEFT
        beq @leftNotPressed
@shiftLeft:
        dec tetriminoX
        jsr isPositionValid
        bne @shiftBackToRight
        lda #$03
        sta soundEffectSlot1Init
        jmp @shiftLeft
@shiftBackToLeft:
        dec tetriminoX
        dec tetriminoX
@shiftBackToRight:
        inc tetriminoX
        lda #$01
        sta autorepeatX
@leftNotPressed:
        rts
.endif
