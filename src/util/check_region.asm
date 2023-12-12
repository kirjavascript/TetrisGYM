checkRegion:
.assert >@vwait1 = >@endVWait, error, "Region detection code crosses page boundary"

; region detection via http://forums.nesdev.com/viewtopic.php?p=163258#p163258
;;; use the power-on wait to detect video system-
	ldx #0
        stx palFlag ; extra zeroing
	ldy #0
@vwait1:
	bit $2002
	bpl @vwait1  ; at this point, about 27384 cycles have passed
@vwait2:
	inx
	bne @noincy
	iny
@noincy:
	bit $2002
	bpl @vwait2  ; at this point, about 57165 cycles have passed
@endVWait:

;;; BUT because of a hardware oversight, we might have missed a vblank flag.
;;;  so we need to both check for 1Vbl and 2Vbl
;;; NTSC NES: 29780 cycles / 12.005 -> $9B0 or $1361 (Y:X)
;;; PAL NES:  33247 cycles / 12.005 -> $AD1 or $15A2
;;; Dendy:    35464 cycles / 12.005 -> $B8A or $1714

	tya
	cmp #16
	bcc @nodiv2
	lsr
@nodiv2:
	clc
	adc #<-9
	cmp #3
	bcc @noclip3
	lda #3
@noclip3:
;;; Right now, A contains 0,1,2,3 for NTSC,PAL,Dendy,Bad
        cmp #0
        beq @ntsc
        lda #1
        sta palFlag
@ntsc:
        rts
