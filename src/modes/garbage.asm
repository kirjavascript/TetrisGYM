prepareNextGarbage:
        lda garbageModifier
        jsr switch_s_plus_2a
        .addr garbageAlwaysTetrisReady
        .addr garbageNormal
        .addr garbageSmart
        .addr garbageHard
        .addr garbageTypeC ; infinite dig

garbageTypeC:
        jsr findTopBulky
        adc #$20 ; offset from starting position
@loop:
        sta tmp3

        jsr random10
        adc tmp3
        tax
        jsr swapMino
        txa

        sta tmp3
        cmp #$c0
        bcc @loop
        rts

findTopBulky:
        lda #$0
@loop:
        sta tmp3 ; line

        tax
        lda #0
        sta tmp2 ; line block qty
        ldy #9
@loopLine:
        lda playfield, x
        cmp #EMPTY_TILE
        beq @noBlock
        inc tmp2
@noBlock:
        inx
        dey
        bne @loopLine
        lda tmp2
        cmp #4 ; requirement
        bpl @done

        lda tmp3
        adc #$A
        cmp #$b8
        bcc @loop
@done:
        txa
        rts

swapMino:
        ldy #EMPTY_TILE
        lda playfield, x
        cmp #EMPTY_TILE
        bne @full
        ldy #BLOCK_TILES+3
@full:
        tya
        sta playfield, x
        rts

garbageNormal:
        jsr randomHole
        jsr randomGarbage
        rts

garbageSmart:
        jsr smartHole
        jsr randomGarbage
        rts

findTop:
        ldx #$0
@loop:
        lda playfield, x
        cmp #EMPTY_TILE
        bne @done
        inx
        cpx #$b8
        bcc @loop
@done:
        rts

randomGarbage:
        jsr findTop
        cpx #130
        bcc @done

        lda garbageDelay
        ; cmp #0 ; lda sets z flag
        bne @delay

        jsr random10
        and #3
        sta pendingGarbage
        jsr random10
        and #$7
        adc #$2+1
        sta garbageDelay
@delay:
        dec garbageDelay
@done:
        rts

garbageHard:
        jsr findTop
        cpx #100
        bcc @nothing

        lda spawnCount
        and #1
        bne @nothing
        jsr randomHole
        inc pendingGarbage
@nothing:
        rts

smartHole:
        ldx #199
@loop:
        lda playfield, x
        cmp #EMPTY_TILE
        beq @done
        dex
        cpx #190
        bcs @loop
@done:
        txa
        sbc #190
        sta garbageHole
        rts

randomHole:
        jsr random10
        sta garbageHole
        rts

garbageAlwaysTetrisReady:
        ; right well
        lda #9
        sta garbageHole

        lda #0
        sta tmp1 ; garbage to add

        ldx #190
        jsr checkTetrisReady
        ldx #180
        jsr checkTetrisReady
        ldx #170
        jsr checkTetrisReady
        ldx #160
        jsr checkTetrisReady

        lda tmp1
        sta pendingGarbage
        rts

checkTetrisReady:
        ldy #9
@loop:
        lda playfield, x
        cmp #EMPTY_TILE
        bne @filled
        inc tmp1 ; add garbage
        ldy #1
@filled:
        inx
        dey
        bne @loop
        rts
