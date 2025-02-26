; canon is updateAudio
updateAudio_jmp:
        jmp updateAudio

; canon is updateAudio
updateAudio2:
        jmp soundEffectSlot2_makesNoSound

LE006:  jmp LE1D8

; Referenced via updateSoundEffectSlotShared
soundEffectSlot0Init_table:
        .addr   soundEffectSlot0_makesNoSound
        .addr   soundEffectSlot0_gameOverCurtainInit
        .addr   soundEffectSlot0_endingRocketInit
soundEffectSlot0Playing_table:
        .addr   advanceSoundEffectSlot0WithoutUpdate
        .addr   updateSoundEffectSlot0_apu
        .addr   advanceSoundEffectSlot0WithoutUpdate
soundEffectSlot1Init_table:
        .addr   soundEffectSlot1_menuOptionSelectInit
        .addr   soundEffectSlot1_menuScreenSelectInit
        .addr   soundEffectSlot1_shiftTetriminoInit
        .addr   soundEffectSlot1_tetrisAchievedInit
        .addr   soundEffectSlot1_rotateTetriminoInit
        .addr   soundEffectSlot1_levelUpInit
        .addr   soundEffectSlot1_lockTetriminoInit
        .addr   soundEffectSlot1_chirpChirpInit
        .addr   soundEffectSlot1_lineClearingInit
        .addr   soundEffectSlot1_lineCompletedInit
soundEffectSlot1Playing_table:
        .addr   soundEffectSlot1_menuOptionSelectPlaying
        .addr   soundEffectSlot1_menuScreenSelectPlaying
        .addr   soundEffectSlot1Playing_advance
        .addr   soundEffectSlot1_tetrisAchievedPlaying
        .addr   soundEffectSlot1_rotateTetriminoPlaying
        .addr   soundEffectSlot1_levelUpPlaying
        .addr   soundEffectSlot1Playing_advance
        .addr   soundEffectSlot1_chirpChirpPlaying
        .addr   soundEffectSlot1_lineClearingPlaying
        .addr   soundEffectSlot1_lineCompletedPlaying
soundEffectSlot3Init_table:
        .addr   soundEffectSlot3_fallingAlien
        .addr   soundEffectSlot3_donk
soundEffectSlot3Playing_table:
        .addr   updateSoundEffectSlot3_apu
        .addr   soundEffectSlot3Playing_advance
; Referenced by unused slot 4 as well
soundEffectSlot2Init_table:
        .addr   soundEffectSlot2_makesNoSound
        .addr   soundEffectSlot2_lowBuzz
        .addr   soundEffectSlot2_mediumBuzz
; input y: $E100+y source addr
copyToSq1Channel:
        lda #$00
        beq copyToApuChannel
copyToTriChannel:
        lda #$08
        bne copyToApuChannel
copyToNoiseChannel:
        lda #$0C
        bne copyToApuChannel
copyToSq2Channel:
        lda #$04
; input a: $4000+a APU addr; input y: $E100+y source; copies 4 bytes
copyToApuChannel:
        sta AUDIOTMP1
        lda #$40
        sta AUDIOTMP2
        sty AUDIOTMP3
        lda #>soundEffectSlot0_gameOverCurtainInitData
        sta AUDIOTMP4
        ldy #$00
@copyByte:
        lda (AUDIOTMP3),y
.if SWAP_DUTY_CYCLES
        cpy #0
        bne @notFirstByte
        jsr swapDutyCycles
@notFirstByte:
.endif
        sta (AUDIOTMP1),y
        iny
        tya
        cmp #$04
        bne @copyByte
        rts

; input a: index-1 into table at $E000+AUDIOTMP1; output AUDIOTMP3/4: address; $EF set to a
computeSoundEffMethod:
        sta currentAudioSlot
        pha
        ldy #>soundEffectSlot0Init_table
        sty AUDIOTMP2
        ldy #$00
@whileYNot2TimesA:
        dec currentAudioSlot
        beq @copyAddr
        iny
        iny
        tya
        cmp #$22
        bne @whileYNot2TimesA
        lda #$91
        sta AUDIOTMP3
        lda #>soundEffectSlot0Init_table
        sta AUDIOTMP4
@ret:   pla
        sta currentAudioSlot
        rts

@copyAddr:
        lda (AUDIOTMP1),y
        sta AUDIOTMP3
        iny
        lda (AUDIOTMP1),y
        sta AUDIOTMP4
        jmp @ret

unreferenced_soundRng:
        lda $EB
        and #$02
        sta $06FF
        lda $EC
        and #$02
        eor $06FF
        clc
        beq @insertRandomBit
        sec
@insertRandomBit:
        ror $EB
        ror $EC
        rts

; Z=0 when returned means disabled
advanceAudioSlotFrame:
        ldx currentSoundEffectSlot
        inc soundEffectSlot0FrameCounter,x
        lda soundEffectSlot0FrameCounter,x
        cmp soundEffectSlot0FrameCount,x
        bne @ret
        lda #$00
        sta soundEffectSlot0FrameCounter,x
@ret:   rts

.align $100
        .byte $00 ; pad so low byte is not zero.  See tya in initSoundEffectShared

; Referenced by initSoundEffectShared
soundEffectSlot0_gameOverCurtainInitData:
        .byte   $1F,$7F,$0F,$C0
soundEffectSlot0_endingRocketInitData:
        .byte   $08,$7F,$0E,$C0
; Referenced at LE20F
unknown_sq1_data1:
        .byte   $9D,$7F,$7A,$28
; Referenced at LE20F
unknown_sq1_data2:
        .byte   $9D,$7F,$40,$28
soundEffectSlot1_rotateTetriminoInitData:
        .byte   $9E,$7F,$C0,$28
soundEffectSlot1Playing_rotateTetriminoStage3:
        .byte   $B2,$7F,$C0,$08
soundEffectSlot1_levelUpInitData:
        .byte   $DE,$7F,$A8,$18
