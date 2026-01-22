keymap = """
CloseBracket OpenBracket RETURN  F8        STOP    Yen     SHIFTRight   KANA
Semicolon    Colon       atSign  F7        Caret   Dash    Slash        Underscore
K            L           O       F6        0       P       Comma        Period
J            U           I       F5        8       9       N            M
H            G           Y       F4        6       7       V            B
D            R           T       F3        4       5       C            F
A            S           W       F2        3       E       Z            X
CTR          Q           ESC     F1        2       1       GRPH         SHIFTLeft
Left         Right       UP      CLR_HOME  INS     DEL     Space        Down
"""

for row, keys in enumerate(keymap.strip().splitlines()):
    for mask, key in enumerate(keys.split()):
        print(f"key{key:<12} = ${((8 - row) << 3) | mask:02X}")
