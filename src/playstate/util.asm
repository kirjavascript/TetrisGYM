isPositionValid:
        ldy tetriminoY
        lda multBy10Table,y
        clc
        adc tetriminoX
        sta generalCounter
        lda currentPiece
        asl a
        asl a
        tax
        ldy #$00
        lda #$04
        sta generalCounter3
; Checks one square within the tetrimino
@checkSquare:
        lda orientationTableY,x
        clc
        adc tetriminoY
        adc #$02 ; carry may be set for this add but doesn't have any noticeable impact

        cmp #$16
        bcs @invalid

        ldy orientationTableY,x
        lda multBy10Table,y
        ; clc omitted, carry is clear from cmp instruction above that branches away on carry set
        adc generalCounter
        sta positionValidTmp
        lda orientationTableX,x
        clc
        adc positionValidTmp
        tay
        lda playfield,y
        bpl @invalid ; tiles do not set negative flag
        lda orientationTableX,x
        clc
        adc tetriminoX
        cmp #$0A
        bcs @invalid
        inx
        dec generalCounter3
        bne @checkSquare
        lda #$00
        sta generalCounter
        rts

@invalid:
        lda #$FF
        sta generalCounter
        rts

updatePlayfield:
        ldx tetriminoY
        dex
        dex
        txa
        bpl @rowInRange
        lda #$00
@rowInRange:
        cmp vramRow
        bpl @ret
        sta vramRow
@ret:   rts

crunchLeftColumns = generalCounter3
crunchRightColumns = generalCounter4


crunchAdjustYSetXHorizMirror:
        jsr copyCrunchModifierMirrored
        jmp _crunchAdjust
crunchAdjustYSetX:
        jsr copyCrunchModifier
        ; add left columns to Y
        ; set X to playable columns
_crunchAdjust:
        ldx crunchLeftModifier
        bne @crunch
        ldx crunchRightModifier
        beq @notCrunch

@crunch:
        ; add crunch left columns to y
        tya
        clc
        adc crunchLeftColumns ; offset y with left column count (generalCounter3)
        tay

        ; set x to playable column count
        lda #$0A
        sec
        sbc crunchLeftColumns ; generalCounter3
        sbc crunchRightColumns ; generalCounter4
        tax
        bne @ret ; unconditional, expected range 4 - 10
@notCrunch:
        ldx #$0A
@ret:
        rts

isBlockInRowAtY:
; y = start of row
; negative flag clear if block found
; check if crunch mode
        jsr crunchAdjustYSetX
@checkForBlockInRow:
        lda playfield,y
        bpl @foundBlock
        iny
        dex
        bne @checkForBlockInRow
        lda #$80 ; set negative flag
@foundBlock:
        rts

updateMusicSpeed:

        ; ldx #$05
        ; lda multBy10Table,x ;this piece of code is parameterized for no reason but the crash checking code relies on the index being 50-59 so if you ever optimize this part out of the code please also adjust the crash test, specifically the part which handles cycles for allegro.
        ; tay

        ldy #50 ; replaces above
        jsr isBlockInRowAtY
        bpl @foundBlockInRow
        lda allegro
        sta wasAllegro
        beq @ret
        lda #$00
        sta allegro
        ldx musicType
        lda musicSelectionTable,x
        jsr setMusicTrack
        jmp @ret

@foundBlockInRow:
        sty allegroIndex
        lda allegro
        sta wasAllegro
        bne @ret
        lda #$FF
        sta allegro
        lda musicType
        clc
        adc #$04
        tax
        lda musicSelectionTable,x
        jsr setMusicTrack
@ret:   rts

checkIfAboveLowStackLine:
; negative clear - block found
        sec
        lda #19
        sbc lowStackRowModifier
        tax
        ldy multBy10Table,x
        jmp isBlockInRowAtY

; canon is adjustMusicSpeed
setMusicTrack:
.if !NO_MUSIC
        sta musicTrack
        lda gameMode
        cmp #$05
        bne @ret
        lda #$FF
        sta musicTrack
.endif
@ret:   rts