soundEffectSlot1_lockTetriminoInitData:
        .byte   $9F,$84,$FF,$0B
soundEffectSlot1_menuOptionSelectInitData:
        .byte   $DB,$7F,$40,$28
soundEffectSlot1Playing_menuOptionSelectStage2:
        .byte   $D2,$7F,$40,$28
soundEffectSlot1_menuScreenSelectInitData:
        .byte   $D9,$7F,$84,$28
soundEffectSlot1_tetrisAchievedInitData:
        .byte   $9E,$9D,$C0,$08
soundEffectSlot1_lineCompletedInitData:
        .byte   $9C,$9A,$A0,$09
soundEffectSlot1_lineClearingInitData:
        .byte   $9E,$7F,$69,$08
soundEffectSlot1_chirpChirpInitData:
        .byte   $96,$7F,$36,$20
soundEffectSlot1Playing_chirpChirpStage2:
        .byte   $82,$7F,$30,$F8
soundEffectSlot1_shiftTetriminoInitData:
        .byte   $98,$7F,$80,$38
soundEffectSlot3_unknown1InitData:
        .byte   $30,$7F,$70,$08
soundEffectSlot3_unknown2InitData:
        .byte   $03,$7F,$3D,$18
soundEffectSlot1_chirpChirpSq1Vol_table:
        .byte   $14,$93,$94,$D3
; See getSoundEffectNoiseNibble
noiselo_table:
        .byte   $7A,$DE,$FF,$EF,$FD,$DF,$FE,$EF
        .byte   $EF,$FD,$EF,$FE,$DF,$FF,$EE,$EE
        .byte   $FF,$EF,$FF,$FF,$FF,$EF,$EF,$FF
        .byte   $FD,$DF,$DF,$EF,$FE,$DF,$EF,$FF
; Similar to noiselo_table. Nibble set to NOISE_VOL bits 0-3 with bit 4 set to 1
noisevol_table:
        .byte   $BF,$FF,$EE,$EF,$EF,$EF,$DF,$FB
        .byte   $BB,$AA,$AA,$99,$98,$87,$76,$66
        .byte   $55,$44,$44,$44,$44,$43,$33,$33
        .byte   $22,$22,$22,$22,$21,$11,$11,$11
updateSoundEffectSlot2:
        ldx #$02
        lda #<soundEffectSlot2Init_table
        ldy #<soundEffectSlot2Init_table
        bne updateSoundEffectSlotShared
updateSoundEffectSlot3:
        ldx #$03
        lda #<soundEffectSlot3Init_table
        ldy #<soundEffectSlot3Playing_table
        bne updateSoundEffectSlotShared
updateSoundEffectSlot4_unused:
        ldx #$04
        lda #<soundEffectSlot2Init_table
        ldy #<soundEffectSlot2Init_table
        bne updateSoundEffectSlotShared
updateSoundEffectSlot1:
        lda soundEffectSlot4Playing
        bne updateSoundEffectSlotShared_rts
        ldx #$01
        lda #<soundEffectSlot1Init_table
        ldy #<soundEffectSlot1Playing_table
        bne updateSoundEffectSlotShared
updateSoundEffectSlot0:
        ldx #$00
        lda #<soundEffectSlot0Init_table
        ldy #<soundEffectSlot0Playing_table
; x: sound effect slot; a: low byte addr, for $E0 high byte; y: low byte addr, for $E0 high byte, if slot unused
updateSoundEffectSlotShared:
.if !NO_SFX
        sta AUDIOTMP1
        stx currentSoundEffectSlot
        lda soundEffectSlot0Init,x
        beq @primaryIsEmpty
@computeAndExecute:
        jsr computeSoundEffMethod
        jmp (AUDIOTMP3)

@primaryIsEmpty:
        lda soundEffectSlot0Playing,x
        beq updateSoundEffectSlotShared_rts
        sty AUDIOTMP1
        bne @computeAndExecute
.endif
updateSoundEffectSlotShared_rts:
        rts

LE1D8:  lda #$0F
        sta SND_CHN
        lda #$55
        sta soundRngSeed
        jsr soundEffectSlot2_makesNoSound
        rts

initAudioAndMarkInited:
        inc audioInitialized
        jsr muteAudio
        sta musicPauseSoundEffectLengthCounter
        rts

handlePausedAudio:  lda audioInitialized
        beq initAudioAndMarkInited
        lda musicPauseSoundEffectLengthCounter
        cmp #$12
        beq LE215
        and #$03
        cmp #$03
        bne LE212
        inc musicPauseSoundEffectCounter
        ldy #<unknown_sq1_data2
        lda musicPauseSoundEffectCounter
        and #$01
        bne LE20F
        ldy #<unknown_sq1_data1
LE20F:  jsr copyToSq1Channel
LE212:  inc musicPauseSoundEffectLengthCounter
LE215:  rts

; Disables APU frame interrupt
updateAudio:
        lda #$C0
        sta JOY2_APUFC
        lda musicStagingNoiseHi
        cmp #$05
        beq handlePausedAudio
        lda #$00
        sta audioInitialized
        sta musicPauseSoundEffectCounter
        jsr updateSoundEffectSlot2
        jsr updateSoundEffectSlot0
        jsr updateSoundEffectSlot3
        jsr updateSoundEffectSlot1
        jsr updateMusic
        lda #$00
        ldx #$06
@clearSoundEffectSlotsInit:
        sta $06EF,x
        dex
        bne @clearSoundEffectSlotsInit
        rts

soundEffectSlot2_makesNoSound:
        jsr LE253
muteAudioAndClearTriControl:
        jsr muteAudio
        lda #$00
        sta DMC_RAW
        sta musicChanControl+2
        rts

LE253:  lda #$00
        sta musicChanInhibit
        sta musicChanInhibit+1
        sta musicChanInhibit+2
        sta musicStagingNoiseLo
        sta resetSq12ForMusic
        tay
