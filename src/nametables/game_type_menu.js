const {
    writeRLE,
    blankNT,
    drawTiles,
    drawRect,
    drawAttrs,
    flatLookup,
} = require('./nametables');

const anydas = !!process.env['GYM_FLAGS']?.match(/-D ANYDAS=1/);

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

modes = `
TETRIS
T-SPINS
SEED
STACKING
PACE
SETUPS
B-TYPE
FLOOR
CRUNCH
(QUICK)TAP
TRANSITION
MARATHON
TAP QUANTITY
CHECKERBOARD
GARBAGE
DROUGHT
DAS DELAY
LOW STACK
KILLSCREEN »2
INVISIBLE
HARD DROP
TAP/ROLL SPEED
SCORING
CRASH
STRICT CRASH
HZ DISPLAY
INPUT DISPLAY
DISABLE FLASH
DISABLE PAUSE
DARK MODE
GOOFY FOOT
BLOCK TOOL
LINECAP
DAS ONLY
QUAL MODE
PAL MODE
`
    .trim()
    .split('\n');

if (anydas) {
    modes.splice(modes.indexOf('DAS DELAY'), 1);
    modes.splice(modes.indexOf('DAS ONLY'), 1);
    modes.push('DAS', 'ARR', 'ENTRY CHARGE');
}

const modeStartRow = 9;
const modeOffset = 6;
const modeIdx = modeStartRow * 32 + modeOffset;

const urlX = 3;
const urlY = 17;

menuScreens = [...Array(30 * 2)]
    .map(() => '#a                            d#'.split(''))
    .flat();

modes.forEach((mode, i) =>
    menuScreens.splice(i * 32 + modeIdx, mode.length, ...mode),
);

menuScreens.splice((30 + urlY) * 32 + urlX, 2, ...'V6');

drawTiles(buffer, lookup, menuScreens.splice(0, 32*30).join(''));
drawTiles(extra, lookup, menuScreens.join(''));

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

drawAttrs(extra, [`
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
`, `
    2333333333333332
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
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
