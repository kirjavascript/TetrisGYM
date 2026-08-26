; the engine from the original game

loadSpriteIntoOamStaging:
        clc
        lda spriteIndex
        rol a
        tax
        lda oamContentLookup,x
        sta generalCounter
        inx
        lda oamContentLookup,x
        sta generalCounter2
        ldx oamStagingLength
        ldy #$00
@whileNotFF:
        lda (generalCounter),y
        cmp #$FF
        beq @ret
        clc
        adc spriteYOffset
        sta oamStaging,x
        inx
        iny
        lda (generalCounter),y
        sta oamStaging,x
        inx
        iny
        lda (generalCounter),y
        sta oamStaging,x
        inx
        iny
        lda (generalCounter),y
        clc
        adc spriteXOffset
        sta oamStaging,x
        inx
        iny
        lda #$04
        clc
        adc oamStagingLength
        sta oamStagingLength
        jmp @whileNotFF

@ret:   rts

.enum
SPRITE_LEVELSELECTCURSOR
SPRITE_GAMETYPECURSOR
SPRITE_MENUSTARTA
SPRITE_MENUSTARTB
SPRITE_BLANK
SPRITE_HIGHSCORENAMECURSOR
SPRITE_DEBUGLEVELEDIT
SPRITE_STATESAVE
SPRITE_STATELOAD
SPRITE_HEARTCURSOR
SPRITE_HEART
SPRITE_READY
SPRITE_CUSTOMLEVELCURSOR
SPRITE_INGAMEHEART
SPRITE_SEEDCURSORA
SPRITE_SEEDCURSORB
SPRITE_PRACTISETYPECURSORA
SPRITE_PRACTISETYPECURSORB
SPRITE_MENUPAGESELECTA
SPRITE_MENUPAGESELECTB
SPRITE_SEED_INVALID
SPRITE_SEED_V4
SPRITE_SEED_V5
.endenum

oamContentLookup:
        .addr   spriteLevelSelectCursor
        .addr   spriteGameTypeCursor
        .addr   spriteMenuStartOptionA
        .addr   spriteMenuStartOptionB
        .addr   spriteBlank
        .addr   spriteHighScoreNameCursor
        .addr   spriteDebugLevelEdit
        .addr   spriteStateSave
        .addr   spriteStateLoad
        .addr   spriteHeartCursor
        .addr   spriteHeart
        .addr   spriteReady
        .addr   spriteCustomLevelCursor
        .addr   spriteIngameHeart
        .addr   spriteSeedCursorA
        .addr   spriteSeedCursorB
        .addr   spritePractiseTypeCursorA
        .addr   spritePractiseTypeCursorB
        .addr   spriteMenuPageSelectA
        .addr   spriteMenuPageSelectB
        .addr   spriteSeedInvalid
        .addr   spriteSeedV4
        .addr   spriteSeedV5
;         .addr   spriteMenuPageSelect2 ; $24
; Sprites are sets of 4 bytes in the OAM format, terminated by FF. byte0=y, byte1=tile, byte2=attrs, byte3=x
; YY AA II XX
spriteLevelSelectCursor:
        .byte   $00,$FC,$20,$00,$00,$FC,$20,$08
        .byte   $08,$FC,$20,$00,$08,$FC,$20,$08
        .byte   $FF
spriteGameTypeCursor:
        .byte   $00,$27,$00,$00,$00,$27,$40,$3A
        .byte   $FF
spriteMenuPageSelectA:
        .byte   $00,$27,$40,$00
        .byte   $00,$27,$00,$D9
        .byte   $FF
spriteMenuPageSelectB:
        .byte   $00,$27,$40,$02
        .byte   $00,$27,$00,$D7
        .byte   $FF
spriteMenuStartOptionA:
        .byte   $00,$96,$00,$FC
        .byte   $00,$97,$00,$04
        .byte   $FF
spriteMenuStartOptionB:
        .byte   $00,$A6,$00,$FC
        .byte   $00,$A7,$00,$04
        .byte   $FF
spriteBlank:
        .byte   $00,$FF,$00,$00,$FF
spriteHighScoreNameCursor:
        .byte   $00,$FD,$20,$00,$FF