LE265:  lda #$00
        sta soundEffectSlot0Playing,y
        iny
        tya
        cmp #$06
        bne LE265
        rts

muteAudio:
        lda #$00
        sta DMC_RAW
        lda #$10
        sta SQ1_VOL
        sta SQ2_VOL
        sta NOISE_VOL
        lda #$00
        sta TRI_LINEAR
        rts

; inits currentSoundEffectSlot; input y: $E100+y to init APU channel (leaves alone if 0); input a: number of frames
initSoundEffectShared:
        ldx currentSoundEffectSlot
        sta soundEffectSlot0FrameCount,x
        txa
        sta $06C7,x
        tya
        beq @continue
        txa
        beq @slot0
        cmp #$01
        beq @slot1
        cmp #$02
        beq @slot2
        cmp #$03
        beq @slot3
        rts

@slot1: jsr copyToSq1Channel
        beq @continue
@slot2: jsr copyToSq2Channel
        beq @continue
@slot3: jsr copyToTriChannel
        beq @continue
@slot0: jsr copyToNoiseChannel
@continue:
        lda currentAudioSlot
        sta soundEffectSlot0Playing,x
        lda #$00
        sta soundEffectSlot0FrameCounter,x
        sta soundEffectSlot0SecondaryCounter,x
        sta soundEffectSlot0TertiaryCounter,x
        sta soundEffectSlot0Tmp,x
        sta resetSq12ForMusic
        rts

soundEffectSlot0_endingRocketInit:
        lda #$20
        ldy #<soundEffectSlot0_endingRocketInitData
        jmp initSoundEffectShared

setNoiseLo:
        sta NOISE_LO
        rts

loadNoiseLo:
        jsr getSoundEffectNoiseNibble
        jmp setNoiseLo

soundEffectSlot0_makesNoSound:
        lda #$10
        ldy #$00
        jmp initSoundEffectShared

advanceSoundEffectSlot0WithoutUpdate:
        jsr advanceAudioSlotFrame
        bne updateSoundEffectSlot0WithoutUpdate_ret
stopSoundEffectSlot0:
        lda #$00
        sta soundEffectSlot0Playing
        lda #$10
        sta NOISE_VOL
updateSoundEffectSlot0WithoutUpdate_ret:
        rts

unreferenced_code2:
        lda #$02
        sta currentAudioSlot
soundEffectSlot0_gameOverCurtainInit:
        lda #$40
        ldy #<soundEffectSlot0_gameOverCurtainInitData
        jmp initSoundEffectShared

updateSoundEffectSlot0_apu:
        jsr advanceAudioSlotFrame
        bne updateSoundEffectNoiseAudio
        jmp stopSoundEffectSlot0

updateSoundEffectNoiseAudio:
        ldx #<noiselo_table
        jsr loadNoiseLo
        ldx #<noisevol_table
        jsr getSoundEffectNoiseNibble
        ora #$10
        sta NOISE_VOL
        inc soundEffectSlot0SecondaryCounter
        rts

; Loads from noiselo_table(x=$54)/noisevol_table(x=$74)
getSoundEffectNoiseNibble:
        stx AUDIOTMP1
        ldy #>soundEffectSlot0_gameOverCurtainInitData
        sty AUDIOTMP2
        ldx soundEffectSlot0SecondaryCounter
        txa
        lsr a
        tay
        lda (AUDIOTMP1),y
        sta AUDIOTMP5
        txa
        and #$01
        beq @shift4
        lda AUDIOTMP5
        and #$0F
        rts

@shift4:lda AUDIOTMP5
        lsr a
        lsr a
        lsr a
        lsr a
        rts

LE33B:  lda soundEffectSlot1Playing
        cmp #$04
        beq LE34E
        cmp #$06
        beq LE34E
        cmp #$09
        beq LE34E
        cmp #$0A
        beq LE34E
LE34E:  rts

soundEffectSlot1_chirpChirpPlaying:
        lda soundEffectSlot1TertiaryCounter
        beq @stage1
        inc soundEffectSlot1SecondaryCounter
        lda soundEffectSlot1SecondaryCounter
        cmp #$16
        bne soundEffectSlot1Playing_ret
        jmp soundEffectSlot1Playing_stop

@stage1:lda soundEffectSlot1SecondaryCounter
        and #$03
        tay
        lda soundEffectSlot1_chirpChirpSq1Vol_table,y
.if SWAP_DUTY_CYCLES
        jsr swapDutyCycles
.endif
        sta SQ1_VOL
        inc soundEffectSlot1SecondaryCounter
        lda soundEffectSlot1SecondaryCounter
        cmp #$08
        bne soundEffectSlot1Playing_ret
        inc soundEffectSlot1TertiaryCounter
        ldy #<soundEffectSlot1Playing_chirpChirpStage2
        jmp copyToSq1Channel

; Unused.
soundEffectSlot1_chirpChirpInit:
        ldy #<soundEffectSlot1_chirpChirpInitData
        jmp initSoundEffectShared

soundEffectSlot1_lockTetriminoInit:
        jsr LE33B
        beq soundEffectSlot1Playing_ret
        lda #$0F
        ldy #<soundEffectSlot1_lockTetriminoInitData
        jmp initSoundEffectShared

soundEffectSlot1_shiftTetriminoInit:
        jsr LE33B
        beq soundEffectSlot1Playing_ret
        lda #$02
        ldy #<soundEffectSlot1_shiftTetriminoInitData
        jmp initSoundEffectShared

soundEffectSlot1Playing_advance:
        jsr advanceAudioSlotFrame
        bne soundEffectSlot1Playing_ret
soundEffectSlot1Playing_stop:
        lda #$10
        sta SQ1_VOL
        lda #$00
        sta musicChanInhibit
        sta soundEffectSlot1Playing
        inc resetSq12ForMusic
soundEffectSlot1Playing_ret:
        rts

soundEffectSlot1_menuOptionSelectPlaying_ret:
        rts

