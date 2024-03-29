const {
    writeRLE,
    blankNT,
    drawTiles,
    drawAttrs,
    flatLookup,
} = require('./nametables');

const buffer = blankNT();

const lookup = flatLookup(`
0123456789ABCDEF
GHIJKLMNOPQRSTUV
WXYZ-+!>˙^()#.##
########qweadzxc
################
################
################
################
################
################
################
################
################
################
################
###############
`);

drawTiles(buffer, lookup, `
################################
################################
###########qwwwwwwwwwweqwwwwwwe#
##qwwwwwwe#a LINES-000da      d#
##a      d#zxxxxxxxxxxcaTOP   d#
##zxxxxxxc#############a      d#
############          #a      d#
############          #aSCORE d#
#qwwwwwwwwe#          #a000000d#
#a########d#          #a      d#
#a        d#          #zxxxxxxc#
#a ###    d#          ##########
#a ###000 d#          ##########
#a ###    d#          ##NEXT####
#a ###000 d#          ##    ####
#a ##     d#          ##    ####
#a ###000 d#          ##    ####
#a ##     d#          ##    ####
#a ## 000 d#          ##########
#a ###    d#          #qwwwwwe##
#a ###000 d#          #aLEVELd##
#a ###    d#          #a     d##
#a ###000 d#          #zxxxxxc##
#a        d#          ##########
#a ###000 d#          ##########
#a        d#          ##########
#zxxxxxxxxc#####################
################################
################################
################################
`);

drawTiles(buffer, lookup, `
ɺɧɷɷɲɹɺɸɵɺɧɷɸʃɸʃɷʇɧɸɳʇɰɱɧʇɸɵɺɲɺɧ
ɲʃʇɷʇɧɸɳʇɲʃʇɸɹɹɺʇɸʄɺʂɺʀʁʂɹɺʇɸʃɸʅ
ʇɲɺʇɸʄɺʂɺʇɧ####################ʇ
ɧɷ########ɷ####################ɧ
ɷʇ########ɷ####################ɷ
ʀɺ########ʇȰȱȱȱȱȱȱȱȱȱȱȲ########ɷ
ɸɹɹɺɧɰɱɧɸɹɳȳ##########ȴ########ʇ
ɹɺɸɹʃʀʁʂɹɺʇȳ##########ȴ########ɧ
ɳ##########ȳ##########ȴ########ʂ
ɷ#ɩɪɫɬɭɮɯɟ#ȳ##########ȴ########ɧ
ʇ##########ȳ##########ȴ########ɷ
ɺ##ɀɁɂ#####ȳ##########ȴɸɹɹɺɸɹɳɸʃ
ɺ##ɐɑɒ#####ȳ##########ȴȰȱȱȱȱȲʇɧɸ
ɺ##ɉɊɋ#####ȳ##########ȴȳ####ȴɲʃɸ
ɧ##əɚɛ#####ȳ##########ȴȳ####ȴʇɲɺ
ɷ##Ɇɇ######ȳ##########ȴȳ####ȴɸʃɰ
ɷ##ɖɗɘ#####ȳ##########ȴȳ####ȴɲɺʀ
ʇ##ɠɡ######ȳ##########ȴȳ####ȴɷɸɳ
ɱ##ɢɣ######ȳ##########ȴȵȶȶȶȶȷʇɧɷ
ʁ##ɃɄɅ#####ȳ##########ȴ#######ɷʇ
ɺ##ɓɔɕ#####ȳ##########ȴ#######ɷɸ
ɺ##ɌɍɎ#####ȳ##########ȴ#######ʇɧ
ɧ##ɜɝɞ#####ȳ##########ȴ#######ɸʅ
ʃ##########ȳ##########ȴɧɸɵɺɧɲɹɺʇ
ɳ##ɤɥɦ#####ȳ##########ȴɴɺʇɸʅʇɧɸɹ
ɷ##########ȳ##########ȴʇɸɹɳʇɲʃɲɺ
ʇ##########ȵȶȶȶȶȶȶȶȶȶȶȷɧɰɱʇɧʇɸʃɧ
ɧɧɸɵɺɲɹɺɧɸɳɸɳɧɲɺɲɹɺɸɹɹɺɷʀʁɸʅɧɸɹʃ
ɷʂɳʇɧʇɧɲʃɧʂɺɷɷɷɧʇɧɰɱɲɺɧʀɺɸɳʇɷɸɹɹ
ʀɺʇɸʄɺɷʇɸʄɺɧʇɷʇɷɲʃʀʁɷɧʂɹɺɧɷɸʃɲɺɧ
`);

drawAttrs(buffer, [`
    3333333333333333
    3333333333333333
    3333333333333333
    3333332222233333
    3333332222233333
    3220032222233333
    3220032222233333
    3220032222233333
`, `
    3220032222233333
    3220032222233333
    3220032222233333
    3220032222233333
    3220032222233333
    3333333333333333
    3333333333333333
    0000000000000000
`]);

writeRLE(
    __dirname + '/game_nametable_practise.bin',
    buffer,
);