spriteDebugLevelEdit:
        .byte   $00,'X',$00,$00
        .byte   $FF
spriteStateLoad:
        .byte   $00,'L',$03,$00,$00,'O',$03,$08
        .byte   $00,'A',$03,$10,$00,'D',$03,$18
        .byte   $00,'E',$03,$20,$00,'D',$03,$28
        .byte   $FF
spriteStateSave:
        .byte   $00,'S',$03,$00,$00,'A',$03,$08
        .byte   $00,'V',$03,$10,$00,'E',$03,$18
        .byte   $00,'D',$03,$20
        .byte   $FF
spriteSeedCursorA:
        .byte   $FD,$6B,$80,$00
        .byte   $02,$6B,$00,$00
        .byte   $FF
spriteSeedCursorB:
        .byte   $FC,$6B,$80,$00
        .byte   $03,$6B,$00,$00
        .byte   $FF
spritePractiseTypeCursorA:
        .byte   $00,$27,$40,$FB
        .byte   $00,$27,$00,$05
        .byte   $FF
spritePractiseTypeCursorB:
        .byte   $00,$27,$40,$FA
        .byte   $00,$27,$00,$06
        .byte   $FF
spriteHeartCursor:
        .byte   $00,$6c,$00,$00,$FF
spriteHeart:
        .byte   $00,$6e,$00,$00,$FF
spriteReady:
        .byte   $00,'R',$01,$00,$08,'E',$01,$00
        .byte   $10,'A',$01,$00,$18,'D',$01,$00
        .byte   $20,'Y',$01,$FF
        .byte   $FF
spriteCustomLevelCursor:
        .byte   $00,$6A,$00,$00,$21,$6A,$80,$00
        .byte   $FF
spriteIngameHeart:
        .byte   $00,$2c,$00,$00,$FF
; room to save space here
spriteSeedV4:
        .byte   $00,"V",$00,$00
        .byte   $00,"4",$00,$08
        .byte   $FF
spriteSeedV5:
        .byte   $00,"V",$00,$00
        .byte   $00,"5",$00,$08
        .byte   $FF
spriteSeedInvalid:
        .byte   $00,"V",$00,$00
        .byte   $00,"?",$00,$08
        .byte   $FF
loadNextPieceIntoOamStaging:
; spriteIndex = 0-7 t, j, z, o, s, l, i, or splitsquare
; spriteTile = 0x7b, 0x7c or 0x7d
        lda mirrorVertFlag
        asl
        ora mirrorHorizFlag
        asl
        asl
        asl
        clc
        adc spriteIndex
        tay
        ldx nextSpriteIndexes,y
        lda oamStagingLength
        tay
        clc
        adc #16
        sta oamStagingLength

        lda #2
        sta oamStaging+2,y
        sta oamStaging+6,y
        sta oamStaging+10,y
        sta oamStaging+14,y

        lda spriteTile
        sta oamStaging+1,y
        sta oamStaging+5,y
        sta oamStaging+9,y
        sta oamStaging+13,y

        ; x = start of 4 * 2 byte coordinates

        ; can be rolled up to save space if needed
        ;tile 1
        lda spriteYOffset
        clc
        adc nextSpriteTable+0,x
        sta oamStaging+0,y

        lda spriteXOffset
        clc
        adc nextSpriteTable+1,x
        sta oamStaging+3,y

        ; tile 2
        lda spriteYOffset
        clc
        adc nextSpriteTable+2,x
        sta oamStaging+4,y

        lda spriteXOffset
        clc
        adc nextSpriteTable+3,x
        sta oamStaging+7,y

        ; tile 3
        lda spriteYOffset
        clc
        adc nextSpriteTable+4,x
        sta oamStaging+8,y

        lda spriteXOffset
        clc
        adc nextSpriteTable+5,x
        sta oamStaging+11,y

        ; tile 4
        lda spriteYOffset
        clc
        adc nextSpriteTable+6,x
        sta oamStaging+12,y

        lda spriteXOffset
        clc
        adc nextSpriteTable+7,x
        sta oamStaging+15,y
        rts

