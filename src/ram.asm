.zeropage
tmp1: .res 1
tmp2: .res 1
tmp3: .res 1
tmpX: .res 1 ;  $0003
tmpY: .res 1 ;  $0004
tmpZ: .res 1 ;  $0005

.res 2
binScore: .res 4 ;  $8 ; 4 bytes binary
score: .res 4 ;  $C ; 4 bytes BCD
nmiReturnAddr: .res 1 ; $0010 ; used for crash
crashState: .res 1 ; $0011 ; used for crash
cycleCount: .res 2 ; $0012 ; 2 bytes ; used for crash
oneThirdPRNG: .res 1 ; $0014 ; used for crash
b_seed: .res 2 ; loaded with rng_seed unless seeded

rng_seed: .res 2 ; $0017
rng_seed_hi:= rng_seed + 1
spawnID: .res 1 ; $0019
spawnCount: .res 1 ; $001A
pointerAddr: .res 2 ; $001B ; used in debug, harddrop
pointerAddrB: .res 2 ; $001D ; used in harddrop
allegroIndex: .res 1 ; $001F for crash
wasAllegro: .res 1 ; $0020 for crash
startParity: .res 1 ; $0021 for crash
lagState: .res 1 ; $0022 for lagged lines & score
    .res $F

.res 1 ; $0032
verticalBlankingInterval: .res 1 ; $0033
set_seed: .res 3 ; $0034 ; rng_seed, rng_seed+1, spawnCount
patchPtr: .res 2
.res 1
.res 4
renderQueueLength: .res 1
renderQueuePointer: .res 1
tetriminoX: .res 1 ; $0040
tetriminoY: .res 1 ; $0041
currentPiece: .res 1 ; $0042                    ; Current piece as an orientation ID
    .res 1
levelNumber: .res 1 ; $0044
fallTimer: .res 1 ; $0045
autorepeatX: .res 1 ; $0046
startLevel: .res 1 ; $0047
playState: .res 1 ; $0048
vramRow: .res 1 ; $0049                        ; Next playfield row to copy. Set to $20 when playfield copy is complete
completedRow: .res 4 ; $004A                    ; Row which has been cleared. 0 if none complete
autorepeatY: .res 1 ; $004E
holdDownPoints: .res 1 ; $004F
lines: .res 2 ; $0050
rowY: .res 1 ; $0052
linesBCDHigh: .res 1 ; $53
linesTileQueue: .res 1 ; $54
    .res 1
completedLines: .res 1 ; $0056
lineIndex: .res 1 ; $0057                        ; Iteration count of playState_checkForCompletedRows
.res 1
garbageHole: .res 1 ; $0059                        ; Position of hole in received garbage
garbageDelay: .res 1 ; $005A
pieceTileModifier: .res 1 ; $005B ; above $80 - use a single one, below - use an offset
curtainRow: .res 1 ; $5C
linesPrev: .res 2 ; $5D-E ; used for delayed draw at high levels
levelPrev: .res 1 ; $5F

mathRAM: .res $12
binary32 := mathRAM+$0
bcd32 := mathRAM+$4
exp := mathRAM+$8
product24 := mathRAM+$9
factorA24 := mathRAM+$C
factorB24 := mathRAM+$F
binaryTemp := mathRAM+$C
sign := mathRAM+$F
dividend := mathRAM+$4
divisor := mathRAM+$7
remainder := mathRAM+$A
pztemp := mathRAM+$D

byteSpriteAddr: .res 2
byteSpriteTile: .res 1
byteSpriteLen: .res 1

; (up to) 32 bytes menu scratch ram.  can be reused in any other mode
; can also overlap with mathram
; this is to spread out for easier thinking

; needs to be the same shape as lr* below
udPointer: .res $2
udAdjust: .res $1
udMin: .res $1
udMax: .res $1
; needs to be the same shape ud* above
lrPointer: .res $2
lrAdjust: .res $1
lrMin: .res $1
lrMax: .res $1

