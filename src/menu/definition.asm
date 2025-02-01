.struct MenuList
        address .addr
.endstruct

.struct MenuItem
        type .byte
        textAddress .addr
        settingsAddress .word ; or data
.endstruct

.macro MENU_ITEM type, textAddress, settings
    .byte type
    .addr textAddress
    .word settings
.endmacro

.macro MENU_LENGTH start, end
    ; 256/5 = safely 50 max menu items
    .assert ((end - start) / .sizeof(MenuItem)) > 256 / .sizeof(MenuItem), error, "too many items in menu"
    .byte ((end - start) / .sizeof(MenuItem))
.endmacro

.enum
MENU_TYPE_ACTION
MENU_TYPE_BYTE
MENU_TYPE_BOOL
MENU_TYPE_SEED
.endenum

.enum
MENU_ACTION_LINECAP
.endenum

menuList:
    .addr menuMain
    ; .addr menuLinecap

menuLenghts:
    MENU_LENGTH (menuMain, menuMainEnd)
    ; MENU_LENGTH(menuLinecapStart, menuLinecapEnd)

;-- menus

menuMain:
    MENU_ITEM MENU_TYPE_ACTION, tetrisText, MENU_ACTION_LINECAP
    MENU_ITEM MENU_TYPE_BYTE, fooText, $0A14
menuMainEnd:

; -- settings

; from10To20Setting := $0A14

; -- strings

tetrisText:
    .byte $6,"TETRIS"

fooText:
    .byte $3,"FOO"
