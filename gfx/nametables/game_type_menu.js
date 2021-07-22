const {
    readStripe,
    writeRLE,
    printNT,
    drawTiles,
    drawRect,
    drawAttrs,
    flatLookup,
} = require('./nametables');

const lookup = flatLookup(`
0123456789ABCDEF
GHIJKLMNOPQRSTUV
WXYZ-,˙>########
########qweadzxc
###############/
##!##~######[]()
###############.
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

const buffer = readStripe(__dirname + '/game_type_menu_nametable.bin');
const extra = [...buffer];

printNT(buffer, lookup);

drawTiles(buffer, lookup, `
#a                            d#
#a                            d#
#a                            d#
#a                            d#
#a                            d#
#a                            d#
#a                            d#
#a                            d#
#a                            d#
#a    TETRIS                  d#
#a    T-SPINS                 d#
#a    SEED                    d#
#a    STACKING                d#
#a    PACE                    d#
#a    SETUPS                  d#
#a    B-TYPE                  d#
#a    FLOOR                   d#
#a    (QUICK)TAP              d#
#a    TRANSITION              d#
#a    INVISIBLE               d#
#a    HARD DROP               d#
#a    GARBAGE                 d#
#a    DROUGHT                 d#
#a    TAP/ROLL SPEED          d#
#a    HZ DISPLAY              d#
#a    INPUT DISPLAY           d#
#a    GOOFY FOOT              d#
#a    DEBUG MODE              d#
#a    PAL MODE                d#
#a                            d#
`);drawTiles(extra, lookup, `
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
`);


drawRect(buffer, 8, 2, 10, 5, 0xB0); // draw logo
// drawRect(extra, 20, 0, 5, 5, 0x9A); // draw QR code

const urlX = 1;
const urlY = 16;
drawRect(extra, urlX, urlY, 12, 1, 0x74);
drawRect(extra, urlX+12, urlY, 12, 1, 0x84);

drawAttrs(buffer, [`
    2222222222222222
    2222211111122222
    2222211111122222
    2222211111122222
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

const line = '2'.repeat(16);
const screen = Array.from({ length: 8 }, () => line).join('\n');
drawAttrs(extra, [screen, screen]);

writeRLE(
    __dirname + '/game_type_menu_nametable_practise.bin',
    buffer,
);

writeRLE(
    __dirname + '/game_type_menu_nametable_extra.bin',
    extra,
);
