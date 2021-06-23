const { readFileSync, writeFileSync } = require('fs');

const buffer = readFileSync(__dirname + '/game_type_menu_nametable.bin');

let lookup = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-,\'>################qweadzxc###############/##!#########[]()###############.############################################################################################################################################### ';

const chars = [...buffer].map(value => lookup[value] || '__NOWAYNOWAY');

console.log(chars.join('').match(/.{35}/g).join('\n'));

const tiles = `
##W################################
##W#########qwwwwwwwwwwwwe#########
##W#qwwwwwww]            [wwwwwwwe#
##W#a                            d#
##W#a                            d#
##W#a                            d#
##W#a                            d#
##W#a                            d#
##W#a   TETRIS                   d#
##W#a   T-SPINS                  d#
##W#a   SEED                     d#
##W#a   STACKING                 d#
##W#a   PACE                     d#
##W#a   SETUPS                   d#
##W#a   FLOOR                    d#
##W#a   (QUICK)TAP               d#
##W#a   GARBAGE                  d#
##W#a   DROUGHT                  d#
##W#a   INPUT DISPLAY            d#
##W#a   DEBUG MODE               d#
##W#a   PAL MODE                 d#
##W#a                            d#
##W#a                            d#
##W#a                            d#
##W#a                            d#
##W#a V4                         d#
##W#a                            d#
##W#zxxxxxxxxxxxxxxxxxxxxxxxxxxxxc#
##W################################
##W################################
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
    const pixel = x+ (y*35);
    for (let i=0;w>i;i++) {
        for (let j=0;h>j;j++) {
            practise[pixel + i + (j * 35)] = offset+i + (j * 0x10);
        }
    }
}

drawTiles(11, 2, 10, 5, 0xB0); // draw logo
drawTiles(25, 22, 5, 5, 0x9A); // draw QR code

// palettes
// DR - DL - UR - UL
const palettes = p => p.trim().match(/.+\n.+$/gm)
    .flatMap(line=>(
        [t,b]=line.split('\n'),
        t.trim().match(r=/../g).map((d,i)=>d+b.trim().match(r)[i])
    ))
    .map(d=>+('0b'+[...d].reverse().map(d=>(+d).toString(2).padStart(2,0)).join``));

[
    [1053, palettes(`
        2222222222222222
        2222211111122222
        2222211111122222
        2222211111122222
        2222222222222222
        2222222222222222
        2222222222222222
        2222222222222222
    `)],
    [1088, palettes(`
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

writeFileSync(
    __dirname + '/game_type_menu_nametable_practise.bin',
    require('./rle')(practise),
);
