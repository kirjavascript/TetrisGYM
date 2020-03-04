.zeropage
tmp1:	.res 1	; $0000
.exportzp tmp1
tmp2:	.res 1	; $0001
.exportzp tmp2
tmp3:	.res 1	; $0002
.exportzp tmp3
.res 20
rng_seed:	.res 2	; $0017
.exportzp rng_seed
spawnID:	.res 1	; $0019
.exportzp spawnID
spawnCount:	.res 1	; $001A
.exportzp spawnCount
.res 24
verticalBlankingInterval:	.res 1	; $0033
.exportzp verticalBlankingInterval
.res 12
tetriminoX:	.res 1	; $0040
.exportzp tetriminoX
tetriminoY:	.res 1	; $0041
.exportzp tetriminoY
currentPiece:	.res 1	; $0042
.exportzp currentPiece
.res 1
levelNumber:	.res 1	; $0044
.exportzp levelNumber
fallTimer:	.res 1	; $0045
.exportzp fallTimer
autorepeatX:	.res 1	; $0046
.exportzp autorepeatX
startLevel:	.res 1	; $0047
.exportzp startLevel
playState:	.res 1	; $0048
.exportzp playState
vramRow:	.res 1	; $0049
.exportzp vramRow
completedRow:	.res 4	; $004A
.exportzp completedRow
autorepeatY:	.res 1	; $004E
.exportzp autorepeatY
holdDownPoints:	.res 1	; $004F
.exportzp holdDownPoints
lines:	.res 2	; $0050
.exportzp lines
rowY:	.res 1	; $0052
.exportzp rowY
score:	.res 3	; $0053
.exportzp score
completedLines:	.res 1	; $0056
.exportzp completedLines
lineIndex:	.res 1	; $0057
.exportzp lineIndex
curtainRow:	.res 1	; $0058
.exportzp curtainRow
startHeight:	.res 1	; $0059
.exportzp startHeight
garbageHole:	.res 1	; $005A
.exportzp garbageHole
.res 5
player1_tetriminoX:	.res 1	; $0060
.exportzp player1_tetriminoX
player1_tetriminoY:	.res 1	; $0061
.exportzp player1_tetriminoY
player1_currentPiece:	.res 1	; $0062
.exportzp player1_currentPiece
.res 1
player1_levelNumber:	.res 1	; $0064
.exportzp player1_levelNumber
player1_fallTimer:	.res 1	; $0065
.exportzp player1_fallTimer
player1_autorepeatX:	.res 1	; $0066
.exportzp player1_autorepeatX
player1_startLevel:	.res 1	; $0067
.exportzp player1_startLevel
player1_playState:	.res 1	; $0068
.exportzp player1_playState
player1_vramRow:	.res 1	; $0069
.exportzp player1_vramRow
player1_completedRow:	.res 4	; $006A
.exportzp player1_completedRow
player1_autorepeatY:	.res 1	; $006E
.exportzp player1_autorepeatY
player1_holdDownPoints:	.res 1	; $006F
.exportzp player1_holdDownPoints
player1_lines:	.res 2	; $0070
.exportzp player1_lines
player1_rowY:	.res 1	; $0072
.exportzp player1_rowY
player1_score:	.res 3	; $0073
.exportzp player1_score
player1_completedLines:	.res 1	; $0076
.exportzp player1_completedLines
.res 1
player1_curtainRow:	.res 1	; $0078
.exportzp player1_curtainRow
player1_startHeight:	.res 1	; $0079
.exportzp player1_startHeight
player1_garbageHole:	.res 1	; $007A
.exportzp player1_garbageHole
.res 5
player2_tetriminoX:	.res 1	; $0080
.exportzp player2_tetriminoX
player2_tetriminoY:	.res 1	; $0081
.exportzp player2_tetriminoY
player2_currentPiece:	.res 1	; $0082
.exportzp player2_currentPiece
.res 1
player2_levelNumber:	.res 1	; $0084
.exportzp player2_levelNumber
player2_fallTimer:	.res 1	; $0085
.exportzp player2_fallTimer
player2_autorepeatX:	.res 1	; $0086
.exportzp player2_autorepeatX
player2_startLevel:	.res 1	; $0087
.exportzp player2_startLevel
player2_playState:	.res 1	; $0088
.exportzp player2_playState
player2_vramRow:	.res 1	; $0089
.exportzp player2_vramRow
player2_completedRow:	.res 4	; $008A
.exportzp player2_completedRow
player2_autorepeatY:	.res 1	; $008E
.exportzp player2_autorepeatY
player2_holdDownPoints:	.res 1	; $008F
.exportzp player2_holdDownPoints
player2_lines:	.res 2	; $0090
.exportzp player2_lines
player2_rowY:	.res 1	; $0092
.exportzp player2_rowY
player2_score:	.res 3	; $0093
.exportzp player2_score
player2_completedLines:	.res 1	; $0096
.exportzp player2_completedLines
.res 1
player2_curtainRow:	.res 1	; $0098
.exportzp player2_curtainRow
player2_startHeight:	.res 1	; $0099
.exportzp player2_startHeight
player2_garbageHole:	.res 1	; $009A
.exportzp player2_garbageHole
.res 5
spriteXOffset:	.res 1	; $00A0
.exportzp spriteXOffset
spriteYOffset:	.res 1	; $00A1
.exportzp spriteYOffset
spriteIndexInOamContentLookup:	.res 1	; $00A2
.exportzp spriteIndexInOamContentLookup
.res 3
nextPiece_2player:	.res 1	; $00A6
.exportzp nextPiece_2player
verticalBlankingWaitRequested_andSomethingElse:	.res 1	; $00A7
.exportzp verticalBlankingWaitRequested_andSomethingElse
generalCounter:	.res 1	; $00A8
.exportzp generalCounter
generalCounter2:	.res 1	; $00A9
.exportzp generalCounter2
generalCounter3:	.res 1	; $00AA
.exportzp generalCounter3
generalCounter4:	.res 1	; $00AB
.exportzp generalCounter4
generalCounter5:	.res 1	; $00AC
.exportzp generalCounter5
selectingLevelOrHeight:	.res 1	; $00AD
.exportzp selectingLevelOrHeight
originalY:	.res 1	; $00AE
.exportzp originalY
dropSpeed:	.res 1	; $00AF
.exportzp dropSpeed
.res 1
frameCounter:	.res 2	; $00B1
.exportzp frameCounter
oamStagingLength:	.res 1	; $00B3
.exportzp oamStagingLength
.res 1
newlyPressedButtons_mirror:	.res 1	; $00B5
.exportzp newlyPressedButtons_mirror
pressedButtons_mirror:	.res 1	; $00B6
.exportzp pressedButtons_mirror
activePlayer:	.res 1	; $00B7
.exportzp activePlayer
playfieldAddr:	.res 2	; $00B8
.exportzp playfieldAddr
.res 1
totalGarbageInactivePlayer:	.res 1	; $00BB
.exportzp totalGarbageInactivePlayer
totalGarbage:	.res 1	; $00BC
.exportzp totalGarbage
renderMode:	.res 1	; $00BD
.exportzp renderMode
numberOfPlayers:	.res 1	; $00BE
.exportzp numberOfPlayers
nextPiece:	.res 1	; $00BF
.exportzp nextPiece
gameMode:	.res 1	; $00C0
.exportzp gameMode
gameType:	.res 1	; $00C1
.exportzp gameType
musicType:	.res 1	; $00C2
.exportzp musicType
sleepCounter:	.res 1	; $00C3
.exportzp sleepCounter
ending:	.res 1	; $00C4
.exportzp ending
.res 9
heldButtons:	.res 1	; $00CE
.exportzp heldButtons
repeats:	.res 1	; $00CF
.exportzp repeats
.res 1
demoButtonsTable_index:	.res 1	; $00D1
.exportzp demoButtonsTable_index
demoButtonsTable_indexOverflowed:	.res 1	; $00D2
.exportzp demoButtonsTable_indexOverflowed
demoIndex:	.res 1	; $00D3
.exportzp demoIndex
highScoreEntryNameOffsetForLetter:	.res 1	; $00D4
.exportzp highScoreEntryNameOffsetForLetter
highScoreEntryRawPos:	.res 1	; $00D5
.exportzp highScoreEntryRawPos
highScoreEntryNameOffsetForRow:	.res 1	; $00D6
.exportzp highScoreEntryNameOffsetForRow
highScoreEntryCurrentLetter:	.res 1	; $00D7
.exportzp highScoreEntryCurrentLetter
.res 7
displayNextPiece:	.res 1	; $00DF
.exportzp displayNextPiece
AUDIOTMP1:	.res 1	; $00E0
.exportzp AUDIOTMP1
AUDIOTMP2:	.res 1	; $00E1
.exportzp AUDIOTMP2
AUDIOTMP3:	.res 1	; $00E2
.exportzp AUDIOTMP3
AUDIOTMP4:	.res 1	; $00E3
.exportzp AUDIOTMP4
AUDIOTMP5:	.res 1	; $00E4
.exportzp AUDIOTMP5
.res 1
musicChanTmpAddr:	.res 2	; $00E6
.exportzp musicChanTmpAddr
.res 5
currentSoundEffectSlot:	.res 1	; $00ED
.exportzp currentSoundEffectSlot
musicChannelOffset:	.res 1	; $00EE
.exportzp musicChannelOffset
currentAudioSlot:	.res 1	; $00EF
.exportzp currentAudioSlot
.res 5
newlyPressedButtons:	.res 1	; $00F5
.exportzp newlyPressedButtons
pressedButtons:	.res 1	; $00F6
.exportzp pressedButtons
getHeldButtons:	.res 1	; $00F7
.exportzp getHeldButtons
.res 3
joy1Location:	.res 1	; $00FB
.exportzp joy1Location
.res 2
currentPpuMask:	.res 1	; $00FE
.exportzp currentPpuMask
currentPpuCtrl:	.res 1	; $00FF
.exportzp currentPpuCtrl

