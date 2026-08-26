MENU_VARS_HI = >menuVars
MENU_VARS_PAGE = menuVars & $FF00

GAME_ACTIVE = $FF

NORAM = $00

MENU_TITLE_PPU = $2106
MENU_STRIPE_WIDTH = 20
MENU_ROWS = 17

CURSOR_SLEEP_1 = 33
CURSOR_SLEEP_2 = 44

; custom routines
.enum
RESET_DEFAULTS
CLEAR_SCOREBOARD
LOAD_VANILLA
LOAD_PRIDE
LOAD_WHITE
LOAD_BUGGED
.endenum

menuDataStart:
.include "menudata.asm"
.out .sprintf("Menu data: %d", *-menuDataStart)

; table of first items instead
; + table of item counts

VALUE_MASK = %00011111
TYPE_MASK = %11100000

; tttnnnnn
TYPE_CUSTOM = %00000000  ; n = custom routine
TYPE_NUMBER = %00100000  ; n = limit
TYPE_CHOICES = %01000000 ; n = wordlist index
TYPE_FF_OFF = %01100000  ; n = limit

TYPE_UNUSED = %10000000
TYPE_GAMEMODE = %10100000 ; n = mode
TYPE_DIGIT = %11000000
TYPE_SUBMENU = %11100000 ; n = menu index


BCD_MASK = $10
TYPE_BCD = TYPE_DIGIT | BCD_MASK
TYPE_HEX = TYPE_DIGIT
DIGIT_VALUE_MASK = $F

sleepToggle = tetriminoY

menuCode:

menuStackPush:
    ldx menuStackPtr
    sta menuStack,x
    inc menuStackPtr
    rts

menuStackPop:
    dec menuStackPtr
    ldx menuStackPtr
    lda menuStack,x
    rts

gameMode_gameTypeMenu:
.if NO_MENU
    inc gameMode
    rts
.endif
    jsr hideSpritesAndBackground
    stagePatchThenWaitForNmi titlePalette

    ldx #RLE_NT_GAME_MENU
    jsr copyRleNametableToPpu

.if INES_MAPPER <> 0
    lda #CHRBankSet0
    jsr changeCHRBanks
.endif

; reenable display
    jsr resetScroll
    lda #NMIEnable
    sta currentPpuCtrl
    lda #RENDER_QUEUE
    sta renderMode
    jsr showSpriteAndBackground

    lda #MENU_VARS_HI
    sta byteSpriteAddr+1
    lda #0
    sta byteSpriteTile
    sta vramRow
    sta gameStarted
    sta sleepCounter
    sta sleepToggle
    jsr makeNotReady

; check to see if returning from level menu or game
    ldy activeMenu
    iny
    bne @initMenu
    jsr exitSubmenuNoSfx
    jmp gameTypeLoop
@initMenu:
    lda #0
    sta menuStackPtr
    jsr enterMenu

gameTypeLoop:
    lda gameStarted
    beq @noGame
    jsr checkIfSeeded
    lda #0
    sta killX2Flag
    lda practiseType
    cmp #MODE_SPEED_TEST
    bne @notSpeedTest
    lda #GAMEMODE_SPEEDTEST
    sta gameMode
    bne @sfx
@notSpeedTest:
    lda practiseType  ; is already in A, but this is explicit
    cmp #MODE_KILLX2
    bne @notKillX2
    lda #RENDER_IDLE
    sta renderMode
    lda #0
    sta gameModeState
    lda #39
    sta levelNumber
    lda #1
    sta killX2Flag
    inc gameMode
@notKillX2:
    lda practiseType
    cmp #MODE_CALIBRATE
    bne @notCalibrate
    lda #0
    sta levelNumber
    lda #GAMEMODE_CALIBRATE
    sta gameMode
    bne @sfx
@notCalibrate:
    inc gameMode
@sfx:
    lda #$2
    sta soundEffectSlot1Init
    rts
