; TetrisGYM - A Tetris Practise ROM
;
; @author Kirjava
; @github kirjavascript/TetrisGYM
; @disassembly CelestialAmber/TetrisNESDisasm
; @information ejona86/taus

.include "charmap.asm"
.include "constants.asm"
.include "io.asm"
.include "ram.asm"
.include "chr.asm"

.setcpu "6502"

.segment    "PRG_chunk1": absolute

; incremented to reset MMC1 reg
initRam:

.include "boot.asm"

mainLoop:
        jsr branchOnGameMode
        cmp gameModeState
        bne @continue
        jsr updateAudioWaitForNmiAndResetOamStaging
@continue:
        jmp mainLoop

.include "nmi/nmi.asm"
.include "nmi/render.asm"
.include "nmi/pollcontroller.asm"

.include "highscores/data.asm"
.include "highscores/util.asm"
.include "highscores/render_menu.asm"
.include "highscores/entry_screen.asm"

.include "util/check_region.asm"
.include "util/bytesprite.asm"
.include "util/strings.asm"
.include "util/math.asm"

.include "sprites/loadsprite.asm"
.include "sprites/piece.asm"
.include "sprites/drawrect.asm"

.include "gamemode/branch.asm"
    ; -> playAndEnding
.include "gamemodestate/branch.asm"
    ; -> updatePlayer1
.include "playstate/branch.asm"

.include "data/bytebcd.asm"
.include "data/orientation.asm"
.include "data/mult.asm"

.include "palettes.asm"
.include "nametables.asm"
.include "presets/presets.asm"

; TODO: util with menuThrottle, modeText etc
; TODO: playstate/util/
; tree -P "*.asm" src


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
        cmp #EMPTY_TILE
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

updateMusicSpeed:
        ldx #$05
        lda multBy10Table,x
        tay
        ldx #$0A
@checkForBlockInRow:
        lda (playfieldAddr),y
        cmp #EMPTY_TILE
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

resetScroll:
        lda #0
        sta ppuScrollX
        sta PPUSCROLL
        sta ppuScrollY
        sta PPUSCROLL
        rts

copyCurrentScrollAndCtrlToPPU:
        lda ppuScrollX
        sta PPUSCROLL
        lda ppuScrollY
        sta PPUSCROLL
        lda currentPpuCtrl
        sta PPUCTRL
        rts

drawBlackBGPalette:
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
        RESET_MMC1
        lda #$1A
        jsr setMMC1Control
        rts

setMMC1Control:
.if INES_MAPPER = 1
        sta MMC1_Control
        lsr a
        sta MMC1_Control
        lsr a
        sta MMC1_Control
        lsr a
        sta MMC1_Control
        lsr a
        sta MMC1_Control
.endif
        rts

changeCHRBank0:
.if INES_MAPPER = 1
        sta MMC1_CHR0
        lsr a
        sta MMC1_CHR0
        lsr a
        sta MMC1_CHR0
        lsr a
        sta MMC1_CHR0
        lsr a
        sta MMC1_CHR0
.endif
        rts

changeCHRBank1:
.if INES_MAPPER = 1
        sta MMC1_CHR1
        lsr a
        sta MMC1_CHR1
        lsr a
        sta MMC1_CHR1
        lsr a
        sta MMC1_CHR1
        lsr a
        sta MMC1_CHR1
.endif
        rts

changePRGBank:
.if INES_MAPPER = 1
        sta MMC1_PRG
        lsr a
        sta MMC1_PRG
        lsr a
        sta MMC1_PRG
        lsr a
        sta MMC1_PRG
        lsr a
        sta MMC1_PRG
.endif
        rts


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
        jmp @notPressedA ; dont allow both actions to happen at once
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
        lda #EMPTY_TILE
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

; hz stuff

; hz = 60.098 * (taps - 1) / (frames - 1)
; PAL is 50.006
;
; HydrantDude explains how and why the formula works here: https://discord.com/channels/374368504465457153/405470199400235013/867156217259884574

hzDebounceThreshold := $10

hzStart: ; called in playState_spawnNextTetrimino, gameModeState_initGameState, gameMode_gameTypeMenu
        lda #0
        sta hzSpawnDelay
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
        and #BUTTON_DPAD
        cmp #BUTTON_LEFT
        beq hzTap
        lda newlyPressedButtons_player1
        and #BUTTON_DPAD
        cmp #BUTTON_RIGHT
        beq hzTap

        lda hzTapCounter
        bne @noDelayInc
        lda hzSpawnDelay
        cmp #$F
        beq @noDelayInc
        inc hzSpawnDelay
