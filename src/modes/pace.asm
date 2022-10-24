; target = lines <= 110 ? scoreLookup : scoreLookup + ((lines - 110) / (230 - 110)) * 348
; pace = score - ((target / 230) * lines)

; rough guide: https://docs.google.com/spreadsheets/d/1FKUkx8borKvwwTFmFoM2j7FqMPFoJ4GkdFtO5JIekFE/edit#gid=465512309

lineTargetThreshold := 110

targetTable:
        .byte $0,$0,$0,$0
        .byte $68,$1,$4B,$0 ; 1
        .byte $F8,$2,$6E,$0 ; 2
        .byte $7E,$4,$9A,$0 ; 3
        .byte $E6,$5,$E5,$0 ; 4
        .byte $6C,$7,$12,$1 ; 5
        .byte $CA,$8,$67,$1 ; 6
        .byte $5A,$A,$89,$1 ; 7
        .byte $B8,$B,$DE,$1 ; 8
        .byte $3E,$D,$B,$2 ; 9
        .byte $F2,$E,$A,$2 ; A
        .byte $2C,$10,$83,$2 ; B
        .byte $94,$11,$CD,$2 ; C
        .byte $38,$13,$DC,$2 ; D
        .byte $B4,$14,$13,$3 ; E
        .byte $08,$16,$72,$3

prepareNextPace:
        ; lines BCD -> binary
        lda lines
        sta bcd32
        lda lines+1
        sta bcd32+1
        lda #0
        sta bcd32+2
        sta bcd32+3
        jsr BCD_BIN

        ; check if lines > 230
        lda binary32+1
        bne @moreThan230
        lda binary32
        cmp #230
        bcc @lessThan230
@moreThan230:
        lda #$AA
        sta paceResult
        sta paceResult+1
        sta paceResult+2
        rts
@lessThan230:

        ; use target multiplier as factor B
        jsr paceTarget

        ; use lines as factor A
        lda binary32
        sta factorA24
        lda #0
        sta factorA24+1
        sta factorA24+2

        ; get actual score target in product24
        jsr unsigned_mul24

        ; subtract target from score
        sec
        lda binScore
        sbc product24
        sta binaryTemp
        lda binScore+1
        sbc product24+1
        sta binaryTemp+1
        lda binScore+2
        sbc product24+2
        sta binaryTemp+2

        ; convert to unsigned, extract sign
        lda #0
        sta sign
        lda binaryTemp+2
        and #$80
        beq @positive
        lda #1
        sta sign
        lda binaryTemp
        eor #$FF
        adc #1
        sta binaryTemp
        lda binaryTemp+1
        eor #$FF
        sta binaryTemp+1
        lda binaryTemp+2
        eor #$FF
        sta binaryTemp+2
@positive:

        lda binaryTemp
        sta binary32
        lda binaryTemp+1
        sta binary32+1
        lda binaryTemp+2
        sta binary32+2
        lda #0
        sta binary32+3

        ; back to BCD
        jsr BIN_BCD

        ; reorder data
        lda bcd32
        sta paceResult+2
        lda bcd32+1
        sta paceResult+1
        lda bcd32+2
        sta paceResult

        ; check if highest nybble is empty and use it for a sign
        ldx #$B0
        lda sign
        sta paceSign
        beq @negative
        ldx #$A0
@negative:
        stx tmp3

        lda paceResult
        and #$F0
        bne @noSign
        lda paceResult
        adc tmp3
        sta paceResult
@noSign:

        rts

paceTarget:
        lda binary32
        cmp #lineTargetThreshold+1
        bcc @baseTarget

        sbc #lineTargetThreshold

        ; store the value as if multiplied by 100
        sta dividend+2
        lda #0
        sta dividend
        sta dividend+1

        ; / (230 - 110)
        lda #120
        sta divisor
        lda #0
        sta divisor+1
        sta divisor+2

        jsr unsigned_div24

        ; result in dividend, copy as first factor
        lda dividend+1
        sta factorA24
        lda dividend+2
        sta factorA24+1
        lda #0
        sta factorA24+2

        ; pace target multiplier as other factor
        jsr paceTargetOffset
        lda targetTable+2, x
        sta factorB24
        lda targetTable+3, x
        sta factorB24+1
        lda #0
        sta factorB24+2

        jsr unsigned_mul24

        ; additional target data now in product24

        ; we take the high bytes, so round the low one
        lda product24+0
        cmp #$80
        bcc @noRounding
        clc
        lda product24+1
        adc #1
        sta product24+1

        lda product24+2
        adc #0 ; this load/add/load has an effect if the carry flag is set
        sta product24+2
@noRounding:

        ; add the base target value to the additional target amount
        jsr paceTargetOffset
        clc
        lda product24+1
        adc targetTable, x
        sta product24
        lda product24+2
        adc targetTable+1, x
        sta product24+1
        lda #0
        adc #0
        sta product24+2

        ; use target as next factor
        lda product24+0
        sta factorB24+0
        lda product24+1
        sta factorB24+1
        lda product24+2
        sta factorB24+2

        jmp @done

@baseTarget:
        jsr paceTargetOffset
        lda targetTable, x
        sta factorB24
        lda targetTable+1, x
        sta factorB24+1
        lda #0
        sta factorB24+2
@done:
        rts

paceTargetOffset:
        lda paceModifier
        asl
        asl
        tax
        rts

gameHUDPace:
        lda #$C0
        sta spriteXOffset
        lda #$27
        sta spriteYOffset
        lda #<paceResult
        sta byteSpriteAddr
        lda #>paceResult
        sta byteSpriteAddr+1

        ldx #$E0
        lda paceSign
        beq @positive
        ldx #$F0
@positive:
        stx byteSpriteTile
        lda #3
        sta byteSpriteLen
        jsr byteSprite
        rts
