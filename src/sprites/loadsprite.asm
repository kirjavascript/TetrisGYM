; the engine from the original game

loadSpriteIntoOamStaging:
        clc
        lda spriteIndexInOamContentLookup
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

oamContentLookup:
        .addr   sprite00LevelSelectCursor
        .addr   sprite01GameTypeCursor
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite06TPiece
        .addr   sprite07SPiece
        .addr   sprite08ZPiece
        .addr   sprite09JPiece
        .addr   sprite0ALPiece
        .addr   sprite0BOPiece
        .addr   sprite0CIPiece
        .addr   sprite0EHighScoreNameCursor
        .addr   sprite0EHighScoreNameCursor
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   spriteDebugLevelEdit ; $16
        .addr   spriteStateSave; $17
        .addr   spriteStateLoad; $18
        .addr   sprite02Blank ; $19
        .addr   sprite02Blank ; $1A
        .addr   spriteSeedCursor ; $1B
        .addr   sprite02Blank
        .addr   spritePractiseTypeCursor ; $1D
        .addr   spriteHeartCursor ; $1E
        .addr   spriteHeart ; $1F
        .addr   spriteReady ; $20
        .addr   spriteCustomLevelCursor ; $21
        .addr   spriteIngameHeart ; $22
; Sprites are sets of 4 bytes in the OAM format, terminated by FF. byte0=y, byte1=tile, byte2=attrs, byte3=x
; YY AA II XX
sprite00LevelSelectCursor:
        .byte   $00,$FC,$20,$00,$00,$FC,$20,$08
        .byte   $08,$FC,$20,$00,$08,$FC,$20,$08
        .byte   $FF
sprite01GameTypeCursor:
        .byte   $00,$27,$00,$00,$00,$27,$40,$3A
        .byte   $FF
; Used as a sort of NOOP for cursors
sprite02Blank:
        .byte   $00,$FF,$00,$00,$FF
sprite06TPiece:
        .byte   $00,$7B,$02,$FC,$00,$7B,$02,$04
        .byte   $00,$7B,$02,$0C,$08,$7B,$02,$04
        .byte   $FF
sprite07SPiece:
        .byte   $00,$7D,$02,$04,$00,$7D,$02,$0C
        .byte   $08,$7D,$02,$FC,$08,$7D,$02,$04
        .byte   $FF
sprite08ZPiece:
        .byte   $00,$7C,$02,$FC,$00,$7C,$02,$04
        .byte   $08,$7C,$02,$04,$08,$7C,$02,$0C
        .byte   $FF
sprite09JPiece:
        .byte   $00,$7D,$02,$FC,$00,$7D,$02,$04
        .byte   $00,$7D,$02,$0C,$08,$7D,$02,$0C
        .byte   $FF
sprite0ALPiece:
        .byte   $00,$7C,$02,$FC,$00,$7C,$02,$04
        .byte   $00,$7C,$02,$0C,$08,$7C,$02,$FC
        .byte   $FF
sprite0BOPiece:
        .byte   $00,$7B,$02,$00,$00,$7B,$02,$08
        .byte   $08,$7B,$02,$00,$08,$7B,$02,$08
        .byte   $FF
sprite0CIPiece:
        .byte   $04,$7B,$02,$F8,$04,$7B,$02,$00
        .byte   $04,$7B,$02,$08,$04,$7B,$02,$10
        .byte   $FF
sprite0EHighScoreNameCursor:
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
spriteSeedCursor:
        .byte   $00,$6B,$00,$00
        .byte   $FF
spritePractiseTypeCursor:
        .byte   $00,$27,$00,$00
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
