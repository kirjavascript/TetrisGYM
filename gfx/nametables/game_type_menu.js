const {
    readStripe,
    writeRLE,
    printNT,
    drawTiles,
    drawRect,
    drawAttrs,
} = require('./nametables');

const lookup = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-,\'>################qweadzxc###############/##!#########[]()###############.############################################################################################################################################### ';

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
#a    INVISIBLE               d#
#a    TRANSITION              d#
#a    GARBAGE                 d#
#a    DROUGHT                 d#
#a    INPUT DISPLAY           d#
#a    GOOFY FOOT              d#
#a    DEBUG MODE              d#
#a    PAL MODE                d#
#a                            d#
#a                            d#
#a                            d#
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
#zxxxxxxxxxxxxxxxxxxxxxxxxxxxxc#
################################
################################
`);

drawRect(buffer, 8, 2, 10, 5, 0xB0); // draw logo
// drawRect(buffer, 22, 22, 5, 5, 0x9A); // draw QR code

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
    2332222222222222
    2222222222222222
    2222222222222222
    2222222222222222
`]);

writeRLE(
    __dirname + '/game_type_menu_nametable_practise.bin',
    buffer,
);

writeRLE(
    __dirname + '/game_type_menu_nametable_extra.bin',
    extra,
);