soundEffectSlot1_menuOptionSelectPlaying:
        jsr advanceAudioSlotFrame
        bne soundEffectSlot1_menuOptionSelectPlaying_ret
        inc soundEffectSlot1SecondaryCounter
        lda soundEffectSlot1SecondaryCounter
        cmp #$02
        bne @stage2
        jmp soundEffectSlot1Playing_stop

@stage2:ldy #<soundEffectSlot1Playing_menuOptionSelectStage2
        jmp copyToSq1Channel

soundEffectSlot1_menuOptionSelectInit:
        lda #$03
        ldy #<soundEffectSlot1_menuOptionSelectInitData
        bne LE417
soundEffectSlot1_rotateTetrimino_ret:
        rts

soundEffectSlot1_rotateTetriminoInit:
        jsr LE33B
        beq soundEffectSlot1_rotateTetrimino_ret
        lda #$04
        ldy #<soundEffectSlot1_rotateTetriminoInitData
        jsr LE417
soundEffectSlot1_rotateTetriminoPlaying:
        jsr advanceAudioSlotFrame
        bne soundEffectSlot1_rotateTetrimino_ret
        lda soundEffectSlot1SecondaryCounter
        inc soundEffectSlot1SecondaryCounter
        beq @stage3
        cmp #$01
        beq @stage2
        cmp #$02
        beq @stage3
        cmp #$03
        bne soundEffectSlot1_rotateTetrimino_ret
        jmp soundEffectSlot1Playing_stop

@stage2:ldy #<soundEffectSlot1_rotateTetriminoInitData
        jmp copyToSq1Channel

; On first glance it appears this is used twice, but the first beq does nothing because the inc result will never be 0
@stage3:ldy #<soundEffectSlot1Playing_rotateTetriminoStage3
        jmp copyToSq1Channel

soundEffectSlot1_tetrisAchievedInit:
        lda #$05
        ldy palFlag
        ; cpy #0 ; ldy sets z flag
        beq @ntsc
        lda #$4
@ntsc:
        ldy #<soundEffectSlot1_tetrisAchievedInitData
        jsr LE417
        lda #$10
        bne LE437
soundEffectSlot1_tetrisAchievedPlaying:
        jsr advanceAudioSlotFrame
        bne LE43A
        ldy #<soundEffectSlot1_tetrisAchievedInitData
        bne LE442
LE417:  jmp initSoundEffectShared

soundEffectSlot1_lineCompletedInit:
        lda #$05
        ldy palFlag
        ; cpy #0 ; ldy sets z flag
        beq @ntsc
        lda #$4
@ntsc:
        ldy #<soundEffectSlot1_lineCompletedInitData
        jsr LE417
        lda #$08
        bne LE437
soundEffectSlot1_lineCompletedPlaying:
        jsr advanceAudioSlotFrame
        bne LE43A
        ldy #<soundEffectSlot1_lineCompletedInitData
        bne LE442
soundEffectSlot1_lineClearingInit:
        lda #$04
        ldy palFlag
        ; cpy #0 ; ldy sets z flag
        beq @ntsc
        lda #$3
@ntsc:
        ldy #<soundEffectSlot1_lineClearingInitData
        jsr LE417
        lda #$00
LE437:  sta soundEffectSlot1TertiaryCounter
LE43A:  rts

soundEffectSlot1_lineClearingPlaying:
        jsr advanceAudioSlotFrame
        bne LE43A
        ldy #<soundEffectSlot1_lineClearingInitData
LE442:  jsr copyToSq1Channel
        clc
        lda soundEffectSlot1TertiaryCounter
        adc soundEffectSlot1SecondaryCounter
        tay
        lda unknown1_table,y
        sta SQ1_LO
        ldy soundEffectSlot1SecondaryCounter
        lda sq1vol_unknown2_table,y
.if SWAP_DUTY_CYCLES
        jsr swapDutyCycles
        tay ; set z flag based on a; y can be safely clobbered
.endif
        sta SQ1_VOL
        bne LE46F
        lda soundEffectSlot1Playing
        cmp #$04
        bne LE46C
        lda #$09
        sta currentAudioSlot
        jmp soundEffectSlot1_lineClearingInit

LE46C:  jmp soundEffectSlot1Playing_stop

LE46F:  inc soundEffectSlot1SecondaryCounter
LE472:  rts

soundEffectSlot1_menuScreenSelectInit:
        lda #$03
        ldy #<soundEffectSlot1_menuScreenSelectInitData
        jsr initSoundEffectShared
        lda soundEffectSlot1_menuScreenSelectInitData+2
        sta soundEffectSlot1SecondaryCounter
        rts

soundEffectSlot1_menuScreenSelectPlaying:
        jsr advanceAudioSlotFrame
        bne LE472
        inc soundEffectSlot1TertiaryCounter
        lda soundEffectSlot1TertiaryCounter
        cmp #$04
        bne LE493
        jmp soundEffectSlot1Playing_stop

LE493:  lda soundEffectSlot1SecondaryCounter
        lsr a
        lsr a
        lsr a
        lsr a
        sta soundEffectSlot1Tmp
        lda soundEffectSlot1SecondaryCounter
        clc
        sbc soundEffectSlot1Tmp
        sta soundEffectSlot1SecondaryCounter
        sta SQ1_LO
        lda #$28
LE4AC:  sta SQ1_HI
LE4AF:  rts

sq1vol_unknown2_table:
        .byte   $9E,$9B,$99,$96,$94,$93,$92,$91
        .byte   $00
unknown1_table:
        .byte   $46,$37,$46,$37,$46,$37,$46,$37
        .byte   $70,$80,$90,$A0,$B0,$C0,$D0,$E0
        .byte   $C0,$89,$B8,$68,$A0,$50,$90,$40
soundEffectSlot1_levelUpPlaying:
        jsr advanceAudioSlotFrame
        bne LE4AF
        ldy soundEffectSlot1SecondaryCounter
        inc soundEffectSlot1SecondaryCounter
        lda unknown18_table,y
        beq LE4E9
        sta SQ1_LO
        lda #$28
        jmp LE4AC