@noDelayInc:
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
@wrap:
        lda #0
        sta hzTapCounter
        sta hzFrameCounter+1
        ; 0 is the first frame (4 means 5 frames)
        sta hzFrameCounter
@within:

        ; increment taps, reset debounce
        inc hzTapCounter
        lda hzTapCounter
        cmp #$10
        bcs @wrap
        lda #0
        sta hzDebounceCounter

        lda dasOnlyFlag
        beq :+
        lda #0
        sta dasOnlyShiftDisabled

        ldx hzTapCounter
        cpx #$A
        bcs @disableShift
        lda palFlag
        beq @NTSCDASOnly
        clc
        txa
        adc #$A
        tax
@NTSCDASOnly:
        lda dasLimitLookup, x
        sta tmpZ
        lda hzFrameCounter
        cmp tmpZ
        bpl :+
@disableShift:
        lda #1
        sta dasOnlyShiftDisabled
:

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

        ldx dividend+1 ; get hz for palette
        lda hzPaletteGradient, x
        sta hzPalette

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

dasLimitLookup:
        .byte 0, 0, 4, 11, 18, 24, 30, 36, 42 , 48; , 54, 60
        .byte 0, 0, 3, 7, 12, 16, 20, 24, 28, 32 ; PAL

; Kitaru on reddit - Thankfully, the same "round-down" effect also benefits DAS speed. Whereas the NTSC DAS timings were 16f start-up and 6f period, PAL DAS timings are 12f start-up and 4f period. Accounting for framerate, this is an improvement from NTSC DAS's real-time rate of 10Hz vs. PAL's real-time rate of 12.5Hz. So, although PAL hits its max gravity at Level 19 instead of Level 29, the boosted DAS makes it a bit more survivable. PAL DAS can still be out-tapped, albeit at a slimmer margin.

hzPaletteGradient: ; goes up to B
        .byte $16, $26, $27, $28, $29, $2a, $2c, $22, $23, $24, $14, $15

; End of "PRG_chunk1" segment
.code

.segment    "PRG_chunk2": absolute

.include "data/demo.asm"
.include "audio.asm"


.if PRACTISE_MODE

practisePrepareNext:
        lda practiseType
        cmp #MODE_PACE
        bne @skipPace
        jmp prepareNextPace
@skipPace:
        cmp #MODE_GARBAGE
        bne @skipGarbo
        jmp prepareNextGarbage
@skipGarbo:
        cmp #MODE_PARITY
        bne @skipParity
        jmp prepareNextParity
@skipParity:
        cmp #MODE_TAPQTY
        bne @skipTapQuantity
        jsr prepareNextTapQuantity
@skipTapQuantity:
        rts
practiseInitGameState:
        lda practiseType
        cmp #MODE_TAPQTY
        bne @skipTapQuantity
        jsr prepareNextTapQuantity
@skipTapQuantity:
        lda practiseType
        cmp #MODE_CHECKERBOARD
        bne @skipChecker
        jsr initChecker
@skipChecker:
        rts

practiseAdvanceGame:
        lda practiseType
        cmp #MODE_TSPINS
        bne @skipTSpins
        jmp advanceGameTSpins
@skipTSpins:
        cmp #MODE_PRESETS
        bne @skipPresets
        jmp advanceGamePreset
@skipPresets:
        cmp #MODE_FLOOR
        bne @skipFloor
        jmp advanceGameFloor
@skipFloor:
        cmp #MODE_TAP
        bne @skipTap
        jmp advanceGameTap
@skipTap:
        rts

practiseGameHUD:
        lda inputDisplayFlag
        beq @noInput
        jsr controllerInputDisplay
@noInput:

        lda practiseType
        cmp #MODE_PACE
        bne @skipPace
        jsr gameHUDPace
@skipPace:

        lda practiseType
        cmp #MODE_TAPQTY
        bne @skipTapQuantity

        ldy #0
        ldx oamStagingLength
@drawQTY:
        ; taps
        tya
        asl
        asl
        asl
        adc #$34
        sta tmpY
        sta oamStaging, x
        inx
        lda tqtyCurrent, y
        cmp #5
        bmi @right0
        sbc #5
        jmp @left0
@right0:
        lda #6
        sbc tqtyCurrent, y
@left0:
        sta oamStaging, x
        inx
        lda #$02
        sta oamStaging, x
        inx
        lda #$64
        sta oamStaging, x
        inx

        ; direction
        lda tmpY
        sta oamStaging, x
        inx

        lda tqtyCurrent, y
        cmp #6
        bmi @right
        lda #$D6
        jmp @left
@right:
        lda #$D7
