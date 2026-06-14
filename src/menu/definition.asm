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
