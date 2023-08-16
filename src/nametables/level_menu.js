const {
    readStripe,
    writeRLE,
    printNT,
    drawTiles,
    drawAttrs,
    flatLookup,
} = require('./nametables');

const buffer = readStripe(__dirname + '/level_menu_nametable.bin');

let lookup = flatLookup(`
0123456789ABCDEF
GHIJKLMNOPQRSTUV
WXYZ-,˙>rtyfhvbn
########qweadzxc
############jkl/
ui!###g@ß#####()
###########æ^$#.
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

lookup = [...lookup].map((d, i) => d === '#' ? String.fromCharCode(9472 + i) : d).join``;

printNT(buffer, lookup);

// heart

// ###a  rtutututututy         d###
// ###a  f0f1f2f3f4f^h         d###
// ###a  jbkbkbkbkbkbl         d###
//
// v4
//
// ###a  rtututututg           d###
// ###a  f0f1f2f3f4f           d###
// ###a  jbkbkbkbkbkb@         d###
// ###a  f5f6f7f8f9f$h         d###
// ###a  vbibibibibibn         d###

// v5-proto1
// #a    rtututututy             d#
// #a    f0f1f2f3f4ßbbb@         d#
// #a    jbkbkbkbkbl   h         d#
// #a    f5f6f7f8f9ßbbbn         d#
// #a    vbibibibibn             d#

drawTiles(buffer, lookup, `
################################
#qwwwwwwwwwwwwwwwwwwwwwwwwwwwwe#
#a                            d#
#a                            d#
#a                            d#
#a                            d#
#a          HIGHSCORES        d#
#a                            d#
#a                            d#
#a                            d#
#a                            d#
#a                            d#
#a                            d#
#a                            d#
#a                            d#
#a                            d#
#a                            d#
#a                      LEVEL d#
#a                            d#
#a                            d#
#a                      rttty d#
#a                      f   h d#
#a                      vbbbn d#
#a                            d#
#a                            d#
#a                            d#
#a                            d#
#a                            d#
#zxxxxxxxxxxxxxxxxxxxxxxxxxxxxc#
################################
`);

drawAttrs(buffer, [`
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
`,`
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
`]);

writeRLE(
    __dirname + '/level_menu_nametable_practise.bin',
    buffer,
);
