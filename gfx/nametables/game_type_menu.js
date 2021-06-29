const { readFileSync, writeFileSync } = require('fs');
const { strip, konamiComp } = require('./rle');

const bin = readFileSync(__dirname + '/game_type_menu_nametable.bin');
const buffer = strip(bin);

let lookup = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-,\'>################qweadzxc###############/##!#########[]()###############.############################################################################################################################################### ';

const chars = [...buffer].map(value => lookup[value] || '__NOWAYNOWAY');

console.log(chars.join('').match(/.{32}/g).join('\n'));

const tiles = `
################################
#########qwwwwwwwwwwwwe#########
#qwwwwwww]            [wwwwwwwe#
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
#a    FLOOR                   d#
#a    (QUICK)TAP              d#
#a    GARBAGE                 d#
#a    DROUGHT                 d#
#a    INPUT DISPLAY           d#
#a    DEBUG MODE              d#
#a    PAL MODE                d#
#a                            d#
#a                            d#
#a                            d#
#a                            d#
#a                            d#
#a                            d#
#zxxxxxxxxxxxxxxxxxxxxxxxxxxxxc#
################################
################################
`;

// tiles
const practise = Buffer.from(buffer);
[...tiles.trim().split('\n').join('')].forEach((d, i) => {
    if (d !== '#') {
        practise[i] = lookup.indexOf(d);
    }
});

const drawTiles = (x, y, w, h, offset) => {
    x += 3;
    const pixel = x+ (y*32);
    for (let i=0;w>i;i++) {
        for (let j=0;h>j;j++) {
            practise[pixel + i + (j * 32)] = offset+i + (j * 0x10);
        }
    }
}

drawTiles(8, 2, 10, 5, 0xB0); // draw logo
drawTiles(22, 22, 5, 5, 0x9A); // draw QR code

// palettes
// DR - DL - UR - UL
const palettes = p => p.trim().match(/.+\n.+$/gm)
    .flatMap(line=>(
        [t,b]=line.split('\n'),
        t.trim().match(r=/../g).map((d,i)=>d+b.trim().match(r)[i])
    ))
    .map(d=>+('0b'+[...d].reverse().map(d=>(+d).toString(2).padStart(2,0)).join``));

[
    [30 * 32, palettes(`
        2222222222222222
        2222211111122222
        2222211111122222
        2222211111122222
        2222222222222222
        2222222222222222
        2222222222222222
        2222222222222222
    `)],
    [31 * 32, palettes(`
        2222222222222222
        2222222222222222
        2222222222222222
        2222222222222222
        2333222222222222
        2222222222222222
        2222222222222222
        2222222222222222
    `)],
].forEach(([index, attributes]) => {
    attributes.forEach((byte, i) => { practise[i+index] = byte; });
});

const compressed = Buffer.from(konamiComp(Array.from(practise)));

console.log(`compressed ${bin.length} -> ${compressed.length}`);

writeFileSync(
    __dirname + '/game_type_menu_nametable_practise.bin',
    compressed,
);