activeItem: .res $1
MENU_PTR_DISTANCE = lrPointer-udPointer
stringSetPtr: .res $2
.res $1

unpackedPageType: .res $1
unpackedPageValue: .res $1
unpackedItemType: .res $1
unpackedItemValue: .res $1
pageItemCount: .res 1
digitPtr: .res $2
originalPage: .res $1
nybbleTemp: .res $1
blankCounter: .res $1
rowCounter: .res $1

.res 4

actualPage: .res $1
gameStarted: .res $1
.res $1

; lr page    ; mem address never changes (activePage)
; lr column  ; mem address never changes (activeColumn)
; lr value   ; current item is set every time anyway
; ud item    ; mem address never changes (activeItem)
; ud value   ; mem address never changes (expandedDigit)


    .res $A

spriteXOffset: .res 1 ; $00A0
spriteYOffset: .res 1 ; $00A1
stringAttrib: .res 1 ; $00A2
spriteTile:
stringLength: .res 1 ; $00A3
stringIndex:
spriteIndex: .res 1 ; can probably be the same as stringIndex
renderFlags: .res 1 ; $00A5
; gameplay
; Bit 0-lines 1-level 2-score 3-debug 4-hz 6-stats 7-high score entry letter
; speedtest
; 0 - hz
; level menu
; 0-customLevel

    .res $1

gameModeState: .res 1 ; $00A7                    ; For values, see playState_checkForCompletedRows
generalCounter: .res 1 ; $00A8                    ; canon is legalScreenCounter2
generalCounter2: .res 1 ; $00A9
generalCounter3: .res 1 ; $00AA
generalCounter4: .res 1 ; $00AB
generalCounter5: .res 1 ; $00AC
positionValidTmp: .res 1 ; $00AD              ; 0-level, 1-height
originalY: .res 1 ; $00AE
dropSpeed: .res 1 ; $00AF
tmpCurrentPiece: .res 1 ; $00B0                    ; Only used as a temporary
frameCounter: .res 2 ; $00B1
frameCounterHi:= frameCounter + 1
oamStagingLength: .res 1 ; $00B3
    .res 1
newlyPressedButtons: .res 1 ; $00B5                 ; Active player's buttons
heldButtons: .res 1 ; $00B6                        ; Active player's buttons
    .res 3
allegro: .res 1 ; $00BA
pendingGarbage: .res 1 ; $00BB                    ; Garbage waiting to be delivered to the current player. This is exchanged with pendingGarbageInactivePlayer when swapping players.
    .res 1
renderMode: .res 1 ; $00BD
    .res 1
nextPiece: .res 1 ; $00BF                        ; Stored by its orientation ID
gameMode: .res 1 ; $00C0                        ; see gamemode/branch.asm
screenStage: .res 1 ; $00C1                        ; used in gameMode_waitScreen, endingAnimation
musicType: .res 1 ; $00C2                        ; 0-3; 3 is off
sleepCounter: .res 1 ; $00C3                    ;
endingSleepCounter: .res 2 ; $00C4
endingRocketCounter: .res 1 ; $00C6
endingRocketX: .res 1 ; $C7
endingRocketY: .res 1 ; $C8
gameTimer: .res 2
gameTimerStop: .res 1
    .res 2
    .res 6 ; used to be demo stuff
highScoreEntryNameOffsetForLetter: .res 1 ; $00D4   ; Relative to current row
highScoreEntryRawPos: .res 1 ; $00D5                ; High score position 0=1st type A, 1=2nd... 4=1st type B... 7=4th/extra type B
highScoreEntryNameOffsetForRow: .res 1 ; $00D6      ; Relative to start of table
highScoreEntryCurrentLetter: .res 1 ; $00D7
lineClearStatsByType: .res 7 ; $00D8                ; bcd. one entry for each of single, double, triple, tetris
hideNextPiece: .res 1 ; $00DF
AUDIOTMP1: .res 1 ; $00E0
AUDIOTMP2: .res 1 ; $00E1
AUDIOTMP3: .res 1 ; $00E2
AUDIOTMP4: .res 1 ; $00E3
AUDIOTMP5: .res 1 ; $00E4
    .res 1
