; TetrisGYM - A Tetris Practise ROM
;
; @author Kirjava
; @github kirjavascript/TetrisGYM
; @disassembly CelestialAmber/TetrisNESDisasm
; @information ejona86/taus

.include "charmap.asm"

PRACTISE_MODE := 1
DEBUG_MODE := 1
NO_MUSIC := 1
ALWAYS_NEXT_BOX := 1
AUTO_WIN := 0
NO_SCORING := 0

BUTTON_DOWN := $4
BUTTON_UP := $8
BUTTON_RIGHT := $1
BUTTON_LEFT := $2
BUTTON_B := $40
BUTTON_A := $80
BUTTON_SELECT := $20
BUTTON_START := $10

MODE_TETRIS := 0
MODE_TSPINS := 1
MODE_SEED := 2
MODE_PARITY := 3
MODE_PACE := 4
MODE_PRESETS := 5
MODE_TYPEB := 6
MODE_FLOOR := 7
MODE_TAP := 8
MODE_TRANSITION := 9
MODE_INVISIBLE := 10
MODE_HARDDROP := 11
MODE_GARBAGE := 12
MODE_DROUGHT := 13
MODE_SPEED_TEST := 14
MODE_HZ_DISPLAY := 15
MODE_INPUT_DISPLAY := 16
MODE_GOOFY := 17
MODE_DEBUG := 18
MODE_PAL := 19

MODE_QUANTITY := 20
MODE_GAME_QUANTITY := 14
MODE_CONFIG_SIZE := 13

MENU_SPRITE_Y_BASE := $47
MENU_MAX_Y_SCROLL := $20
MENU_TOP_MARGIN_SCROLL := 7 ; blocks
BLOCK_TILES := $7B
INVISIBLE_TILE := $43

; menuConfigSizeLookup
.define MENUSIZES $0, $0, $0, $0, $F, $7, $8, $C, $20, $10, $0, $0, $4, $12, $0, $1, $1, $1, $1, $1

.macro MODENAMES
    .byte   "TETRIS"
    .byte   "TSPINS"
    .byte   " SEED "
    .byte   "STACKN"
    .byte   " PACE "
    .byte   "SETUPS"
    .byte   "B-TYPE"
    .byte   "FLOOR "
    .byte   "QCKTAP"
    .byte   "TRNSTN"
    .byte   "INVZBL"
    .byte   "HRDDRP"
    .byte   "GARBGE"
    .byte   "LOBARS"
.endmacro

        .setcpu "6502"

SRAM        := $6000 ; 8 delicious kilobytes

tmp1        := $0000
tmp2        := $0001
tmp3        := $0002
tmpX        := $0003
tmpY        := $0004
tmpZ        := $0005
tmpBulkCopyToPpuReturnAddr:= $0006 ; 2 bytes
patchToPpuAddr  := $0014 ; unused
rng_seed    := $0017
spawnID     := $0019
spawnCount  := $001A
verticalBlankingInterval:= $0033
set_seed    := $0034 ; 3 bytes - rng_seed, rng_seed+1, spawnCount
set_seed_input := $0037 ; copied to set_seed during gameModeState_initGameState

; ... $003F
tetriminoX  := $0040                        ; Player data is $20 in size. It is copied here from $60 or $80, processed, then copied back
tetriminoY  := $0041
currentPiece    := $0042                    ; Current piece as an orientation ID
levelNumber := $0044
fallTimer   := $0045
autorepeatX := $0046
startLevel  := $0047
playState   := $0048
vramRow     := $0049                        ; Next playfield row to copy. Set to $20 when playfield copy is complete
completedRow    := $004A                    ; Row which has been cleared. 0 if none complete
autorepeatY := $004E
holdDownPoints  := $004F
lines       := $0050
rowY        := $0052
score       := $0053
completedLines  := $0056
lineIndex   := $0057                        ; Iteration count of playState_checkForCompletedRows
startHeight := $0058
garbageHole := $0059                        ; Position of hole in received garbage
garbageDelay  := $005A
pieceTileModifier := $005B ; above $80 - use a single one, below - use an offset

paceRAM := $60 ; $12 bytes
binary32 := paceRAM+$0
bcd32 := paceRAM+$4
exp := paceRAM+$8
product24 := paceRAM+$9
factorA24 := paceRAM+$C
factorB24 := paceRAM+$F
binaryTemp := paceRAM+$C
sign := paceRAM+$F
dividend := paceRAM+$4
divisor := paceRAM+$7
remainder := paceRAM+$A
pztemp := paceRAM+$D

byteSpriteRAM := $72
byteSpriteXOffset := byteSpriteRAM
byteSpriteYOffset := byteSpriteRAM+1
byteSpriteAddr := byteSpriteRAM+2
byteSpriteTile := byteSpriteRAM+4
byteSpriteLen := byteSpriteRAM+5
; ... $0078

; ... $009A
spriteXOffset   := $00A0
spriteYOffset   := $00A1
spriteIndexInOamContentLookup:= $00A2
outOfDateRenderFlags:= $00A3                ; Bit 0-lines 1-level 2-score 4-hz 6-stats 7-high score entry letter

; ... $00A6
gameModeState   := $00A7                    ; For values, see playState_checkForCompletedRows
generalCounter  := $00A8                    ; canon is legalScreenCounter2
generalCounter2 := $00A9
generalCounter3 := $00AA
generalCounter4 := $00AB
generalCounter5 := $00AC
positionValidTmp:= $00AD              ; 0-level, 1-height
originalY   := $00AE
dropSpeed   := $00AF
tmpCurrentPiece := $00B0                    ; Only used as a temporary
frameCounter    := $00B1
oamStagingLength:= $00B3
newlyPressedButtons:= $00B5                 ; Active player's buttons
heldButtons := $00B6                        ; Active player's buttons
; activePlayer    := $00B7                    ; Which player is being processed (data in $40)
playfieldAddr   := $00B8                    ; HI byte is leftPlayfield in canon. Current playfield being processed: $0400 (left; 1st player) or $0500 (right; 2nd player)
allegro     := $00BA
pendingGarbage  := $00BB                    ; Garbage waiting to be delivered to the current player. This is exchanged with pendingGarbageInactivePlayer when swapping players.
pendingGarbageInactivePlayer := $00BC       ; canon is totalGarbage
renderMode  := $00BD
; numberOfPlayers := $00BE
nextPiece   := $00BF                        ; Stored by its orientation ID
gameMode    := $00C0                        ; 0=legal, 1=title, 2=type menu, 3=level menu, 4=play and ending and high score, 5=demo, 6=start demo
; gameType    := $00C1                        ; A=0, B=1
musicType   := $00C2                        ; 0-3; 3 is off
sleepCounter    := $00C3                    ; canon is legalScreenCounter1

; ... $00CD
demo_heldButtons:= $00CE
demo_repeats    := $00CF
demoButtonsAddr := $00D1                    ; Current address within demoButtonsTable
demoIndex   := $00D3
highScoreEntryNameOffsetForLetter:= $00D4   ; Relative to current row
highScoreEntryRawPos:= $00D5                ; High score position 0=1st type A, 1=2nd... 4=1st type B... 7=4th/extra type B
highScoreEntryNameOffsetForRow:= $00D6      ; Relative to start of table
highScoreEntryCurrentLetter:= $00D7
lineClearStatsByType:= $00D8                ; bcd. one entry for each of single, double, triple, tetris
displayNextPiece:= $00DF
AUDIOTMP1   := $00E0
AUDIOTMP2   := $00E1
AUDIOTMP3   := $00E2
AUDIOTMP4   := $00E3
AUDIOTMP5   := $00E4
musicChanTmpAddr:= $00E6
music_unused2   := $00EA                    ; Always 0
soundRngSeed    := $00EB                    ; Set, but not read
currentSoundEffectSlot:= $00ED              ; Temporary
musicChannelOffset:= $00EE                  ; Temporary. Added to $4000-3 for MMIO
currentAudioSlot:= $00EF                    ; Temporary
unreferenced_buttonMirror := $00F1          ; Mirror of $F5-F8
newlyPressedButtons_player1:= $00F5         ; $80-a $40-b $20-select $10-start $08-up $04-down $02-left $01-right
newlyPressedButtons_player2:= $00F6
heldButtons_player1:= $00F7
heldButtons_player2:= $00F8
joy1Location    := $00FB                    ; normal=0; 1 or 3 for expansion

; $FC, $FD free

currentPpuMask  := $00FE
currentPpuCtrl  := $00FF
stack       := $0100
oamStaging  := $0200                        ; format: https://wiki.nesdev.com/w/index.php/PPU_programmer_reference#OAM
statsByType := $03F0
playfield   := $0400
; $500 ...

practiseType := $600
spawnDelay := $601
dasValueHigh := $602
dasValueLow := $603
tspinX := $604
tspinY := $605
tspinType := $606
tspinQuantity := $60E ; reusing presetIndex
parityIndex := $607
parityCount := $608
parityColor := $609
saveStateDirty := $60A
saveStateSlot := $60B
saveStateSpriteType := $60C
saveStateSpriteDelay := $60D
presetIndex := $60E ; can be mangled in other modes
pausedOutOfDateRenderFlags := $60F ; 0 - statistics 1 - saveslot
debugLevelEdit := $610
debugNextCounter := $611
paceResult := $612 ; 3 bytes
paceSign := $615
hzRAM := $616
hzTapCounter := hzRAM+0
hzFrameCounter := hzRAM+1 ; 2 byte
hzDebounceCounter := hzRAM+3 ; 1 byte
hzTapDirection := hzRAM+4 ; 1 byte
hzResult := hzRAM+5 ; 2 byte

; ... $67F
musicStagingSq1Lo:= $0680
musicStagingSq1Hi:= $0681
audioInitialized:= $0682
musicStagingSq2Lo:= $0684
musicStagingSq2Hi:= $0685
musicStagingTriLo:= $0688
musicStagingTriHi:= $0689
resetSq12ForMusic:= $068A                   ; 0-off. 1-sq1. 2-sq1 and sq2
musicStagingNoiseLo:= $068C
musicStagingNoiseHi:= $068D
musicDataNoteTableOffset:= $0690            ; AKA start of musicData, of size $0A
musicDataDurationTableOffset:= $0691
musicDataChanPtr:= $0692
musicChanControl:= $069A                    ; high 3 bits are for LO offset behavior. Low 5 bits index into musicChanVolControlTable, minus 1. Technically size 4, but usages of the next variable 'cheat' since that variable's first index is unused
musicChanVolume := $069D                    ; Must not use first index. First and second index are unused. High nibble always used; low nibble may be used depending on control and frame
musicDataChanPtrDeref:= $06A0               ; deref'd musicDataChanPtr+musicDataChanPtrOff
musicDataChanPtrOff:= $06A8
musicDataChanInstructionOffset:= $06AC
musicDataChanInstructionOffsetBackup:= $06B0
musicChanNoteDurationRemaining:= $06B4
musicChanNoteDuration:= $06B8
musicChanProgLoopCounter:= $06BC            ; As driven by bytecode instructions
musicStagingSq1Sweep:= $06C0                ; Used as if size 4, but since Tri/Noise does nothing when written for sweep, the other two entries can have any value without changing behavior
musicChanNote:= $06C3
musicChanInhibit:= $06C8                    ; Always zero
musicTrack_dec  := $06CC                    ; $00-$09
musicChanVolFrameCounter:= $06CD            ; Pos 0/1 are unused
musicChanLoFrameCounter:= $06D1             ; Pos 3 unused
soundEffectSlot0FrameCount:= $06D5          ; Number of frames
soundEffectSlot0FrameCounter:= $06DA        ; Current frame
soundEffectSlot0SecondaryCounter:= $06DF    ; nibble index into noiselo_/noisevol_table
soundEffectSlot1SecondaryCounter:= $06E0
soundEffectSlot2SecondaryCounter:= $06E1
soundEffectSlot3SecondaryCounter:= $06E2
soundEffectSlot0TertiaryCounter:= $06E3
soundEffectSlot1TertiaryCounter:= $06E4
soundEffectSlot2TertiaryCounter:= $06E5
soundEffectSlot3TertiaryCounter:= $06E6
soundEffectSlot0Tmp:= $06E7
soundEffectSlot1Tmp:= $06E8
soundEffectSlot2Tmp:= $06E9
soundEffectSlot3Tmp:= $06EA
soundEffectSlot0Init:= $06F0                ; NOISE sound effect. 2-game over curtain. 3-ending rocket. For mapping, see soundEffectSlot0Init_table
soundEffectSlot1Init:= $06F1                ; SQ1 sound effect. Menu, move, rotate, clear sound effects. For mapping, see soundEffectSlot1Init_table
soundEffectSlot2Init:= $06F2                ; SQ2 sound effect. For mapping, see soundEffectSlot2Init_table
soundEffectSlot3Init:= $06F3                ; TRI sound effect. For mapping, see soundEffectSlot3Init_table
soundEffectSlot4Init:= $06F4                ; Unused. Assume meant for DMC sound effect. Uses some data from slot 2
musicTrack  := $06F5                        ; $FF turns off music. $00 continues selection. $01-$0A for new selection
soundEffectSlot0Playing:= $06F8             ; Used if init is zero
soundEffectSlot1Playing:= $06F9
soundEffectSlot2Playing:= $06FA
soundEffectSlot3Playing:= $06FB
soundEffectSlot4Playing:= $06FC
currentlyPlayingMusicTrack:= $06FD          ; Copied from musicTrack
unreferenced_soundRngTmp:= $06FF
highScoreNames  := $0700
highScoreScoresA:= $0730
; highScoreScoresB:= $073C
highScoreLevels := $0748
; .. bunch of unused stuff: highScoreNames sized
initMagic   := $0750                        ; Initialized to a hard-coded number. When resetting, if not correct number then it knows this is a cold boot

menuRAM := $760
menuSeedCursorIndex := menuRAM+0
menuScrollY := menuRAM+1
menuMoveThrottle := menuRAM+2
menuThrottleTmp := menuRAM+3
menuPaletteDelay := menuRAM+4
menuVars := $765
paceModifier := menuVars+0
presetModifier := menuVars+1
typeBModifier := menuVars+2
floorModifier := menuVars+3
tapModifier := menuVars+4
transitionModifier := menuVars+5
garbageModifier := menuVars+6
droughtModifier := menuVars+7
hzFlag := menuVars+8
inputDisplayFlag := menuVars+9
goofyFlag := menuVars+10
debugFlag := menuVars+11
palFlag := menuVars+12

; ... $7FF
PPUCTRL     := $2000
PPUMASK     := $2001
PPUSTATUS   := $2002
OAMADDR     := $2003
OAMDATA     := $2004
PPUSCROLL   := $2005
PPUADDR     := $2006
PPUDATA     := $2007
SQ1_VOL     := $4000
SQ1_SWEEP   := $4001
SQ1_LO      := $4002
SQ1_HI      := $4003
SQ2_VOL     := $4004
SQ2_SWEEP   := $4005
SQ2_LO      := $4006
SQ2_HI      := $4007
TRI_LINEAR  := $4008
TRI_LO      := $400A
TRI_HI      := $400B
NOISE_VOL   := $400C
NOISE_LO    := $400E
NOISE_HI    := $400F
DMC_FREQ    := $4010
DMC_RAW     := $4011
DMC_START   := $4012                        ; start << 6 + $C000
DMC_LEN     := $4013                        ; len << 4 + 1
OAMDMA      := $4014
SND_CHN     := $4015
JOY1        := $4016
JOY2_APUFC  := $4017                        ; read: bits 0-4 joy data lines (bit 0 being normal controller), bits 6-7 are FC inhibit and mode

MMC1_CHR0   := $BFFF
MMC1_CHR1   := $DFFF

.segment    "PRG_chunk1": absolute

; incremented to reset MMC1 reg
initRam:
        ldx #$00
        jmp initRamContinued
nmi:    pha
        txa
        pha
        tya
        pha
        lda #$00
        sta oamStagingLength
        jsr render
        dec sleepCounter
        lda sleepCounter
        cmp #$FF
        bne @jumpOverIncrement
        inc sleepCounter
@jumpOverIncrement:
        jsr copyOamStagingToOam
        lda frameCounter
        clc
        adc #$01
        sta frameCounter
        lda #$00
        adc frameCounter+1
        sta frameCounter+1
        ldx #rng_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        ; PPUSCROLL used to be reset here
        lda #$01
        sta verticalBlankingInterval
        jsr pollControllerButtons
        pla
        tay
        pla
        tax
        pla
irq:    rti

render: lda renderMode
        jsr switch_s_plus_2a
        .addr   render_mode_static
        .addr   render_mode_scroll
        .addr   render_mode_congratulations_screen
        .addr   render_mode_play_and_demo
        .addr   render_mode_pause
initRamContinued:
        ldy #$06
        sty tmp2
        ldy #$00
        sty tmp1
        lda #$00
@zeroOutPages:
        sta (tmp1),y
        dey
        bne @zeroOutPages
        dec tmp2
        bpl @zeroOutPages
        lda initMagic
        cmp #$54
        bne @initHighScoreTable
        lda initMagic+1
        cmp #$2D
        bne @initHighScoreTable
        lda initMagic+2
        cmp #$47
        bne @initHighScoreTable
        lda initMagic+3
        cmp #$59
        bne @initHighScoreTable
        lda initMagic+4
        cmp #$4D
        bne @initHighScoreTable
        jmp @continueWarmBootInit

        ldx #$00
; Only run on cold boot
@initHighScoreTable:
        lda defaultHighScoresTable,x
        cmp #$FF
        beq @continueColdBootInit
        sta highScoreNames,x
        inx
        jmp @initHighScoreTable

@continueColdBootInit:
        lda #$54
        sta initMagic
        lda #$2D
        sta initMagic+1
        lda #$47
        sta initMagic+2
        lda #$59
        sta initMagic+3
        lda #$4D
        sta initMagic+4
@continueWarmBootInit:
        ldx #$89
        stx rng_seed
        dex
        stx rng_seed+1
        ldy #$00
        sty PPUSCROLL
        ldy #$00
        sty PPUSCROLL
        lda #$90
        sta currentPpuCtrl
        sta PPUCTRL
        lda #$06
        sta PPUMASK
        jsr LE006
        jsr updateAudio2
        lda #$C0
        sta stack
        lda #$80
        sta stack+1
        lda #$35
        sta stack+3
        lda #$AC
        sta stack+4
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
        lda #$20
        jsr LAA82
        lda #$24
        jsr LAA82
        lda #$28
        jsr LAA82
        lda #$2C
        jsr LAA82
        lda #$EF
        ldx #$04
        ldy #$04 ; used to be 5, but we dont need to clear 2p playfield
        jsr memset_page
        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda #$00
        sta gameModeState
        sta gameMode
        lda #$00
        sta frameCounter+1
@mainLoop:
        jsr branchOnGameMode
        cmp gameModeState
        bne @checkForDemoDataExhaustion
        jsr updateAudioWaitForNmiAndResetOamStaging
@checkForDemoDataExhaustion:
        lda gameMode
        cmp #$05
        bne @continue
        lda demoButtonsAddr+1
        cmp #$DF
        bne @continue
        lda #$DD
        sta demoButtonsAddr+1
        lda #$00
        sta frameCounter+1
        lda #$01
        sta gameMode
@continue:
        jmp @mainLoop

checkRegion:
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

gameMode_playAndEndingHighScore_jmp:
        jsr gameMode_playAndEndingHighScore
        rts

branchOnGameMode:
        lda gameMode
        jsr switch_s_plus_2a
        .addr   gameMode_legalScreen
        .addr   gameMode_titleScreen_unused
        .addr   gameMode_gameTypeMenu
        .addr   gameMode_levelMenu
        .addr   gameMode_playAndEndingHighScore_jmp
        .addr   gameMode_playAndEndingHighScore_jmp
        .addr   gameMode_startDemo