nextSpriteIndexes:
; normal
    .byte <(spriteTPiece-nextSpriteTable)
    .byte <(spriteJPiece-nextSpriteTable)
    .byte <(spriteZPiece-nextSpriteTable)
    .byte <(spriteOPiece-nextSpriteTable)
    .byte <(spriteSPiece-nextSpriteTable)
    .byte <(spriteLPiece-nextSpriteTable)
    .byte <(spriteIPiece-nextSpriteTable)
    .byte <(spriteSplitSquare-nextSpriteTable)
; horizontal
    .byte <(spriteTPiece-nextSpriteTable)
    .byte <(spriteJPieceHoriz-nextSpriteTable)
    .byte <(spriteZPieceHoriz-nextSpriteTable)
    .byte <(spriteOPiece-nextSpriteTable)
    .byte <(spriteSPieceHoriz-nextSpriteTable)
    .byte <(spriteLPieceHoriz-nextSpriteTable)
    .byte <(spriteIPiece-nextSpriteTable)
    .byte <(spriteSplitSquare-nextSpriteTable)
; vertical
    .byte <(spriteTPieceVert-nextSpriteTable)
    .byte <(spriteJPieceVert-nextSpriteTable)
    .byte <(spriteZPieceHoriz-nextSpriteTable)
    .byte <(spriteOPiece-nextSpriteTable)
    .byte <(spriteSPieceHoriz-nextSpriteTable)
    .byte <(spriteLPieceVert-nextSpriteTable)
    .byte <(spriteIPiece-nextSpriteTable)
    .byte <(spriteSplitSquare-nextSpriteTable)
; 180
    .byte <(spriteTPieceVert-nextSpriteTable)
    .byte <(spriteJPiece180-nextSpriteTable)
    .byte <(spriteZPiece-nextSpriteTable)
    .byte <(spriteOPiece-nextSpriteTable)
    .byte <(spriteSPiece-nextSpriteTable)
    .byte <(spriteLPiece180-nextSpriteTable)
    .byte <(spriteIPiece-nextSpriteTable)
    .byte <(spriteSplitSquare-nextSpriteTable)


nextSpriteTable:
spriteTPiece:
        .byte   $00,$FC,$00,$04
        .byte   $00,$0C,$08,$04
spriteJPiece:
        .byte   $00,$FC,$00,$04
        .byte   $00,$0C,$08,$0C
spriteZPiece:
        .byte   $00,$FC,$00,$04
        .byte   $08,$04,$08,$0C
spriteOPiece:
        .byte   $00,$00,$00,$08
        .byte   $08,$00,$08,$08
spriteSPiece:
        .byte   $00,$04,$00,$0C
        .byte   $08,$FC,$08,$04
spriteLPiece:
        .byte   $00,$FC,$00,$04
        .byte   $00,$0C,$08,$FC
spriteIPiece:
        .byte   $04,$F8,$04,$00
        .byte   $04,$08,$04,$10
spriteSplitSquare:
        .byte   $00,$FC,$00,$0C
        .byte   $08,$FC,$08,$0C

; horiz J/Z/S/L
spriteJPieceHoriz:
        .byte   $00,$FC,$00,$04
        .byte   $00,$0C,$08,$FC
spriteZPieceHoriz:
        .byte   $00,$04,$00,$0C
        .byte   $08,$FC,$08,$04
spriteSPieceHoriz:
        .byte   $00,$FC,$00,$04
        .byte   $08,$04,$08,$0C
spriteLPieceHoriz:
        .byte   $00,$FC,$00,$04
        .byte   $00,$0C,$08,$0C

; vert T/J/Z/S/L
spriteTPieceVert:
        .byte   $08,$FC,$08,$04
        .byte   $08,$0C,$00,$04
spriteJPieceVert:
        .byte   $08,$FC,$08,$04
        .byte   $08,$0C,$00,$0C
spriteLPieceVert:
        .byte   $08,$FC,$08,$04
        .byte   $08,$0C,$00,$FC

; 180 T/J/L
spriteJPiece180:
        .byte   $08,$FC,$08,$04
        .byte   $08,$0C,$00,$FC
spriteLPiece180:
        .byte   $08,$FC,$08,$04
        .byte   $08,$0C,$00,$0C