LE4E9:  jmp soundEffectSlot1Playing_stop

soundEffectSlot1_levelUpInit:
        lda #$06
        ldy palFlag
        ; cpy #0 ; ldy sets z flag
        beq @ntsc
        lda #$5
@ntsc:
        ldy #<soundEffectSlot1_levelUpInitData
        jmp initSoundEffectShared

unknown18_table:
        .byte   $69,$A8,$69,$A8,$8D,$53,$8D,$53
        .byte   $8D,$00,$A9,$10,$8D,$04,$40,$A9
        .byte   $00,$8D,$C9,$06,$8D,$FA,$06,$60
; Unused
soundEffectSlot2_mediumBuzz:
        .byte   $A9,$3F,$A0,$60,$A2,$0F
        bne LE51B
; Unused
soundEffectSlot2_lowBuzz:
        lda #$3F
        ldy #$60
        ldx #$0E
        bne LE51B
LE51B:  sta DMC_LEN
        sty DMC_START
        stx DMC_FREQ
        lda #$0F
        sta SND_CHN
        lda #$00
        sta DMC_RAW
        lda #$1F
        sta SND_CHN
        rts

; Unused
soundEffectSlot3_donk:
        lda #$02
        ldy #<soundEffectSlot3_unknown2InitData
        jmp initSoundEffectShared

soundEffectSlot3Playing_advance:
        jsr advanceAudioSlotFrame
        bne soundEffectSlot3Playing_ret
soundEffectSlot3Playing_stop:
        lda #$00
        sta TRI_LINEAR
        sta musicChanInhibit+2
        sta soundEffectSlot3Playing
        lda #$18
        sta TRI_HI
soundEffectSlot3Playing_ret:
        rts

updateSoundEffectSlot3_apu:
        jsr advanceAudioSlotFrame
        bne soundEffectSlot3Playing_ret
        ldy soundEffectSlot3SecondaryCounter
        inc soundEffectSlot3SecondaryCounter
        lda trilo_table,y
        beq soundEffectSlot3Playing_stop
        sta TRI_LO
        sta soundEffectSlot3TertiaryCounter
        lda soundEffectSlot3_unknown1InitData+3
        sta TRI_HI
        rts

; Unused
soundEffectSlot3_fallingAlien:
        lda #$06
        ldy #<soundEffectSlot3_unknown1InitData
        jsr initSoundEffectShared
        lda soundEffectSlot3_unknown1InitData+2
        sta soundEffectSlot3TertiaryCounter
        rts

trilo_table:
        .byte   $72,$74,$77,$00
updateMusic_noSoundJmp:
        jmp soundEffectSlot2_makesNoSound

updateMusic:
        lda musicTrack
        tay
        ; old:
        ; cmp #$FF
        ; beq updateMusic_noSoundJmp
        ; cmp #$00
        ; beq @checkIfAlreadyPlaying

        ; new:
        beq @checkIfAlreadyPlaying ; tay sets z flag
        cmp #$FF
        beq updateMusic_noSoundJmp
        sta currentAudioSlot
        sta musicTrack_dec
        dec musicTrack_dec
        lda #$7F
        sta musicStagingSq1Sweep
        sta musicStagingSq1Sweep+1
        jsr loadMusicTrack
@updateFrame:
        jmp updateMusicFrame

@checkIfAlreadyPlaying:
        lda currentlyPlayingMusicTrack
        bne @updateFrame
        rts

; triples of bytes, one for each MMIO
noises_table:
        .byte   $00,$10,$01,$18,$00,$01,$38,$00
        .byte   $03,$40,$00,$06,$58,$00,$0A,$38
        .byte   $02,$04,$40,$13,$05,$40,$14,$0A
        .byte   $40,$14,$08,$40,$12,$0E,$08,$16
        .byte   $0E,$28,$16,$0B,$18
; input x: channel number (0-3). Does nothing for track 1 and NOISE
updateMusicFrame_setChanLo:
        lda currentlyPlayingMusicTrack
        cmp #$01
        beq @ret
        txa
        cmp #$03
        beq @ret
        lda musicChanControl,x
        and #$E0
        beq @ret
        sta AUDIOTMP1
        lda musicChanNote,x
        cmp #$02
        beq @incAndRet
        ldy musicChannelOffset
        lda musicStagingSq1Lo,y
        sta AUDIOTMP2
        jsr updateMusicFrame_setChanLoOffset
@incAndRet:
        inc musicChanLoFrameCounter,x
@ret:   rts

musicLoOffset_8AndC:
        lda AUDIOTMP3
        cmp #$31
        bne @lessThan31
        lda #$27
@lessThan31:
        tay
        lda loOff9To0FallTable,y
        pha
        lda musicChanNote,x
        cmp #$46
        bne LE613
        pla
        lda #$00
        beq musicLoOffset_setLoAndSaveFrameCounter
LE613:  pla
        jmp musicLoOffset_setLoAndSaveFrameCounter

; Doesn't loop
musicLoOffset_4:
        lda AUDIOTMP3
        tay
        cmp #$10
        bcs @outOfRange
        lda loOffDescendToNeg11BounceToNeg9Table,y
        jmp musicLoOffset_setLo

@outOfRange:
        lda #$F6
        bne musicLoOffset_setLo
; Every frame is the same
musicLoOffset_minus2_6:
        lda musicChanNote,x
        cmp #$4C
        bcc @unnecessaryBranch
        lda #$FE
        bne musicLoOffset_setLo
@unnecessaryBranch:
        lda #$FE
        bne musicLoOffset_setLo
