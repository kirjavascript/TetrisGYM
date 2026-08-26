gameMode_calibrate:
; stays in loop until ABSS

@fillModifier = anydasFlag
; 0-3, increases on up/down
; rotates through a blank board or filled with each of the three minos
; refreshes pattern if not in fill mode

; levelNumber
; 0-9, increase/decrease with left/right

@fillFlag = tetriminoY
; 0-1, toggled by B
; 0 = show random pattern
; 1 = fill board with @fillModifier

@suspendRefresh = fallTimer
; 0-1, toggled by start
; 0 = refresh pattern every 128 frames
; 1 = stay on current pattern

@nextBoxPiece = tetriminoX
; 0-6, increases on select and wraps around at 6
; corresponding stats counter increases on each increment
; hold A to rotate once per frame

    jsr gameModeState_initGameBackground
    jsr gameModeState_initGameState
    ldx nextPiece
    stx currentPiece
    lda tetriminoTypeFromOrientation,x
    sta @nextBoxPiece

@refreshPattern:
    lda #0
    sta vramRow
    lda @fillFlag
    bne @tilefill
    ldy #15
@fill:
    ldx #b_seed
    jsr generateNextPseudorandomNumber5x
    lda oneThirdPRNG
    clc
    adc #$7B
    sta mathRAM,y
    dey
    bpl @fill

    lda rng_seed+1
    and #7
    tax
    lda #$EF
    sta mathRAM,x
    sta mathRAM+8,x

    ldy #200
    lda rng_seed
    and #15
    tax
@loop:
    lda mathRAM,x
    sta playfield-1,y
    dex
    bpl :+
    ldx #15
:
    dey
    bne @loop
    jmp @waitLoop

@tilefill:
    ldx #200
    lda @fillModifier
    beq @empty
    lda #$7A
    clc
    adc @fillModifier
    bne @tile
@empty:
    lda #EMPTY_TILE
@tile:
    sta playfield-1,x
    dex
    bne @tile
    jmp @waitLoop

@checkInputs:

; reset sequence
    lda heldButtons_player1
    cmp #BUTTON_A+BUTTON_B+BUTTON_SELECT+BUTTON_START
    bne @noReset
    lda #GAMEMODE_GAMETYPEMENU
    sta gameMode
    rts
@noReset:

; B to toggle @fillFlag
    lda newlyPressedButtons_player1
    and #BUTTON_B
    beq @noToggle
    lda @fillFlag
    eor #1
    sta @fillFlag
    jmp @refreshPattern
@noToggle:

; up/down to rotate @fillModifier
    lda newlyPressedButtons_player1
    and #BUTTON_UP|BUTTON_DOWN
    beq @upNotPressed
    inc @fillModifier
    lda @fillModifier
    and #3
    sta @fillModifier
    jmp @refreshPattern
@upNotPressed:

; start to suspend pattern refresh
    lda newlyPressedButtons_player1
    and #BUTTON_START
    beq @startNotPressed
    lda @suspendRefresh
    eor #1
    sta @suspendRefresh
    bne @waitLoop
    jmp @refreshPattern
@startNotPressed:

; select to rotate piece
; A+select to rapdily rotate
    lda newlyPressedButtons_player1
    and #BUTTON_SELECT
    bne @rotatePiece
    lda heldButtons_player1
    cmp #BUTTON_A+BUTTON_SELECT
    bne @noPieceRotate

@rotatePiece:
    lda nextPiece
    sta currentPiece
    jsr incrementPieceStat
    inc @nextBoxPiece
    lda @nextBoxPiece
    cmp #7
    bne @noRollover
    lda #0
    sta @nextBoxPiece
@noRollover:
    tax
    lda spawnTable,x
    sta nextPiece
    jmp @waitLoop

; left/right to decrease/increase levelNumber
@noPieceRotate:
    lda newlyPressedButtons_player1
    and #3
    beq @checkFrameCounter
    lsr
    bcs @rightPressed

; left pressed
    dec levelNumber
    bpl @renderLevel
    lda #9
    sta levelNumber
    bne @renderLevel

@rightPressed:
    inc levelNumber
    lda levelNumber
    cmp #$0A
    bcc @renderLevel
    lda #0
    sta levelNumber

@renderLevel:
    lda levelNumber

; optional 7 digit
    ldy scoringModifier
    cpy #2
    beq @sevenDigit
    lda #0
@sevenDigit:
    sta bcd32+3

; fill score & lines, render & exit
    lda levelNumber
    sta lines+1
    asl
    asl
    asl
    asl
    ora levelNumber
    sta lines
    sta bcd32
    sta bcd32+1
    sta bcd32+2
    jsr presetScoreFromBCD
    lda #RENDER_LINES|RENDER_LEVEL|RENDER_SCORE
    sta renderFlags

@waitLoop:
    jsr stageSpriteForNextPiece
    jsr updateAudioWaitForNmiAndResetOamStaging
    jmp @checkInputs

; shuffle every 128 frames
@checkFrameCounter:
    lda @suspendRefresh
    bne @waitLoop
    lda frameCounter
    and #$7F
    beq @refresh
    jmp @waitLoop
@refresh:
    jmp @refreshPattern

.out .sprintf("Calibrate code: %d", *-gameMode_calibrate)
