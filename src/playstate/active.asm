playState_playerControlsActiveTetrimino:
        lda hardDropFlag
        beq @notHard
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

; secret grade checking deferred until frame following a harddrop
        bne @hardDrop
        lda secretGradePending
        beq playState_playerControlsActiveTetrimino_return
        lda #0
        sta secretGradePending
        jmp secretGradeGrading
@hardDrop:
        lda #1
        sta secretGradePending
        lda tetriminoY
        sta tmpY
        lda hardDropGhostY ; value set by previous frame's sprite staging
        sta tetriminoY

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

        lda #$20
        sta vramRow
        lda #1
        sta playState
        lda #0
        sta autorepeatY
        sta completedLines
        sta completedRow+3 ; for checkerboard clearing

        ldy #$14
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
; check top row separately
        lda teppozFlag
        beq @checkTopRow
        jmp harddropShift
@checkTopRow:
        lda playfield
        ora playfield+1
        ora playfield+2
        ora playfield+3
        ora playfield+4
        ora playfield+5
        ora playfield+6
        ora playfield+7
        ora playfield+8
        ora playfield+9
        bmi @normalBoardHandling
        inc harddropBuffer ; mark top row as cleared
        ldx #245
@shiftPlayfield:
        ; no page boundries crossed to avoid +1 cycle penalty
        lda playfield,x
        sta playfield+10,x
        dex
        ; loop stops at zero to avoid comparison
        bne @shiftPlayfield
        ; last tile omitted in loop, handle separately
        lda playfield
        sta playfield+10
@normalBoardHandling:
        sec
        lda tetriminoY
        sbc #3
        sta tmpX
        clc
        adc #4
        sta tmpY ; row
        lda tmpX
        bpl @lineLoop
        lda #0
        sta tmpX ; sets lower limit to row 1
@lineLoop:
        lda #$14
        sec
        sbc tmpY ; contains current row being checked
        cmp currentFloor
        bcc @skipRow ; ignore floor rows
        ldx tmpY
        ldy multBy10Table, x
        lda playfield,y
        ora playfield+1,y
        ora playfield+2,y
        ora playfield+3,y
        ora playfield+4,y
        ora playfield+5,y
        ora playfield+6,y
        ora playfield+7,y
        ora playfield+8,y
        ora playfield+9,y
        eor #$80
        asl
        rol harddropBuffer,x
@skipRow:
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
        ldx tmpY
        beq @noLineClear ; ignore top row
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

        ldy #9
@shiftLineLoop:
        lda (harddropAddr+2), y
        sta (harddropAddr), y

        dey
        bpl @shiftLineLoop

@nextLine:
        dec tmpY
        beq @addScore
        jmp @lineLoop

@addScore:
        lda harddropBuffer
        beq @noTopRowClear
        inc completedLines
@noTopRowClear:
        lda completedLines
        beq @noScore

; refresh rows * completed lines
        ldy completedLines
        ldx multBy10Table,y
        dex
        ldy #9
@topRowLoop:
        lda topRowBuffer,y
        sta playfield, x
        dey
        bpl @noReset
        ldy #9
@noReset:
        dex
        bpl @topRowLoop
        jsr drawFloorTopRow

; next tap quantity
        lda practiseType
        cmp #MODE_TAPQTY
        bne @tapQtyEnd
        lda completedLines
        beq @tapQtyEnd
        ; mark as complete
        lda tqtyNext
        sta tqtyCurrent
@tapQtyEnd:

        jsr playState_updateLinesAndStatistics
        lda #0
        sta vramRow

        ; lda #TETRIMINO_X_HIDE
        ; sta tetriminoX
        jsr stageFullPlayfield
        lda #PIECE_HIDDEN
        sta currentPiece
@noScore:
        jsr playState_prepareNext
        lda playState
        cmp #$A
        bne @notGameOver
        rts

@notGameOver:
        lda practiseType
        cmp #MODE_CHECKERBOARD
        bne @notChecker
        ; check to see if bottom row for checkerboard has been cleared
        lda #$13
        sec
        sbc currentFloor
        tax
        lda harddropBuffer,x
        beq @notChecker
        jmp typeBEndingStuff
@notChecker:
        jsr playState_receiveGarbage


        lda #8 ; jump straight to spawnTetrimino
        sta playState
        lda #PIECE_HIDDEN
        sta currentPiece
        lda dropSpeed
        sta fallTimer
        ; skip drop sound if levelup sound is loaded
        lda soundEffectSlot1Init
        cmp #6
        beq @ret
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
        .dbyt   $0F0D,$1212,$1111,$1313
drop_tetrimino:
        lda linecapState
        cmp #LINECAP_KILLX2
        beq @killX2
        lda killX2Flag
        beq @normal
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

        ; region stuff
        lda dasModifier
        sta dasValueDelay
        sec
        sbc arrModifier
        sta dasValuePeriod
        ; ldy palFlag
        ; ; cpy #0 ; ldy sets z flag
        ; beq @shiftTetrimino
        ; lda #PAL_DAS
        ; sta dasValueDelay
        ; lda #PAL_DAS - PAL_ARR
        ; sta dasValuePeriod
@shiftTetrimino:

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
        lda disableDasFlag
        bne @ret
        inc autorepeatX
        lda autorepeatX
        cmp dasValueDelay
        bmi @ret
@zeroDas:
        lda dasValuePeriod
        cmp dasValueDelay
        beq @zeroArr
        sta autorepeatX
        jmp @buttonHeldDown

@resetAutorepeatX:
        lda dasValueDelay
        beq @zeroDas
        lda #$00
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
        bne @normal
        lda no5TapFlag
        bne @restoreX
@normal:
        jsr isPositionValid
        bne @restoreX
        lda #$03
        sta soundEffectSlot1Init
        jmp @ret

@restoreX:
        lda originalY
        sta tetriminoX
        lda noWallChargeFlag
        bne @ret
        lda dasValueDelay
        sta autorepeatX
@ret:   rts

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
        lda noWallChargeFlag
        bne @leftNotPressed
        lda dasValueDelay
        sta autorepeatX
@leftNotPressed:
        rts
