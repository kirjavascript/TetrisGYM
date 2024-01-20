;This routine converts a packed 8 digit BCD value in memory loactions
;binary32 to binary32+3 to a binary value with the dp value in location
;EXP and stores it in locations bcd32 to bcd32+3. It Then packs the dp value
;in the MSBY high nibble location bcd32+3.
; source: http://www.6502.org/source/integers/32bcdbin.htm
BCD_BIN:
        lda #0
        sta exp
        sta binary32
        sta binary32+1
        sta binary32+2
        sta binary32+3 ;Reset MSBY
        jsr NXT_BCD  ;Get next BCD value
        sta binary32   ;Store in LSBY
        ldx #$07
GET_NXT:
        jsr NXT_BCD  ;Get next BCD value
        jsr MPY10
        dex
        bne GET_NXT
        asl exp      ;Move dp nibble left
        asl exp
        asl exp
        asl exp
        lda binary32+3 ;Get MSBY and filter it
        and #$0f
        ora exp      ;Pack dp
        sta binary32+3
        rts
NXT_BCD:
        ldy #$04
        lda #$00
MV_BITS:
        asl bcd32
        rol bcd32+1
        rol bcd32+2
        rol bcd32+3
        rol a
        dey
        bne MV_BITS
        rts

;Conversion subroutine for BCD_BIN
MPY10:
        sta tmp2    ;Save digit just entered
        lda binary32+3 ;Save partial result on
        pha          ;stack
        lda binary32+2
        pha
        lda binary32+1
        pha
        lda binary32
        pha
        asl binary32   ;Multiply partial
        rol binary32+1 ;result by 2
        rol binary32+2
        rol binary32+3
        asl binary32   ;Multiply by 2 again
        rol binary32+1
        rol binary32+2
        rol binary32+3
        pla          ;Add original result
        adc binary32
        sta binary32
        pla
        adc binary32+1
        sta binary32+1
        pla
        adc binary32+2
        sta binary32+2
        pla
        adc binary32+3
        sta binary32+3
        asl binary32   ;Multiply result by 2
        rol binary32+1
        rol binary32+2
        rol binary32+3
        lda tmp2    ;Add digit just entered
        adc binary32
        sta binary32
        lda #$00
        adc binary32+1
        sta binary32+1
        lda #$00
        adc binary32+2
        sta binary32+2
        lda #$00
        adc binary32+3
        sta binary32+3
        rts

BIN_BCD:
        lda binary32+3 ;Get MSBY
        and #$f0     ;Filter out low nibble
        lsr a        ;Move hi nibble right (dp)
        lsr a
        lsr a
        lsr a
        sta exp      ;store dp
        lda binary32+3
        and #$0f     ;Filter out high nibble
        sta binary32+3
BCD_DP:
        ldy #$00     ;Clear table pointer
NXTDIG:
        ldx #$00     ;Clear digit count
SUB_MEM:
        lda binary32   ;Get LSBY of binary value
        sec
        sbc SUBTBL,y ;Subtract LSBY + y of table value
        sta binary32   ;Return result
        lda binary32+1 ;Get next byte of binary value
        iny
        sbc SUBTBL,y ;Subtract next byte of table value
        sta binary32+1
        lda binary32+2 ;Get next byte
        iny
        sbc SUBTBL,y ;Subtract next byte of table
        sta binary32+2
        lda binary32+3 ;Get MSBY of binary value
        iny
        sbc SUBTBL,y ;Subtract MSBY of table
        bcc ADBACK   ;If result is neg go add back
        sta binary32+3 ;Store MSBY then point back to LSBY of table
        dey
        dey
        dey
        inx
        jmp SUB_MEM  ;Go subtract again
ADBACK:
        dey          ;Point back to LSBY of table
        dey
        dey
        lda binary32   ;Get LSBY of binary value and add LSBY
        adc SUBTBL,y ;of table value
        sta binary32
        lda binary32+1 ;Get next byte
        iny
        adc SUBTBL,y ;Add next byte of table
        sta binary32+1
        lda binary32+2 ;Next byte
        iny
        adc SUBTBL,y ;Add next byte of table
        sta binary32+2
        txa          ;Put dec count in acc
        jsr BCDREG   ;Put in BCD reg
        iny
        iny
        cpy #$20     ;End of table?
        bcc NXTDIG   ;No? go back with next dec weight
        lda binary32   ;Yes? put remainder in acc and put in BCD reg
BCDREG:
        asl a
        asl a
        asl a
        asl a
        ldx #$04
SHFT_L:
        asl a
        rol bcd32
        rol bcd32+1
        rol bcd32+2
        rol bcd32+3
        dex
        bne SHFT_L
        rts

SUBTBL:
        .byte $00,$e1,$f5,$05
        .byte $80,$96,$98,$00
        .byte $40,$42,$0f,$00
        .byte $a0,$86,$01,$00
        .byte $10,$27,$00,$00
        .byte $e8,$03,$00,$00
        .byte $64,$00,$00,$00
        .byte $0a,$00,$00,$00

