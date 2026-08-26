clearPlayfield:
        ldx #0
        lda #EMPTY_TILE
@loop:
        sta playfield,x
        dex
        bne @loop
        rts

clearNametable:
        lda #$20
        sta PPUADDR
clearNametableOffset:
        lda #$0
        sta PPUADDR
        lda #EMPTY_TILE
        ldx #4
        ldy #$BF
@clearTile:
        sta PPUDATA
        dey
        bne @clearTile
        sta PPUDATA
        ldy #$FF
        dex
        bne @clearTile
        rts

drawBlackBGPalette:
        ldx renderQueuePointer
        lda #$3F
        sta stack,x
        inx
        lda #$0
        sta stack,x
        inx
        ldy #31
        tya
        sta stack,x
        lda #$F
@loadPaletteLoop:
        sta stack,x
        inx
        dey
        bpl @loadPaletteLoop
        inc renderQueueLength
        rts

resetScroll:
        lda #0
        sta ppuScrollX
        sta ppuScrollY
        rts

random10:
        ldx #rng_seed
        jsr generateNextPseudorandomNumber5x
        lda rng_seed
        and #$0F
        cmp #$0A
        bpl random10
        rts

; canon is waitForVerticalBlankingInterval
updateAudioWaitForNmiAndResetOamStaging:
        jsr updateAudio_jmp
        lda #$00
        sta verticalBlankingInterval
checkForNmi:
        lda verticalBlankingInterval
; label used for crash code to determine if nmi happened here or at the previous instruction
nmiLoopMidpoint:
        beq checkForNmi
; Read Family BASIC Keyboard
        jsr pollKeyboard
resetOAMStaging:
; Hide a sprite by moving it down offscreen, by writing any values between #$EF-#$FF here.
; Sprites are never displayed on the first line of the picture, and it is impossible to place
; a sprite partially off the top of the screen.
; https://www.nesdev.org/wiki/PPU_OAM
        ldx #$00
        lda #$FF
@hideY:
        sta oamStaging,x
        inx
        inx
        inx
        inx
        bne @hideY
        rts

; 7  bit  0
; ---- ----
; BGRs bMmG
; |||| ||||
; |||| |||+- Greyscale (0: normal color, 1: greyscale)
; |||| ||+-- 1: Show background in leftmost 8 pixels of screen, 0: Hide
; |||| |+--- 1: Show sprites in leftmost 8 pixels of screen, 0: Hide
; |||| +---- 1: Enable background rendering
; |||+------ 1: Enable sprite rendering
; ||+------- Emphasize red (green on PAL/Dendy)
; |+-------- Emphasize green (red on PAL/Dendy)
; +--------- Emphasize blue

hideSpritesAndBackground:
        lda #RENDER_IDLE
        sta renderMode
        lda #0
        sta PPUMASK
        rts

showSpriteAndBackground:
        lda renderMode
        pha
        lda #RENDER_IDLE
        sta renderMode
        jsr waitForNmi
        lda #%00011110
        sta PPUMASK
        pla
        sta renderMode
        rts

updateAudioAndWaitForNmi:
        jsr updateAudio_jmp
waitForNmi:
        lda #$00
        sta verticalBlankingInterval
@checkForNmi:
        lda verticalBlankingInterval
        beq @checkForNmi
        rts


;reg x: zeropage addr of seed
generateNextPseudorandomNumber5x:
        jsr generateNextPseudorandomNumber
generateNextPseudorandomNumber4x:
        jsr generateNextPseudorandomNumber
generateNextPseudorandomNumber3x:
        jsr generateNextPseudorandomNumber
generateNextPseudorandomNumber2x:
        jsr generateNextPseudorandomNumber
generateNextPseudorandomNumber:
        lda tmp1,x
        eor tmp2,x
        lsr
        lsr
        ror tmp1,x
        ror tmp2,x
        lda oneThirdPRNG
        sbc #$00
        bpl @noReset
        lda #$2
@noReset:
        sta oneThirdPRNG
        rts

copyPatchAtXYToQueue:
    stx patchPtr
    sty patchPtr+1
@counter = generalCounter
    ldx renderQueuePointer
    ldy #0
@stripe:
; high ppu byte or end marker
    lda (patchPtr),y
    beq @end
    sta stack,x
    iny
    inx
; low ppu byte
    lda (patchPtr),y
    sta stack,x
    iny
    inx
; length
    lda (patchPtr),y
    sta stack,x
    sta @counter
    inx
    iny
@tile:
    lda (patchPtr),y
    sta stack,x
    inx
    iny
    dec @counter
    bpl @tile
    inc renderQueueLength
    bne @stripe
@end:
    stx renderQueuePointer
    rts