@left:
        sta oamStaging, x
        inx
        lda #$02
        sta oamStaging, x
        inx
        lda #$6E
        sta oamStaging, x
        inx

        ; $D6 / D7 for direction
        ; increase OAM index
        lda #$08
        clc
        adc oamStagingLength
        sta oamStagingLength
        iny
        cpy #2
        bmi @drawQTY

@skipTapQuantity:
        rts

controllerInputDisplay:
        lda #0
        sta tmp3
controllerInputDisplayX:
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
        adc tmp3
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
        rts

clearPlayfield:
        lda #EMPTY_TILE
        ldx #$C8
@loop:
        sta $0400, x
        dex
        bne @loop
        rts

prepareNextTapQuantity:
; patch in @updatePlayfieldComplete
@checkEqual:
        lda tqtyNext
        cmp tqtyCurrent
        bne @notEqual
        jsr random10
        sta tqtyNext
        jmp @checkEqual
@notEqual:

        ; playfield
        sec
        lda tapqtyModifier
        and #$F
        tax
        cpx #0
        bne @notZero
        ldx #4 ; default to four
@notZero:
        lda multBy10Table, x
        sta tmp1
        lda #$c8
        sbc tmp1
        sta tmp1 ; starting offset

        ldx #0
@drawLoop:
        lda #BLOCK_TILES
        cpx tmp1
        bcs @saveMino
        lda #EMPTY_TILE
@saveMino:
        sta playfield, x
        inx
        cpx #$c8
        bcc @drawLoop

        ; wells
        clc
        lda tmp1
        tax
@nextLoop:
        txa
        adc tqtyCurrent
        tay
        lda #EMPTY_TILE
        sta playfield, y

        txa
        adc tqtyNext
        tay
        lda #BLOCK_TILES+1
        sta playfield, y

        txa
        adc #10
        tax
        cpx #$c8
        bcc @nextLoop
        rts

initChecker:
CHECKERBOARD_TILE := BLOCK_TILES
CHECKERBOARD_FLIP := CHECKERBOARD_TILE ^ EMPTY_TILE
        lda #0
        sta vramRow
        ldx checkerModifier
        lda typeBBlankInitCountByHeightTable, x
        tax
        cpx #$C8 ; edge case for height 0
        bne @notZero
        ldx #$BE
@notZero:
        lda frameCounter
        and #1
        beq @checkerStartA
        lda #CHECKERBOARD_TILE
        bne @checkerStart
@checkerStartA:
        lda #EMPTY_TILE
@checkerStart:
        ; hydrantdude found the short way to do this
        ldy #$B
@loop:
        dey
        bne @notA
        eor #CHECKERBOARD_FLIP
        ldy #$A
@notA:  sta playfield, x
        eor #CHECKERBOARD_FLIP
        inx
        cpx #$C8
        bcc @loop
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

        jsr clearPoints

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
        jsr addPointsRaw

        ; TODO: copy score to top
        lda #$20
        sta spawnDelay
        lda #TETRIMINO_X_HIDE
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
        lda #EMPTY_TILE
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
        cpy #EMPTY_TILE
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
        cmp #EMPTY_TILE
        bne @startGapEnd
        lda playfield+1, x
        cmp #EMPTY_TILE
        beq @startGapEnd
        lda parityColor
        sta playfield+1, x
@startGapEnd:

highlightGapsOverhang:
        ldy #10

@checkHang:
        lda playfield, x
        cmp #EMPTY_TILE
        bne @checkGroup
        lda playfield-10, x
        cmp #EMPTY_TILE
        beq @checkGroup

        ; draw in red
        lda parityColor
        sta playfield-10, x

@checkGroup:
        cpy #3 ; you want the first 8
        bmi @groupNext
        ; horizontal
        lda playfield, x
        cmp #EMPTY_TILE
        beq @groupNext
        lda playfield+1, x
        cmp #EMPTY_TILE
        bne @groupNext
        lda playfield+2, x
        cmp #EMPTY_TILE
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
        cmp #EMPTY_TILE
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
        cmp #EMPTY_TILE
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
        ldy #EMPTY_TILE
        lda playfield, x
        cmp #EMPTY_TILE
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
        cmp #EMPTY_TILE
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
        cmp #EMPTY_TILE
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
        ldx #rng_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        ldx #rng_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        ldx #rng_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
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
        cmp #EMPTY_TILE
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

MMC1_PRG:
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00
        .byte   $00

; End of "PRG_chunk3" segment
.code


.segment    "VECTORS": absolute

        .addr   nmi
        .addr   reset
        .addr   irq

; End of "VECTORS" segment
.code
