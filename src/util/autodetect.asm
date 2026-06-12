; Mapper detect code by pinobatch.   Only relevant code has been copied and has been modified.
; Original code: https://github.com/pinobatch/holy-mapperel/blob/60ea5c0d97dedca1522525b054012b7c8526f1e1/src/mapper_detect.s

; Original notice:

; Mapper detection for Holy Mapperel
;
; Copyright 2013-2017 Damian Yerrick
; 
; This software is provided 'as-is', without any express or implied
; warranty.  In no event will the authors be held liable for any damages
; arising from the use of this software.
; 
; Permission is granted to anyone to use this software for any purpose,
; including commercial applications, and to alter it and redistribute it
; freely, subject to the following restrictions:
; 
; 1. The origin of this software must not be misrepresented; you must not
;    claim that you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation would be
;    appreciated but is not required.
; 2. Altered source versions must be plainly marked as such, and must not be
;    misrepresented as being the original software.
; 3. This notice may not be removed or altered from any source distribution.
;

MIRRPROBE_V = %0101
MIRRPROBE_H = %0011

testHorizontalMirroring:
        inc mapperId
        jsr setHorizontalMirroring
        dec mapperId
        jsr testMirroring
        cmp #MIRRPROBE_H
        rts

testVerticalMirroring:
        inc mapperId
        jsr setVerticalMirroring
        dec mapperId
        jsr testMirroring
        cmp #MIRRPROBE_V
        rts

testMirroring:
; write_mirror_probe_vals
        ldx #$20
        ldy #$00
        stx PPUADDR
        sty PPUADDR
        sty PPUDATA
        ldx #$2C
        stx PPUADDR
        sty PPUADDR
        iny
        sty PPUDATA

; read_mirror_probe_vals
        ldx #$20  ; src address high
        ldy #$00  ; src address low
        lda #$10  ; ring counter loop: finish once the 1 gets rotated out
readloop:
        pha
        stx PPUADDR
        inx
        sty PPUADDR
        inx
        bit PPUDATA
        inx
        lda PPUDATA
        inx
        lsr a
        pla
        rol a
        bcc readloop
        rts
