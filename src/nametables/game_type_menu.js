const {
    writeRLE,
    blankNT,
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

const buffer = blankNT();
const extra = [...buffer];

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
#a    CRUNCH                  d#
#a    (QUICK)TAP              d#
#a    TRANSITION              d#
#a    MARATHON                d#
#a    TAP QUANTITY            d#
#a    CHECKERBOARD            d#
#a    GARBAGE                 d#
#a    DROUGHT                 d#
#a    DAS DELAY               d#
#a    KILLSCREEN »2           d#
#a    INVISIBLE               d#
#a    HARD DROP               d#
#a    TAP/ROLL SPEED          d#
`);drawTiles(extra, lookup, `
#a    SCORING                 d#
#a    CRASH                   d#
#a    HZ DISPLAY              d#
#a    INPUT DISPLAY           d#
#a    DISABLE FLASH           d#
#a    DISABLE PAUSE           d#
#a    GOOFY FOOT              d#
#a    BLOCK TOOL              d#
#a    LINECAP                 d#
#a    DAS ONLY                d#
#a    QUAL MODE               d#
#a    PAL MODE                d#
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
`);

const background = `
ɢ##############################ɳ
ɲ##############################ɢ
ɲ##############################ɲ
ʂ##############################ʡ
ʀ##############################ɢ
ɢ##############################ɂ
ɀ##############################ʂ
ʂ##############################ɢ
ʀ##############################ɂ
ʐ##############################ʂ
ɲ##############################ɡ
ʂ##############################ɲ
ɢ##############################ʂ
ɲ##############################ʃ
ʠ##############################ɡ
ɠ##############################ʂ
ɰ##############################ʃ
ʁ##############################ʁ
ɡ##############################ʃ
ʂ##############################ɢ
ɳ##############################ʠ
ʃ##############################ɳ
ɡ##############################ɡ
ɱ##############################ʂ
ɡ##############################ɡ
ʂ##############################ɱ
ɢ##############################ʁ
ɲ##############################ɢ
ɲ##############################ɲ
ʂ##############################ʡ
`;

drawTiles(buffer, lookup, background);
drawTiles(extra, lookup, background);

drawRect(buffer, 8, 2, 10, 5, 0xB0); // draw logo

const urlX = 3;
const urlY = 14;
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
drawAttrs(extra, [`
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
    2333333333333332
`, screen]);

writeRLE(
    __dirname + '/game_type_menu_nametable_practise.bin',
    buffer,
);

writeRLE(
    __dirname + '/game_type_menu_nametable_extra.bin',
    extra,
);
