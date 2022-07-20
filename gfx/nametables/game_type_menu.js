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
#########»#####.
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
#a    CTWC DAS 2022           d#
#a                            d#
#a    WORLD CHAMPION          d#
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
#a    TAP QUANTITY            d#
#a    CHECKERBOARD            d#
#a    GARBAGE                 d#
#a    DROUGHT                 d#
#a    DAS DELAY               d#
#a    KILLSCREEN »2           d#
#a    INVISIBLE               d#
#a    HARD DROP               d#
#a    TAP/ROLL SPEED          d#
#a    SCORING                 d#
#a    HZ DISPLAY              d#
`);drawTiles(extra, lookup, `
#a    INPUT DISPLAY           d#
#a    DISABLE FLASH           d#
#a    GOOFY FOOT              d#
#a    BLOCK TOOL              d#
#a    QUAL MODE               d#
#a    PAL MODE                d#
#a    DAS ONLY                d#
#a                            d#
#a                            d#
#a V5                         d#
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


drawRect(buffer, 19, 2, 7, 7, 0x92); // draw logo
// drawRect(extra, 20, 0, 5, 5, 0x9A); // draw QR code

const urlX = 3;
const urlY = 9;
drawRect(extra, urlX, urlY, 12, 1, 0x74);
drawRect(extra, urlX+12, urlY, 12, 1, 0x84);

drawAttrs(buffer, [`
    2222222222222222
    2222222222111112
    2222222222111112
    2211111111111112
    2222222222111112
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
drawAttrs(extra, [`
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
    2333333333333332
    2222222222222222
    2222222222222222
    2222222222222222
`, screen]);

writeRLE(
    __dirname + '/game_type_menu_nametable_practise.bin',
    buffer,
);

writeRLE(
    __dirname + '/game_type_menu_nametable_extra.bin',
    extra,
);