musicChanTmpAddr: .res 2 ; $00E6
    .res 2
music_unused2: .res 1 ; $00EA                    ; Always 0
soundRngSeed: .res 2 ; $00EB                    ; Set, but not read
currentSoundEffectSlot: .res 1 ; $00ED              ; Temporary
musicChannelOffset: .res 1 ;  $00EE                  ; Temporary. Added to $4000-3 for MMIO
currentAudioSlot: .res 1 ; $00EF                    ; Temporary
    .res 5
newlyPressedButtons_player1: .res 1 ; $00F5         ; $80-a $40-b $20-select $10-start $08-up $04-down $02-left $01-right
newlyPressedButtons_player2: .res 1 ; $00F6
heldButtons_player1: .res 1 ; $00F7
    .res 3
joy1Location: .res 1 ; $00FB                    ; normal=0; 1 or 3 for expansion
ppuScrollY: .res 1 ; $00FC
ppuScrollX: .res 1 ; $00FD
currentPpuMask: .res 1 ; $00FE
currentPpuCtrl: .res 1 ; $00FF

.bss
stack: .res $FF ; $0100
    .res 1
oamStaging: .res $100 ; $0200                        ; format: https://wiki.nesdev.com/w/index.php/PPU_programmer_reference#OAM


; todo:  find out which need to be preserved
trtLineCounter: .res $2
trtScratch: .res $6
trtRam: .res $8
    .res $E0
statsByType: .res $E ; $03F0
    .res 2
playfield: .res $c8 ; $0400
    .res $38 ; still technically part of playfield

    .res $100 ; $500 ; 2 player playfield
.res 1
spawnDelay: .res 1 ; $601
dasValueDelay: .res 1 ; $602
dasValuePeriod: .res 1 ; $603
tspinX: .res 1 ; $604
tspinY: .res 1 ; $605
tspinQuantity := presetIndex
tspinType: .res 1 ; $606
parityIndex: .res 1 ; $607
parityCount: .res 1 ; $608
parityColor: .res 1 ; $609
saveStateDirty: .res 1 ; $60A
saveStateSlot: .res 1 ; $60B
saveStateSpriteType: .res 1 ; $60C
saveStateSpriteDelay: .res 1 ; $60D
presetIndex: .res 1 ; $60E ; can be mangled in other modes
.res 1
debugLevelEdit: .res 1 ; $610
debugNextCounter: .res 1 ; $611
paceResult: .res 3 ; $612 ; 3 bytes
paceSign: .res 1 ; $615

hzRAM: .res 9; $616
hzTapCounter := hzRAM+0
hzFrameCounter := hzRAM+1 ; 2 byte
hzDebounceCounter := hzRAM+3 ; 1 byte
hzTapDirection := hzRAM+4 ; 1 byte
hzResult := hzRAM+5 ; 2 byte
hzSpawnDelay := hzRAM+7 ; 1 byte
hzPalette := hzRAM+8 ; 1 byte
inputLogCounter := presetIndex ; reusing presetIndex
    .res 2
tqtyCurrent: .res 1 ; $621
tqtyNext: .res 1 ; $622

; hard drop ram is pretty big, but can be reused in other modes
; 23 bytes total
completedLinesCopy: .res 1 ; $623
lineOffset: .res 1 ; $624
harddropBuffer: .res $15 ; $625 ; 21 bytes (!)

linecapState: .res 1 ; $63A ; 0 if not triggered, 1 + linecapHow otherwise, reset on game init

dasOnlyShiftDisabled: .res 1 ; $63B

