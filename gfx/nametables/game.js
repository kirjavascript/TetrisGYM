const {
    readStripe,
    writeRLE,
    printNT,
    drawTiles,
    drawAttrs,
    flatLookup,
} = require('./nametables');

const buffer = readStripe(__dirname + '/game_nametable.bin');

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
############æß##
###############
`);

printNT(buffer, lookup);

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
#a ###000 d#          #qwwwwwwe#
#a        d#          #a  ß  æd#
#zxxxxxxxxc############zxxxxxxc#
################################
################################
################################
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
`,`
    3220032222233333
    3220032222233333
    3220032222233333
    3220032222233333
    3220032222231113
    3333333333333333
    3333333333333333
    3333333333333333
`]);

writeRLE(
    __dirname + '/game_nametable_practise.bin',
    buffer,
);
