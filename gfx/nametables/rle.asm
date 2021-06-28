; Konami RLE decompressor

; MIT License

; Copyright (c) 2019 Eric Anderson

; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:

; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.

; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;
; Encoding:
;   $00     Unsupported (useless)
;   <= $80  Repeat next byte n times
;   $FF     End
;   > $80   Next (n-128) bytes are literal

addrLo  := $0000
addrHi  := addrLo+1

copyRleNametableToPpu:
        jsr     copyAddrAtReturnAddressToTmp_incrReturnAddrBy2
        ldx     PPUSTATUS
        lda     #$20
        sta     PPUADDR
        lda     #$00
        sta     PPUADDR
        jmp     rleDecodeToPpu

; Decodes Konami RLE-encoded stream with address stored at $0000.
;
; Does not support 0-length runs; control byte $00 is not supported
rleDecodeToPpu:
        ; y is current input offset
        ; x is chunk length remaining
        ldy     #$00

@processChunk:
        lda     (addrLo),y
        cmp     #$81
        bmi     @runLength
        cmp     #$FF
        beq     @ret
        and     #$7F

; literalLength
        tax
@literalLoop:
        iny
        lda     (addrLo),y
        sta     PPUDATA
        dex
        bne     @literalLoop
        beq     @preventYOverflow

@runLength:
        tax
        iny
        lda     (addrLo),y
@runLengthLoop:
        sta     PPUDATA
        dex
        bne     @runLengthLoop

@preventYOverflow:
        ; The largest input chunk size is literal with a length of 126, which
        ; is 127 bytes of input. We make sure adding 127 to y does not
        ; overflow. This allows us to ignore y overflow during loops.
        iny
        bpl     @processChunk
        ; y is at risk of overflowing next chunk
        tya
        ldy     #$00
        clc
        adc     addrLo
        sta     addrLo
        bcc     @processChunk
        inc     addrHi
        jmp     @processChunk

@ret:
        rts