.bss
stack:	.res $FF	; $0100
.export stack
.res 1
oamStaging:	.res $100	; $0200
.export oamStaging
.res 240
statsByType:	.res $0E	; $03F0
.export statsByType
.res 2
playfield:	.res $C8	; $0400
.export playfield
.res 56
playfieldForSecondPlayer:	.res $C8	; $0500
.export playfieldForSecondPlayer
.res 184
musicStagingSq1Lo:	.res 1	; $0680
.export musicStagingSq1Lo
musicStagingSq1Hi:	.res 1	; $0681
.export musicStagingSq1Hi
audioInitialized:	.res 1	; $0682
.export audioInitialized
.res 1
musicStagingSq2Lo:	.res 1	; $0684
.export musicStagingSq2Lo
musicStagingSq2Hi:	.res 1	; $0685
.export musicStagingSq2Hi
.res 2
musicStagingTriLo:	.res 1	; $0688
.export musicStagingTriLo
musicStagingTriHi:	.res 1	; $0689
.export musicStagingTriHi
resetSq12ForMusic:	.res 1	; $068A
.export resetSq12ForMusic
.res 1
musicStagingNoiseLo:	.res 1	; $068C
.export musicStagingNoiseLo
musicStagingNoiseHi:	.res 1	; $068D
.export musicStagingNoiseHi
.res 2
musicDataNoteTableOffset:	.res 1	; $0690
.export musicDataNoteTableOffset
musicDataDurationTableOffset:	.res 1	; $0691
.export musicDataDurationTableOffset
musicDataChanPtr:	.res $08	; $0692
.export musicDataChanPtr
musicChanControl:	.res $03	; $069A
.export musicChanControl
musicChanVolume:	.res $03	; $069D
.export musicChanVolume
musicDataChanPtrDeref:	.res $08	; $06A0
.export musicDataChanPtrDeref
musicDataChanPtrOff:	.res $04	; $06A8
.export musicDataChanPtrOff
musicDataChanInstructionOffset:	.res $04	; $06AC
.export musicDataChanInstructionOffset
musicDataChanInstructionOffsetBackup:	.res $04	; $06B0
.export musicDataChanInstructionOffsetBackup
musicChanNoteDurationRemaining:	.res $04	; $06B4
.export musicChanNoteDurationRemaining
musicChanNoteDuration:	.res $04	; $06B8
.export musicChanNoteDuration
musicChanProgLoopCounter:	.res $04	; $06BC
.export musicChanProgLoopCounter
musicStagingSq1Sweep:	.res $02	; $06C0
.export musicStagingSq1Sweep
.res 6
musicChanInhibit:	.res $03	; $06C8
.export musicChanInhibit
.res 1
musicTrack_dec:	.res 1	; $06CC
.export musicTrack_dec
musicChanVolFrameCounter:	.res $04	; $06CD
.export musicChanVolFrameCounter
musicChanLoFrameCounter:	.res $04	; $06D1
.export musicChanLoFrameCounter
soundEffectSlot0FrameCount:	.res 5	; $06D5
.export soundEffectSlot0FrameCount
soundEffectSlot0FrameCounter:	.res 5	; $06DA
.export soundEffectSlot0FrameCounter
soundEffectSlot0SecondaryCounter:	.res 1	; $06DF
.export soundEffectSlot0SecondaryCounter
soundEffectSlot1SecondaryCounter:	.res 1	; $06E0
.export soundEffectSlot1SecondaryCounter
soundEffectSlot2SecondaryCounter:	.res 1	; $06E1
.export soundEffectSlot2SecondaryCounter
soundEffectSlot3SecondaryCounter:	.res 1	; $06E2
.export soundEffectSlot3SecondaryCounter
soundEffectSlot0TertiaryCounter:	.res 1	; $06E3
.export soundEffectSlot0TertiaryCounter
soundEffectSlot1TertiaryCounter:	.res 1	; $06E4
.export soundEffectSlot1TertiaryCounter
soundEffectSlot2TertiaryCounter:	.res 1	; $06E5
.export soundEffectSlot2TertiaryCounter
soundEffectSlot3TertiaryCounter:	.res 1	; $06E6
.export soundEffectSlot3TertiaryCounter
soundEffectSlot0Tmp:	.res 1	; $06E7
.export soundEffectSlot0Tmp
soundEffectSlot1Tmp:	.res 1	; $06E8
.export soundEffectSlot1Tmp
soundEffectSlot2Tmp:	.res 1	; $06E9
.export soundEffectSlot2Tmp
soundEffectSlot3Tmp:	.res 1	; $06EA
.export soundEffectSlot3Tmp
.res 5
soundEffectSlot0Init:	.res 1	; $06F0
.export soundEffectSlot0Init
soundEffectSlot1Init:	.res 1	; $06F1
.export soundEffectSlot1Init
soundEffectSlot2Init:	.res 1	; $06F2
.export soundEffectSlot2Init
soundEffectSlot3Init:	.res 1	; $06F3
.export soundEffectSlot3Init
soundEffectSlot4Init:	.res 1	; $06F4
.export soundEffectSlot4Init
musicTrack:	.res 1	; $06F5
.export musicTrack
.res 2
soundEffectSlot0Playing:	.res 1	; $06F8
.export soundEffectSlot0Playing
soundEffectSlot1Playing:	.res 1	; $06F9
.export soundEffectSlot1Playing
soundEffectSlot2Playing:	.res 1	; $06FA
.export soundEffectSlot2Playing
soundEffectSlot3Playing:	.res 1	; $06FB
.export soundEffectSlot3Playing
soundEffectSlot4Playing:	.res 1	; $06FC
.export soundEffectSlot4Playing
currentlyPlayingMusicTrack:	.res 1	; $06FD
.export currentlyPlayingMusicTrack
.res 2
highScoreNames:	.res $30	; $0700
.export highScoreNames
highScoreScoresA:	.res $C	; $0730
.export highScoreScoresA
highScoreScoresB:	.res $C	; $073C
.export highScoreScoresB
highScoreLevels:	.res $08	; $0748
.export highScoreLevels
initMagic:	.res $05	; $0750
.export initMagic