gameModeState_updatePlayer1:
        lda #$04
        sta playfieldAddr+1
        ; copy controller from mirror
        lda newlyPressedButtons_player1
        sta newlyPressedButtons
        lda heldButtons_player1
        sta heldButtons

        jsr checkDebugGameplay
        jsr practiseAdvanceGame
        jsr practiseGameHUD
        jsr branchOnPlayStatePlayer1

        jsr stageSpriteForCurrentPiece
        jsr stageSpriteForNextPiece
        inc gameModeState
        rts

gameModeState_next:
        inc gameModeState
        rts

gameMode_playAndEndingHighScore:
        lda gameModeState
        jsr switch_s_plus_2a
        .addr   gameModeState_initGameBackground
        .addr   gameModeState_initGameState
        .addr   gameModeState_updateCountersAndNonPlayerState
        .addr   gameModeState_handleGameOver
        .addr   gameModeState_updatePlayer1
        .addr   gameModeState_next
        .addr   gameModeState_checkForResetKeyCombo
        .addr   gameModeState_startButtonHandling
        .addr   gameModeState_vblankThenRunState2
branchOnPlayStatePlayer1:
        lda playState
        jsr switch_s_plus_2a
        .addr   playState_unassignOrientationId
        .addr   playState_playerControlsActiveTetrimino
        .addr   playState_lockTetrimino
        .addr   playState_checkForCompletedRows
        .addr   playState_noop
        .addr   playState_updateLinesAndStatistics
        .addr   playState_prepareNext ; used to be bTypeGoalCheck
        .addr   playState_receiveGarbage
        .addr   playState_spawnNextTetrimino
        .addr   playState_noop
        .addr   playState_checkStartGameOver
        .addr   playState_incrementPlayState

playState_playerControlsActiveTetrimino:
        jsr shift_tetrimino
        jsr rotate_tetrimino
        jsr drop_tetrimino
        lda hzFlag
        beq @noHz
        jsr hzControl
@noHz:
        lda practiseType
        cmp #MODE_HARDDROP
        bne @soft
        jsr harddrop_tetrimino
@soft:
        rts

harddrop_tetrimino:
        lda newlyPressedButtons
        and #BUTTON_UP
        beq @noHard
        lda tetriminoY
@loop:
        inc tetriminoY
        jsr isPositionValid
        beq @loop
        dec tetriminoY
        lda #0
        sta autorepeatY
        lda dropSpeed
        sta fallTimer
@noHard:
        rts

gameMode_legalScreen: ; boot
        ; ABSS goes to gameTypeMenu instead of here

        ; reset cursors (seems to cause problems on misterFPGA)
        lda #$0
        sta practiseType
        sta menuSeedCursorIndex

        ; set start level to 8/18
        lda #$8
        sta startLevel

        ; zero out config memory
        lda #0
        ldx #$9F
@loop:
        sta menuRAM, x
        dex
        bpl @loop

        ; default pace to A
        lda #$A
        sta paceModifier

        ; detect region
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr checkRegion

        lda #2
        sta gameMode
        rts

blank_palette:
        lda #$3F
        sta PPUADDR
        lda #$0
        sta PPUADDR
        ldx #$10
@loadPaletteLoop:
        lda #$F
        sta PPUDATA
        dex
        bne @loadPaletteLoop
        rts