; input x: channel number (0-2). input AUDIOTMP1: musicChanControl masked by #$E0. input AUDIOTMP2: base LO
updateMusicFrame_setChanLoOffset:
        lda musicChanLoFrameCounter,x
        sta AUDIOTMP3
        lda AUDIOTMP1
        cmp #$20
        beq @2AndE
        cmp #$A0
        beq @A
        cmp #$60
        beq musicLoOffset_minus2_6
        cmp #$40
        beq musicLoOffset_4
        cmp #$80
        beq musicLoOffset_8AndC
        cmp #$C0
        beq musicLoOffset_8AndC
; Loops between 0-9
@2AndE: lda AUDIOTMP3
        cmp #$0A
        bne @2AndE_lessThanA
        lda #$00
@2AndE_lessThanA:
        tay
        lda loOffTrillNeg2To2Table,y
        jmp musicLoOffset_setLoAndSaveFrameCounter

; Ends by looping in 2 and E table
@A:     lda AUDIOTMP3
        cmp #$2B
        bne @A_lessThan2B
        lda #$21
@A_lessThan2B:
        tay
        lda loOffSlowStartTrillTable,y
musicLoOffset_setLoAndSaveFrameCounter:
        pha
        tya
        sta musicChanLoFrameCounter,x
        pla
musicLoOffset_setLo:
        pha
        lda musicChanInhibit,x
        bne @ret
        pla
        clc
        adc AUDIOTMP2
        ldy musicChannelOffset
        sta SQ1_LO,y
        rts

@ret:   pla
        rts

; Values are signed
loOff9To0FallTable:
        .byte   $09,$08,$07,$06,$05,$04,$03,$02
        .byte   $02,$01,$01,$00
; Includes next table
loOffSlowStartTrillTable:
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$01
        .byte   $00,$00,$00,$00,$FF,$00,$00,$00
        .byte   $00,$01,$01,$00,$00,$00,$FF,$FF
        .byte   $00
loOffTrillNeg2To2Table:
        .byte   $00,$01,$01,$02,$01,$00,$FF,$FF
        .byte   $FE,$FF
loOffDescendToNeg11BounceToNeg9Table:
        .byte   $00,$FF,$FE,$FD,$FC,$FB,$FA,$F9
        .byte   $F8,$F7,$F6,$F5,$F6,$F7,$F6,$F5
copyFFFFToDeref:
        lda #$FF
        sta musicDataChanPtrDeref,x
        bne storeDeref1AndContinue
loadMusicTrack:
        jsr muteAudioAndClearTriControl
        lda currentAudioSlot
        sta currentlyPlayingMusicTrack
        lda musicTrack_dec
        tay
        lda musicDataTableIndex,y
        tay
        ldx #$00
@copyByteToMusicData:
        lda musicDataTable,y
        sta musicDataNoteTableOffset,x
        iny
        inx
        txa
        cmp #$0A
        bne @copyByteToMusicData
        lda #$01
        sta musicChanNoteDurationRemaining
        sta musicChanNoteDurationRemaining+1
        sta musicChanNoteDurationRemaining+2
        sta musicChanNoteDurationRemaining+3
        lda #$00
        sta music_unused2
        ldy #$08
@zeroFillDeref:
        sta musicDataChanPtrDeref+7,y
        dey
        bne @zeroFillDeref
        tax
derefNextAddr:
        lda musicDataChanPtr,x
        sta musicChanTmpAddr
        lda musicDataChanPtr+1,x
        cmp #$FF
        beq copyFFFFToDeref
        sta musicChanTmpAddr+1
        ldy musicDataChanPtrOff
        lda (musicChanTmpAddr),y
        sta musicDataChanPtrDeref,x
        iny
        lda (musicChanTmpAddr),y
storeDeref1AndContinue:
        sta musicDataChanPtrDeref+1,x
        inx
        inx
        txa
        cmp #$08
        bne derefNextAddr
        rts

initSq12IfTrashedBySoundEffect:
        lda resetSq12ForMusic
        beq initSq12IfTrashedBySoundEffect_ret
        cmp #$01
        beq @setSq1
        lda #$7F
        sta SQ2_SWEEP
        lda musicStagingSq2Lo
        sta SQ2_LO
        lda musicStagingSq2Hi
        sta SQ2_HI
@setSq1:lda #$7F
        sta SQ1_SWEEP
        lda musicStagingSq1Lo
        sta SQ1_LO
        lda musicStagingSq1Hi
        sta SQ1_HI
        lda #$00
        sta resetSq12ForMusic
initSq12IfTrashedBySoundEffect_ret:
        rts

; input x: channel number (0-3). Does nothing for SQ1/2
updateMusicFrame_setChanVol:
        txa
        cmp #$02
        bcs initSq12IfTrashedBySoundEffect_ret
        lda musicChanControl,x
        and #$1F
        beq @ret
        sta AUDIOTMP2
        lda musicChanNote,x
        cmp #$02
        beq @muteAndAdvanceFrame
        ldy #$00
@controlMinus1Times2_storeToY:
        dec AUDIOTMP2
        beq @loadFromTable
        iny
        iny
        bne @controlMinus1Times2_storeToY
@loadFromTable:
        lda musicChanVolControlTable,y
        sta AUDIOTMP3
        lda musicChanVolControlTable+1,y
        sta AUDIOTMP4
        lda musicChanVolFrameCounter,x
        lsr a
        tay
        lda (AUDIOTMP3),y
        sta AUDIOTMP5
        cmp #$FF
        beq @constVolAtEnd
        cmp #$F0
        beq @muteAtEnd
        lda musicChanVolFrameCounter,x
        and #$01
        bne @useNibbleFromTable
        lsr AUDIOTMP5
        lsr AUDIOTMP5
        lsr AUDIOTMP5
        lsr AUDIOTMP5
@useNibbleFromTable:
        lda AUDIOTMP5
        and #$0F
        sta AUDIOTMP1
        lda musicChanVolume,x
        and #$F0
        ora AUDIOTMP1
        tay
@advanceFrameAndSetVol:
        inc musicChanVolFrameCounter,x
@setVol:lda musicChanInhibit,x
        bne @ret
        tya
        ldy musicChannelOffset