@noGame:
    ; todo: write down which vars are used by which func
    jsr collectControllerInput
    jsr setScratch
    jsr randomizeSeed
    jsr addInputs
    jsr checkGoofy
    jsr respondToInput
    jsr stageCursor
    ; scratch is not important anymore
    jsr stageVRAMRow
    jsr stageVRAMRow
    jsr stageVRAMRow
    jsr stageVRAMRow
    jsr stageVRAMRow
    jsr stageVRAMRow
    lda goofyFlag
    sta prevGoofy
gameTypeLoopWait:
    jsr updateAudioWaitForNmiAndResetOamStaging
    jmp gameTypeLoop


enterSubMenu:
    ldy #$02
    sty soundEffectSlot1Init
    pha
    lda #$FF
    sta vramRow
    lda activeRow
    jsr menuStackPush
    lda activePage
    jsr menuStackPush
    lda activeMenu
    jsr menuStackPush
    pla
enterMenu:
    sta activeMenu
    cmp #GAME_ACTIVE
    bne @normalMenu
    rts
@normalMenu:
    lda #0
enterPage:
    sta activePage
    sta originalPage
    ldy activeMenu
    clc
    adc startPageByMenu,y
    sta actualPage
    jsr setItemCount
    lda #$FF
    sta vramRow
    ldx actualPage
    lda pageTypes,x
    and #VALUE_MASK
    sta unpackedPageValue
    beq @noStorePractiseType
    sta practiseType

@noStorePractiseType:
    lda pageTypes,x
    and #TYPE_MASK
    sta unpackedPageType

    ldy activeMenu
    lda pageCountByMenu,y
    ldy #$00
    sty activeColumn
    cmp #$1
    beq @storeRow
    dey ; start at page select row for multipage
    ; dec unpackedPageType ; hack for now
@storeRow:
    sty activeRow

setScratch:
    ldx actualPage
    lda activeRow
    clc
    adc startItemByPage,x
    sta activeItem
    tax
    lda itemTypes,x
    tay
    and #VALUE_MASK
    sta unpackedItemValue

    tya
    and #TYPE_MASK
    sta unpackedItemType

    jsr setupLR
    jmp setupUD

exitSubmenu:
    ldy #$02
    sty soundEffectSlot1Init

exitSubmenuNoSfx:
    jsr menuStackPop
    jsr enterMenu
    jsr menuStackPop
    jsr enterPage
    jsr menuStackPop
    sta activeRow
    jmp setScratch


setupUD:
    ldy activeColumn
    bne setupUDDigitChange

setupUDRowChange:
; ud change row 1/2 - activeColumn == 0
    ldy #$00
    lda unpackedPageType
    ldx activeMenu
    lda pageCountByMenu,x
    tax
    dex
    beq @storeMin ; no page select row for single page
    dey
@storeMin:
    sty udMin
    lda pageItemCount
    sta udMax

    lda #>activeRow
    sta udPointer+1
    lda #<activeRow
    sta udPointer

    lda udAdjust
    eor #$FF
    clc
    adc #$01
    sta udAdjust
    rts

setupUDDigitChange:
; ud change digit 2/2 - activeColumn > 0
    dey
    tya
    lsr
    tay ; y points to digit
    php ; save for later, carry clear if hi byte
    lda #$0
    sta udMin
    sta udPointer+1 ; won't work if nybbleTemp is not zeropage
    lda #<nybbleTemp
    sta udPointer
    ldx #$10
    lda unpackedItemValue
    and #BCD_MASK
    beq @storeDigitMax
    ldx #$A
@storeDigitMax:
    stx udMax
    lda #MENU_VARS_HI
    sta digitPtr+1
    ldx activeItem
    lda memoryOffsets,x

    sta digitPtr
    lda (digitPtr),y
    plp
    bcs @storeNybble

    lsr
    lsr
    lsr
    lsr
@storeNybble:
    and #$F
    sta nybbleTemp
    rts

setupLR:
    lda activeRow
    bmi setupLRPageSelect

    lda unpackedItemType
    bpl setupLRValueChange

    cmp #TYPE_DIGIT
    beq setupLRColumnChange

    lda #$00
    sta lrAdjust
    rts


setupLRPageSelect:
; setupLRPageSelect  - activeRow < 0
    lda #>activePage
    sta lrPointer+1
    lda #<activePage
    sta lrPointer
    ldy activeMenu
    lda pageCountByMenu,y
    sta lrMax
    lda #0
    sta lrMin
    rts


setupLRValueChange:
; setupLRValueChange - activeRow >= 0 && itemType < 128
    lda #MENU_VARS_HI
    sta lrPointer+1
    ldx activeItem
    lda memoryOffsets,x
    sta lrPointer
    ldy #$0
    lda unpackedItemType
    and #TYPE_MASK
    cmp #TYPE_FF_OFF
    bne @storeMin
    dey
@storeMin:
    sty lrMin
    ldx unpackedItemValue
    cmp #TYPE_CHOICES
    bne @storeMax
    txa
    asl
    tax
    lda choiceSetIndexes+1,x
    lsr
    lsr
    lsr
    tax
    inx
    inx
@storeMax:
    stx lrMax
    rts

setupLRColumnChange:
; setupLRColumnChange itemType & %10100000 == %10000000
    lda #0
    sta lrMin
    lda #>activeColumn
    sta lrPointer+1
    lda #<activeColumn
    sta lrPointer
    lda unpackedItemValue
    and #DIGIT_VALUE_MASK
    tay
    iny
    sty lrMax
    rts

setItemCount:
    asl
    tax
    lda pageIndexes+1,x
    lsr
    lsr
    lsr
    sta pageItemCount
    rts

collectControllerInput:
    lda #$00
    sta udAdjust
    sta lrAdjust
; maybe also folded saves bytes?
    lda #BUTTON_UP
    jsr menuThrottle
    beq @upNotPressed
    inc udAdjust
    rts
@upNotPressed:
    lda #BUTTON_DOWN
    jsr menuThrottle
    beq @downNotPressed
    dec udAdjust
    rts
@downNotPressed:
    lda #BUTTON_LEFT
    jsr menuThrottle
    beq @leftNotPressed
    dec lrAdjust
    rts
@leftNotPressed:
    lda #BUTTON_RIGHT
    jsr menuThrottle
    beq @rightNotPressed
    inc lrAdjust
    rts
@rightNotPressed:
    rts

checkGoofy:
    lda prevGoofy
    cmp goofyFlag
    beq checkGoofy-1

; apply goofy to held & throttle tmp
    ldx #<menuThrottleTmp
    ldy #>menuThrottleTmp
    jsr applyGoofy
    ldx #<heldButtons_player1
    ldy #>heldButtons_player1
applyGoofy:
    ; x/y = lo/hi byte of buttons
    stx tmp1
    sty tmp2
    ldy #$0
    lda (tmp1),y
    asl
    and #$AA
    sta tmp3
    lda (tmp1),y
    and #$AA
    lsr
    ora tmp3
    sta (tmp1),y
@ret:
    rts

respondToInput:
    ldy activeColumn
    beq enterNewPage
    lda udAdjust
    beq enterNewPage

rePackDigit:
    dey
    tya
    lsr
    tay
    bcs @smallDigit
    lda (digitPtr),y
    and #$0F
    sta (digitPtr),y
    lda nybbleTemp
    asl
    asl
    asl
    asl
    ora (digitPtr),y
    sta (digitPtr),y

    jmp enterNewPage

@smallDigit:
    lda (digitPtr),y
    and #$F0
    ora nybbleTemp
    sta (digitPtr),y

enterNewPage:
    lda activePage
    cmp originalPage
    beq checkIfGameStartOrSubmenu
    jmp enterPage

checkIfGameStartOrSubmenu:
    lda newlyPressedButtons_player1
    and #BUTTON_START
    bne @checkActiveRow
    jmp checkIfExitSubmenu

@checkActiveRow:
    lda activeRow
    bpl @checkItemType
    jmp checkPageMode

@checkItemType:
    lda unpackedItemType
    cmp #TYPE_GAMEMODE
    beq startGameFromItem

    cmp #TYPE_SUBMENU
    beq goToSubMenu

    cmp #TYPE_CUSTOM
    beq @goToCustom

@checkPageMode:
    jmp checkPageMode
@ret:
    rts
@goToCustom:
    lda newlyPressedButtons_player1
    and #BUTTON_START
    beq @ret
    lda #$FF
    sta vramRow
    lda #2
    sta soundEffectSlot1Init
    branchTo unpackedItemValue, \
        customResetDefaults, \
        customClearScoreboard, \
        customLoadVanilla, \
        customLoadPride, \
        customLoadWhite, \
        customLoadBugged

customLoadVanilla:
    jmp resetVanillaPalette

customLoadBugged:
    lda buggedModifier
    clc
    adc #GameColors::bugged+9
    tax
    jmp resetPaletteAtX

customLoadPride:
    ldx #GameColors::pride+9
    jmp resetPaletteAtX

customLoadWhite:
    ldx #29
    lda #$30
@loop:
    sta customLevel0,x
    dex
    bpl @loop
    rts

customResetDefaults:
    jmp resetMenuVars

customClearScoreboard:
    jmp resetScores

goToSubMenu:
    lda unpackedItemValue
    jmp enterSubMenu

startGameFromItem:
    lda unpackedItemValue
    sta practiseType
    jmp setGameStartedFlag

checkPageMode:
    lda newlyPressedButtons_player1
    and #BUTTON_START
    beq @noGame
    jmp setGameStartedFlag

@noGame:
    rts

checkIfExitSubmenu:
    lda newlyPressedButtons_player1
    and #BUTTON_B
    beq doSomethingWithSelect
    lda activeMenu
    bne @exitSubmenu
    lda activeColumn
    bne @setLeftColumn
    lda activeRow
    bpl @setTopRow
    lda activePage
    beq doSomethingWithSelect
    lda #0
    sta activePage
    beq @sfx
@setLeftColumn:
    lda #0
    sta activeColumn
    beq @sfx
@setTopRow:
    lda #$FF
    sta activeRow
@sfx:
    ldy #$02
    sty soundEffectSlot1Init
    rts
@exitSubmenu:
    jmp exitSubmenu

doSomethingWithSelect:
    ; lda selectPressed
    ; placeholder
    rts

setGameStartedFlag:
    inc gameStarted
    lda #GAME_ACTIVE
    jmp enterSubMenu


addInputs:
    ldx #0 ; upDown
    jsr @doActualAdd
    ldx #MENU_PTR_DISTANCE ; leftRight
@doActualAdd:
    lda soundEffectSlot1Init
    bne @ret ; skip leftRight if up/down input was received
    lda udAdjust,x
    beq @ret ; skip if nothing to do
    clc
    adc (udPointer,x)
    sta (udPointer,x)
    ldy udMax,x
    beq @sfx ; 0 means unlimited.  expected values 2-31
    cmp udMax,x
    beq @rollToMin
    clc
    adc #$1
    cmp udMin,x
    bne @sfx
    ldy udMax,x
    dey
    tya
    bne @storeDigit
@rollToMin:
    lda udMin,x
@storeDigit:
    sta (udPointer,x)
@sfx:
    lda #$FF
    sta vramRow
    inc soundEffectSlot1Init
    jsr copyVarsToSram
@ret:
    rts

randomizeSeed:
; only start shuffling on newly pressed, continue on held
    lda #BUTTON_SELECT
    jsr menuThrottle
    beq @ret
; b_seed is not important until a b_type game is started
; shuffling here keeps it out of sync with rng_seed
    ldx #b_seed
    jsr generateNextPseudorandomNumber
    rol tmp1 ; save carry

; only care about seed inputs
    ldy activeItem
    ldx memoryOffsets,y
    cpx #<b_seed_input
    beq @b_seed
    cpx #<set_seed_input
    bne @ret
    ldy #2
    bne @resetVramRow
@b_seed:
    ldy #1

@resetVramRow:
    lda #0
    sta vramRow

; shuffle
    lda #1
    sta soundEffectSlot1Init
; do stupid math to rng & framecounter, store in tmp1/2/3
    lsr tmp1 ; restore saved carry
    lda b_seed+1
    adc frameCounter
    sta tmp2
    lda rng_seed
    sbc frameCounter+1
    sta tmp1
    lda rng_seed+1
    adc b_seed
    sta tmp3

; copy 2 or 3 bytes depending on seed size
@loop:
    lda tmp1,y
    sta MENU_VARS_PAGE,x
    inx
    dey
    bpl @loop
@ret:
    rts

stageCustomPalette:
    inc vramRow
    lda activeRow
    bpl @mod10
    lda #8
@mod10:
    cmp #$A
    bcc @stage
    sbc #$A
    bcs @mod10
@stage:
    tay
    ldx renderQueuePointer
    lda #$3F
    sta stack,x
    inx
    lda #$01
    sta stack,x
    inx
    lda #$2
    sta stack,x
    inx
    lda multBy3,y
    tay
    lda activeMenu
    cmp #SUBMENU_CUSTOMPALETTE
    beq @noHide
    lda #$0F
    sta stack,x
    sta stack+1,x
    sta stack+2,x
    bne @end
@noHide:
    lda customLevel0,y
    sta stack,x
    iny
    lda customLevel0,y
    sta stack+1,x
    iny
    lda customLevel0,y
    sta stack+2,x
@end:
    inx
    inx
    inx
    stx renderQueuePointer
    inc renderQueueLength
    rts

stageVRAMRow:
    lda vramRow   ; use OG game logic & values
    bmi stageCustomPalette
    cmp #$20
    bne @stage
@ret:
    rts
@stage:

    @blankCounter = blankCounter
    @rowCounter = rowCounter
    @stringPtr = stringSetPtr
    @itemPtr = generalCounter
    @padding = generalCounter5

    lda #MENU_STRIPE_WIDTH
    sta @blankCounter
    ldx activeMenu

    lda actualPage
    jsr setItemCount
    lda actualPage
    asl
    tax
    lda pageIndexes,x
    clc
    adc #<pageLabels
    sta @itemPtr
    lda pageIndexes+1,x
    and #$7
    adc #>pageLabels
    sta @itemPtr+1

    ldx actualPage
    lda pageTypes,x
    lsr
    lsr
    lsr
    lsr
    lsr
    sta @padding

    lda vramRow
    asl
    tay

    ldx renderQueuePointer
    lda menuVramRowTable+1,y
    sta stack,x
    inx
    lda menuVramRowTable,y
    sta stack,x
    inx
    lda #MENU_STRIPE_WIDTH-1
    sta stack,x
    inx

@loop:
    lda pageItemCount
    cmp vramRow
    bcc @fillBlank

    lda (@itemPtr),y
    clc
    adc #<strTable
    php
    sta @stringPtr
    iny
    lda (@itemPtr),y
    lsr
    lsr
    lsr
    lsr
    sta stringLength
    lda (@itemPtr),y
    and #$F
    plp
    adc #>strTable
    sta @stringPtr+1

; padding goes here
    lda vramRow
    bne @startString
    lda #$FF
@pad:
    dec @padding
    bmi @startString
    sta stack,x
    dec @blankCounter
    inx
    bne @pad
@startString:

    ldy #0
@copy:
    lda (@stringPtr),y
    sta stack,x
    iny
    inx
    dec blankCounter
    dec stringLength
    bpl @copy
@fillBlank: ; should only be entered directly when end of string reached
    dec @blankCounter
    bmi @finish
    lda #$FF
    sta stack,x
    inx
    bne @fillBlank ; always taken
@finish:
    inc renderQueueLength
    stx renderQueuePointer

    lda vramRow
    beq @noValue
    lda pageItemCount
    cmp vramRow
    bcc @noValue

    txa
    sec
    sbc #8
    sta renderQueuePointer
    jsr stageCurrentValue


@noValue:
    inc vramRow
    lda vramRow
    cmp #MENU_ROWS
    bne @ret2
    lda #$20
    sta vramRow
@ret2:
    rts

stageCurrentValue:
    ldx actualPage
    lda startItemByPage,x
    clc
    adc vramRow
    sec
    sbc #1
    tay
    sty activeItem
    lda memoryOffsets,y
    sta byteSpriteAddr
    lda #MENU_VARS_HI
    sta byteSpriteAddr+1
    lda itemTypes,y
    tax
    ldy #0
    and #TYPE_MASK
    cmp #TYPE_CUSTOM
    bne @notCustom
    jmp @ret
@notCustom:
    sta unpackedItemType
    bmi @digitInputOrEdge

    cmp #TYPE_CHOICES
    beq @drawString

    cmp #TYPE_NUMBER
    bne @drawFFOff
@setupOneByte:
    lda #$02
    bne @drawOneByte

@drawFFOff:
    lda (byteSpriteAddr),y
    bpl @setupOneByte
    ldx #CHOICESET_OFFON
    jsr @setStringList
    jmp @startCopy

@drawString:
    txa
    and #%11111
    tax
    jsr @setStringList
    lda (byteSpriteAddr),y
    asl
    tay
@startCopy:
    lda (stringSetPtr),y
    clc
    adc #<strTable
    pha
    php
    iny
    lda (stringSetPtr),y
    lsr
    lsr
    lsr
    lsr
    clc
    adc #1
    sta generalCounter
    lda (stringSetPtr),y
    and #$F
    plp
    adc #>strTable
    sta stringSetPtr+1
    pla
    sta stringSetPtr
    lda generalCounter
    jsr setStackOffset

    ldy #0
@nextChar:
    lda (stringSetPtr),y
    sta stack,x
    inx
    iny
    dec generalCounter
    bne @nextChar

@endCopy:
    jmp @ret

@setStringList:
    txa
    asl
    tax
    lda choiceSetIndexes,x
    clc
    adc #<choiceSets
    sta stringSetPtr
    lda choiceSetIndexes+1,x
    and #$7
    adc #>choiceSets
    sta stringSetPtr+1
    rts

@digitInputOrEdge:
    and #TYPE_MASK
    cmp #TYPE_GAMEMODE
    beq @ret
    cmp #TYPE_SUBMENU
    beq @ret
    txa
    and #DIGIT_VALUE_MASK
@drawOneByte:
    pha
    sec
    sbc #1
    lsr
    clc
    adc #$1
    sta generalCounter
    pla
    jsr setStackOffset

    ldy #$00
    sty generalCounter2

; skip decimal if 2 digit hex/bcd
    lda unpackedItemType
    cmp #TYPE_DIGIT
    beq @digitLoop

; decimal conversion if 2 digit hex
    lda generalCounter
    cmp #1
    bne @digitLoop
    lda (byteSpriteAddr),y
    cmp #100
    bcc @bcd
    inc generalCounter2
    tay
    lda #1
    sta stack-1,x
    tya
    sbc #100
    cmp #100
    bcc @bcd
    sbc #100
    inc stack-1,x
@bcd:
    tay
    lda levelDisplayTable,y
    ldy generalCounter2
    bne @oneDigit ; if at least 100, draw 0 in 10s
    cmp #10
    bcs @oneDigit

    ; skip 10s
    inx
    bne @lowNybble

@digitLoop: ; y is zero
    lda (byteSpriteAddr),y
@oneDigit:
    pha
    lsr
    lsr
    lsr
    lsr
    sta stack,x
    inx
    pla
@lowNybble:
    and #$0F
    sta stack,x
    inx
    iny
    dec generalCounter
    bne @digitLoop
@ret:

    lda renderQueuePointer
    clc
    adc #8
    sta renderQueuePointer
    rts

setStackOffset:
    eor #$FF
    clc
    adc #$09
    clc
    adc renderQueuePointer
    tax
    rts

menuVramRowTable:
; 17 for now (title + 16 items)
    .addr $2109
.repeat 16,i
    .addr $2146+(i*32)
.endrepeat

stageCursor:
    lda seedEnabled
    beq @noSeed
    lda set_seed_input
    bne @notZeroSeed
    lda set_seed_input+1
    and #$FE
    bne @notZeroSeed
    lda #SPRITE_SEED_INVALID
    jmp @storeSeedSprite
@notZeroSeed:
    lda set_seed_input+2
    and #$F0
    beq @v5Seed
    lda #SPRITE_SEED_V4
    jmp @storeSeedSprite
@v5Seed:
    lda #SPRITE_SEED_V5
@storeSeedSprite:
    sta spriteIndex
@stageSeedVer:
    lda #$D4
    sta spriteYOffset
    lda #$C8
    sta spriteXOffset
    jsr loadSpriteIntoOamStaging
@noSeed:
    ldx activeMenu
    lda pageCountByMenu,x
    cmp #$1
    beq @singlePage
    ldx oamStagingLength
    sta oamStaging+9,x
    lda #$4F
    sta oamStaging+5,x

    lda #$CB
    sta oamStaging+0,x
    sta oamStaging+4,x
    sta oamStaging+8,x

    lda #$C8
    sta oamStaging+3,x
    clc
    adc #$08
    sta oamStaging+7,x
    adc #$08
    sta oamStaging+11,x

    lda #$00
    sta oamStaging+2,x
    sta oamStaging+6,x
    sta oamStaging+10,x

    ldy activePage
    iny
    tya
    sta oamStaging+1,x
    txa
    clc
    adc #$C
    sta oamStagingLength

@singlePage:

    lda activeRow
    bpl @notTitle

    lda #$3F
    sta spriteYOffset
    lda #$10
    sta spriteXOffset
    lda #SPRITE_MENUPAGESELECTA
    sta spriteIndex
    jmp @stage

@notTitle:
    asl
    asl
    asl
    clc
    adc #$4F
    sta spriteYOffset
; digit input
    ldx activeColumn
    beq @notColumn
    txa
    asl
    asl
    asl
    clc
    adc #$B9
    sta spriteXOffset
    ldx activeItem
    lda itemTypes,x
    and #DIGIT_VALUE_MASK
    sec
    sbc #1
    lsr
    asl
    asl
    asl
    asl
    eor #$FF
    sec
    adc spriteXOffset
    sta spriteXOffset
    lda #SPRITE_SEEDCURSORA  ; digit select
    bne @store
@notColumn:
    lda #$1A
    sta spriteXOffset

; this code is redundant
    ldx activeMenu
    lda startPageByMenu,x
    clc
    adc activePage
    tax
    lda activeRow
    clc
    adc startItemByPage,x
    tax
    lda itemTypes,x

    and #TYPE_MASK
    cmp #TYPE_CUSTOM
    beq @noValue
    cmp #TYPE_SUBMENU
    beq @noValue
    cmp #TYPE_GAMEMODE
    beq @noValue
    lda #SPRITE_PRACTISETYPECURSORA  ; option select
@store:
    sta spriteIndex
@stage:
    lda sleepCounter
    bne @noToggle
    lda sleepToggle
    eor #1
    sta sleepToggle
    beq @sleep1
    lda #CURSOR_SLEEP_2
    bne @storeSleep
@sleep1:
    lda #CURSOR_SLEEP_1
@storeSleep:
    sta sleepCounter
@noToggle:
    lda sleepToggle
    clc
    adc spriteIndex
    sta spriteIndex
@noFrameAdjust:
    jmp loadSpriteIntoOamStaging
@noValue:
    lda #SPRITE_MENUSTARTA
    sta spriteIndex
    jmp @stage
gotoEdgeCase:
    rts

.out .sprintf("menu code: %d", *-menuCode)
.out .sprintf("menu total: %d", *-menuDataStart)