; source: https://codebase64.org/doku.php?id=base:24bit_multiplication_24bit_product
unsigned_mul24:
    lda #$00			; set product to zero
    sta product24
    sta product24+1
    sta product24+2

@loop:
    lda factorB24                   ; while factorB24 !=0
    bne @nz
    lda factorB24+1
    bne @nz
    lda factorB24+2
    bne @nz
    rts
@nz:
    lda factorB24; if factorB24 isodd
    and #$01
    beq @skip

    lda factorA24			; product24 += factorA24
    clc
    adc product24
    sta product24

    lda factorA24+1
    adc product24+1
    sta product24+1

    lda factorA24+2
    adc product24+2
    sta product24+2			; end if

@skip:
    asl factorA24			; << factorA24
    rol factorA24+1
    rol factorA24+2
    lsr factorB24+2			; >> factorB24
    ror factorB24+1
    ror factorB24

    jmp @loop			; end while

unsigned_div24:
        lda #0	        ;preset remainder to 0
    sta remainder
    sta remainder+1
    sta remainder+2
    ldx #24	        ;repeat for each bit: ...

@divloop:
        asl dividend	;dividend lb & hb*2, msb -> Carry
    rol dividend+1
    rol dividend+2
    rol remainder	;remainder lb & hb * 2 + msb from carry
    rol remainder+1
    rol remainder+2
    lda remainder
    sec
    sbc divisor	;substract divisor to see if it fits in
    tay	        ;lb result -> Y, for we may need it later
    lda remainder+1
    sbc divisor+1
    sta pztemp
    lda remainder+2
    sbc divisor+2
    bcc @skip	;if carry=0 then divisor didn't fit in yet

    sta remainder+2	;else save substraction result as new remainder,
    lda pztemp
    sta remainder+1
    sty remainder
    inc dividend 	;and INCrement result cause divisor fit in 1 times

@skip:
        dex
    bne @divloop
    rts

; from http://forum.6502.org/viewtopic.php?p=5789&sid=46a88a49579252ae3edcf53c0cd54f68#p5789
;----------------------------------------------------------------
;
; SIN(A) COS(A) routines. a full circle is represented by $00 to
; $00 in 256 1.40625 degree steps. returned value is signed 15
; bit with X being the high byte and ranges over +/-0.99997

;----------------------------------------------------------------
;
; get COS(A) in AX

cos_A:
      clc                     ; clear carry for add
      adc   #$40              ; add 1/4 rotation

;----------------------------------------------------------------
;
; get SIN(A) in AX. enter with flags reflecting the contents of A

sin_A:
      bpl   sin_cos           ; just get SIN/COS and return if +ve

      and   #$7F              ; else make +ve
      jsr   sin_cos           ; get SIN/COS
                              ; now do twos complement
      eor   #$FF              ; toggle low byte
      clc                     ; clear carry for add
      adc   #$01              ; add to low byte
      pha                     ; save low byte
      txa                     ; copy high byte
      eor   #$FF              ; toggle high byte
      adc   #$00              ; add carry from low byte
      tax                     ; copy back to X
      pla                     ; restore low byte
      rts

;----------------------------------------------------------------
;
; get AX from SIN/COS table

sin_cos:
      cmp   #$41              ; compare with max+1
      bcc   quadrant          ; branch if less

      eor   #$7F              ; wrap $41 to $7F ..
      adc   #$00              ; .. to $3F to $00
quadrant:
      asl                     ; * 2 bytes per value
      tax                     ; copy to index
      lda   sintab,X          ; get SIN/COS table value low byte
      pha                     ; save it
      lda   sintab+1,X        ; get SIN/COS table value high byte
      tax                     ; copy to X
      pla                     ; restore low byte
      rts

;----------------------------------------------------------------
;
; SIN/COS table. returns values between $0000 and $7FFF

sintab:
      .word $0000,$0324,$0647,$096A,$0C8B,$0FAB,$12C8,$15E2
      .word $18F8,$1C0B,$1F19,$2223,$2528,$2826,$2B1F,$2E11
      .word $30FB,$33DE,$36BE,$398C,$3C56,$3F17,$41CE,$447A
      .word $471C,$49B4,$4C3F,$4EBF,$5133,$539B,$55F5,$5842
      .word $5A82,$5CB4,$5ED7,$60EC,$62F2,$64EB,$66CF,$68A6
      .word $6A6D,$6C24,$6DC4,$6F5F,$70E2,$7255,$73B5,$7504
      .word $7641,$776C,$7884,$798A,$7A7D,$7B5D,$7C2A,$7CE3
      .word $7D8A,$7E1D,$7E9D,$7F09,$7F62,$7FA7,$7FD8,$7FF6
      .word $7FFF