.if SWAP_DUTY_CYCLES
        jsr swapDutyCycles
.endif
        sta SQ1_VOL,y
@ret:   rts

@constVolAtEnd:
        ldy musicChanVolume,x
        bne @setVol
; Only seems valid for NOISE
@muteAtEnd:
        ldy #$10
        bne @setVol
; Only seems valid for NOISE
@muteAndAdvanceFrame:
        ldy #$10
        bne @advanceFrameAndSetVol
;
updateMusicFrame_progLoadNextScript:
        iny
        lda (musicChanTmpAddr),y
        sta musicDataChanPtr,x
        iny
        lda (musicChanTmpAddr),y
        sta musicDataChanPtr+1,x
        lda musicDataChanPtr,x
        sta musicChanTmpAddr
        lda musicDataChanPtr+1,x
        sta musicChanTmpAddr+1
        txa
        lsr a
        tax
        lda #$00
        tay
        sta musicDataChanPtrOff,x
        jmp updateMusicFrame_progLoadRoutine

updateMusicFrame_progEnd:
        jsr soundEffectSlot2_makesNoSound
updateMusicFrame_ret:
        rts

updateMusicFrame_progNextRoutine:
        txa
        asl a
        tax
        lda musicDataChanPtr,x
        sta musicChanTmpAddr
        lda musicDataChanPtr+1,x
        sta musicChanTmpAddr+1
        txa
        lsr a
        tax
        inc musicDataChanPtrOff,x
        inc musicDataChanPtrOff,x
        ldy musicDataChanPtrOff,x
; input musicChanTmpAddr: current channel's musicDataChanPtr. input y: offset. input x: channel number (0-3)
updateMusicFrame_progLoadRoutine:
        txa
        asl a
        tax
        lda (musicChanTmpAddr),y
        sta musicDataChanPtrDeref,x
        iny
        lda (musicChanTmpAddr),y
        sta musicDataChanPtrDeref+1,x
        ; cmp #$00 ; lda sets z flag
        beq updateMusicFrame_progEnd
        cmp #$FF
        beq updateMusicFrame_progLoadNextScript
        txa
        lsr a
        tax
        lda #$00
        sta musicDataChanInstructionOffset,x
        lda #$01
        sta musicChanNoteDurationRemaining,x
        bne updateMusicFrame_updateChannel
;
updateMusicFrame_progNextRoutine_jmp:
        jmp updateMusicFrame_progNextRoutine

updateMusicFrame:
        jsr initSq12IfTrashedBySoundEffect
        lda #$00
        tax
        sta musicChannelOffset
        beq updateMusicFrame_updateChannel
; input x: channel number * 2
updateMusicFrame_incSlotFromOffset:
        txa
        lsr a
        tax
; input x: channel number (0-3)
updateMusicFrame_incSlot:
        inx
        txa
        cmp #$04
        beq updateMusicFrame_ret
        lda musicChannelOffset
        clc
        adc #$04
        sta musicChannelOffset
; input x: channel number (0-3)
updateMusicFrame_updateChannel:
        txa
        asl a
        tax
        lda musicDataChanPtrDeref,x
        sta musicChanTmpAddr
        lda musicDataChanPtrDeref+1,x
        sta musicChanTmpAddr+1
        lda musicDataChanPtrDeref+1,x
        cmp #$FF
        beq updateMusicFrame_incSlotFromOffset
        txa
        lsr a
        tax
        dec musicChanNoteDurationRemaining,x
        bne @updateChannelFrame
        lda #$00
        sta musicChanVolFrameCounter,x
        sta musicChanLoFrameCounter,x
@processChannelInstruction:
        jsr musicGetNextInstructionByte
        beq updateMusicFrame_progNextRoutine_jmp
        cmp #$9F
        beq @setControlAndVolume
        cmp #$9E
        beq @setDurationOffset
        cmp #$9C
        beq @setNoteOffset
        tay
        cmp #$FF
        beq @endLoop
        and #$C0
        cmp #$C0
        beq @startForLoop
        jmp @noteAndMaybeDuration

@endLoop:
        lda musicChanProgLoopCounter,x
        beq @processChannelInstruction_jmp
        dec musicChanProgLoopCounter,x
        lda musicDataChanInstructionOffsetBackup,x
        sta musicDataChanInstructionOffset,x
        bne @processChannelInstruction_jmp
; Low 6 bits are number of times to run loop (1 == run code once)
@startForLoop:
        tya
        and #$3F
        sta musicChanProgLoopCounter,x
        dec musicChanProgLoopCounter,x
        lda musicDataChanInstructionOffset,x
        sta musicDataChanInstructionOffsetBackup,x
@processChannelInstruction_jmp:
        jmp @processChannelInstruction

@updateChannelFrame:
        jsr updateMusicFrame_setChanVol
        jsr updateMusicFrame_setChanLo
        jmp updateMusicFrame_incSlot

@playDmcAndNoise_jmp:
        jmp @playDmcAndNoise

@applyDurationForTri_jmp:
        jmp @applyDurationForTri

@setControlAndVolume:
        jsr musicGetNextInstructionByte
        sta musicChanControl,x
        jsr musicGetNextInstructionByte
        sta musicChanVolume,x
        jmp @processChannelInstruction

@unreferenced_code3:
        jsr musicGetNextInstructionByte
        jsr musicGetNextInstructionByte
        jmp @processChannelInstruction

@setDurationOffset:
        jsr musicGetNextInstructionByte
        sta musicDataDurationTableOffset
        jmp @processChannelInstruction

@setNoteOffset:
        jsr musicGetNextInstructionByte
        sta musicDataNoteTableOffset
        jmp @processChannelInstruction

; Duration, if present, is first
@noteAndMaybeDuration:
        tya
        and #$B0
        cmp #$B0
        bne @processNote
        tya
        and #$0F
        clc
        adc musicDataDurationTableOffset
        tay
        lda noteDurationTable,y
        sta musicChanNoteDuration,x
        tay
        txa
        cmp #$02
        beq @applyDurationForTri_jmp