invisibleFlag: .res 1 ; $63C  ; 0 for normal mode, non-zero for Invisible playfield rendering.  Reset on game init and game over.
currentFloor: .res 1 ; $63D floorModifier is copied here at game init.  Set to 0 otherwise and incremented when linecap floor.
mapperId: .res 1 ; $63E ; For INES_MAPPER 1000 (autodetect).  0 = CNROM.  1 = MMC1.
hardDropGhostY: .res 1 ; $63F ; ghost Y used as a shortcut for hard/sonic drop
anydasFlag: .res 1 ; $640
seededPieces: .res 1 ; $641
killX2Flag: .res 1 ; $642
skipNormalPlayfieldRender: .res 1 ; $643

kbReadState: .res 1 ; $644 - used for high score entry
kbHeldInput: .res 1 ; $645 - high score input throttling
kbRawInput: .res 9 ; $646  - all 72 keys' input
kbInputThrottle: .res 1 ; $64F

; used to track state of high score entry screen.  Can possibly use the address of the nmi interrupted
; routine in the stack to track instead
highScoreEntryActive: .res 1  ; $650
trtLines: .res 2 ; $651 ; fix for now for transition mode/trt compat

menuStack: .res 28 ; $653

; only important in menu mode
prevGoofy: .res 1 ; $66F

topRowBuffer: .res 10 ; $670

secretGrade: .res 1 ; $67A
secretGradePending: .res 1 ; $67B
detectedRegion: .res 1 ; $67C ; set at same time as palFlag but not user configurable

linecapLinesBinHi: .res 1 ; $67D ; menu input is BCD, converted to binary and stored here
                          ; low byte is also BCD but is treated by game as BCD

.segment "MUSIC_RAM": absolute
musicStagingSq1Lo: .res 1 ; $0680
musicStagingSq1Hi: .res 1 ; $0681
audioInitialized: .res 1 ; $0682
musicPauseSoundEffectLengthCounter: .res 1
musicStagingSq2Lo: .res 1 ; $0684
musicStagingSq2Hi: .res 1 ; $0685
    .res 2
musicStagingTriLo: .res 1 ; $0688
musicStagingTriHi: .res 1 ; $0689
resetSq12ForMusic: .res 1 ; $068A                   ; 0-off. 1-sq1. 2-sq1 and sq2
musicPauseSoundEffectCounter: .res 1
musicStagingNoiseLo: .res 1 ; $068C
musicStagingNoiseHi: .res 1 ; $068D
    .res 2
musicDataNoteTableOffset: .res 1 ; $0690            ; AKA start of musicData, of size $ 0A
musicDataDurationTableOffset: .res 1 ; $0691
musicDataChanPtr: .res 8 ; $0692
musicChanControl: .res 3 ; $069A                    ; high 3 bits are for LO offset behavior. Low 5 bits index into musicChanVolControlTable, minus 1. Technically size 4, but usages of the next variable 'cheat' since that variable's first index is unused
musicChanVolume: .res 3 ; $069D                    ; Must not use first index. First and second index are unused. High nibble always used; low nibble may be used depending on control and frame
musicDataChanPtrDeref: .res 8 ; $06A0               ; deref'd musicDataChanPtr+musicDataChanPtrOff
musicDataChanPtrOff: .res 4 ; $06A8
musicDataChanInstructionOffset: .res 4 ; $06AC
musicDataChanInstructionOffsetBackup: .res 4 ; $06B0
musicChanNoteDurationRemaining: .res 4 ; $06B4
musicChanNoteDuration: .res 4 ; $06B8
musicChanProgLoopCounter: .res 4 ; $06BC            ; As driven by bytecode instructions
musicStagingSq1Sweep: .res 2 ; $06C0                ; Used as if size 4, but since Tri/Noise does nothing when written for sweep, the other two entries can have any value without changing behavior
    .res 1
musicChanNote: .res 4 ; $06C3
    .res 1
musicChanInhibit: .res 3 ; $06C8                    ; Always zero
    .res 1
