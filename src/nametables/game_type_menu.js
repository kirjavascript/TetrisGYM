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
ɢa                            dɳ
ɲa                            dɢ
ɲa                            dɲ
ʂa                            dʡ
ʀa                            dɢ
ɢa                            dɂ
ɀa                            dʂ
ʂa                            dɢ
ʀa                            dɂ
ʐa    TETRIS                  dʂ
ɲa    T-SPINS                 dɡ
ʂa    SEED                    dɲ
ɢa    STACKING                dʂ
ɲa    PACE                    dʃ
ʠa    SETUPS                  dɡ
ɠa    B-TYPE                  dʂ
ɰa    FLOOR                   dʃ
ʁa    CRUNCH                  dʁ
ɡa    (QUICK)TAP              dʃ
ʂa    TRANSITION              dɢ
ɳa    MARATHON                dʠ
ʃa    TAP QUANTITY            dɳ
ɡa    CHECKERBOARD            dɡ
ɱa    GARBAGE                 dʂ
ɡa    DROUGHT                 dɡ
ʂa    DAS DELAY               dɱ
ɢa    KILLSCREEN »2           dʁ
ɲa    INVISIBLE               dɢ
ɲa    HARD DROP               dɲ
ʂa    TAP/ROLL SPEED          dʡ
`);drawTiles(extra, lookup, `
ɢa    SCORING                 dɳ
ɲa    CRASH                   dɢ
ɲa    HZ DISPLAY              dɲ
ʂa    INPUT DISPLAY           dʡ
ʀa    DISABLE FLASH           dɢ
ɢa    DISABLE PAUSE           dɂ
ɀa    GOOFY FOOT              dʂ
ʂa    BLOCK TOOL              dɢ
ʀa    LINECAP                 dɂ
ʐa    DAS ONLY                dʂ
ɲa    QUAL MODE               dɡ
ʂa    PAL MODE                dɲ
ɢa                            dʂ
ɲa                            dʃ
ʠa V5                         dɡ
ɠa                            dʂ
ɰa                            dʃ
ʁa                            dʁ
ɡa                            dʃ
ʂa                            dɢ
ɳa                            dʠ
ʃa                            dɳ
ɡa                            dɡ
ɱa                            dʂ
ɡa                            dɡ
ʂa                            dɱ
ɢa                            dʁ
ɲa                            dɢ
ɲa                            dɲ
ʂa                            dʡ
`);

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