@loadNextAsNote:
        jsr musicGetNextInstructionByte
        tay
@processNote:
        tya
        sta musicChanNote,x
        txa
        cmp #$03
        beq @playDmcAndNoise_jmp
        pha
        ldx musicChannelOffset
        lda noteToWaveTable+1,y
        beq @determineVolume
        lda musicDataNoteTableOffset
        bpl @signMagnitudeIsPositive
        and #$7F
        sta AUDIOTMP4
        tya
        clc
        sbc AUDIOTMP4
        jmp @noteOffsetApplied

@signMagnitudeIsPositive:
        tya
        clc
        adc musicDataNoteTableOffset
@noteOffsetApplied:
        tay
        lda noteToWaveTable+1,y
        sta musicStagingSq1Lo,x
        lda noteToWaveTable,y
        ora #$08
        sta musicStagingSq1Hi,x
; Complicated way to determine if we skipped setting lo/hi, maybe because of the needed pla. If we set lo/hi (by falling through from above), then we'll go to @loadVolume. If we jmp'ed here, then we'll end up muting the volume
@determineVolume:
        tay
        pla
        tax
        tya
        bne @loadVolume
        lda #$00
        sta AUDIOTMP1
        txa
        cmp #$02
        beq @checkChanControl
        lda #$10
        sta AUDIOTMP1
        bne @checkChanControl
;
@loadVolume:
        lda musicChanVolume,x
        sta AUDIOTMP1
; If any of 5 low bits of control is non-zero, then mute
@checkChanControl:
        txa
        dec musicChanInhibit,x
        cmp musicChanInhibit,x
        beq @channelInhibited
        inc musicChanInhibit,x
        ldy musicChannelOffset
        txa
        cmp #$02
        beq @useDirectVolume
        lda musicChanControl,x
        and #$1F
        beq @useDirectVolume
        lda AUDIOTMP1
        cmp #$10
        beq @setMmio
        and #$F0
        ora #$00
        bne @setMmio
@useDirectVolume:
        lda AUDIOTMP1
@setMmio:
.if SWAP_DUTY_CYCLES
        jsr swapDutyCycles
.endif
        sta SQ1_VOL,y
        lda musicStagingSq1Sweep,x
        sta SQ1_SWEEP,y
        lda musicStagingSq1Lo,y
        sta SQ1_LO,y
        lda musicStagingSq1Hi,y
        sta SQ1_HI,y
@copyDurationToRemaining:
        lda musicChanNoteDuration,x
        sta musicChanNoteDurationRemaining,x
        jmp updateMusicFrame_incSlot

; Never triggered
@channelInhibited:
        inc musicChanInhibit,x
        jmp @copyDurationToRemaining

; input y: duration of 60Hz frames. TRI has no volume control. The volume MMIO for TRI goes to a linear counter. While the length counter can be disabled, that doesn't appear possible for the linear counter.
@applyDurationForTri:
        lda musicChanControl+2
        and #$1F
        bne @setTriVolume
        lda musicChanControl+2
        and #$C0
        bne @highCtrlImpliesOn
@useDuration:
        tya
        bne @durationToLinearClock
@highCtrlImpliesOn:
        cmp #$C0
        beq @useDuration
        lda #$FF
        bne @setTriVolume
; Not quite clear what the -1 is for. Times 4 because the linear clock counts quarter frames
@durationToLinearClock:
        clc
        adc #$FF
        asl a
        asl a
        cmp #$3C
        bcc @setTriVolume
        lda #$3C
@setTriVolume:
        sta musicChanVolume+2
        jmp @loadNextAsNote

@playDmcAndNoise:
        tya
        pha
        jsr playDmc
        pla
        and #$3F
        tay
        jsr playNoise
        jmp @copyDurationToRemaining

; Weird that it references slot 0. Slot 3 would make most sense as NOISE channel and slot 1 would make sense if the point was to avoid noise during a sound effect. But slot 0 isn't used very often
playNoise:
        lda soundEffectSlot0Playing
        bne @ret
        lda noises_table,y
        sta NOISE_VOL
        lda noises_table+1,y
        sta NOISE_LO
        lda noises_table+2,y
        sta NOISE_HI
@ret:   rts

playDmc:tya
        and #$C0
        cmp #$40
        beq @loadDmc0
        cmp #$80
        beq @loadDmc1
        rts

; dmc0
@loadDmc0:
        lda #$0E
        sta AUDIOTMP2
        lda #$07
        ldy #$00
        beq @loadIntoDmc
; dmc1
@loadDmc1:
        lda #$0E
        sta AUDIOTMP2
        lda #$0F
        ldy #$02
; Note that bit 4 in SND_CHN is 0. That disables DMC. It enables all channels but DMC
@loadIntoDmc:
        sta DMC_LEN
        sty DMC_START
        lda $06F7
        bne @ret
        lda AUDIOTMP2
        sta DMC_FREQ
        lda #$0F
        sta SND_CHN
        lda #$00
        sta DMC_RAW
        lda #$1F
        sta SND_CHN
@ret:   rts

; input x: music channel. output a: next value
musicGetNextInstructionByte:
        ldy musicDataChanInstructionOffset,x
        inc musicDataChanInstructionOffset,x
        lda (musicChanTmpAddr),y
        rts

.if SWAP_DUTY_CYCLES
; input a: byte to be written to $4000 or $4004. output a: the same byte with the duty cycle index mapped from (0, 1, 2, 3) to (0, 2, 1, 3), counteracting the behavior of some clone consoles
swapDutyCycles:
        cmp #%01000000
        bmi @ret ; branch if upper bits are not %01 or %10
        eor #%11000000 ; swap between %01 and %10
@ret:   rts
.endif

musicChanVolControlTable:
noteToWaveTable:
noteDurationTable:
musicDataTableIndex:
musicDataTable:
