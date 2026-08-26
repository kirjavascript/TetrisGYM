render_mode_queue:
    lda #>dump01Tiles
    sta tmp2
    tsx
    txa
    ldx #$FF
    txs
    tax
checkQueueLength:
    lda renderQueueLength
    bne @stripe
    jmp restoreStackPointer
@stripe:
    pla
    sta PPUADDR
    pla
    sta PPUADDR
    pla ; 0 = 1 tile, max 32 tiles
    tay
    lda queueJumpTable,y
    sta tmp1
    jmp (tmp1)
.repeat 32,i
.ident(.sprintf("dump%02dTiles", 32-i)):
    pla
    sta PPUDATA
.endrepeat
    dec renderQueueLength
    beq restoreStackPointer
    jmp checkQueueLength
restoreStackPointer:
    txs
resetRenderQueue:
    lda #0
    sta renderQueueLength
    sta renderQueuePointer
    rts

queueJumpTable:
.repeat 32,i
    .byte <.ident(.sprintf("dump%02dTiles", i+1))
.endrepeat

.out .sprintf("render queue dump: %d", *-render_mode_queue)
.assert >dump01Tiles=>dump32Tiles,error,"render queue needs to exist in one page"


; .struct GameRender
;     WithPlayfield .struct
;         WithoutPlayfield .struct
;             paletteAddr     .word
;             paletteLen      .byte
;             paletteTiles    .byte 32
;
;             scoreAddr       .word
;             scoreLen        .byte
;             scoreTiles      .byte 7
;
;             linesAddr       .word
;             linesLen        .byte
;             linesTiles      .byte 4
;
;             levelAddr       .word
;             levelLen        .byte
;             levelTiles      .byte 3
;         .endstruct
;         pfield0Addr     .word
;         pfield0Len      .byte
;         pfield0Tiles    .byte 10
;         pfield1Addr     .word
;         pfield1Len      .byte
;         pfield1Tiles    .byte 10
;         pfield2Addr     .word
;         pfield2Len      .byte
;         pfield2Tiles    .byte 10
;         pfield3Addr     .word
;         pfield3Len      .byte
;         pfield3Tiles    .byte 10
;     .endstruct
; .endstruct
;
;
; PALETTE_ADDR = $3f00
;
; ; placeholder values
; SCORE_ADDR = $2000
; LINES_ADDR = $2000
; LEVEL_ADDR = $2000
;
;
; initializeGameRender:
;     lda #>PALETTE_ADDR
;     sta stack+GameRender::paletteAddr
;     lda #<PALETTE_ADDR
;     sta stack+GameRender::paletteAddr+1
;     lda #31
;     sta stack+GameRender::paletteLen
;
;     lda #>SCORE_ADDR
;     sta stack+GameRender::scoreAddr
;     lda #<SCORE_ADDR
;     sta stack+GameRender::scoreAddr+1
;     lda #6
;     sta stack+GameRender::scoreLen
;
;     lda #>LINES_ADDR
;     sta stack+GameRender::linesAddr
;     lda #<LINES_ADDR
;     sta stack+GameRender::linesAddr+1
;     lda #3
;     sta stack+GameRender::linesLen
;
;     lda #>LEVEL_ADDR
;     sta stack+GameRender::levelAddr
;     lda #<LEVEL_ADDR
;     sta stack+GameRender::levelAddr+1
;     lda #2
;     sta stack+GameRender::levelLen
;
; setNoPlayfieldRender:
;     lda #4
;     sta renderQueueLength
;     lda #.sizeof(GameRender::WithoutPlayfield)
;     sta renderQueuePointer
;     rts
