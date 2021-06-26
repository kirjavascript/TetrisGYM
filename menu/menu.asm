.include "scrolltext.asm"

; make nametable longer
; sort out yscroll for it
; coarse rendering


; http://forums.nesdev.com/viewtopic.php?p=64111#64111

; menuRAM := $613
; menuCurrentLine :=
; menuFrameChars :=
; menuIndex

;         lda frameCounter
;         cmp #$F
;         bne @ret
;         ; menu ram

;         ; todo: cache
;         lda #$20
;         sta PPUADDR
;         lda #$60
;         sta PPUADDR
;         ldx #$92
; @loop:
;         lda #$A
;         sta PPUDATA
;         dex
;         bne @loop
; @ret:
