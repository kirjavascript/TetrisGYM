; to do
; get into game
; do arbitrary action
; get back into menu from game or level menu
; get back into menu from game w/block tool on
; each title associated with action
; more sanity checks
; set defaults
; save/restore to/from sram


AUTO_MENU_VARS_HI = >autoMenuVars

; valid background chars are 0-253
EOL = $FE
EOF = $FF
NORAM = $00

MENU_TITLE_PPU = $2106
MENU_STRIPE_WIDTH = 20
MENU_ROWS = 9
MENU_STACK = $DF ; $01C8 - $01DF intended range

MODE_DEFAULT = 0 ; needs to be auto generated

menuDataStart:
.include "menudata.asm"
.out .sprintf("Menu data: %d", *-menuDataStart)

; tttnnnnnn n = mode
PAGE_DEFAULT = %00000000

; table of first items instead
; + table of item counts

VALUE_MASK = %00011111
TYPE_MASK = %11100000

; tttnnnnn
TYPE_UNUSED = %00000000
TYPE_NUMBER = %00100000  ; n = limit
TYPE_CHOICES = %01000000 ; n = wordlist index
TYPE_FF_OFF = %01100000  ; n = limit

TYPE_HEX = %10000000 ; n = digits
TYPE_MODE_ONLY = %10100000 ; n = mode
TYPE_BCD = %11000000 ; n = digits, v bit to differentiate from hex
TYPE_SUBMENU = %11100000 ; n = menu index

DIGIT_MASK = %10100000
DIGIT_COMPARE = %10000000



gameMode_gameTypeMenu:
.if NO_MENU
    inc gameMode
    rts
.endif
    jsr updateAudioWaitForNmiAndDisablePpuRendering
    jsr disableNmi
    jsr bulkCopyToPpu
    .addr title_palette
    jsr copyRleNametableToPpu
    .addr game_type_menu_nametable
.if INES_MAPPER <> 0
    lda #CHRBankSet0
    jsr changeCHRBanks
.endif
    lda #NMIEnable
    sta currentPpuCtrl
    jsr waitForVBlankAndEnableNmi
    jsr updateAudioWaitForNmiAndResetOamStaging
    jsr updateAudioWaitForNmiAndEnablePpuRendering
    jsr updateAudioWaitForNmiAndResetOamStaging

    lda #AUTO_MENU_VARS_HI
    sta byteSpriteAddr+1
    lda #$1
    sta renderMode
    lda #0
    sta hideNextPiece
    sta byteSpriteTile
    sta gameStarted
    jsr makeNotReady

; check to see if returning from level menu or game
    ldy activeMenu
    iny
    bne @initMenu
    jsr exitSubmenuNoSfx
    jmp gameTypeLoop
@initMenu:
    lda #MENU_STACK
    sta menuStackPtr
    lda #0
    jsr enterMenu

gameTypeLoop:
    lda gameStarted
    beq @noGame
    inc gameMode
    lda #$2
    sta soundEffectSlot1Init
    rts
@noGame:
    ; todo: write down which vars are used by which func
    jsr collectControllerInput
    jsr setScratch
    jsr addInputs
    jsr respondToInput
    jsr stageCursor

    ; scratch is not important anymore
    jsr stageBackgroundTiles
    jsr stageCurrentValues
gameTypeLoopWait:
    jsr updateAudioWaitForNmiAndResetOamStaging
    jmp gameTypeLoop


.out .sprintf("bg setup & loop: %d", *-gameMode_gameTypeMenu)

.macro switchToMenuStack
    tsx
    stx stackPtr
    ldx menuStackPtr
    txs
.endmacro

.macro switchToNormalStack
    tsx
    stx menuStackPtr
    ldx stackPtr
    txs
.endmacro

enterSubMenu:
    ldy #$02
    sty soundEffectSlot1Init
    pha
    switchToMenuStack
    lda activeRow
    pha
    lda activePage
    pha
    lda activeMenu
    pha
    switchToNormalStack
    pla
enterMenu:
    sta activeMenu
    tay
    iny
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
    tax

    lda pageTypes,x
    and #VALUE_MASK
    sta unpackedPageValue ; always 0 for now

    lda pageTypes,x
    and #TYPE_MASK
    sta unpackedPageType

    lda pageCountByMenu,y
    ldy #$00
    sty activeColumn
    cmp #$1
    beq @storeRow
    dey ; start at page select row for multipage
    dec unpackedPageType ; hack for now
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
    switchToMenuStack
    pla
    switchToNormalStack

    jsr enterMenu

    switchToMenuStack
    pla
    switchToNormalStack

    jsr enterPage

    switchToMenuStack
    pla
    switchToNormalStack

    sta activeRow
    jmp setScratch


setupUD:
    ldy activeColumn
    bne setupUDDigitChange

setupUDRowChange:
; ud change row 1/2 - activeColumn == 0
    ldy #$00
    lda unpackedPageType
    bpl @storeMin ; no page select row for single page
    dey
@storeMin:
    sty udMin
    ldx actualPage
    lda itemCountByPage,x
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
    lda #$10
    bit unpackedItemType ; check if bcd
    bvc @storeDigitMax
    lda #$A
@storeDigitMax:
    sta udMax

    lda #AUTO_MENU_VARS_HI
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

    and #DIGIT_MASK
    cmp #DIGIT_COMPARE
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
    lda #AUTO_MENU_VARS_HI
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
    lda choiceSetCounts,x
    tax
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
    tay
    iny
    sty lrMax
    rts


.out .sprintf("setup: %d", *-enterSubMenu)


collectControllerInput:
    lda #$00
    sta selectPressed
    sta APressed
    sta startPressed
    sta startOrAPressed
    sta BPressed
    sta udAdjust
    sta lrAdjust

    lda newlyPressedButtons_player1
    tax

    and #BUTTON_START
    beq @checkA
    inc startPressed
    inc startOrAPressed
    jmp @checkCardinals
@checkA:
    txa
    and #BUTTON_A ; do different things for these instead?
    beq @checkB
    inc APressed
    inc startOrAPressed
    jmp @checkCardinals
@checkB:
    txa
    and #BUTTON_B
    beq @checkSelect
    inc BPressed
    jmp @checkCardinals
@checkSelect:
    txa
    and #BUTTON_SELECT
    beq @checkCardinals
    inc selectPressed

@checkCardinals:


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
    lda startOrAPressed
    beq checkIfExitSubmenu

    lda activeRow
    bmi checkPageMode

    lda unpackedItemType
    cmp #TYPE_MODE_ONLY
    beq startGameFromItem

    cmp #TYPE_SUBMENU
    beq goToSubMenu
    jmp checkPageMode

goToSubMenu:
    lda unpackedItemValue
    jmp enterSubMenu

startGameFromItem:
    lda unpackedPageValue
    rts

checkPageMode:
    ; lda unpackedPageValue ; 0 right now
    lda startPressed
    beq @noGame
    jmp setGameStartedFlag

@noGame:

    rts

checkIfExitSubmenu:
    lda BPressed
    beq doSomethingWithSelect
    lda activeMenu
    beq doSomethingWithSelect
    jmp exitSubmenu


doSomethingWithSelect:
    ; lda selectPressed
    ; placeholder
    rts

setGameStartedFlag:
    inc gameStarted
    lda #$FF
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
    inc soundEffectSlot1Init
@ret:
    rts


.out .sprintf("input handling: %d", *-collectControllerInput)


stageBackgroundTiles:
; page index points to split address tables
; tables are pointers into strings
; word1,0,word2,0,word3,-1

    ldx actualPage

    @blankCounter = blankCounter
    @rowCounter = rowCounter
    @stringPtr = stringSetPtr

    lda pageLabelsLo,x
    sta @stringPtr
    lda pageLabelsHi,x
    sta @stringPtr+1

    lda #>MENU_TITLE_PPU
    sta stack
    lda #<MENU_TITLE_PPU
    sta stack+1
    lda #MENU_ROWS
    sta @rowCounter
    ldx #$2

@nextRow:
    lda #MENU_STRIPE_WIDTH
    sta @blankCounter

@loop:
    ldy #0
    lda (@stringPtr),y
    tay
    iny
    beq @fillBlank ; stop advancing pointer when $FF is reached
    inc @stringPtr
    bne @noCarry
    inc @stringPtr+1
@noCarry:
    iny
    beq @fillBlank ; $FE also blanks line but after advancing pointer
    sta stack,x
    dec @blankCounter
    inx
    bne @loop ; always taken
@fillBlank: ; should only be entered directly when end of string reached
    dec @blankCounter
    bmi @finishRow
    lda #$FF
    sta stack,x
    inx
    bne @fillBlank ; always taken

@finishRow:
; check if all rows drawn
    dec @rowCounter
    beq @shiftTitleRow

; set next row based on last row
    lda stack-((MENU_STRIPE_WIDTH+2)-1),x
    clc
    adc #$40
    sta stack+1,x
    lda stack-(MENU_STRIPE_WIDTH+2),x
    adc #$00
    sta stack,x
    inx
    inx
    bne @nextRow ; always taken
@shiftTitleRow:
; bump title row 4 tiles to the right
    lda stack+1
    eor #%1111
    sta stack+1
    rts


.out .sprintf("background staging: %d", *-stageBackgroundTiles)


stageCurrentValues:
    @counter = blankCounter
    @itemCount = rowCounter

    lda #$00
    sta @counter
    lda #AUTO_MENU_VARS_HI

    ldx actualPage
    lda startItemByPage,x

    sta activeItem
    lda itemCountByPage,x

    sta @itemCount

    lda#(MENU_STRIPE_WIDTH+2) - 8
    sta stackPtr

@memoryStageLoop:
    lda stackPtr
    clc
    adc #MENU_STRIPE_WIDTH+2
    sta stackPtr
    tax

    ldy activeItem
    lda memoryOffsets,y
    sta byteSpriteAddr
    lda #AUTO_MENU_VARS_HI
    sta byteSpriteAddr+1
    lda itemTypes,y
    tax
    ldy #0
    and #TYPE_MASK
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
    tay
@startCopy:
    lda (stringSetPtr),y
    tay
    lda choiceSetTable,y
    beq @endCopy
    sta generalCounter
    jsr setStackOffset
    iny
@nextChar:
    lda choiceSetTable,y
    sta stack,x
    inx
    iny
    dec generalCounter
    bne @nextChar

@endCopy:
    jmp @nextByte

@setStringList:
    lda choiceSetIndexes,x
    clc
    adc #<choiceSets
    sta stringSetPtr
    lda #$00
    adc #>choiceSets
    sta stringSetPtr+1
    rts

@digitInputOrEdge:
    and #TYPE_MASK
    cmp #TYPE_MODE_ONLY
    beq @nextByte
    cmp #TYPE_SUBMENU
    beq @nextByte
    txa
    and #%11111
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
@digitLoop:
    lda (byteSpriteAddr),y
    pha
    lsr
    lsr
    lsr
    lsr
    sta stack,x
    inx
    pla
    and #$0F
    sta stack,x
    inx
    iny
    dec generalCounter
    bne @digitLoop
    jmp @nextByte

@nextByte:
    inc activeItem
    inc @counter
    lda @counter
    cmp @itemCount
    beq @ret
    jmp @memoryStageLoop
@ret:
    rts

setStackOffset:
    eor #$FF
    clc
    adc #$09
    clc
    adc stackPtr
    tax
    rts


.out .sprintf("value staging: %d", *-stageCurrentValues)


stageCursor:
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
    lda #$23 ; page select
    sta spriteIndexInOamContentLookup
    jmp loadSpriteIntoOamStaging

@notTitle:
    asl
    asl
    asl
    asl
    clc
    adc #$4F
    sta spriteYOffset
; digit input
    ldx activeColumn
    beq @notColumn
    sec
    sbc #$09
    sta spriteYOffset
    txa
    asl
    asl
    asl
    clc
    adc #$B9
    sta spriteXOffset
    ldx activeItem
    lda itemTypes,x
    and #VALUE_MASK
    sec
    sbc #1
    lsr
    asl
    asl
    asl
    asl
    eor #$FF
    clc
    adc #$01
    clc
    adc spriteXOffset
    sta spriteXOffset
    lda #$1B  ; digit select
    bne @store
@notColumn:
    lda #$14
    sta spriteXOffset
    lda #$1D  ; option select
@store:
    sta spriteIndexInOamContentLookup
@stage:
    jmp loadSpriteIntoOamStaging
gotoEdgeCase:
    rts


.out .sprintf("cursor staging: %d", *-stageCursor)


render_mode_menu:
    tsx
    txa
    ldx #$ff
    txs
    tax
    ldy #MENU_ROWS
@nextRow:
    pla
    sta PPUADDR
    pla
    sta PPUADDR
    .repeat MENU_STRIPE_WIDTH
    pla
    sta PPUDATA
    .endrepeat
    dey
    bne @nextRow
    txs
    rts


.out .sprintf("render dump: %d", *-render_mode_menu)


.out .sprintf("total: %d", *-gameMode_gameTypeMenu)
