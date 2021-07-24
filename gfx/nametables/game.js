const {
    readStripe,
    writeRLE,
    printNT,
    drawTiles,
    flatLookup,
} = require('./nametables');

const buffer = readStripe(__dirname + '/game_nametable.bin');

const lookup = flatLookup(`
0123456789ABCDEF
GHIJKLMNOPQRSTUV
WXYZ-.˙>!^()####
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
#a ###    d#          ##########
#a ###    d#          ##NEXT####
#a ###    d#          ##    ####
#a ##     d#          ##    ####
#a ###    d#          ##    ####
#a ##     d#          ##    ####
#a ##     d#          ##########
#a ###    d#          #qwwwwwe##
#a ###    d#          #aLEVELd##
#a ###    d#          #a     d##
#a ###    d#          #zxxxxxc##
#a        d#          ##########
#a ###    d#          ##########
#a        d#          ##########
#zxxxxxxxxc#####################
################################
################################
################################
`);

writeRLE(
    __dirname + '/game_nametable_practise.bin',
    buffer,
);