gameMode_titleScreen_unused:
gameMode_gameTypeMenu:
        jsr hzStart
        jsr calc_menuScrollY
        sta menuScrollY

        inc initRam
        ; switch to blank charmap
        ; (stops glitching when resetting
        lda #$02
        jsr changeCHRBank1
        lda #%10011 ; used to be $10 (enable horizontal mirroring)
        jsr setMMC1Control
        lda #$1
        sta renderMode
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
        jsr blank_palette
        lda #$3
        sta menuPaletteDelay ; title_palette loaded in render_mode_scroll
        jsr copyRleNametableToPpu
        .addr   game_type_menu_nametable
        lda #$28
        sta tmp3
        jsr copyRleNametableToPpuOffset
        .addr   game_type_menu_nametable_extra
        lda #$00
        jsr changeCHRBank0
        lda #$00
        jsr changeCHRBank1
        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        jsr updateAudioWaitForNmiAndResetOamStaging

gameTypeLoop:
        ; memset FF-02 used to happen every loop
        ; but it's done in ResetOamStaging anyway?
        jsr renderMenuHz
        jmp seedControls

gameTypeLoopContinue:
        lda practiseType
        cmp #MODE_SPEED_TEST
        bne @noHz
        jsr hzControl
@noHz:
        jsr menuConfigControls
        jsr practiseTypeMenuControls

gameTypeLoopCheckStart:
        lda newlyPressedButtons_player1
        cmp #BUTTON_START
        bne gameTypeLoopNext
        ; check it's a selectable option
        lda practiseType
        cmp #MODE_GAME_QUANTITY
        bpl gameTypeLoopNext

        lda #$02
        sta soundEffectSlot1Init
        inc gameMode
        rts

gameTypeLoopNext:
        jsr renderMenuVars
        jsr updateAudioWaitForNmiAndResetOamStaging
        jmp gameTypeLoop

seedControls:
        lda practiseType
        cmp #MODE_SEED
        bne gameTypeLoopContinue

        lda newlyPressedButtons_player1
        cmp #BUTTON_SELECT
        bne @skipSeedSelect
        lda rng_seed
        sta set_seed_input
        lda rng_seed+1
        sta set_seed_input+1
        lda rng_seed+1
        eor #$77
        ror
        sta set_seed_input+2
@skipSeedSelect:

        lda #BUTTON_LEFT
        jsr menuThrottle
        beq @skipSeedLeft
        lda #$01
        sta soundEffectSlot1Init
        lda menuSeedCursorIndex
        bne @noSeedLeftWrap
        lda #7
        sta menuSeedCursorIndex
@noSeedLeftWrap:
        dec menuSeedCursorIndex
@skipSeedLeft:

        lda #BUTTON_RIGHT
        jsr menuThrottle
        beq @skipSeedRight
        lda #$01
        sta soundEffectSlot1Init
        inc menuSeedCursorIndex
        lda menuSeedCursorIndex
        cmp #7
        bne @skipSeedRight
        lda #0
        sta menuSeedCursorIndex
@skipSeedRight:

        lda menuSeedCursorIndex
        beq @skipSeedControl

        lda menuSeedCursorIndex
        sbc #1
        lsr
        tax ; save seed offset

        ; handle changing seed vals

        ; lda newlyPressedButtons_player1
        ; cmp #BUTTON_UP
        ; bne @skipSeedUp
        lda #BUTTON_UP
        jsr menuThrottle
        beq @skipSeedUp
        lda #$01
        sta soundEffectSlot1Init
        lda menuSeedCursorIndex
        and #1
        beq @lowNybbleUp

        lda set_seed_input, x
        clc
        adc #$10
        sta set_seed_input, x

        jmp @skipSeedUp
@lowNybbleUp:
        lda set_seed_input, x
        clc
        tay
        and #$F
        cmp #$F
        bne @noWrapUp
        tya
        and #$F0
        sta set_seed_input, x
        jmp @skipSeedUp
@noWrapUp:
        tya
        adc #1
        sta set_seed_input, x
@skipSeedUp:

        lda #BUTTON_DOWN
        jsr menuThrottle
        beq @skipSeedDown
        lda #$01
        sta soundEffectSlot1Init
        lda menuSeedCursorIndex
        and #1
        beq @lowNybbleDown

        lda set_seed_input, x
        sbc #$10
        clc
        sta set_seed_input, x

        jmp @skipSeedDown
@lowNybbleDown:
        lda set_seed_input, x
        clc
        tay
        and #$F
        cmp #$0
        bne @noWrapDown
        tya
        and #$F0
        clc
        adc #$F
        sta set_seed_input, x
        jmp @skipSeedDown
@noWrapDown:
        tya
        sbc #1
        sta set_seed_input, x
@skipSeedDown:

        jmp gameTypeLoopCheckStart
@skipSeedControl:
        jmp gameTypeLoopContinue

menuConfigControls:
        ; account for 'gaps' in config items of size zero
        ; previously the offset was just set on X directly

        ldx #0 ; memory offset we want
        ldy #0 ; cursor
@searchByte:
        cpy practiseType
        bne @notYet
        lda menuConfigSizeLookup, y
        beq @configEnd
        ; if zero, caller will beq to skip the config
        jmp @searchEnd
@notYet:
        lda menuConfigSizeLookup, y
        beq @noMem
        inx
@noMem:
        iny
        jmp @searchByte
@searchEnd:

        ; actual offset now in Y
        ; RAM offset now in X

        ; check if pressing left
        lda #BUTTON_LEFT
        jsr menuThrottle
        beq @skipLeftConfig
        ; check if zero
        lda menuVars, x
        cmp #0
        beq @skipLeftConfig
        ; dec value
        dec menuVars, x
        lda #$01
        sta soundEffectSlot1Init
        jsr checkGoofy
@skipLeftConfig:

        ; check if pressing right
        lda #BUTTON_RIGHT
        jsr menuThrottle
        beq @skipRightConfig
        ; check if within the offset
        lda menuVars, x
        cmp menuConfigSizeLookup, y
        bpl @skipRightConfig
        inc menuVars, x
        lda #$01
        sta soundEffectSlot1Init
        jsr checkGoofy
@skipRightConfig:
@configEnd:
        rts

menuConfigSizeLookup:
        .byte   MENUSIZES

checkGoofy:
        lda practiseType
        cmp #MODE_GOOFY
        bne @noFlip
        lda heldButtons_player1
        asl
        and #$AA
        sta tmp3
        lda heldButtons_player1
        and #$AA
        lsr
        ora tmp3
        sta heldButtons_player1
@noFlip:
        rts

practiseTypeMenuControls:
        ; down
        lda #BUTTON_DOWN
        jsr menuThrottle
        beq @downEnd
        lda #$01
        sta soundEffectSlot1Init

        inc practiseType
        lda practiseType
        cmp #MODE_QUANTITY
        bne @downEnd
        lda #0
        sta practiseType
@downEnd:

        ; up
        lda #BUTTON_UP
        jsr menuThrottle
        beq @upEnd
        lda #$01
        sta soundEffectSlot1Init
        lda practiseType
        bne @noWrap
        lda #MODE_QUANTITY
        sta practiseType
@noWrap:
        dec practiseType
@upEnd:
        rts

menuThrottle: ; add DAS-like movement to the menu
        sta menuThrottleTmp
        lda newlyPressedButtons_player1
        cmp menuThrottleTmp
        beq menuThrottleNew
        lda heldButtons_player1
        cmp menuThrottleTmp
        bne @endThrottle
        dec menuMoveThrottle
        beq menuThrottleContinue
@endThrottle:
        lda #0
        rts
menuThrottleNew:
        lda #$10
        sta menuMoveThrottle
        rts
menuThrottleContinue:
        lda #$4
        sta menuMoveThrottle
        rts

renderMenuHz:
MENU_HZ_Y_BASE := MENU_SPRITE_Y_BASE + (MODE_SPEED_TEST * 8) + 1
        ; taps
        lda #MENU_HZ_Y_BASE
        sta byteSpriteYOffset
        lda #$E0
        sta byteSpriteXOffset
        lda hzTapCounter
        and #$F
        jsr menuSprite
        ; hz
        lda #MENU_HZ_Y_BASE
        sta byteSpriteYOffset
        lda #$D0
        sta byteSpriteXOffset
        lda #$55
        jsr menuSprite
        ; hz 10s unit
        ldx oamStagingLength
        lda #MENU_HZ_Y_BASE
        sbc menuScrollY
        sta byteSpriteYOffset
        lda #$C0
        sta byteSpriteXOffset
        lda #1
        sta byteSpriteLen
        lda #0
        sta byteSpriteTile
        lda #<hzResult
        sta byteSpriteAddr
        lda #>hzResult
        sta byteSpriteAddr+1
        jsr byteSprite
        rts

renderMenuVars:

        ; playType / seed cursors

        lda menuSeedCursorIndex
        bne @seedCursor

        lda practiseType
        asl a
        asl a
        asl a
        clc
        adc #MENU_SPRITE_Y_BASE + 1
        sbc menuScrollY
        sta spriteYOffset
        lda #$17
        sta spriteXOffset
        lda #$53
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging
        jmp @cursorFinished

@seedCursor:
        lda #MENU_SPRITE_Y_BASE + 7
        sbc menuScrollY
        sta spriteYOffset
        lda menuSeedCursorIndex
        asl a
        asl a
        asl a
        adc #$B1
        sta spriteXOffset
        lda #$1B
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging

@cursorFinished:

menuCounter := tmp1
menuRAMCounter := tmp3
menuYTmp := tmp2

        ; render seed

        lda #$b8
        sta byteSpriteXOffset
        lda #MENU_SPRITE_Y_BASE + $10
        sbc menuScrollY
        sta byteSpriteYOffset
        lda #set_seed_input
        sta byteSpriteAddr
        lda #0
        sta byteSpriteAddr+1
        lda #0
        sta byteSpriteTile
        lda #3
        sta byteSpriteLen
        jsr byteSprite

        ; render config vars


        ; YTAX
        lda #0
        sta menuCounter
        sta menuRAMCounter
@loop:
        lda menuCounter
        asl
        asl
        asl
        adc #MENU_SPRITE_Y_BASE + 1
        sbc menuScrollY
        sta menuYTmp

        ldy menuRAMCounter ; gap support

        ; handle boolean
        lda menuCounter
        tax ; used to get loaded into Y
        lda menuConfigSizeLookup, x

        beq @loopNext ; gap support
        inc menuRAMCounter ; only increment RAM when config size isnt zero

        cmp #1
        bne @notBool
        jsr @renderBool
        jmp @loopNext
@notBool:

        ldx oamStagingLength
        lda menuYTmp


        sta oamStaging, x
        inx
        lda menuVars, y
        sta oamStaging, x
        inx
        lda #$00
        sta oamStaging, x
        inx
        lda #$E0
        sta oamStaging, x
        inx
        ; increase OAM index
        lda #$04
        clc
        adc oamStagingLength
        sta oamStagingLength

@loopNext:
        inc menuCounter
        lda menuCounter
        cmp #MODE_QUANTITY
        bne @loop
        rts

@renderBool:

        lda menuYTmp
        sta spriteYOffset
        lda #$D0
        sta spriteXOffset
        lda menuVars, y
        adc #$18
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging
        rts


byteSprite:
menuXTmp := tmp2
        ldy #0
@loop:
        tya
        asl
        asl
        asl
        asl
        adc byteSpriteXOffset
        sta menuXTmp

        ldx oamStagingLength
        lda byteSpriteYOffset
        sta oamStaging, x
        inx
        lda (byteSpriteAddr), y
        and #$F0
        lsr a
        lsr a
        lsr a
        lsr a
        adc byteSpriteTile
        sta oamStaging, x
        inx
        lda #$00
        sta oamStaging, x
        inx
        lda menuXTmp
        sta oamStaging, x
        inx

        lda byteSpriteYOffset
        sta oamStaging, x
        inx
        lda (byteSpriteAddr), y
        and #$F
        adc byteSpriteTile
        sta oamStaging, x
        inx
        lda #$00
        sta oamStaging, x
        inx
        lda menuXTmp
        adc #$8
        sta oamStaging, x
        inx

        ; increase OAM index
        lda #$08
        clc
        adc oamStagingLength
        sta oamStagingLength

        iny
        cpy byteSpriteLen
        bne @loop

        rts

menuSprite: ; a - value, xoff/yoff
        tay
        lda byteSpriteYOffset
        sbc menuScrollY
        sta oamStaging, x
        inx
        tya
        sta oamStaging, x
        inx
        lda #$00
        sta oamStaging, x
        inx
        lda byteSpriteXOffset
        sta oamStaging, x
        inx
        ; increase OAM index
        lda #$04
        clc
        adc oamStagingLength
        sta oamStagingLength
        rts

gameMode_levelMenu:
        inc initRam
        lda #$10
        jsr setMMC1Control
        jsr updateAudio2
        lda #$0
        sta renderMode
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
        lda #$00
        jsr changeCHRBank0
        lda #$00
        jsr changeCHRBank1
        jsr bulkCopyToPpu
        .addr   menu_palette
        jsr copyRleNametableToPpu
        .addr   level_menu_nametable
        lda #$20
        sta tmp1
        lda #$B4 ; $6D is OEM position
        sta tmp2
        jsr displayModeText
        jsr showHighScores
        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda #$00
        sta PPUSCROLL
        lda #$00
        sta PPUSCROLL
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda #$00
        sta originalY
        sta dropSpeed
@forceStartLevelToRange:
        ; account for level 29 when loading
        lda startLevel
        cmp #29
        bne @not29
        lda #$0A
        sta startLevel
        jmp gameMode_levelMenu_processPlayer1Navigation
@not29:
        cmp #$0A
        bcc gameMode_levelMenu_processPlayer1Navigation
        sec
        sbc #$0A
        sta startLevel
        jmp @forceStartLevelToRange

gameMode_levelMenu_processPlayer1Navigation:
        lda newlyPressedButtons_player1
        sta newlyPressedButtons
        jsr gameMode_levelMenu_handleLevelNavigation
        lda newlyPressedButtons_player1
        cmp #BUTTON_START
        bne @checkBPressed

        ; checks for level29
        lda startLevel
        cmp #$A
        bne @skip29
        lda #29
        sta startLevel
        jmp @startAndANotPressed
@skip29:

        lda heldButtons_player1
        cmp #BUTTON_START+BUTTON_A
        bne @startAndANotPressed
        lda startLevel
        clc
        adc #$0A
        sta startLevel
@startAndANotPressed:
        lda #$00
        sta gameModeState
        lda #$02
        sta soundEffectSlot1Init
        inc gameMode
        rts

@checkBPressed:
        lda newlyPressedButtons_player1
        cmp #BUTTON_B
        bne @continue
        lda #$02
        sta soundEffectSlot1Init
        dec gameMode
        rts

@continue:
        jsr updateAudioWaitForNmiAndResetOamStaging
        jmp gameMode_levelMenu_processPlayer1Navigation

; Starts by checking if right pressed
gameMode_levelMenu_handleLevelNavigation:
        lda newlyPressedButtons
        cmp #BUTTON_RIGHT
        bne @checkLeftPressed
        lda #$01
        sta soundEffectSlot1Init
        lda startLevel
        cmp #$A ; used to be 9
        beq @checkLeftPressed
        inc startLevel
@checkLeftPressed:
        lda newlyPressedButtons
        cmp #BUTTON_LEFT
        bne @checkDownPressed
        lda #$01
        sta soundEffectSlot1Init
        lda startLevel
        beq @checkDownPressed
        dec startLevel
@checkDownPressed:
        lda newlyPressedButtons
        cmp #BUTTON_DOWN
        bne @checkUpPressed
        lda #$01
        sta soundEffectSlot1Init
        lda startLevel
        cmp #$05
        bpl @checkUpPressed
        clc
        adc #$05
        sta startLevel
        jmp @checkUpPressed

@checkUpPressed:
        lda newlyPressedButtons
        cmp #BUTTON_UP
        bne @checkAPressed
        lda #$01
        sta soundEffectSlot1Init
        lda startLevel
        cmp #$0A
        beq @checkAPressed ; dont do anything on 29
        cmp #$05
        bmi @checkAPressed
        sec
        sbc #$05
        sta startLevel
        jmp @checkAPressed

@checkAPressed:
        lda frameCounter
        and #$03
        beq @ret
@showSelectionLevel:
        ldx startLevel
        lda levelToSpriteYOffset,x
        sta spriteYOffset
        lda #$00
        sta spriteIndexInOamContentLookup
        ldx startLevel
        lda levelToSpriteXOffset,x
        sta spriteXOffset
        jsr loadSpriteIntoOamStaging
@ret:   rts

levelToSpriteYOffset:
        .byte   $53,$53,$53,$53,$53,$63,$63,$63
        .byte   $63,$63,$63
levelToSpriteXOffset:
        .byte   $34,$44,$54,$64,$74,$34,$44,$54
        .byte   $64,$74,$84
heightToPpuHighAddr:
        .byte   $53,$53,$53,$63,$63,$63
heightToPpuLowAddr:
        .byte   $9C,$AC,$BC,$9C,$AC,$BC
musicSelectionTable:
        .byte   $03,$04,$05,$FF,$06,$07,$08,$FF

gameModeState_initGameBackground:
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
        lda #$01
        jsr changeCHRBank0
        lda #$01
        jsr changeCHRBank1
        jsr bulkCopyToPpu
        .addr   game_palette
        jsr copyRleNametableToPpu
        .addr   game_nametable

        jsr showPaceDiffText
        beq @skipTop
        lda #$20
        sta PPUADDR
        lda #$B8
        sta PPUADDR
        lda highScoreScoresA
        jsr twoDigsToPPU
        lda highScoreScoresA+1
        jsr twoDigsToPPU
        lda highScoreScoresA+2
        jsr twoDigsToPPU
@skipTop:

        lda hzFlag
        beq @noHz
        jsr clearStatisticsBox
@noHz:

        lda #$20
        sta tmp1
        lda #$83
        sta tmp2
        jsr displayModeText
        jsr statisticsNametablePatch ; for input display
        jsr debugNametableUI
        jmp gameModeState_initGameBackground_finish

displayModeText:
        ldx practiseType
        cpx #MODE_SEED
        bne @drawModeName
        ; draw seed instead
        lda tmp1
        sta PPUADDR
        lda tmp2
        sta PPUADDR
        lda set_seed_input
        jsr twoDigsToPPU
        lda set_seed_input+1
        jsr twoDigsToPPU
        lda set_seed_input+2
        jsr twoDigsToPPU
        rts

@drawModeName:
        ; ldx practiseType
        lda #0
@loopAddr:
        cpx #0
        beq @addr
        clc
        adc #6
        dex
        jmp @loopAddr
@addr:
        ; offset in X
        tax

        lda tmp1
        sta PPUADDR
        lda tmp2
        sta PPUADDR

        ldy #6
@writeChar:
        lda modeText, x
        sta PPUDATA
        inx
        dey
        bne @writeChar
        rts

modeText:
MODENAMES

debugNametableUI:
        lda debugFlag
        beq @notDebug
        jsr saveStateNametableUI
        jsr saveSlotNametablePatch
@notDebug:
        rts

saveSlotNametablePatch:
        lda #$23
        sta PPUADDR
        lda #$1D
        sta PPUADDR
        lda saveStateSlot
        sta PPUDATA
        rts

saveStateNametableUI:
        ldx #$00
@nextPpuAddress:
        lda savestate_nametable_patch,x
        inx
        sta PPUADDR
        lda savestate_nametable_patch,x
        inx
        sta PPUADDR
@nextPpuData:
        lda savestate_nametable_patch,x
        inx
        cmp #$FE
        beq @nextPpuAddress
        cmp #$FD
        beq @endOfPpuPatching
        sta PPUDATA
        jmp @nextPpuData
@endOfPpuPatching:
        rts

statisticsNametablePatch:
        lda #$21
        sta PPUADDR
        lda #$22
        sta PPUADDR
        ldx #8
        ldy #$68
@loop:
        lda inputDisplayFlag
        beq @show
        ldy #$FF
@show:
        sty PPUDATA
        iny
        dex
        bne @loop
        rts

showPaceDiffText:
        lda practiseType
        cmp #MODE_PACE
        bne @done
        lda #$20
        sta PPUADDR
        lda #$98
        sta PPUADDR
        lda #$D
        sta PPUDATA
        lda #$12
        sta PPUDATA
        lda #$F
        sta PPUDATA
        lda #$F
        sta PPUDATA
        lda #0
@done:
        rts

clearStatisticsBox:
        lda #$21
        sta tmpX
        lda #$63
        sta tmpY

        ldx #12
@startLine:
        lda tmpX
        sta PPUADDR
        lda tmpY
        sta PPUADDR

        ldy #6
@clearLine:
        lda #$FF
        sta PPUDATA
        dey
        bne @clearLine
        ; add to pointer
        clc
	lda tmpY
	adc #$20
	sta tmpY
        bcc @noverflow
        inc tmpX
@noverflow:
        dex
        bne @startLine
        rts

savestate_nametable_patch:
        .byte   $22,$F7,$38,$39,$39,$39,$39,$39,$39,$3A,$FE
        .byte   $23,$17,$3B,$1C,$15,$18,$1D,$FF,$FF,$3C,$FE
        .byte   $23,$37,$3B,$FF,$FF,$FF,$FF,$FF,$FF,$3C,$FE
        .byte   $23,$57,$3D,$3E,$3E,$3E,$3E,$3E,$3E,$3F,$FD

gameModeState_initGameBackground_finish:
        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda #$01
        sta playState
        lda startLevel
        sta levelNumber
        inc gameModeState
        rts

gameModeState_initGameState:
        lda #$EF
        ldx #$04
        ldy #$04
        jsr memset_page
        ldx #$0F
        lda #$00
; statsByType
@initStatsByType:
        sta $03EF,x
        dex
        bne @initStatsByType
        lda #$05
        sta tetriminoX

        ; set seed init
        lda set_seed_input
        sta set_seed
        lda set_seed_input+1
        sta set_seed+1
        lda set_seed_input+2
        sta set_seed+2

        ; paceResult init
        lda #$B0
        sta paceResult
        lda #$00
        sta paceSign
        sta paceResult+1
        sta paceResult+2

        ; misc
        sta spawnDelay
        sta saveStateSpriteDelay
        sta saveStateDirty
        sta completedLines ; reset during tetris bugfix
        sta presetIndex ; actually for tspinQuantity

        ; OEM stuff
        sta tetriminoY
        sta vramRow
        sta fallTimer
        sta pendingGarbage
        sta pendingGarbageInactivePlayer
        sta score
        sta score+1
        sta score+2
        sta lines
        sta lines+1
        sta lineClearStatsByType
        sta lineClearStatsByType+1
        sta lineClearStatsByType+2
        sta lineClearStatsByType+3
        sta allegro
        sta demo_heldButtons
        sta demo_repeats
        sta demoIndex
        sta demoButtonsAddr
        sta spawnID
        lda #$70
        sta demoButtonsAddr+1
        lda #$03
        sta renderMode
        lda #$A0
        sta autorepeatY
        jsr chooseNextTetrimino
        sta currentPiece
        jsr incrementPieceStat
        ldx #rng_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        jsr chooseNextTetrimino
        sta nextPiece

        lda practiseType
        cmp #MODE_TRANSITION
        bne @notTransition
        jsr transitionModeSetup
@notTransition:

        lda practiseType
        cmp #MODE_TYPEB
        bne @notTypeB
        lda #$25
        sta lines
@notTypeB:

        lda #$57
        sta outOfDateRenderFlags
        jsr updateAudioWaitForNmiAndResetOamStaging

        lda practiseType
        cmp #MODE_TYPEB
        bne @noTypeBPlayfield
        jsr initPlayfieldForTypeB
@noTypeBPlayfield:

        jsr hzStart

        ldx musicType
        lda musicSelectionTable,x
        jsr setMusicTrack
        inc gameModeState
        rts

transitionModeSetup:
        ; set score

        lda transitionModifier
        cmp #$10 ; (SXTOKL compat)
        beq @ret
        rol
        rol
        rol
        rol
        sta score+2

        ; set lines

        ; level + 1
        lda levelNumber
        clc
        adc #1
        sta tmp1
        ; max(10, level - 4)
        sbc #$5
        cmp #10
        bpl @noMin
        lda #10
@noMin:
        ; smallest
        cmp tmp1
        bmi @smaller
        lda tmp1
@smaller:
        ; render from A
        tax
        dex ; 10 lines before transition
        lda byteToBcdTable, x
        and #$F
        rol
        rol
        rol
        rol
        sta lines
        lda byteToBcdTable, x
        and #$F0
        lsr
        lsr
        lsr
        lsr
        sta lines+1
@ret:
        rts

initPlayfieldForTypeB:
        lda typeBModifier
        cmp #$6
        bmi @normalStart
        sbc #$5
        asl
        adc #$0c
        jmp @abnormalStart
@normalStart:
        lda #$0C
@abnormalStart:
        sta generalCounter
L87E7:  lda generalCounter
        beq L884A
        lda #$14
        sec
        sbc generalCounter
        sta generalCounter2
        lda #$00
        sta vramRow
        lda #$09
        sta generalCounter3
L87FC:  ldx #$17
        ldy #$02
        jsr generateNextPseudorandomNumber
        lda rng_seed
        and #$07
        tay
        lda rngTable,y
        sta generalCounter4
        ldx generalCounter2
        lda multBy10Table,x
        clc
        adc generalCounter3
        tay
        lda generalCounter4
        sta playfield,y
        lda generalCounter3
        beq L8824
        dec generalCounter3
        jmp L87FC

L8824:  ldx #$17
        ldy #$02
        jsr generateNextPseudorandomNumber
        lda rng_seed
        and #$0F
        cmp #$0A
        bpl L8824
        sta generalCounter5
        ldx generalCounter2
        lda multBy10Table,x
        clc
        adc generalCounter5
        tay
        lda #$EF
        sta playfield,y
        jsr updateAudioWaitForNmiAndResetOamStaging
        dec generalCounter
        bne L87E7
L884A:
        ldx typeBModifier
        lda typeBBlankInitCountByHeightTable,x
        tay
        lda #$EF
L885D:  sta playfield,y
        dey
        cpy #$0
        bne L885D
        lda #$00
        sta vramRow
        rts

        ; 0 3 5 8 10 12 -> 14 16 18
typeBBlankInitCountByHeightTable:
        .byte $C8,$AA,$96,$78,$64,$50,$3C,$28,$14
rngTable:
        .byte $EF,$7B,$EF,$7C,$7D,$7D,$EF
        .byte $EF

gameModeState_updateCountersAndNonPlayerState:
        lda #$01
        jsr changeCHRBank0
        lda #$01
        jsr changeCHRBank1
        lda #$00
        sta oamStagingLength
        inc fallTimer
        lda newlyPressedButtons_player1
        and #$20
        beq @ret
        lda displayNextPiece
        eor #$01
        sta displayNextPiece
@ret:   inc gameModeState
        rts

rotate_tetrimino:
        lda currentPiece
        sta originalY
        clc
        lda currentPiece
        asl a
        tax
        lda newlyPressedButtons
        and #BUTTON_A
        cmp #BUTTON_A
        bne @aNotPressed
        inx
        lda rotationTable,x
        sta currentPiece
        jsr isPositionValid
        bne @restoreOrientationID
        lda #$05
        sta soundEffectSlot1Init
        jmp @ret

@aNotPressed:
        lda newlyPressedButtons
        and #BUTTON_B
        cmp #BUTTON_B
        bne @ret
        lda rotationTable,x
        sta currentPiece
        jsr isPositionValid
        bne @restoreOrientationID
        lda #$05
        sta soundEffectSlot1Init
        jmp @ret

@restoreOrientationID:
        lda originalY
        sta currentPiece
@ret:   rts

rotationTable:
        .dbyt   $0301,$0002,$0103,$0200
        .dbyt   $0705,$0406,$0507,$0604
        .dbyt   $0909,$0808,$0A0A,$0C0C
        .dbyt   $0B0B,$100E,$0D0F,$0E10
        .dbyt   $0F0D,$1212,$1111
drop_tetrimino:
        lda autorepeatY
        bpl @notBeginningOfGame
        lda newlyPressedButtons
        and #BUTTON_DOWN
        beq @incrementAutorepeatY
        lda #$00
        sta autorepeatY
@notBeginningOfGame:
        bne @autorepeating
@playing:
        lda heldButtons
        and #$03
        bne @lookupDropSpeed
        lda newlyPressedButtons
        and #$0F
        cmp #BUTTON_DOWN
        bne @lookupDropSpeed
        lda #$01
        sta autorepeatY
        jmp @lookupDropSpeed

@autorepeating:
        lda heldButtons
        and #$0F
        cmp #BUTTON_DOWN
        beq @downPressed
        lda #$00
        sta autorepeatY
        sta holdDownPoints
        jmp @lookupDropSpeed

@downPressed:
        inc autorepeatY
        lda autorepeatY
        cmp #$03
        bcc @lookupDropSpeed
        lda #$01
        sta autorepeatY
        inc holdDownPoints
@drop:  lda #$00
        sta fallTimer
        lda tetriminoY
        sta originalY
        inc tetriminoY
        jsr isPositionValid
        beq @ret
        lda originalY
        sta tetriminoY
        lda #$02
        sta playState
        jsr updatePlayfield
@ret:   rts

@incrementAutorepeatY:
        inc autorepeatY
        jmp @ret

@lookupDropSpeed:
        lda #$01
        ldx levelNumber
        cpx #$1D
        bcs @noTableLookup
        lda framesPerDropTableNTSC,x
        ldy palFlag
        cpy #0
        beq @noTableLookup
        lda framesPerDropTablePAL,x
@noTableLookup:
        sta dropSpeed
        lda fallTimer
        cmp dropSpeed
        bpl @drop
        jmp @ret

framesPerDropTableNTSC:
        .byte   $30,$2B,$26,$21,$1C,$17,$12,$0D
        .byte   $08,$06,$05,$05,$05,$04,$04,$04
        .byte   $03,$03,$03,$02,$02,$02,$02,$02
        .byte   $02,$02,$02,$02,$02,$01
framesPerDropTablePAL:
        .byte   $24,$20,$1d,$19,$16,$12,$0f,$0b
        .byte   $07,$05,$04,$04,$04,$03,$03,$03
        .byte   $02,$02,$02,$01,$01,$01,$01,$01
        .byte   $01,$01,$01,$01,$01,$01
shift_tetrimino:
        ; region stuff
        lda #$10
        sta dasValueHigh
        lda #$0A
        sta dasValueLow
        ldy palFlag
        cpy #0
        beq @shiftTetrimino
        lda #$0C
        sta dasValueHigh
        lda #$08
        sta dasValueLow
@shiftTetrimino:

        lda tetriminoX
        sta originalY
        lda heldButtons
        and #BUTTON_DOWN
        bne @ret
        lda newlyPressedButtons
        and #$03
        bne @resetAutorepeatX
        lda heldButtons
        and #$03
        beq @ret
        inc autorepeatX
        lda autorepeatX
        cmp dasValueHigh
        bmi @ret
        lda dasValueLow
        sta autorepeatX
        jmp @buttonHeldDown

@resetAutorepeatX:
        lda #$00
        sta autorepeatX
@buttonHeldDown:
        lda heldButtons
        and #BUTTON_RIGHT
        beq @notPressingRight
        inc tetriminoX
        jsr isPositionValid
        bne @restoreX
        lda #$03
        sta soundEffectSlot1Init
        jmp @ret

@notPressingRight:
        lda heldButtons
        and #BUTTON_LEFT
        beq @ret
        dec tetriminoX
        jsr isPositionValid
        bne @restoreX
        lda #$03
        sta soundEffectSlot1Init
        jmp @ret

@restoreX:
        lda originalY
        sta tetriminoX
        lda dasValueHigh
        sta autorepeatX
@ret:   rts

stageSpriteForCurrentPiece:
        lda #$0
        sta pieceTileModifier
        jsr stageSpriteForCurrentPiece_actual

        lda practiseType
        cmp #MODE_HARDDROP
        beq ghostPiece
        rts

ghostPiece:
        lda playState
        cmp #3
        bpl @noGhost
        lda tetriminoY
        sta tmp3
@loop:
        inc tetriminoY
        jsr isPositionValid
        beq @loop
        dec tetriminoY
        lda #$1D
        sta pieceTileModifier
        jsr stageSpriteForCurrentPiece_actual
        lda tmp3
        sta tetriminoY
@noGhost:
        rts

tileModifierForCurrentPiece:
        lda pieceTileModifier
        beq @tileNormal
        and #$80
        bne @tileSingle
; @tileMultiple:
        lda orientationTable,x
        clc
        adc pieceTileModifier
        rts
@tileSingle:
        lda pieceTileModifier
        rts
@tileNormal:
        lda orientationTable,x
        rts

stageSpriteForCurrentPiece_actual:
        lda tetriminoX
        cmp #$EF ; set in tspin code
        beq stageSpriteForCurrentPiece_return
        asl a
        asl a
        asl a
        adc #$60
        sta generalCounter3
        clc
        lda tetriminoY
        rol a
        rol a
        rol a
        adc #$2F
        sta generalCounter4
        lda currentPiece
        sta generalCounter5
        clc
        lda generalCounter5
        rol a
        rol a
        sta generalCounter
        rol a
        adc generalCounter
        tax
        ldy oamStagingLength
        lda #$04
        sta generalCounter2
L8A4B:  lda orientationTable,x
        asl a
        asl a
        asl a
        clc
        adc generalCounter4
        sta oamStaging,y
        sta originalY
        inc oamStagingLength
        iny
        inx
        jsr tileModifierForCurrentPiece ; used to just load from orientationTable
        ; lda orientationTable, x
        sta oamStaging,y
        inc oamStagingLength
        iny
        inx
        lda #$02
        sta oamStaging,y
        lda originalY
        cmp #$2F
        bcs L8A84
        inc oamStagingLength
        dey
        lda #$FF
        sta oamStaging,y
        iny
        iny
        lda #$00
        sta oamStaging,y
        jmp L8A93

L8A84:  inc oamStagingLength
        iny
        lda orientationTable,x
        asl a
        asl a
        asl a
        clc
        adc generalCounter3
        sta oamStaging,y
L8A93:  inc oamStagingLength
        iny
        inx
        dec generalCounter2
        bne L8A4B
stageSpriteForCurrentPiece_return:
        rts

orientationTable:
        .byte   $00,$7B,$FF,$00,$7B,$00,$00,$7B
        .byte   $01,$FF,$7B,$00,$FF,$7B,$00,$00
        .byte   $7B,$00,$00,$7B,$01,$01,$7B,$00
        .byte   $00,$7B,$FF,$00,$7B,$00,$00,$7B
        .byte   $01,$01,$7B,$00,$FF,$7B,$00,$00
        .byte   $7B,$FF,$00,$7B,$00,$01,$7B,$00
        .byte   $FF,$7D,$00,$00,$7D,$00,$01,$7D
        .byte   $FF,$01,$7D,$00,$FF,$7D,$FF,$00
        .byte   $7D,$FF,$00,$7D,$00,$00,$7D,$01
        .byte   $FF,$7D,$00,$FF,$7D,$01,$00,$7D
        .byte   $00,$01,$7D,$00,$00,$7D,$FF,$00
        .byte   $7D,$00,$00,$7D,$01,$01,$7D,$01
        .byte   $00,$7C,$FF,$00,$7C,$00,$01,$7C
        .byte   $00,$01,$7C,$01,$FF,$7C,$01,$00
        .byte   $7C,$00,$00,$7C,$01,$01,$7C,$00
        .byte   $00,$7B,$FF,$00,$7B,$00,$01,$7B
        .byte   $FF,$01,$7B,$00,$00,$7D,$00,$00
        .byte   $7D,$01,$01,$7D,$FF,$01,$7D,$00
        .byte   $FF,$7D,$00,$00,$7D,$00,$00,$7D
        .byte   $01,$01,$7D,$01,$FF,$7C,$00,$00
        .byte   $7C,$00,$01,$7C,$00,$01,$7C,$01
        .byte   $00,$7C,$FF,$00,$7C,$00,$00,$7C
        .byte   $01,$01,$7C,$FF,$FF,$7C,$FF,$FF
        .byte   $7C,$00,$00,$7C,$00,$01,$7C,$00
        .byte   $FF,$7C,$01,$00,$7C,$FF,$00,$7C
        .byte   $00,$00,$7C,$01,$FE,$7B,$00,$FF
        .byte   $7B,$00,$00,$7B,$00,$01,$7B,$00
        .byte   $00,$7B,$FE,$00,$7B,$FF,$00,$7B
        .byte   $00,$00,$7B,$01,$00,$FF,$00,$00
        .byte   $FF,$00,$00,$FF,$00,$00,$FF,$00

stageSpriteForNextPiece:
.if !ALWAYS_NEXT_BOX
        lda displayNextPiece
        bne @ret
.endif
        lda #$C8
        sta spriteXOffset
        lda #$77
        sta spriteYOffset
        ldx nextPiece
        lda orientationToSpriteTable,x
        sta spriteIndexInOamContentLookup
        jmp loadSpriteIntoOamStaging

@ret:   rts

; Only cares about orientations selected by spawnTable
orientationToSpriteTable:
        .byte   $00,$00,$06,$00,$00,$00,$00,$09
        .byte   $08,$00,$0B,$07,$00,$00,$0A,$00
        .byte   $00,$00,$0C
loadSpriteIntoOamStaging:
        clc
        lda spriteIndexInOamContentLookup
        rol a
        tax
        lda oamContentLookup,x
        sta generalCounter
        inx
        lda oamContentLookup,x
        sta generalCounter2
        ldx oamStagingLength
        ldy #$00
@whileNotFF:
        lda (generalCounter),y
        cmp #$FF
        beq @ret
        clc
        adc spriteYOffset
        sta oamStaging,x
        inx
        iny
        lda (generalCounter),y
        sta oamStaging,x
        inx
        iny
        lda (generalCounter),y
        sta oamStaging,x
        inx
        iny
        lda (generalCounter),y
        clc
        adc spriteXOffset
        sta oamStaging,x
        inx
        iny
        lda #$04
        clc
        adc oamStagingLength
        sta oamStagingLength
        jmp @whileNotFF

@ret:   rts

oamContentLookup:
        .addr   sprite00LevelSelectCursor
        .addr   sprite01GameTypeCursor
        .addr   sprite02Blank
        .addr   sprite03PausePalette6
        .addr   sprite05DebugPalette4
        .addr   sprite05DebugPalette4
        .addr   sprite06TPiece
        .addr   sprite07SPiece
        .addr   sprite08ZPiece
        .addr   sprite09JPiece
        .addr   sprite0ALPiece
        .addr   sprite0BOPiece
        .addr   sprite0CIPiece
        .addr   sprite0EHighScoreNameCursor
        .addr   sprite0EHighScoreNameCursor
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   spriteDebugLevelEdit
        .addr   spriteStateSave
        .addr   spriteStateLoad
        .addr   spriteOff
        .addr   spriteOn
        .addr   spriteSeedCursor
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite53MusicTypeCursor
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   isPositionValid
        .addr   isPositionValid
        .addr   isPositionValid
        .addr   isPositionValid
; Sprites are sets of 4 bytes in the OAM format, terminated by FF. byte0=y, byte1=tile, byte2=attrs, byte3=x
; YY AA II XX
sprite00LevelSelectCursor:
        .byte   $00,$FC,$20,$00,$00,$FC,$20,$08
        .byte   $08,$FC,$20,$00,$08,$FC,$20,$08
        .byte   $FF
sprite01GameTypeCursor:
        .byte   $00,$27,$00,$00,$00,$27,$40,$3A
        .byte   $FF
; Used as a sort of NOOP for cursors
sprite02Blank:
        .byte   $00,$FF,$00,$00,$FF
sprite03PausePalette6:
        .byte   $00,$19,$00,$00,$00,$0A,$00,$08
        .byte   $00,$1E,$00,$10,$00,$1C,$00,$18
        .byte   $00,$0E,$00,$20,$FF
sprite05DebugPalette4:
        .byte   $00,$0b,$00,$00,$00,$15,$00,$08
        .byte   $00,$18,$00,$10,$00,$0c,$00,$18
        .byte   $00,$14,$00,$20
        .byte   $FF
sprite06TPiece:
        .byte   $00,$7B,$02,$FC,$00,$7B,$02,$04
        .byte   $00,$7B,$02,$0C,$08,$7B,$02,$04
        .byte   $FF
sprite07SPiece:
        .byte   $00,$7D,$02,$04,$00,$7D,$02,$0C
        .byte   $08,$7D,$02,$FC,$08,$7D,$02,$04
        .byte   $FF
sprite08ZPiece:
        .byte   $00,$7C,$02,$FC,$00,$7C,$02,$04
        .byte   $08,$7C,$02,$04,$08,$7C,$02,$0C
        .byte   $FF
sprite09JPiece:
        .byte   $00,$7D,$02,$FC,$00,$7D,$02,$04
        .byte   $00,$7D,$02,$0C,$08,$7D,$02,$0C
        .byte   $FF
sprite0ALPiece:
        .byte   $00,$7C,$02,$FC,$00,$7C,$02,$04
        .byte   $00,$7C,$02,$0C,$08,$7C,$02,$FC
        .byte   $FF
sprite0BOPiece:
        .byte   $00,$7B,$02,$00,$00,$7B,$02,$08
        .byte   $08,$7B,$02,$00,$08,$7B,$02,$08
        .byte   $FF
sprite0CIPiece:
        .byte   $04,$7B,$02,$F8,$04,$7B,$02,$00
        .byte   $04,$7B,$02,$08,$04,$7B,$02,$10
        .byte   $FF
sprite0EHighScoreNameCursor:
        .byte   $00,$FD,$20,$00,$FF
spriteDebugLevelEdit:
        .byte   $00,$21,$00,$00
        .byte   $FF
spriteStateLoad:
        .byte   $00,$15,$03,$00,$00,$18,$03,$08
        .byte   $00,$0A,$03,$10,$00,$0D,$03,$18
        .byte   $00,$0E,$03,$20,$00,$0D,$03,$28
        .byte   $FF
spriteStateSave:
        .byte   $00,$1c,$03,$00,$00,$0a,$03,$08
        .byte   $00,$1f,$03,$10,$00,$0e,$03,$18
        .byte   $00,$0d,$03,$20
        .byte   $FF
spriteOff:
        .byte   $00,$18,$00,$00,$00,$0f,$00,$08
        .byte   $00,$0f,$00,$10
        .byte   $FF
spriteOn:
        .byte   $00,$18,$00,$08,$00,$17,$00,$10
        .byte   $FF
spriteSeedCursor:
        .byte   $00,$6B,$00,$00
        .byte   $FF
sprite53MusicTypeCursor:
        .byte   $00,$27,$00,$00
        .byte   $FF

isPositionValid:
        lda tetriminoY
        asl a
        sta generalCounter
        asl a
        asl a
        clc
        adc generalCounter
        adc tetriminoX
        sta generalCounter
        lda currentPiece
        asl a
        asl a
        sta generalCounter2
        asl a
        clc
        adc generalCounter2
        tax
        ldy #$00
        lda #$04
        sta generalCounter3
; Checks one square within the tetrimino
@checkSquare:
        lda orientationTable,x
        clc
        adc tetriminoY
        adc #$02

        cmp #$16
        bcs @invalid
        lda orientationTable,x
        asl a
        sta generalCounter4
        asl a
        asl a
        clc
        adc generalCounter4
        clc
        adc generalCounter
        sta positionValidTmp
        inx
        inx
        lda orientationTable,x
        clc
        adc positionValidTmp
        tay
        lda (playfieldAddr),y
        cmp #$EF
        bcc @invalid
        lda orientationTable,x
        clc
        adc tetriminoX
        cmp #$0A
        bcs @invalid
        inx
        dec generalCounter3
        bne @checkSquare
        lda #$00
        sta generalCounter
        rts

@invalid:
        lda #$FF
        sta generalCounter
        rts

render_mode_static:
        lda currentPpuCtrl
        and #$FC
        sta currentPpuCtrl
        lda #$00
        sta PPUSCROLL
        sta PPUSCROLL
        rts

render_mode_scroll:
        ; handle loading of palette
        lda menuPaletteDelay
        beq @loadedPalette
        cmp #1
        bne @waitingPalette
        jsr bulkCopyToPpu
        .addr   title_palette
@waitingPalette:
        dec menuPaletteDelay
@loadedPalette:

        ; handle scroll
        lda currentPpuCtrl
        and #$FC
        sta currentPpuCtrl
        sta PPUCTRL
        lda #0
        sta PPUSCROLL

        jsr calc_menuScrollY
        cmp menuScrollY
        beq @endscroll
        ; not equal
        cmp menuScrollY
        bcc @lessThan
        inc menuScrollY
        jmp @endscroll
@lessThan:
        dec menuScrollY
@endscroll:

        lda menuScrollY
        cmp #MENU_MAX_Y_SCROLL
        bcc @uncapped
        lda #MENU_MAX_Y_SCROLL
        sta menuScrollY
@uncapped:

        sta PPUSCROLL
        rts

calc_menuScrollY:
        lda practiseType
        cmp #MENU_TOP_MARGIN_SCROLL
        bcs @underflow
        lda #MENU_TOP_MARGIN_SCROLL+1
@underflow:
        sbc #MENU_TOP_MARGIN_SCROLL
        asl
        asl
        asl
        rts

render_mode_pause:
        ; lda pausedOutOfDateRenderFlags
        ; and #$01
        ; beq @skipStatisticsPatch
        ; jsr statisticsNametablePatch
; @skipStatisticsPatch:
        lda pausedOutOfDateRenderFlags
        and #$02
        beq @skipSaveSlotPatch
        jsr saveSlotNametablePatch
@skipSaveSlotPatch:
        lda #0
        sta pausedOutOfDateRenderFlags

        lda playState
        cmp #$04
        beq @done
        jsr render_playfield
@done:

        lda #0
        sta PPUSCROLL
        sta PPUSCROLL
        rts

render_playfield:
        lda #$04
        sta playfieldAddr+1
        jsr copyPlayfieldRowToVRAM
        jsr copyPlayfieldRowToVRAM
        jsr copyPlayfieldRowToVRAM
        jsr copyPlayfieldRowToVRAM
        rts

render_mode_play_and_demo:
        lda playState
        cmp #$04
        bne @playStateNotDisplayLineClearingAnimation
        lda #$04
        sta playfieldAddr+1
        jsr updateLineClearingAnimation
        lda #$00
        sta vramRow
        jmp @renderLines

@playStateNotDisplayLineClearingAnimation:
        jsr render_playfield
@renderLines:
        lda outOfDateRenderFlags
        and #$01
        beq @renderLevel
        lda #$20
        sta PPUADDR
        lda #$73
        sta PPUADDR
        lda lines+1
        sta PPUDATA
        lda lines
        jsr twoDigsToPPU
        lda outOfDateRenderFlags
        and #$FE
        sta outOfDateRenderFlags

@renderLevel:
        lda outOfDateRenderFlags
        and #$02
        beq @renderScore

        ldx levelNumber
        lda levelDisplayTable,x
        sta generalCounter

        lda practiseType
        cmp #MODE_TYPEB
        beq @renderLevelTypeB

        lda #$22
        sta PPUADDR
        lda #$BA
        sta PPUADDR
        lda generalCounter
        jsr twoDigsToPPU
        jmp @renderLevelEnd

@renderLevelTypeB:
        lda #$22
        sta PPUADDR
        lda #$B9
        sta PPUADDR
        lda generalCounter
        jsr twoDigsToPPU
        lda #$24
        sta PPUDATA
        lda typeBModifier
        sta PPUDATA
        ; jmp @renderLevelEnd

@renderLevelEnd:
        jsr updatePaletteForLevel
        lda outOfDateRenderFlags
        and #$FD
        sta outOfDateRenderFlags

@renderScore:
        lda outOfDateRenderFlags
        and #$04
        beq @renderHz
        lda #$21
        sta PPUADDR
        lda #$18
        sta PPUADDR

        lda score+2 ; patched

        ; 7 digit score clamping
        ; cmp #$A0
        ; bcc @nomax
        ; sbc #$A0
; @nomax:

        jsr twoDigsToPPU
        lda score+1
        jsr twoDigsToPPU
        lda score
        jsr twoDigsToPPU

        ; draw million digit
        ; lda score+2
        ; cmp #$A0
        ; bcc @noExtraDigit
        ; lda #$21
        ; sta PPUADDR
        ; lda #$17
        ; sta PPUADDR
        ; lda #$1
        ; sta PPUDATA
; @noExtraDigit:

        lda outOfDateRenderFlags
        and #$FB
        sta outOfDateRenderFlags
@renderHz:
        lda hzFlag
        beq @renderStats
        lda outOfDateRenderFlags
        and #$10
        beq @renderTetrisFlashAndSound
        ; only set at game start and when player is controlling a piece
        ; during which, no other tile updates are happening

        ; last I checked you could draw $A extra tiles *every* frame
        ; without issues, and this uses up TODO tiles

        ; TODO: line piece stat

        ; tap counter
        lda #$21
        sta PPUADDR
        lda #$83
        sta PPUADDR
        lda hzTapCounter
        and #$f
        sta PPUDATA

        ; hz
        lda #$21
        sta PPUADDR
        lda #$C3
        sta PPUADDR
        ldx #0
@hzLoop:
        lda hzResult, x
        jsr twoDigsToPPU
        inx
        cpx #2
        bne @hzLoop

        ; direction

        lda #$22
        sta PPUADDR
        lda #$03
        sta PPUADDR
        lda hzTapDirection
        clc
        adc #$D0
        sta PPUDATA

        lda outOfDateRenderFlags
        and #$EF
        sta outOfDateRenderFlags

        jmp @renderTetrisFlashAndSound
@renderStats:
        lda outOfDateRenderFlags
        and #$40
        beq @renderTetrisFlashAndSound
        lda #$00
        sta tmpCurrentPiece
@renderPieceStat:
        lda tmpCurrentPiece
        asl a
        tax
        lda pieceToPpuStatAddr,x
        sta PPUADDR
        lda pieceToPpuStatAddr+1,x
        sta PPUADDR
        lda statsByType+1,x
        sta PPUDATA
        lda statsByType,x
        jsr twoDigsToPPU
        inc tmpCurrentPiece
        lda tmpCurrentPiece
        cmp #$07
        bne @renderPieceStat
        lda outOfDateRenderFlags
        and #$BF
        sta outOfDateRenderFlags
@renderTetrisFlashAndSound:
        lda #$3F
        sta PPUADDR
        lda #$0E
        sta PPUADDR
        ldx #$00
        lda completedLines
        cmp #$04
        bne @setPaletteColor
        lda frameCounter
        and #$03
        bne @setPaletteColor
        ldx #$30
        lda frameCounter
        and #$07
        bne @setPaletteColor
        lda #$09
        sta soundEffectSlot1Init
@setPaletteColor:
        stx PPUDATA
        ldy #$00
        sty PPUSCROLL
        ldy #$00
        sty PPUSCROLL
        rts

pieceToPpuStatAddr:
        .dbyt   $2186,$21C6,$2206,$2246
        .dbyt   $2286,$22C6,$2306
multBy10Table:
        .byte   $00,$0A,$14,$1E,$28,$32,$3C,$46
        .byte   $50,$5A,$64,$6E,$78,$82,$8C,$96
        .byte   $A0,$AA,$B4,$BE
; addresses
vramPlayfieldRows:
        .word   $20C6,$20E6,$2106,$2126
        .word   $2146,$2166,$2186,$21A6
        .word   $21C6,$21E6,$2206,$2226
        .word   $2246,$2266,$2286,$22A6
        .word   $22C6,$22E6,$2306,$2326
twoDigsToPPU:
        sta generalCounter
        and #$F0
        lsr a
        lsr a
        lsr a
        lsr a
        sta PPUDATA
        lda generalCounter
        and #$0F
        sta PPUDATA
        rts

copyPlayfieldRowToVRAM:
        ldx vramRow
        cpx #$15
        bpl @ret
        lda multBy10Table,x
        tay
        txa
        asl a
        tax
        inx
        lda vramPlayfieldRows,x
        sta PPUADDR
        dex

        lda vramPlayfieldRows,x
        clc
        adc #$06
        sta PPUADDR
@copyRow:
        ldx #$0A
@copyByte:
        lda (playfieldAddr),y
        sta PPUDATA
        iny
        dex
        bne @copyByte
        inc vramRow
        lda vramRow
        cmp #$14
        bmi @ret
        lda #$20
        sta vramRow
@ret:   rts

updateLineClearingAnimation:
        lda frameCounter
        and #$03
        bne @ret
        ; invisible mode show blocks intead of empty
        ldy #$FF
        lda practiseType
        cmp #MODE_INVISIBLE
        bne @notInvisible
        ldy #BLOCK_TILES
@notInvisible:
        sty tmp3

        lda #$00
        sta generalCounter3
@whileCounter3LessThan4:
        ldx generalCounter3
        lda completedRow,x
        beq @nextRow
        asl a
        tay
        lda vramPlayfieldRows,y
        sta generalCounter
        lda generalCounter
        clc
        adc #$06
        sta generalCounter

        iny
        lda vramPlayfieldRows,y
        sta generalCounter2
        sta PPUADDR
        ldx rowY
        lda leftColumns,x
        clc
        adc generalCounter
        sta PPUADDR
        lda tmp3 ; #$FF
        sta PPUDATA
        lda generalCounter2
        sta PPUADDR
        ldx rowY
        lda rightColumns,x
        clc
        adc generalCounter
        sta PPUADDR
        lda tmp3 ; #$FF
        sta PPUDATA
@nextRow:
        inc generalCounter3
        lda generalCounter3
        cmp #$04
        bne @whileCounter3LessThan4
        inc rowY
        lda rowY
        cmp #$05
        bmi @ret
        inc playState
@ret:   rts

leftColumns:
        .byte   $04,$03,$02,$01,$00
rightColumns:
        .byte   $05,$06,$07,$08,$09
; Set Background palette 2 and Sprite palette 2
updatePaletteForLevel:
        lda levelNumber
@mod10: cmp #$0A
        bcc @copyPalettes
        sec
        sbc #$0A
        jmp @mod10

@copyPalettes:
        asl a
        asl a
        tax
        lda #$00
        sta generalCounter
@copyPalette:
        lda #$3F
        sta PPUADDR
        lda #$08
        clc
        adc generalCounter
        sta PPUADDR
        lda colorTable,x
        sta PPUDATA
        lda colorTable+1,x
        sta PPUDATA
        lda colorTable+1+1,x
        sta PPUDATA
        lda colorTable+1+1+1,x
        sta PPUDATA
        lda generalCounter
        clc
        adc #$10
        sta generalCounter
        cmp #$20
        bne @copyPalette
        rts

; 4 bytes per level (bg, fg, c3, c4)
colorTable:
        .dbyt   $0F30,$2112,$0F30,$291A
        .dbyt   $0F30,$2414,$0F30,$2A12
        .dbyt   $0F30,$2B15,$0F30,$222B
        .dbyt   $0F30,$0016,$0F30,$0513
        .dbyt   $0F30,$1612,$0F30,$2716
; This increment and clamping is performed in copyPlayfieldRowToVRAM instead of here
noop_disabledVramRowIncr:
        rts

playState_spawnNextTetrimino:
        lda vramRow
        cmp #$20
        bmi @ret

.if PRACTISE_MODE
        lda spawnDelay
        beq @notDelaying
        dec spawnDelay
        jmp @ret
.endif

@notDelaying:
        lda #$01
        sta playState

.if PRACTISE_MODE
        ; savestate patch
        lda saveStateDirty
        beq @noSaveState
        lda #0
        sta saveStateDirty
        rts
@noSaveState:
.endif

        jsr hzStart
        lda #$00
        sta fallTimer
        sta tetriminoY
        lda #$05
        sta tetriminoX
        ldx nextPiece
        lda spawnOrientationFromOrientation,x
        sta currentPiece
        jsr incrementPieceStat
        jsr chooseNextTetrimino
        sta nextPiece
@resetDownHold:
        lda #$00
        sta autorepeatY
@ret:   rts

chooseNextTetrimino:
        jmp pickTetriminoPre

pickRandomTetrimino:
        inc spawnCount
        lda rng_seed
        clc
        adc spawnCount
        and #$07
        cmp #$07
        beq @invalidIndex
        tax
        lda spawnTable,x
        cmp spawnID
        bne useNewSpawnID
@invalidIndex:
        ldx #rng_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        lda rng_seed
        and #$07
        clc
        adc spawnID
L992A:  cmp #$07
        bcc L9934
        sec
        sbc #$07
        jmp L992A

L9934:  tax
        lda spawnTable,x
useNewSpawnID:
        sta spawnID
        jsr pickTetriminoPost
        rts

pickTetriminoPre:
        lda practiseType
        cmp #MODE_TSPINS
        beq pickTetriminoTSpin
        lda practiseType
        cmp #MODE_SEED
        beq pickTetriminoSeed
        lda practiseType
        cmp #MODE_TAP
        beq pickTetriminoTap
        lda practiseType
        cmp #MODE_PRESETS
        beq pickTetriminoPreset
        jmp pickRandomTetrimino

pickTetriminoTSpin:
        lda #$2
        sta spawnID
        rts

pickTetriminoTap:
        lda #$12
        sta spawnID
        rts

pickTetriminoSeed:
        jsr setSeedNextRNG

        ; SPSv2

        lda set_seed_input+2
        ror
        ror
        ror
        ror
        and #$F
        cmp #0
        beq @compatMode

        adc #1
        sta tmp3 ; step + 1 in tmp3
@loop:
        jsr setSeedNextRNG
        dec tmp3
        lda tmp3
        bne @loop
@compatMode:

        inc set_seed+2 ; 'spawnCount'
        lda set_seed
        clc
        adc set_seed+2
        and #$07
        cmp #$07
        beq @invalidIndex
        tax
        lda spawnTable,x
        cmp spawnID
        bne @useNewSpawnID
@invalidIndex:
        ldx #set_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        lda set_seed
        and #$07
        clc
        adc spawnID
@L992A:
        cmp #$07
        bcc @L9934
        sec
        sbc #$07
        jmp @L992A

@L9934:
        tax
        lda spawnTable,x
@useNewSpawnID:
        sta spawnID
        rts

setSeedNextRNG:
        ldx #set_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        rts

pickTetriminoPreset:
presetBitmask := tmp2
@start:
        inc presetIndex
        lda presetIndex
        and #$07
        cmp #$07
        beq pickTetriminoPreset
        sta presetIndex
        tax ; RNG in x
        ; store piece bitmask
        ldy presetModifier
        lda presets, y ; offset of preset in A
        tay
        lda presets, y
        sta presetBitmask
        ; create bit to compare with mask from RNG
        lda #1
@shiftBit:
        cpx #0
        beq @doneShifting
        asl
        dex
        jmp @shiftBit
@doneShifting:
        and presetBitmask
        bne @start
        ldx presetIndex ; restore RNG
        lda spawnTable,x
        sta spawnID
        rts

pickTetriminoPost:
        lda practiseType
        cmp #MODE_DROUGHT
        beq pickTetriminoDrought
        lda spawnID ; restore A
        rts

pickTetriminoDrought:
        lda spawnID ; restore A
        cmp #$12
        bne @droughtDone
        lda rng_seed+1
        and #$F
        adc #1 ; always adds 1 so code continues as normal if droughtModifier is 0
        cmp droughtModifier
        bmi @pickRando
        lda spawnID ; restore A
@droughtDone:
        rts
@pickRando:
        jmp pickRandomTetrimino

tetriminoTypeFromOrientation:
        .byte   $00,$00,$00,$00,$01,$01,$01,$01
        .byte   $02,$02,$03,$04,$04,$05,$05,$05
        .byte   $05,$06,$06
spawnTable:
        .byte   $02,$07,$08,$0A,$0B,$0E,$12
        .byte   $02
spawnOrientationFromOrientation:
        .byte   $02,$02,$02,$02,$07,$07,$07,$07
        .byte   $08,$08,$0A,$0B,$0B,$0E,$0E,$0E
        .byte   $0E,$12,$12
incrementPieceStat:
        tax
        lda tetriminoTypeFromOrientation,x
        asl a
        tax
        lda statsByType,x
        clc
        adc #$01
        sta generalCounter
        and #$0F
        cmp #$0A
        bmi L9996
        lda generalCounter
        clc
        adc #$06
        sta generalCounter
        cmp #$A0
        bcc L9996
        clc
        adc #$60
        sta generalCounter
        lda statsByType+1,x
        clc
        adc #$01
        sta statsByType+1,x
L9996:  lda generalCounter
        sta statsByType,x
        lda outOfDateRenderFlags
        ora #$40
        sta outOfDateRenderFlags
        rts

playState_lockTetrimino:
        jsr isPositionValid
        beq @notGameOver
; gameOver:
        lda #$02
        sta soundEffectSlot0Init
        lda #$0A ; playState_checkStartGameOver
        sta playState
        jsr updateAudio2

        ; make invisible tiles visible
        lda #$00
        sta vramRow
        ldx #$C8
        lda #BLOCK_TILES+3
@invizLoop:
        ldy playfield, x
        cpy #INVISIBLE_TILE
        bne @emptyTile
        sta playfield, x
@emptyTile:
        dex
        bne @invizLoop
        rts

@notGameOver:
        lda vramRow
        cmp #$20
        bmi @ret
        lda tetriminoY
        asl a
        sta generalCounter
        asl a
        asl a
        clc
        adc generalCounter
        adc tetriminoX
        sta generalCounter
        lda currentPiece
        asl a
        asl a
        sta generalCounter2
        asl a
        clc
        adc generalCounter2
        tax
        ldy #$00
        lda #$04
        sta generalCounter3
; Copies a single square of the tetrimino to the playfield
@lockSquare:
        lda orientationTable,x
        asl a
        sta generalCounter4
        asl a
        asl a
        clc
        adc generalCounter4
        clc
        adc generalCounter
        sta positionValidTmp
        inx
        lda orientationTable,x
        sta generalCounter5
        lda practiseType
        cmp #MODE_INVISIBLE
        bne @notInvisible
        lda #INVISIBLE_TILE
        sta generalCounter5
@notInvisible:
        inx
        lda orientationTable,x
        clc
        adc positionValidTmp
        tay
        lda generalCounter5
        ; BLOCK_TILES
        sta (playfieldAddr),y
        inx
        dec generalCounter3
        bne @lockSquare
        lda #$00
        sta lineIndex
        jsr updatePlayfield
        jsr updateMusicSpeed
        inc playState
@ret:   rts

playState_checkStartGameOver:
        ; skip curtain / rocket

@checkForStartButton:
        lda newlyPressedButtons_player1
        cmp #$10
        bne @ret2
        lda #$00
        sta playState
        sta newlyPressedButtons_player1
@ret2:  rts

playState_checkForCompletedRows:
        lda vramRow
        cmp #$20
        bpl @updatePlayfieldComplete
        jmp playState_checkForCompletedRows_return

@updatePlayfieldComplete:
        lda tetriminoY
        sec
        sbc #$02
        bpl @yInRange
        lda #$00
@yInRange:
        clc
        adc lineIndex
        sta generalCounter2
        asl a
        sta generalCounter
        asl a
        asl a
        clc
        adc generalCounter
        sta generalCounter
        tay
        ldx #$0A

@checkIfRowComplete:
        ; this block
        jsr practiseRowCompletePatch
.if !AUTO_WIN
        beq @rowNotComplete
.endif

        ; replaces this one
        ; lda (playfieldAddr),y
        ; cmp #$EF
        ; beq @rowNotComplete

        iny
        dex
        bne @checkIfRowComplete
        lda #$0A
        sta soundEffectSlot1Init
        inc completedLines
        ldx lineIndex
        lda generalCounter2
        sta completedRow,x
        ldy generalCounter
        dey
@movePlayfieldDownOneRow:
        lda (playfieldAddr),y
        ldx #$0A
        stx playfieldAddr
        sta (playfieldAddr),y
        lda #$00
        sta playfieldAddr
        dey
        cpy #$FF
        bne @movePlayfieldDownOneRow
        lda #$EF
        ldy #$00
@clearRowTopRow:
        sta (playfieldAddr),y
        iny
        cpy #$0A
        bne @clearRowTopRow
        lda #$13
        sta currentPiece
        jmp @incrementLineIndex

@rowNotComplete:
        ldx lineIndex
        lda #$00
        sta completedRow,x
@incrementLineIndex:
        inc lineIndex
        lda lineIndex
        cmp #$04
        bmi playState_checkForCompletedRows_return
        ldy completedLines
        lda garbageLines,y
        clc
        adc pendingGarbageInactivePlayer
        sta pendingGarbageInactivePlayer
        lda #$00
        sta vramRow
        sta rowY
        lda completedLines
        cmp #$04
        bne @skipTetrisSoundEffect
        lda #$04
        sta soundEffectSlot1Init
@skipTetrisSoundEffect:
        inc playState
        lda completedLines
        bne playState_checkForCompletedRows_return
@skipLines:
playState_completeRowContinue:
        inc playState
        lda #$07
        sta soundEffectSlot1Init
playState_checkForCompletedRows_return:
        rts

playState_prepareNext:
        ; bTypeGoalCheck
        lda practiseType
        cmp #MODE_TYPEB
        bne @bTypeEnd
        lda lines
        bne @bTypeEnd

        ; copy success graphic
        ldx #$5C
        ldy #$0
@copySuccessGraphic:
        lda typebSuccessGraphic,y
        cmp #$80
        beq @graphicCopied
        sta playfield,x
        inx
        iny
        jmp @copySuccessGraphic
@graphicCopied:
        lda #$00
        sta vramRow

        ; play sfx
        lda #$4
        sta soundEffectSlot1Init

        jsr sleep_typeb
        lda #$0A ; playState_checkStartGameOver
        sta playState

        ; patch levelNumber with score multiplier
        ldx levelNumber
        stx tmp3 ; and save a copy
        lda levelDisplayTable, x
        and #$F
        clc
        adc typeBModifier
        sta levelNumber
        beq @typeBScoreDone
        dec levelNumber

        ; patch some stuff
        lda #$5
        sta completedLines
        jsr addLineClearPoints
        dec playState

        ; restore level
@typeBScoreDone:
        lda tmp3
        sta levelNumber

        rts
@bTypeEnd:

        jsr practisePrepareNext
        inc playState
        rts

sleep_typeb:
        lda #$30
        sta sleepCounter
        jsr stageSpriteForNextPiece
@loop:  jsr updateAudioWaitForNmiAndResetOamStaging
        jsr stageSpriteForNextPiece
        lda sleepCounter
        bne @loop
        rts

typebSuccessGraphic:
        .byte   $17,$12,$0C,$0E,$FF,$28,$80

playState_receiveGarbage:
        ldy pendingGarbage
        beq @ret
        lda vramRow
        cmp #$20
        bmi @delay
        lda multBy10Table,y
        sta generalCounter2
        lda #$00
        sta generalCounter
@shiftPlayfieldUp:
        ldy generalCounter2
        lda (playfieldAddr),y
        ldy generalCounter
        sta (playfieldAddr),y
        inc generalCounter
        inc generalCounter2
        lda generalCounter2
        cmp #$C8
        bne @shiftPlayfieldUp
        iny

        ldx #$00
@fillGarbage:
        cpx garbageHole
        beq @hole
        lda #BLOCK_TILES + 3
        jmp @set
@hole:
        lda #$EF ; was $FF ?
@set:
        sta (playfieldAddr),y
        inx
        cpx #$0A
        bne @inc
        ldx #$00
@inc:   iny
        cpy #$C8
        bne @fillGarbage
        lda #$00
        sta pendingGarbage
        sta vramRow
@ret:  inc playState
@delay:  rts


garbageLines:
        .byte   $00,$00,$01,$02,$04
playState_updateLinesAndStatistics:
        jsr updateMusicSpeed
        lda completedLines
        bne @linesCleared
        jmp addHoldDownPoints

@linesCleared:
        tax
        dex
        lda lineClearStatsByType,x
        clc
        adc #$01
        sta lineClearStatsByType,x
        and #$0F
        cmp #$0A
        bmi @noCarry
        lda lineClearStatsByType,x
        clc
        adc #$06
        sta lineClearStatsByType,x
@noCarry:
        lda outOfDateRenderFlags
        ora #$01
        sta outOfDateRenderFlags

; type-b lines decrement
        lda practiseType
        cmp #MODE_TYPEB
        bne @notTypeB
        lda completedLines
        sta generalCounter
        lda lines
        sec
        sbc generalCounter
        sta lines
        bpl @checkForBorrow
        lda #$00
        sta lines
        jmp addHoldDownPoints
@checkForBorrow:
        and #$0F
        cmp #$0A
        bmi addHoldDownPoints
        lda lines
        sec
        sbc #$06
        sta lines
        jmp addHoldDownPoints
@notTypeB:

        ldx completedLines
incrementLines:
        inc lines
        lda lines
        and #$0F
        cmp #$0A
        bmi L9BC7
        lda lines
        clc
        adc #$06
        sta lines
        and #$F0
        cmp #$A0
        bcc L9BC7
        lda lines
        and #$0F
        sta lines
        inc lines+1
L9BC7:  lda lines
        and #$0F
        bne L9BFB

        ; needed when mode is set to G (SXTOKL compat)
        lda practiseType
        cmp #MODE_TRANSITION
        beq @nextLevel

        lda lines+1
        sta generalCounter2
        lda lines
        sta generalCounter
        lsr generalCounter2
        ror generalCounter
        lsr generalCounter2
        ror generalCounter
        lsr generalCounter2
        ror generalCounter
        lsr generalCounter2
        ror generalCounter
        lda levelNumber
        cmp generalCounter
        bpl L9BFB

        ; clamp levelNumber
        ; cmp #$EF
        ; beq L9BFB

@nextLevel:
        inc levelNumber
        lda #$06
        sta soundEffectSlot1Init
        lda outOfDateRenderFlags
        ora #$02
        sta outOfDateRenderFlags
L9BFB:  dex
        bne incrementLines
addHoldDownPoints:
.if NO_SCORING
        jmp L9C27
.endif
        lda holdDownPoints
        cmp #$02
        bmi addLineClearPoints
        clc
        dec score
        adc score
        sta score
        and #$0F
        cmp #$0A
        bcc L9C18
        lda score
        clc
        adc #$06
        sta score
L9C18:  lda score
        and #$F0
        cmp #$A0
        bcc L9C27
        clc
        adc #$60
        sta score
        inc score+1
L9C27:  lda outOfDateRenderFlags
        ora #$04
        sta outOfDateRenderFlags
addLineClearPoints:
.if NO_SCORING
        jmp addLineClearPointsDone
.endif
        lda #$00
        sta holdDownPoints
        lda levelNumber
        sta generalCounter
        inc generalCounter
L9C37:  lda completedLines
        asl a
        tax
        lda pointsTable,x
        clc
        adc score
        sta score
        cmp #$A0
        bcc L9C4E
        clc
        adc #$60
        sta score
        inc score+1
L9C4E:
        inx
        lda pointsTable,x
        clc
        adc score+1
        sta score+1
        and #$0F
        cmp #$0A
        bcc L9C64
        lda score+1
        clc
        adc #$06
        sta score+1
L9C64:
        lda score+1
        and #$F0
        cmp #$A0
        bcc L9C75
        lda score+1
        clc
        adc #$60
        sta score+1
        inc score+2
L9C75:
        lda score+2
        and #$0F
        cmp #$0A
        bcc L9C84
        lda score+2
        clc
        adc #$06
        sta score+2
L9C84:
        ; score limit used to live here
        dec generalCounter
        bne L9C37
        lda outOfDateRenderFlags
        ora #$04
        sta outOfDateRenderFlags
addLineClearPointsDone:
        lda #$00
        sta completedLines
        inc playState
        rts

pointsTable:
        .word   $0000,$0040,$0100,$0300,$1200
        .word   $1000 ; used in b-type score
updatePlayfield:
        ldx tetriminoY
        dex
        dex
        txa
        bpl @rowInRange
        lda #$00
@rowInRange:
        cmp vramRow
        bpl @ret
        sta vramRow
@ret:   rts

gameModeState_handleGameOver:
        lda #$05
        sta generalCounter2
        lda playState
        cmp #$00
        beq @gameOver
        lda #$1 ; deleting this line causes the next piece to flash (?)
        jmp @ret
@gameOver:
        lda #$03
        sta renderMode
        jsr handleHighScoreIfNecessary
        lda #$01
        sta playState
        lda #$EF
        ldx #$04
        ldy #$04 ; used to be 5, but we dont need to clear 2p playfield
        jsr memset_page
        lda #$00
        sta vramRow
        lda #$01
        sta playState
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda #$03
        sta gameMode
        rts

@ret:   inc gameModeState
        rts

updateMusicSpeed:
        ldx #$05
        lda multBy10Table,x
        tay
        ldx #$0A
@checkForBlockInRow:
        lda (playfieldAddr),y
        cmp #$EF
        bne @foundBlockInRow
        iny
        dex
        bne @checkForBlockInRow
        lda allegro
        beq @ret
        lda #$00
        sta allegro
        ldx musicType
        lda musicSelectionTable,x
        jsr setMusicTrack
        jmp @ret

@foundBlockInRow:
        lda allegro
        bne @ret
        lda #$FF
        sta allegro
        lda musicType
        clc
        adc #$04
        tax
        lda musicSelectionTable,x
        jsr setMusicTrack
@ret:   rts

pollControllerButtons:
        lda gameMode
        cmp #$05
        beq @demoGameMode
        ; beq @recording
        jsr pollController
        rts

@demoGameMode:
        lda $D0
        cmp #$FF
        beq @recording
        jsr pollController
        lda newlyPressedButtons_player1
        cmp #$10
        beq @startButtonPressed
        lda demo_repeats
        beq @finishedMove
        dec demo_repeats
        jmp @moveInProgress

@finishedMove:
        ldx #$00
        lda (demoButtonsAddr,x)
        sta generalCounter
        jsr demoButtonsTable_indexIncr
        lda demo_heldButtons
        eor generalCounter
        and generalCounter
        sta newlyPressedButtons_player1
        lda generalCounter
        sta demo_heldButtons
        ldx #$00
        lda (demoButtonsAddr,x)
        sta demo_repeats
        jsr demoButtonsTable_indexIncr
        lda demoButtonsAddr+1
        cmp #$DF
        beq @ret
        jmp @holdButtons

@moveInProgress:
        lda #$00
        sta newlyPressedButtons_player1
@holdButtons:
        lda demo_heldButtons
        sta heldButtons_player1
@ret:   rts

@startButtonPressed:
        lda #$DD
        sta demoButtonsAddr+1
        lda #$00
        sta frameCounter+1
        lda #$01
        sta gameMode
        rts

@recording:
        jsr pollController
        lda gameMode
        cmp #$05
        bne @ret2
        ; lda $D0
        ; cmp #$FF
        bne @ret2
        lda heldButtons_player1
        cmp demo_heldButtons
        beq @buttonsNotChanged
        ldx #$00
        lda demo_heldButtons
        sta (demoButtonsAddr,x)
        jsr demoButtonsTable_indexIncr
        lda demo_repeats
        sta (demoButtonsAddr,x)
        jsr demoButtonsTable_indexIncr
        lda demoButtonsAddr+1
        cmp #$DF ; check movie has ended
        beq @ret2
        lda heldButtons_player1
        sta demo_heldButtons
        lda #$00
        sta demo_repeats
        rts

@buttonsNotChanged:
        inc demo_repeats

@ret2:  rts

demoButtonsTable_indexIncr:
        lda demoButtonsAddr
        clc
        adc #$01
        sta demoButtonsAddr
        lda #$00
        adc demoButtonsAddr+1
        sta demoButtonsAddr+1
        rts

gameMode_startDemo:
        sta gameModeState
        sta playState
        sta startLevel
        lda #$05
        sta gameMode
        jmp gameMode_playAndEndingHighScore_jmp

; canon is adjustMusicSpeed
setMusicTrack:
.if !NO_MUSIC
        sta musicTrack
        lda gameMode
        cmp #$05
        bne @ret
        lda #$FF
        sta musicTrack
.endif
@ret:   rts

; A+B+Select+Start
gameModeState_checkForResetKeyCombo:
        lda heldButtons_player1
        cmp #BUTTON_A+BUTTON_B+BUTTON_START+BUTTON_SELECT
        beq @reset
        inc gameModeState
        rts

@reset: jsr updateAudio2
        lda #$02 ; straight to menu screen
        sta gameMode
        rts

; It looks like the jsr _must_ do nothing, otherwise reg a != gameModeState in mainLoop and there would not be any waiting on vsync
gameModeState_vblankThenRunState2:
        lda #$02
        sta gameModeState
        jsr noop_disabledVramRowIncr
        rts

playState_unassignOrientationId:
        lda #$13
        sta currentPiece
        rts

playState_incrementPlayState:
        inc playState
playState_noop:
        rts

showHighScores:
        jsr bulkCopyToPpu      ;not using @-label due to MMC1_Control in PAL
MMC1_Control    := * + 1
        .addr   high_scores_nametable
        lda #$00
        sta generalCounter2
@copyEntry:
        lda generalCounter2
        and #$03
        asl a
        tax
        lda highScorePpuAddrTable,x
        sta PPUADDR
        lda generalCounter2
        and #$03
        asl a
        tax
        inx
        lda highScorePpuAddrTable,x
        sta PPUADDR
        lda generalCounter2
        asl a
        sta generalCounter
        asl a
        clc
        adc generalCounter
        tay
        ldx #$06
@copyChar:
        lda highScoreNames,y
        sty generalCounter
        tay
        lda highScoreCharToTile,y
        ldy generalCounter
        sta PPUDATA
        iny
        dex
        bne @copyChar
        lda #$FF
        sta PPUDATA
        lda generalCounter2
        sta generalCounter
        asl a
        clc
        adc generalCounter
        tay
        lda highScoreScoresA,y
        jsr twoDigsToPPU
        iny
        lda highScoreScoresA,y
        jsr twoDigsToPPU
        iny
        lda highScoreScoresA,y
        jsr twoDigsToPPU
        lda #$FF
        sta PPUDATA
        ldy generalCounter2
        lda highScoreLevels,y
        tax
        lda byteToBcdTable,x
        jsr twoDigsToPPU
        inc generalCounter2
        lda generalCounter2
        cmp #$03
        beq showHighScores_ret
        cmp #$07
        beq showHighScores_ret
        jmp @copyEntry

showHighScores_ret:  rts

highScorePpuAddrTable:
        .dbyt   $2289,$22C9,$2309
highScoreCharToTile:
        .byte   $24,$0A,$0B,$0C,$0D,$0E,$0F,$10
        .byte   $11,$12,$13,$14,$15,$16,$17,$18
        .byte   $19,$1A,$1B,$1C,$1D,$1E,$1F,$20
        .byte   $21,$22,$23,$00,$01,$02,$03,$04
        .byte   $05,$06,$07,$08,$09,$25,$4F,$5E
        .byte   $5F,$6E,$6F,$FF
levelDisplayTable:
byteToBcdTable:
        .byte   $00,$01,$02,$03,$04,$05,$06,$07
        .byte   $08,$09,$10,$11,$12,$13,$14,$15
        .byte   $16,$17,$18,$19,$20,$21,$22,$23
        .byte   $24,$25,$26,$27,$28,$29,$30,$31
        .byte   $32,$33,$34,$35,$36,$37,$38,$39
        .byte   $40,$41,$42,$43,$44,$45,$46,$47
        .byte   $48,$49,$50,$51,$52,$53,$54,$55
        .byte   $56,$57,$58,$59,$60

; Adjusts high score table and handles data entry, if necessary
handleHighScoreIfNecessary:
        lda #$00
        sta highScoreEntryRawPos
@compareWithPos:
        lda highScoreEntryRawPos
        sta generalCounter2
        asl a
        clc
        adc generalCounter2
        tay
        lda highScoreScoresA,y
        cmp score+2
        beq @checkHundredsByte
        bcs @tooSmall
        bcc adjustHighScores
@checkHundredsByte:
        iny
        lda highScoreScoresA,y
        cmp score+1
        beq @checkOnesByte
        bcs @tooSmall
        bcc adjustHighScores
; This breaks ties by prefering the new score
@checkOnesByte:
        iny
        lda highScoreScoresA,y
        cmp score
        beq adjustHighScores
        bcc adjustHighScores
@tooSmall:
        inc highScoreEntryRawPos
        lda highScoreEntryRawPos
        cmp #$03
        beq @ret
        cmp #$07
        beq @ret
        jmp @compareWithPos

@ret:   rts

adjustHighScores:
        lda highScoreEntryRawPos
        and #$03
        cmp #$02
        bpl @doneMovingOldScores
        lda #$06
        jsr copyHighScoreNameToNextIndex
        lda #$03
        jsr copyHighScoreScoreToNextIndex
        lda #$01
        jsr copyHighScoreLevelToNextIndex
        lda highScoreEntryRawPos
        and #$03
        bne @doneMovingOldScores
        lda #$00
        jsr copyHighScoreNameToNextIndex
        lda #$00
        jsr copyHighScoreScoreToNextIndex
        lda #$00
        jsr copyHighScoreLevelToNextIndex
@doneMovingOldScores:
        ldx highScoreEntryRawPos
        lda highScoreIndexToHighScoreNamesOffset,x
        tax
        ldy #$06
        lda #$00
@clearNameLetter:
        sta highScoreNames,x
        inx
        dey
        bne @clearNameLetter
        ldx highScoreEntryRawPos
        lda highScoreIndexToHighScoreScoresOffset,x
        tax
        lda score+2
        sta highScoreScoresA,x
        inx
        lda score+1
        sta highScoreScoresA,x
        inx
        lda score
        sta highScoreScoresA,x
        ldx highScoreEntryRawPos
        lda levelNumber
        sta highScoreLevels,x
        jmp highScoreEntryScreen

; reg a: start byte to copy
copyHighScoreNameToNextIndex:
        sta generalCounter
        lda #$05
        sta generalCounter2
@copyLetter:
        lda generalCounter
        clc
        adc generalCounter2
        tax
        lda highScoreNames,x
        sta generalCounter3
        txa
        clc
        adc #$06
        tax
        lda generalCounter3
        sta highScoreNames,x
        dec generalCounter2
        lda generalCounter2
        cmp #$FF
        bne @copyLetter
        rts

; reg a: start byte to copy
copyHighScoreScoreToNextIndex:
        tax
        lda highScoreScoresA,x
        sta highScoreScoresA+3,x
        inx
        lda highScoreScoresA,x
        sta highScoreScoresA+3,x
        inx
        lda highScoreScoresA,x
        sta highScoreScoresA+3,x
        rts

; reg a: start byte to copy
copyHighScoreLevelToNextIndex:
        tax
        lda highScoreLevels,x
        sta highScoreLevels+1,x
        rts

highScoreIndexToHighScoreNamesOffset:
        .byte   $00,$06,$0C,$12,$18,$1E,$24,$2A
highScoreIndexToHighScoreScoresOffset:
        .byte   $00,$03,$06,$09,$0C,$0F,$12,$15
highScoreEntryScreen:
        inc initRam
        lda #$10
        jsr setMMC1Control
        lda #$09
        jsr setMusicTrack
        lda #$02
        sta renderMode
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
        lda #$00
        jsr changeCHRBank0
        lda #$00
        jsr changeCHRBank1
        jsr bulkCopyToPpu
        .addr   menu_palette
        jsr copyRleNametableToPpu
        .addr   enter_high_score_nametable
        jsr showHighScores
        lda #$21
        sta tmp1
        lda #$89
        sta tmp2
        jsr displayModeText
        lda #$02
        sta renderMode
        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda highScoreEntryRawPos
        asl a
        sta generalCounter
        asl a
        clc
        adc generalCounter
        sta highScoreEntryNameOffsetForRow
        lda #$00
        sta highScoreEntryNameOffsetForLetter
        sta oamStaging
        lda highScoreEntryRawPos
        and #$03
        tax
        lda highScorePosToY,x
        sta spriteYOffset
@renderFrame:
        lda #$00
        sta oamStaging
        ldx highScoreEntryNameOffsetForLetter
        lda highScoreNamePosToX,x
        sta spriteXOffset
        lda #$0E
        sta spriteIndexInOamContentLookup
        lda frameCounter
        and #$03
        bne @flickerStateSelected_checkForStartPressed
        lda #$02
        sta spriteIndexInOamContentLookup
@flickerStateSelected_checkForStartPressed:
        jsr loadSpriteIntoOamStaging
        lda newlyPressedButtons_player1
        and #$10
        beq @checkForAOrRightPressed
        lda #$02
        sta soundEffectSlot1Init
        jmp @ret

@checkForAOrRightPressed:
        lda newlyPressedButtons_player1
        and #$81
        beq @checkForBOrLeftPressed
        lda #$01
        sta soundEffectSlot1Init
        inc highScoreEntryNameOffsetForLetter
        lda highScoreEntryNameOffsetForLetter
        cmp #$06
        bmi @checkForBOrLeftPressed
        lda #$00
        sta highScoreEntryNameOffsetForLetter
@checkForBOrLeftPressed:
        lda newlyPressedButtons_player1
        and #$42
        beq @checkForDownPressed
        lda #$01
        sta soundEffectSlot1Init
        dec highScoreEntryNameOffsetForLetter
        lda highScoreEntryNameOffsetForLetter
        bpl @checkForDownPressed
        lda #$05
        sta highScoreEntryNameOffsetForLetter
@checkForDownPressed:
        lda heldButtons_player1
        and #$04
        beq @checkForUpPressed
        lda frameCounter
        and #$07
        bne @checkForUpPressed
        lda #$01
        sta soundEffectSlot1Init
        lda highScoreEntryNameOffsetForRow
        sta generalCounter
        clc
        adc highScoreEntryNameOffsetForLetter
        tax
        lda highScoreNames,x
        sta generalCounter
        dec generalCounter
        lda generalCounter
        bpl @letterDoesNotUnderflow
        clc
        adc #$2C
        sta generalCounter
@letterDoesNotUnderflow:
        lda generalCounter
        sta highScoreNames,x
@checkForUpPressed:
        lda heldButtons_player1
        and #$08
        beq @waitForVBlank
        lda frameCounter
        and #$07
        bne @waitForVBlank
        lda #$01
        sta soundEffectSlot1Init
        lda highScoreEntryNameOffsetForRow
        sta generalCounter
        clc
        adc highScoreEntryNameOffsetForLetter
        tax
        lda highScoreNames,x
        sta generalCounter
        inc generalCounter
        lda generalCounter
        cmp #$2C
        bmi @letterDoesNotOverflow
        sec
        sbc #$2C
        sta generalCounter
@letterDoesNotOverflow:
        lda generalCounter
        sta highScoreNames,x
@waitForVBlank:
        lda highScoreEntryNameOffsetForRow
        clc
        adc highScoreEntryNameOffsetForLetter
        tax
        lda highScoreNames,x
        sta highScoreEntryCurrentLetter
        lda #$80
        sta outOfDateRenderFlags
        jsr updateAudioWaitForNmiAndResetOamStaging
        jmp @renderFrame

@ret:   jsr updateAudioWaitForNmiAndResetOamStaging
        rts

highScorePosToY:
        .byte   $9F,$AF,$BF
highScoreNamePosToX:
        .byte   $48,$50,$58,$60,$68,$70
render_mode_congratulations_screen:
        lda #$00
        sta PPUSCROLL
        sta PPUSCROLL

        lda outOfDateRenderFlags
        and #$80
        beq @ret
        lda highScoreEntryRawPos
        and #$03
        asl a
        tax
        lda highScorePpuAddrTable,x
        sta PPUADDR
        lda highScoreEntryRawPos
        and #$03
        asl a
        tax
        inx
        lda highScorePpuAddrTable,x
        sta generalCounter
        clc
        adc highScoreEntryNameOffsetForLetter
        sta PPUADDR
        ldx highScoreEntryCurrentLetter
        lda highScoreCharToTile,x
        sta PPUDATA
        lda #$00
        sta PPUSCROLL
        sta PPUSCROLL
        sta outOfDateRenderFlags
@ret:   rts

; Handles pausing and exiting demo
gameModeState_startButtonHandling:
        lda gameMode
        cmp #$05
        bne @checkIfInGame
        lda newlyPressedButtons_player1
        cmp #$10
        bne @checkIfInGame
        lda #$01
        sta gameMode
        jmp @ret

@checkIfInGame:
        lda renderMode
        cmp #$03
        bne @ret

        lda newlyPressedButtons_player1
        and #$10
        bne @startPressed
        jmp @ret

@startPressed:
        lda #$05
        sta musicStagingNoiseHi
        lda #$04 ; render_mode_pause
        sta renderMode
        jsr updateAudioAndWaitForNmi
        lda #$1E ; $16 for black
        sta PPUMASK
        lda #$FF
        ldx #$02
        ldy #$02
        jsr memset_page
@pauseLoop:
        lda #$74
        sta spriteXOffset
        lda #$58
        sta spriteYOffset
        ; put 3 or 5 in a
        lda debugFlag
        asl
        adc #3
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging

        jsr practiseGameHUD
        jsr debugMode
        ; debugMode calls stageSpriteForNextPiece, stageSpriteForCurrentPiece

        lda newlyPressedButtons_player1
        cmp #$10
        beq @resume
        jsr updateAudioWaitForNmiAndResetOamStaging
        jmp @pauseLoop

@resume:lda #$1E
        sta PPUMASK
        lda #$00
        sta musicStagingNoiseHi
        sta vramRow
        lda #$03
        sta renderMode
@ret:   inc gameModeState
        rts

; canon is waitForVerticalBlankingInterval
updateAudioWaitForNmiAndResetOamStaging:
        jsr updateAudio_jmp
        lda #$00
        sta verticalBlankingInterval
        nop
@checkForNmi:
        lda verticalBlankingInterval
        beq @checkForNmi
        lda #$FF
        ldx #$02
        ldy #$02
        jsr memset_page
        rts

updateAudioAndWaitForNmi:
        jsr updateAudio_jmp
        lda #$00
        sta verticalBlankingInterval
        nop
@checkForNmi:
        lda verticalBlankingInterval
        beq @checkForNmi
        rts

updateAudioWaitForNmiAndDisablePpuRendering:
        jsr updateAudioAndWaitForNmi
        lda currentPpuMask
        and #$E1
_updatePpuMask:
        sta PPUMASK
        sta currentPpuMask
        rts

updateAudioWaitForNmiAndEnablePpuRendering:
        jsr updateAudioAndWaitForNmi
        jsr copyCurrentScrollAndCtrlToPPU
        lda currentPpuMask
        ora #$1E
        bne _updatePpuMask
waitForVBlankAndEnableNmi:
        lda PPUSTATUS
        and #$80
        bne waitForVBlankAndEnableNmi
        lda currentPpuCtrl
        ora #$80
        bne _updatePpuCtrl
disableNmi:
        lda currentPpuCtrl
        and #$7F
_updatePpuCtrl:
        sta PPUCTRL
        sta currentPpuCtrl
        rts

LAA82:  ldx #$FF
        ldy #$00
        jsr memset_ppu_page_and_more
        rts

copyCurrentScrollAndCtrlToPPU:
        lda #$00
        sta PPUSCROLL
        sta PPUSCROLL
        lda currentPpuCtrl
        sta PPUCTRL
        rts

bulkCopyToPpu:
        jsr copyAddrAtReturnAddressToTmp_incrReturnAddrBy2
        jmp copyToPpu

LAA9E:  pha
        sta PPUADDR
        iny
        lda (tmp1),y
        sta PPUADDR
        iny
        lda (tmp1),y
        asl a
        pha
        lda currentPpuCtrl
        ora #$04
        bcs LAAB5
        and #$FB
LAAB5:  sta PPUCTRL
        sta currentPpuCtrl
        pla
        asl a
        php
        bcc LAAC2
        ora #$02
        iny
LAAC2:  plp
        clc
        bne LAAC7
        sec
LAAC7:  ror a
        lsr a
        tax
LAACA:  bcs LAACD
        iny
LAACD:  lda (tmp1),y
        sta PPUDATA
        dex
        bne LAACA
        pla
        cmp #$3F
        bne LAAE6
        sta PPUADDR
        stx PPUADDR
        stx PPUADDR
        stx PPUADDR
LAAE6:  sec
        tya
        adc tmp1
        sta tmp1
        lda #$00
        adc tmp2
        sta tmp2
; Address to read from stored in tmp1/2
copyToPpu:
        ldx PPUSTATUS
        ldy #$00
        lda (tmp1),y
        bpl LAAFC
        rts

LAAFC:  cmp #$60
        bne LAB0A
        pla
        sta tmp2
        pla
        sta tmp1
        ldy #$02
        bne LAAE6
LAB0A:  cmp #$4C
        bne LAA9E
        lda tmp1
        pha
        lda tmp2
        pha
        iny
        lda (tmp1),y
        tax
        iny
        lda (tmp1),y
        sta tmp2
        stx tmp1
        bcs copyToPpu
copyAddrAtReturnAddressToTmp_incrReturnAddrBy2:
        tsx
        lda stack+3,x
        sta tmpBulkCopyToPpuReturnAddr
        lda stack+4,x
        sta tmpBulkCopyToPpuReturnAddr+1
        ldy #$01
        lda (tmpBulkCopyToPpuReturnAddr),y
        sta tmp1
        iny
        lda (tmpBulkCopyToPpuReturnAddr),y
        sta tmp2
        clc
        lda #$02
        adc tmpBulkCopyToPpuReturnAddr
        sta stack+3,x
        lda #$00
        adc tmpBulkCopyToPpuReturnAddr+1
        sta stack+4,x
        rts

;reg x: zeropage addr of seed; reg y: size of seed
generateNextPseudorandomNumber:
        lda tmp1,x
        and #$02
        sta tmp1
        lda tmp2,x
        and #$02
        eor tmp1
        clc
        beq @updateNextByteInSeed
        sec
@updateNextByteInSeed:
        ror tmp1,x
        inx
        dey
        bne @updateNextByteInSeed
        rts

; canon is initializeOAM
copyOamStagingToOam:
        lda #$00
        sta OAMADDR
        lda #$02
        sta OAMDMA
        rts

pollController_actualRead:
        ldx joy1Location
        inx
        stx JOY1
        dex
        stx JOY1
        ldx #$08
@readNextBit:
        lda JOY1
        lsr a
        rol newlyPressedButtons_player1
        lsr a
        rol tmp1
        lda JOY2_APUFC
        lsr a
        rol newlyPressedButtons_player2
        lsr a
        rol tmp2
        dex
        bne @readNextBit
        rts

addExpansionPortInputAsControllerInput:
        lda tmp1
        ora newlyPressedButtons_player1
        sta newlyPressedButtons_player1
        lda tmp2
        ora newlyPressedButtons_player2
        sta newlyPressedButtons_player2
        rts

        jsr pollController_actualRead
        beq diffOldAndNewButtons
pollController:
        jsr pollController_actualRead
        jsr addExpansionPortInputAsControllerInput
        lda newlyPressedButtons_player1
        sta generalCounter2
        lda newlyPressedButtons_player2
        sta generalCounter3
        jsr pollController_actualRead
        jsr addExpansionPortInputAsControllerInput
        lda newlyPressedButtons_player1
        and generalCounter2
        sta newlyPressedButtons_player1
        lda newlyPressedButtons_player2
        and generalCounter3
        sta newlyPressedButtons_player2

        lda goofyFlag
        beq @noGoofy
        lda newlyPressedButtons_player1
        asl
        and #$AA
        sta tmp3
        lda newlyPressedButtons_player1
        and #$AA
        lsr
        ora tmp3
        sta newlyPressedButtons_player1
@noGoofy:

diffOldAndNewButtons:
        ldx #$01
@diffForPlayer:
        lda newlyPressedButtons_player1,x
        tay
        eor heldButtons_player1,x
        and newlyPressedButtons_player1,x
        sta newlyPressedButtons_player1,x
        sty heldButtons_player1,x
        dex
        bpl @diffForPlayer
        rts

memset_ppu_page_and_more:
        sta tmp1
        stx tmp2
        sty tmp3
        lda PPUSTATUS
        lda currentPpuCtrl
        and #$FB
        sta PPUCTRL
        sta currentPpuCtrl
        lda tmp1
        sta PPUADDR
        ldy #$00
        sty PPUADDR
        ldx #$04
        cmp #$20
        bcs LAC40
        ldx tmp3
LAC40:  ldy #$00
        lda tmp2
LAC44:  sta PPUDATA
        dey
        bne LAC44
        dex
        bne LAC44
        ldy tmp3
        lda tmp1
        cmp #$20
        bcc LAC67
        adc #$02
        sta PPUADDR
        lda #$C0
        sta PPUADDR
        ldx #$40
LAC61:  sty PPUDATA
        dex
        bne LAC61
LAC67:  ldx tmp2
        rts

; reg a: value; reg x: start page; reg y: end page (inclusive)
memset_page:
        pha
        txa
        sty tmp2
        clc
        sbc tmp2
        tax
        pla
        ldy #$00
        sty tmp1
@setByte:
        sta (tmp1),y
        dey
        bne @setByte
        dec tmp2
        inx
        bne @setByte
        rts

switch_s_plus_2a:
        asl a
        tay
        iny
        pla
        sta tmp1
        pla
        sta tmp2
        lda (tmp1),y
        tax
        iny
        lda (tmp1),y
        sta tmp2
        stx tmp1
        jmp (tmp1)

        sei
        inc initRam
        lda #$1A
        jsr setMMC1Control
        rts

setMMC1Control:
        sta MMC1_Control
        lsr a
        sta MMC1_Control
        lsr a
        sta MMC1_Control
        lsr a
        sta MMC1_Control
        lsr a
        sta MMC1_Control
        rts

changeCHRBank0:
        sta MMC1_CHR0
        lsr a
        sta MMC1_CHR0
        lsr a
        sta MMC1_CHR0
        lsr a
        sta MMC1_CHR0
        lsr a
        sta MMC1_CHR0
        rts

changeCHRBank1:
        sta MMC1_CHR1
        lsr a
        sta MMC1_CHR1
        lsr a
        sta MMC1_CHR1
        lsr a
        sta MMC1_CHR1
        lsr a
        sta MMC1_CHR1
        rts

changePRGBank:
        sta MMC1_PRG
        lsr a
        sta MMC1_PRG
        lsr a
        sta MMC1_PRG
        lsr a
        sta MMC1_PRG
        lsr a
        sta MMC1_PRG
        rts

game_palette:
        .byte   $3F,$00,$20,$0F,$30,$12,$16,$0F
        .byte   $20,$12,$18,$0F,$2C,$16,$29,$0F
        .byte   $3C,$00,$30,$0F,$16,$2A,$22,$0F
        .byte   $10,$16,$2D,$0F,$2C,$16,$29,$0F
        .byte   $3C,$00,$30,$FF
title_palette:
        .byte   $3F,$00,$14,$0F,$3C,$38,$00,$0F
        .byte   $17,$27,$37,$0F,$30,$12,$00,$0F
        .byte   $22,$2A,$28,$0F,$30,$29,$27,$FF
menu_palette:
        .byte   $3F,$00,$14,$0F,$30,$38,$26,$0F
        .byte   $17,$27,$37,$0F,$30,$12,$00,$0F
        .byte   $16,$2A,$28,$0F,$30,$26,$27,$FF
defaultHighScoresTable:
        .byte   $2B,$2B,$2B,$2B,$2B,$2B ; HOWARD
        .byte   $2B,$2B,$2B,$2B,$2B,$2B ; OTASAN
        .byte   $2B,$2B,$2B,$2B,$2B,$2B ; LANCE
        .byte   $00,$00,$00,$00,$00,$00 ;unknown
        .byte   $2B,$2B,$2B,$2B,$2B,$2B ; ALEX
        .byte   $2B,$2B,$2B,$2B,$2B,$2B ; TONY
        .byte   $2B,$2B,$2B,$2B,$2B,$2B ; NINTEN
        .byte   $00,$00,$00,$00,$00,$00 ;unknown
        ;High Scores are stored in BCD
        .byte   $00,$00,$00
        .byte   $00,$00,$00
        .byte   $00,$00,$00
        .byte   $00,$00,$00 ;unknown
        .byte   $00,$20,$00 ;Game B 1st Entry Score, 2000
        .byte   $00,$10,$00 ;Game B 2nd Entry Score, 1000
        .byte   $00,$05,$00 ;Game B 3rd Entry Score, 500
        .byte   $00,$00,$00 ;unknown
        .byte   $00 ;Game A 1st Entry Level
        .byte   $00 ;Game A 2nd Entry Level
        .byte   $00 ;Game A 3nd Entry Level
        .byte   $00 ;unknown
        .byte   $09 ;Game B 1st Entry Level
        .byte   $05 ;Game B 2nd Entry Level
        .byte   $00 ;Game B 3rd Entry Level
        .byte   $00 ;unknown
        .byte   $FF
game_type_menu_nametable: ; RLE
        .incbin "gfx/nametables/game_type_menu_nametable_practise.bin"
game_type_menu_nametable_extra: ; RLE
        .incbin "gfx/nametables/game_type_menu_nametable_extra.bin"
level_menu_nametable: ; RLE
        .incbin "gfx/nametables/level_menu_nametable_practise.bin"
game_nametable: ; RLE
        .incbin "gfx/nametables/game_nametable_practise.bin"
enter_high_score_nametable: ; RLE
        .incbin "gfx/nametables/enter_high_score_nametable_practise.bin"
high_scores_nametable:
        .incbin "gfx/nametables/high_scores_nametable.bin"

.include "gfx/nametables/rle.asm"

.include "presets/presets.asm"

SLOT_SIZE := $100 ; ~$CC used, the rest free

; some repeated code here, dynamic 16 bit addressing is hard
; could replace it with code executed / modified in RAM

saveslots:
        .addr saveslot0
        .addr saveslot1
        .addr saveslot2
        .addr saveslot3
        .addr saveslot4
        .addr saveslot5
        .addr saveslot6
        .addr saveslot7
        .addr saveslot8
        .addr saveslot9
saveslot0:
        sta SRAM,y
        rts
saveslot1:
        sta SRAM+SLOT_SIZE,y
        rts
saveslot2:
        sta SRAM+(SLOT_SIZE*2),y
        rts
saveslot3:
        sta SRAM+(SLOT_SIZE*3),y
        rts
saveslot4:
        sta SRAM+(SLOT_SIZE*4),y
        rts
saveslot5:
        sta SRAM+(SLOT_SIZE*5),y
        rts
saveslot6:
        sta SRAM+(SLOT_SIZE*6),y
        rts
saveslot7:
        sta SRAM+(SLOT_SIZE*7),y
        rts
saveslot8:
        sta SRAM+(SLOT_SIZE*8),y
        rts
saveslot9:
        sta SRAM+(SLOT_SIZE*9),y
        rts

saveSlot:
        sta tmp3 ; save a copy of A
        lda saveStateSlot
        asl
        tax
        lda saveslots,x
        sta tmp1
        lda saveslots+1,x
        sta tmp1+1
        lda tmp3 ; restore it
        jmp (tmp1)

saveState:
        ldy #0
@copy:
        lda playfield,y
        jsr saveSlot
        iny
        cpy #$c8
        bcc @copy

        lda tetriminoX
        jsr saveSlot
        iny
        lda tetriminoY
        jsr saveSlot
        iny
        lda currentPiece
        jsr saveSlot
        iny
        lda nextPiece
        jsr saveSlot

        ; level/lines/score
        ; iny
        ; lda levelNumber
        ; jsr saveSlot
        ; iny
        ; lda lines
        ; jsr saveSlot
        ; iny
        ; lda score
        ; jsr saveSlot
        ; iny
        ; lda score+1
        ; jsr saveSlot
        ; iny
        ; lda score+2
        ; jsr saveSlot


        lda #$17
        sta saveStateSpriteType
        lda #$20
        sta saveStateSpriteDelay
        rts

loadslots:
        .addr loadslot0
        .addr loadslot1
        .addr loadslot2
        .addr loadslot3
        .addr loadslot4
        .addr loadslot5
        .addr loadslot6
        .addr loadslot7
        .addr loadslot8
        .addr loadslot9
loadslot0:
        lda SRAM,y
        rts
loadslot1:
        lda SRAM+SLOT_SIZE,y
        rts
loadslot2:
        lda SRAM+(SLOT_SIZE*2),y
        rts
loadslot3:
        lda SRAM+(SLOT_SIZE*3),y
        rts
loadslot4:
        lda SRAM+(SLOT_SIZE*4),y
        rts
loadslot5:
        lda SRAM+(SLOT_SIZE*5),y
        rts
loadslot6:
        lda SRAM+(SLOT_SIZE*6),y
        rts
loadslot7:
        lda SRAM+(SLOT_SIZE*7),y
        rts
loadslot8:
        lda SRAM+(SLOT_SIZE*8),y
        rts
loadslot9:
        lda SRAM+(SLOT_SIZE*9),y
        rts

loadSlot:
        lda saveStateSlot
        asl
        tax
        lda loadslots,x
        sta tmp1
        lda loadslots+1,x
        sta tmp1+1
        jmp (tmp1)

loadState:
        ldy #0
@copy:
        jsr loadSlot
        sta playfield,y
        iny
        cpy #$c8
        bcc @copy

        jsr loadSlot
        sta tetriminoX
        iny
        jsr loadSlot
        sta tetriminoY
        iny
        jsr loadSlot
        sta currentPiece
        iny
        jsr loadSlot
        sta nextPiece

        ; level/lines/score
        ; iny
        ; jsr loadSlot
        ; sta levelNumber
        ; iny
        ; jsr loadSlot
        ; sta lines
        ; iny
        ; jsr loadSlot
        ; sta score
        ; iny
        ; jsr loadSlot
        ; sta score+1
        ; iny
        ; jsr loadSlot
        ; sta score+2
        ; ; mark for update
        ; lda #7
        ; sta outOfDateRenderFlags

        lda #$18
        sta saveStateSpriteType
        lda #$20
        sta saveStateSpriteDelay
@done:
        rts

renderStateGameplay:
        lda #$03
        sta playState
        lda #1
        sta saveStateDirty ; cleared in game init
        lda #$20
        sta spawnDelay
        lda #$00
        sta tetriminoY
        lda #$05
        sta tetriminoX
        rts

renderStateDebug:
        jsr renderDebugPlayfield
        rts

checkDebugGameplay:
        lda debugFlag
        cmp #0
        beq @done

        ; sprite
        jsr renderDebugHUD

        ; controls
        lda heldButtons_player1
        and #BUTTON_SELECT
        beq @done

        lda newlyPressedButtons_player1
        and #BUTTON_B
        beq @done
        ldy #0
        jsr loadSlot ; check slot is empty
        beq @done
        jsr loadState
        jsr renderStateGameplay
        jmp @done
@done:
        rts

checkSaveStateControlsDebug:
        ; load / save
        lda newlyPressedButtons_player1
        and #BUTTON_B
        beq @notPressedB
        ldy #0
        jsr loadSlot ; check slot is empty
        beq @notPressedB
        jsr loadState
        jsr renderStateDebug
@notPressedB:
        lda newlyPressedButtons_player1
        and #BUTTON_A
        beq @notPressedA
        jsr saveState
@notPressedA:
        ; save slot
        lda newlyPressedButtons_player1
        and #BUTTON_UP
        beq @notPressedUp
        jsr renderDebugSaveSlot
        inc saveStateSlot
        lda saveStateSlot
        cmp #$A
        bne @notPressedUp
        lda #0
        sta saveStateSlot
@notPressedUp:
        lda newlyPressedButtons_player1
        and #BUTTON_DOWN
        beq @notPressedDown
        lda saveStateSlot
        bne @noWrap
        lda #$A
        sta saveStateSlot
@noWrap:
        dec saveStateSlot
        jsr renderDebugSaveSlot
@notPressedDown:
        rts

renderDebugSaveSlot:
        lda pausedOutOfDateRenderFlags
        ora #$2
        sta pausedOutOfDateRenderFlags
        rts

renderDebugHUD:
        ; savestates
        lda saveStateSpriteDelay
        beq @noSprite
        dec saveStateSpriteDelay
        lda #$C0
        sta spriteXOffset
        lda #$C8
        sta spriteYOffset
        lda saveStateSpriteType
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging
@noSprite:
        rts

controllerInputTiles:
        ; .byte "RLDUSSBA"
        .byte $D0, $D1, $D2, $D3
        .byte $D4, $D4, $D5, $D5
controllerInputX:
        .byte $8, $0, $5, $4
        .byte $1D, $14, $27, $30
controllerInputY:
        .byte $FF, $0, $5, $FB
        .byte $0, $0, $FF, $FF

renderDebugPlayfield:
        lda #$00
        sta vramRow
        rts

.if DEBUG_MODE

debugSelectMenuControls:
        lda heldButtons_player1
        and #BUTTON_SELECT
        beq debugContinue

        lda newlyPressedButtons_player1
        and #BUTTON_LEFT+BUTTON_RIGHT
        beq @skipDebugType
        ; toggle mode
        lda debugLevelEdit
        eor #1
        sta debugLevelEdit
@skipDebugType:

        jsr checkSaveStateControlsDebug

        ; fallthrough

debugDrawPieces:
        jsr renderDebugHUD

        ; handle pieces / X
        jsr stageSpriteForNextPiece

        lda debugLevelEdit
        and #1
        bne @handleX
        jsr stageSpriteForCurrentPiece
        rts

@handleX:
        ; load X
        lda tetriminoX
        asl
        asl
        asl
        clc
        adc #$60
        sta spriteXOffset

        ; load Y
        lda tetriminoY
        asl
        asl
        asl
        clc
        adc #$2F
        sta spriteYOffset

        lda #$16
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging
        rts

pauseDrawPieces:
        jsr stageSpriteForNextPiece
        jsr stageSpriteForCurrentPiece
        rts

debugMode:

DEBUG_ORIGINAL_Y := tmp1
DEBUG_ORIGINAL_CURRENT_PIECE := tmp2

        lda debugFlag
        cmp #0
        beq pauseDrawPieces

        jmp debugSelectMenuControls
debugContinue:
        lda tetriminoX
        sta originalY
        lda tetriminoY
        sta DEBUG_ORIGINAL_Y
        lda currentPiece
        sta DEBUG_ORIGINAL_CURRENT_PIECE

        ; update position
        lda #BUTTON_UP
        jsr menuThrottle
        beq @notPressedUp
        dec tetriminoY
@notPressedUp:
        lda #BUTTON_DOWN
        jsr menuThrottle
        beq @notPressedDown
        inc tetriminoY
@notPressedDown:
        lda #BUTTON_LEFT
        jsr menuThrottle
        beq @notPressedLeft
        dec tetriminoX
@notPressedLeft:
        lda #BUTTON_RIGHT
        jsr menuThrottle
        beq @notPressedRight
        inc tetriminoX
@notPressedRight:

        ; check mode
        lda debugLevelEdit
        and #1
        bne handleLevelEditor

        ; handle next piece
        lda heldButtons_player1
        and #BUTTON_B
        beq @notPressedBothB
        lda newlyPressedButtons_player1
        and #BUTTON_A
        beq @notPressedBothB
        jmp @changeNext
@notPressedBothB:
        lda heldButtons_player1
        and #BUTTON_A
        beq @notPressedBothA
        lda newlyPressedButtons_player1
        and #BUTTON_B
        beq @notPressedBothA
        jmp @changeNext
@notPressedBothA:

        ; change current piece
        lda newlyPressedButtons_player1
        and #BUTTON_B
        beq @notPressedB
        lda currentPiece
        cmp #$1
        bmi @notPressedB
        dec currentPiece
@notPressedB:

        lda newlyPressedButtons_player1
        and #BUTTON_A
        beq @notPressedA
        lda currentPiece
        cmp #$12
        bpl @notPressedA
        inc currentPiece
@notPressedA:

        ; handle piece
        jsr isPositionValid
        bne @restore_
        jmp debugDrawPieces

@restore_:
        lda originalY
        sta tetriminoX
        lda DEBUG_ORIGINAL_Y
        sta tetriminoY
        lda DEBUG_ORIGINAL_CURRENT_PIECE
        sta currentPiece
        jmp debugDrawPieces

@changeNext:
        lda debugNextCounter
        and #7
        cmp #7
        bne @notDupe
        inc debugNextCounter
@notDupe:
        tax
        lda spawnTable,x
        sta nextPiece

        inc debugNextCounter
        jmp debugDrawPieces


handleLevelEditor:
        jsr debugDrawPieces

        ; handle editing

        lda newlyPressedButtons_player1
        and #BUTTON_B
        beq @notPressedB
        jsr @getPos
        ldx tmp3
        lda #$EF
        sta playfield, x
        jmp renderDebugPlayfield

@notPressedB:

        lda newlyPressedButtons_player1
        and #BUTTON_A
        beq @notPressedA
        jsr @getPos
        ldx tmp3
        lda #$7B
        sta playfield, x
        jmp renderDebugPlayfield

@notPressedA:

        rts

@getPos:
        ; multiply by 10
        ldx tetriminoY
        lda multBy10Table,x

        ; add X
        adc tetriminoX
        sta tmp3
        dec tmp3
        rts

.endif

; pace = score - ((target / 230) * lines)
; target = lines <= 110 ? 4000 : 4000 + ((lines - 110) / (230 - 110)) * 348

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
        sta paceRAM
        sta paceRAM+1
        sta paceRAM+2
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

        ; convert score to binary
        lda score
        sta bcd32
        lda score+1
        sta bcd32+1
        lda score+2
        sta bcd32+2
        lda #0
        sta bcd32+3

        ; normalise score base to BCD
        lda bcd32+2
        cmp #$A0
        bcc @noverflow
        sbc #$A0
        sta bcd32+2
        lda #$1
        sta bcd32+3
@noverflow:
        jsr BCD_BIN

        ; score in binary32, target in product24

        ; do subtraction
        sec
        lda binary32
        sbc product24
        sta binaryTemp
        lda binary32+1
        sbc product24+1
        sta binaryTemp+1
        lda binary32+2
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
        sta byteSpriteXOffset
        lda #$27
        sta byteSpriteYOffset
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

; hz stuff

; hz = 60.098 * (taps - 1) / (frames - 1)
; PAL is 50.006
;
; HydrantDude explains how and why the formula works here: https://discord.com/channels/374368504465457153/405470199400235013/867156217259884574

hzDebounceThreshold := $10

hzStart: ; called in playState_spawnNextTetrimino, gameModeState_initGameState, gameMode_gameTypeMenu
        lda #0
        sta hzTapCounter
        lda #hzDebounceThreshold
        sta hzDebounceCounter
        ; frame counter is reset on first tap
        rts

hzControl: ; called in playState_playerControlsActiveTetrimino, gameTypeLoopContinue
        lda hzTapCounter
        beq @notTapping
        ; tick frame counter
        lda hzFrameCounter
        clc
        adc #$01
        sta hzFrameCounter
        lda #$00
        adc hzFrameCounter+1
        sta hzFrameCounter+1
@notTapping:

        ; tick debounce counter
        lda hzDebounceCounter
        cmp #hzDebounceThreshold
        beq @elapsed
        inc hzDebounceCounter
@elapsed:

        ; detect inputs
        lda newlyPressedButtons_player1
        and #BUTTON_LEFT
        bne hzTap
        lda newlyPressedButtons_player1
        and #BUTTON_RIGHT
        bne hzTap
        rts

hzTap:
        tax ; button direction
        dex ; normalize to 1/0
        cpx hzTapDirection
        bne @fresh
        ; if debouncing meets threshold, this is a fresh tap
        lda hzDebounceCounter
        cmp #hzDebounceThreshold
        bne @within
@fresh:
        stx hzTapDirection
        lda #0
        sta hzTapCounter
        sta hzFrameCounter+1
        ; 0 is the first frame (4 means 5 frames)
        sta hzFrameCounter
@within:

        ; increment taps, reset debounce
        inc hzTapCounter
        lda #0
        sta hzDebounceCounter

        ; ignore 1 tap
        lda hzTapCounter
        cmp #2
        bcc @calcEnd

        lda #$7A
        sta factorB24
        lda #$17
        sta factorB24+1
        lda #0
        sta factorA24+1
        sta factorA24+2
        sta factorB24+2

        lda hzTapCounter
        sbc #1
        sta factorA24

        lda palFlag
        beq @notPAL
        lda #$89
        sta factorB24
        lda #$13
        sta factorB24+1
@notPAL:

        jsr unsigned_mul24

        ; taps-1 * 6010 now in product24

        lda product24
        sta dividend
        lda product24+1
        sta dividend+1
        lda product24+2
        sta dividend+2

        ; then divide by the hzFrameCounter, which should be frames-1

        lda hzFrameCounter
        sta divisor
        lda hzFrameCounter+1
        sta divisor+1
        lda #0
        sta divisor+2

        jsr unsigned_div24 ; hz*100 in dividend

        lda dividend
        sta binary32
        lda dividend+1
        sta binary32+1
        lda dividend+2
        sta binary32+2
        lda #0
        sta binary32+3

        jsr BIN_BCD ; hz*100 as BCD in bcd32

        lda bcd32
        sta hzResult+1
        lda bcd32+1
        sta hzResult

@calcEnd:

        ; update game UI
        lda outOfDateRenderFlags
        ora #$10 ; @renderHz
        sta outOfDateRenderFlags
        rts

; math routines

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


; End of "PRG_chunk1" segment
.code

.segment    "PRG_chunk2": absolute

.include "data/demo_data.asm"

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
        lda #$E1
        sta AUDIOTMP4
        ldy #$00
@copyByte:
        lda (AUDIOTMP3),y
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
        ldy #$E0
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
        lda #$E0
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

unreferenced_data3:
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $03,$7F,$0F,$C0
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
        lda #$45
        ldy #$45
        bne updateSoundEffectSlotShared
updateSoundEffectSlot3:
        ldx #$03
        lda #$3D
        ldy #$41
        bne updateSoundEffectSlotShared
updateSoundEffectSlot4_unused:
        ldx #$04
        lda #$45
        ldy #$45
        bne updateSoundEffectSlotShared
updateSoundEffectSlot1:
        lda soundEffectSlot4Playing
        bne updateSoundEffectSlotShared_rts
        ldx #$01
        lda #$15
        ldy #$29
        bne updateSoundEffectSlotShared
updateSoundEffectSlot0:
        ldx #$00
        lda #$09
        ldy #$0F
; x: sound effect slot; a: low byte addr, for $E0 high byte; y: low byte addr, for $E0 high byte, if slot unused
updateSoundEffectSlotShared:
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
        sta $0683
        rts

LE1EF:  lda audioInitialized
        beq initAudioAndMarkInited
        lda $0683
        cmp #$12
        beq LE215
        and #$03
        cmp #$03
        bne LE212
        inc $068B
        ldy #$10
        lda $068B
        and #$01
        bne LE20F
        ldy #$0C
LE20F:  jsr copyToSq1Channel
LE212:  inc $0683
LE215:  rts

; Disables APU frame interrupt
updateAudio:
        lda #$C0
        sta JOY2_APUFC
        lda musicStagingNoiseHi
        cmp #$05
        beq LE1EF
        lda #$00
        sta audioInitialized
        sta $068B
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
        ldy #$08
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
        ldy #$04
        jmp initSoundEffectShared

updateSoundEffectSlot0_apu:
        jsr advanceAudioSlotFrame
        bne updateSoundEffectNoiseAudio
        jmp stopSoundEffectSlot0

updateSoundEffectNoiseAudio:
        ldx #$54
        jsr loadNoiseLo
        ldx #$74
        jsr getSoundEffectNoiseNibble
        ora #$10
        sta NOISE_VOL
        inc soundEffectSlot0SecondaryCounter
        rts

; Loads from noiselo_table(x=$54)/noisevol_table(x=$74)
getSoundEffectNoiseNibble:
        stx AUDIOTMP1
        ldy #$E1
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
        sta SQ1_VOL
        inc soundEffectSlot1SecondaryCounter
        lda soundEffectSlot1SecondaryCounter
        cmp #$08
        bne soundEffectSlot1Playing_ret
        inc soundEffectSlot1TertiaryCounter
        ldy #$40
        jmp copyToSq1Channel

; Unused.
soundEffectSlot1_chirpChirpInit:
        ldy #$3C
        jmp initSoundEffectShared

soundEffectSlot1_lockTetriminoInit:
        jsr LE33B
        beq soundEffectSlot1Playing_ret
        lda #$0F
        ldy #$20
        jmp initSoundEffectShared

soundEffectSlot1_shiftTetriminoInit:
        jsr LE33B
        beq soundEffectSlot1Playing_ret
        lda #$02
        ldy #$44
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

@stage2:ldy #$28
        jmp copyToSq1Channel

soundEffectSlot1_menuOptionSelectInit:
        lda #$03
        ldy #$24
        bne LE417
soundEffectSlot1_rotateTetrimino_ret:
        rts

soundEffectSlot1_rotateTetriminoInit:
        jsr LE33B
        beq soundEffectSlot1_rotateTetrimino_ret
        lda #$04
        ldy #$14
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

@stage2:ldy #$14
        jmp copyToSq1Channel

; On first glance it appears this is used twice, but the first beq does nothing because the inc result will never be 0
@stage3:ldy #$18
        jmp copyToSq1Channel

soundEffectSlot1_tetrisAchievedInit:
        lda #$05
        ldy palFlag
        cpy #0
        beq @ntsc
        lda #$4
@ntsc:
        ldy #$30
        jsr LE417
        lda #$10
        bne LE437
soundEffectSlot1_tetrisAchievedPlaying:
        jsr advanceAudioSlotFrame
        bne LE43A
        ldy #$30
        bne LE442
LE417:  jmp initSoundEffectShared

soundEffectSlot1_lineCompletedInit:
        lda #$05
        ldy palFlag
        cpy #0
        beq @ntsc
        lda #$4
@ntsc:
        ldy #$34
        jsr LE417
        lda #$08
        bne LE437
soundEffectSlot1_lineCompletedPlaying:
        jsr advanceAudioSlotFrame
        bne LE43A
        ldy #$34
        bne LE442
soundEffectSlot1_lineClearingInit:
        lda #$04
        ldy palFlag
        cpy #0
        beq @ntsc
        lda #$3
@ntsc:
        ldy #$38
        jsr LE417
        lda #$00
LE437:  sta soundEffectSlot1TertiaryCounter
LE43A:  rts

soundEffectSlot1_lineClearingPlaying:
        jsr advanceAudioSlotFrame
        bne LE43A
        ldy #$38
LE442:  jsr copyToSq1Channel
        clc
        lda soundEffectSlot1TertiaryCounter
        adc soundEffectSlot1SecondaryCounter
        tay
        lda unknown1_table,y
        sta SQ1_LO
        ldy soundEffectSlot1SecondaryCounter
        lda sq1vol_unknown2_table,y
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
        ldy #$2C
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
        cpy #0
        beq @ntsc
        lda #$5
@ntsc:
        ldy #$1C
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
        ldy #$4C
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
        ldy #$48
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
        cmp #$FF
        beq updateMusic_noSoundJmp
        cmp #$00
        beq @checkIfAlreadyPlaying
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
        cmp #$00
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

musicChanVolControlTable:
noteToWaveTable:
noteDurationTable:
musicDataTableIndex:
musicDataTable:

.if PRACTISE_MODE

practiseRowCompletePatch:
        lda practiseType
        cmp #MODE_TSPINS
        beq @skipCheck

        lda practiseType
        cmp #MODE_FLOOR
        bne @normal

        ; floor patch stuff
        stx tmp3 ; store X

        ldx floorModifier
        cpx #0
        beq @normal
        lda multBy10Table, x
        sta tmp1
        ; $4c8 = last playfield byte
        lda #$c8
        sbc tmp1
        sta tmp1

        ldx tmp3 ; restore X

        cpy tmp1
        bpl @skipCheck

@normal: ; normal behaviour
        lda (playfieldAddr),y ; patched command
        cmp #$EF ; patched command
        rts

@skipCheck:
        ; jump to @rowNotComplete
        lda #$EF
        cmp #$EF
        rts

practisePrepareNext:
        lda practiseType
        cmp #MODE_PACE
        bne @skipPace
        jsr prepareNextPace
@skipPace:
        lda practiseType
        cmp #MODE_GARBAGE
        bne @skipGarbo
        jsr prepareNextGarbage
@skipGarbo:
        lda practiseType
        cmp #MODE_PARITY
        bne @skipParity
        jsr prepareNextParity
@skipParity:
        rts

practiseAdvanceGame:
        lda practiseType
        cmp #MODE_TSPINS
        bne @skipTSpins
        jsr advanceGameTSpins
@skipTSpins:
        lda practiseType
        cmp #MODE_PRESETS
        bne @skipPresets
        jsr advanceGamePreset
@skipPresets:
        lda practiseType
        cmp #MODE_FLOOR
        bne @skipFloor
        jsr advanceGameFloor
@skipFloor:
        lda practiseType
        cmp #MODE_TAP
        bne @skipTap
        jsr advanceGameTap
@skipTap:
        rts

practiseGameHUD:
        jsr controllerInputDisplay

        lda practiseType
        cmp #MODE_PACE
        bne @skipPace
        jsr gameHUDPace
@skipPace:
        rts

controllerInputDisplay:
        lda inputDisplayFlag
        beq @noInput
        lda heldButtons_player1
        sta tmp1
        ldy #0
@inputLoop:
        lda tmp1
        and #1
        beq @inputContinue
        ldx oamStagingLength
        lda controllerInputY, y
        adc #$4C
        sta oamStaging, x
        inx
        lda controllerInputTiles, y
        sta oamStaging, x
        inx
        lda #$01
        sta oamStaging, x
        inx
        lda controllerInputX, y
        adc #$13
        sta oamStaging, x
        inx
        ; increase OAM index
        lda #$04
        clc
        adc oamStagingLength
        sta oamStagingLength
@inputContinue:
        lda tmp1
        ror
        sta tmp1
        iny
        cpy #8
        bmi @inputLoop
@noInput:
        rts


clearPlayfield:
        lda #$EF
        ldx #$C8
@loop:
        sta $0400, x
        dex
        bne @loop
        rts

advanceGamePreset:
        jsr clearPlayfield
        ; render layout
        ldx #0
        stx generalCounter
@drawNext:
        ; get layout offset
        ldy presetModifier
        lda presets, y

        ; add index
        adc generalCounter

        ; load byte from layout
        tax
        ldy presets, x

        ; check if finished
        cpy #$FF
        beq @skip

        ; draw from y
        lda #$7B
        sta $0400, y

        ; loop
        inc generalCounter
        jmp @drawNext
@skip:
        rts


advanceGameTSpins:
        ; track the tspin quantity on the first tspin attempt
        lda tspinQuantity
        bne @qtyEnd
        lda tetriminoX
        cmp #$EF
        beq @qtyEnd
        lda statsByType
        sta tspinQuantity
@qtyEnd:
        ; reset score if tspinQuantity doesnt match
        lda score
        bne @scrub
        lda score+1
        bne @scrub
        lda score+2
        bne @scrub
        jmp @continue
@scrub:
        lda tspinQuantity
        beq @continue
        cmp statsByType
        beq @continue

        ; reset score
        lda #0
        sta score
        sta score+1
        sta score+2

        lda outOfDateRenderFlags
        ora #$04
        sta outOfDateRenderFlags
@continue:

advanceGameTSpins_actual:
        ; see if the sprite has reached the right position
        lda #8
        sbc tspinX
        cmp tetriminoX
        bne @notSuccessful
        lda #18
        sbc tspinY
        cmp tetriminoY
        bne @notSuccessful
        ; check the orientation
        lda currentPiece
        cmp #2
        bne @notSuccessful

        ; set successful tspin vars
        lda #$3
        sta playState
        lda #0
        sta tspinX
        sta vramRow ; shorter to do it here than in rendering

        ; add score
        lda #$2
        sta completedLines
        jsr addLineClearPoints
        dec playState

        ; TODO: copy score to top
        lda #$20
        sta spawnDelay
        lda #$EF ; magic number in stageSpriteForCurrentPiece
        sta tetriminoX

@notSuccessful:
        ; check if a tspin is setup
        lda tspinX
        cmp #0
        bne renderTSpin

generateNewTSpin:
        ldx #rng_seed
        ldy #$2
        jsr generateNextPseudorandomNumber
        lda rng_seed
        tax
        ; lower nybble
        and #$7
        sta tspinX
        ; high nybbleish
        txa
        ror
        ror
        ror
        ror
        and #3
        sta tspinY
        ; some other bit
        txa
        and #1
        sta tspinType

        lda #0
        sta tspinQuantity

renderTSpin:
        jsr clearPlayfield

        lda tspinY
        adc #1
        jsr drawFloor

        ; get tspin offset
        ldx tspinY
        lda multBy10Table, x
        sta tmp1

        lda #$FF
        sbc tspinX ; sub X
        sbc tmp1 ; sub Y
        tax
        ; draw tspin
        lda #$EF
        sta $03bc, x
        sta $03bd, x
        sta $03be, x
        sta $03c7, x
        sta $03b3, x
        ldy tspinType
        cpy #0
        bne @noInc
        inx
        inx
@noInc:
        sta $03b2, x

        rts

advanceGameFloor:
        lda floorModifier
drawFloor:
        ; get correct offset
        sta tmp1
        lda #$D
        sbc tmp1
        tax
        ; x10
        lda multBy10Table, x
        tax
        ; tile to draw is $7B
        lda #$7B
@loop:
        sta $0446,X
        inx
        cpx #$82
        bmi @loop
@skip:
        rts

advanceGameTap:
        jsr clearPlayfield
        ldx tapModifier
        cpx #0
        beq @skip ; skip if zero
        ldy #$BF ; left side
        cpx #$11
        bmi @loop
        ldy #$C6 ; right side
        txa
        sbc #$10
        tax

@loop:
        lda #$7B
        sta $400, y
        ; add 10 to y
        tya
        sec ;important
        sbc #$A
        tay
        dex
        bne @loop
@skip:
        rts

prepareNextParity:
        ; stacking highlights

        ; 1 red 1+ white
        ;   skip the first one
        ; 1 gap inbetween make the others red
        ; gap between wall and stack (left only)
        ; overhangs

        ldx #$7C
        lda levelNumber
        cmp #19
        bne @altColor
        inx
@altColor:
        stx parityColor

        ; change everything to 7B
        ldx #$C8
        lda #$7B
@loop:
        ldy playfield, x
        cpy #$EF
        beq @empty
        sta playfield, x
@empty:
        dex
        bne @loop

        ; mark things with parityColor

        lda #190
        sta parityIndex
@runLine:
        jsr highlightParity
        lda parityIndex
        sec
        sbc #10
        sta parityIndex
        cmp #30
        bcs @runLine
        rts

highlightParity:
        jsr highlightOrphans
        jsr highlightGaps
        rts

highlightGaps:
        ldx parityIndex

highlistGapsLeft:
        ; check first gap
        lda playfield, x
        cmp #$EF
        bne @startGapEnd
        lda playfield+1, x
        cmp #$EF
        beq @startGapEnd
        lda parityColor
        sta playfield+1, x
@startGapEnd:

highlightGapsOverhang:
        ldy #10

@checkHang:
        lda playfield, x
        cmp #$EF
        bne @checkGroup
        lda playfield-10, x
        cmp #$EF
        beq @checkGroup

        ; draw in red
        lda parityColor
        sta playfield-10, x

@checkGroup:
        cpy #3 ; you want the first 8
        bmi @groupNext
        ; horizontal
        lda playfield, x
        cmp #$EF
        beq @groupNext
        lda playfield+1, x
        cmp #$EF
        bne @groupNext
        lda playfield+2, x
        cmp #$EF
        beq @groupNext

        ; draw in red
        lda parityColor
        sta playfield, x
        sta playfield+2, x

@groupNext:
        inx
        dey
        bne @checkHang

        rts

highlightOrphans:
        ldx parityIndex
        ; reset stuff
        lda #0
        sta parityCount
        ldy #10

@checkString:
        lda playfield, x
        cmp #$EF
        beq @stringEmpty
        inc parityCount
        jmp @stringNext
@stringEmpty:
        lda parityCount
        cmp #1
        bne @resetCount
        ; dont highlight the first one
        cpy #9
        beq @resetCount
        ; last is skipped anyway
        lda parityColor
        sta playfield-1, x

@resetCount:
        lda #0
        sta parityCount
        jmp @stringNext

@stringNext:
        inx
        dey
        bne @checkString
        rts


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
        cmp #$EF
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
        ldy #$ef
        lda playfield, x
        cmp #$ef
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
        cmp #$EF
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
        cmp #0
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
        cmp #$EF
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

random10:
        ldx #rng_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        lda rng_seed
        and #$0F
        cmp #$0A
        bpl random10
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
        cmp #$EF
        bne @filled
        inc tmp1 ; add garbage
        ldy #1
@filled:
        inx
        dey
        bne @loop
        rts

.endif


; End of "PRG_chunk2" segment
.code


.segment    "PRG_chunk3": absolute

; incremented to reset MMC1 reg
reset:  cld
        sei
        ldx #$00
        stx PPUCTRL
        stx PPUMASK
@vsyncWait1:
        lda PPUSTATUS
        bpl @vsyncWait1
@vsyncWait2:
        lda PPUSTATUS
        bpl @vsyncWait2
        dex
        txs
        inc reset
        lda #$10
        jsr setMMC1Control
        lda #$00
        jsr changeCHRBank0
        lda #$00
        jsr changeCHRBank1
        lda #$00
        jsr changePRGBank
        jmp initRam

.include "data/unreferenced_data5.asm"
MMC1_PRG:
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00
        .byte   $00

; End of "PRG_chunk3" segment
.code


.segment    "VECTORS": absolute

        .addr   nmi
        .addr   reset
LFFFF       := * + 1
        .addr   irq

; End of "VECTORS" segment
.code