musicTrack_dec: .res 1 ; $06CC                    ; $00-$09
musicChanVolFrameCounter: .res 4 ; $06CD            ; Pos 0/1 are unused
musicChanLoFrameCounter: .res 4 ; $06D1             ; Pos 3 unused
soundEffectSlot0FrameCount: .res 5 ; $06D5          ; Number of frames
soundEffectSlot0FrameCounter: .res 5 ; $06DA        ; Current frame
soundEffectSlot0SecondaryCounter: .res 1 ; $06DF    ; nibble index into noiselo_/noisevol_table
soundEffectSlot1SecondaryCounter: .res 1 ; $06E0
soundEffectSlot2SecondaryCounter: .res 1 ; $06E1
soundEffectSlot3SecondaryCounter: .res 1 ; $06E2
soundEffectSlot0TertiaryCounter: .res 1 ; $06E3
soundEffectSlot1TertiaryCounter: .res 1 ; $06E4
soundEffectSlot2TertiaryCounter: .res 1 ; $06E5
soundEffectSlot3TertiaryCounter: .res 1 ; $06E6
soundEffectSlot0Tmp: .res 1 ; $06E7
soundEffectSlot1Tmp: .res 1 ; $06E8
soundEffectSlot2Tmp: .res 1 ; $06E9
soundEffectSlot3Tmp: .res 1 ; $06EA
    .res 5
soundEffectSlot0Init: .res 1 ; $06F0                ; NOISE sound effect. 2-game over curtain. 3-ending rocket. For mapping, see soundEffectSlot0Init_table
soundEffectSlot1Init: .res 1 ; $06F1                ; SQ1 sound effect. Menu, move, rotate, clear sound effects. For mapping, see soundEffectSlot1Init_table
soundEffectSlot2Init: .res 1 ; $06F2                ; SQ2 sound effect. For mapping, see soundEffectSlot2Init_table
soundEffectSlot3Init: .res 1 ; $06F3                ; TRI sound effect. For mapping, see soundEffectSlot3Init_table
soundEffectSlot4Init: .res 1 ; $06F4                ; Unused. Assume meant for DMC sound effect. Uses some data from slot 2
musicTrack: .res 1 ; $06F5                        ; $FF turns off music. $00 continues selection. $01-$0A for new selection
    .res 2
soundEffectSlot0Playing: .res 1 ; $06F8             ; Used if init is zero
soundEffectSlot1Playing: .res 1 ; $06F9
soundEffectSlot2Playing: .res 1 ; $06FA
soundEffectSlot3Playing: .res 1 ; $06FB
soundEffectSlot4Playing: .res 1 ; $06FC
currentlyPlayingMusicTrack: .res 1 ; $06FD          ; Copied from musicTrack
    .res 2


.segment "SCORE_RAM": absolute
highscores: ; $700
; scores are name - score - lines - startlevel - level
highScoreQuantity := 3
highScoreNameLength := 8
highScoreScoreLength := 4
highScoreLinesLength := 2
highScoreLevelsLength := 2
highScoreLength := highScoreNameLength + highScoreScoreLength + highScoreLinesLength + highScoreLevelsLength
    .res highScoreQuantity * highScoreLength ; 48 bytes
    .res 43
initMagic: .res 5 ; $075B                        ; Initialized to a hard-coded number. When resetting, if not correct number then it knows this is a cold boot


.segment "VARS_RAM": absolute
menuRAM:  ; $760
menuMoveThrottle: .res 1
menuThrottleTmp: .res 1
levelControlMode: .res 1
classicLevel: .res 1
heartsAndReady: .res 1   ; high nybble used for ready
practiseType: .res 1
customLevel: .res 1

; menu
activeMenu: .res 1
activePage: .res 1
activeRow: .res 1
activeColumn: .res 1
menuStackPtr: .res 1

menuVars:
.include "menu/menuram.asm"
sramVariableLength := * - menuVars
menuRAMLength = * - menuRAM


; ... $7FF
