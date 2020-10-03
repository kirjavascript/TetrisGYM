const { readFileSync, writeFileSync } = require('fs');

const buffer = readFileSync(__dirname + '/game_type_menu_nametable.bin');

let lookup = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-.\'>################qweadzxc###############/##!###########()############################################################################################################################################################### ';

lookup = [...lookup].map((d, i) => d === '#' ? String.fromCharCode(9472 + i) : d).join``

const chars = [...buffer].map(value => lookup[value] || '__NOWAYNOWAY');

console.log(chars.join('').match(/.{35}/g).join('\n'));

// const tiles = `
// W0W################################
// WWW####qwwwwwwwwwwwwwwwwwwwwwwe####
// W#W#qwwaTETRIS GYM (PROTOTYPE)dwwe#
// W#W#a  zxxxxxxxxxxxxxxxxxxxxxxc  d#
// W#W#a                            d#
// W#W#a                            d#
// W#W#a                            d#
// W#W#a                            d#
// X0W#a                            d#
// XWW#a                            d#
// X#W#a                            d#
// X#W#a   PLAY                     d#
// X#W#a   T-SPINS                  d#
// X#W#a   PARITY                   d#
// X#W#a   SETUPS                   d#
// X#W#a   FLOOR                    d#
// Y0W#a   (QUICK)TAP               d#
// YWW#a   DROUGHT                  d#
// Y#W#a   DEBUG MODE               d#
// Y#W#a                            d#
// Y#W#a                            d#
// Y#W#a                            d#
// Y#W#a                            d#
// Y#W#a                            d#
// Z0W#a                            d#
// ZWW#a                            d#
// Z#W#a                     KIRJAVAd#
// Z#W#zxxxxxxxxxxxxxxxxxxxxxxxxxxxxc#
// Z#W################################
// Z#W################################
// Z#W▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
// Z#W▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
// `;

const tiles = `
W0Wqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
WWWqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
W#Wqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
W#Wqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
W#Wqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
W#Wqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
W#Wqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
W#Wqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
X0Wqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
XWWqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
X#Wqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
X#Wqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
X#Wqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
X#Wqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
X#Wqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
X#Wqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
Y0Wqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
YWWqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
Y#Wqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
Y#Wqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
Y#Wqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
Y#Wqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
Y#Wqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
Y#Wqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
Z0Wqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
ZWWqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
Z#Wqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
Z#Wqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
Z#Wqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
Z#Wqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
`;

// tiles
const practise = Buffer.from(buffer);
[...tiles.trim().split('\n').join('')].forEach((d, i) => {
    if (d !== '#') {
        practise[i] = lookup.indexOf(d);
    }
});


// palettes
// DR - DL - UR - UL
`
AABBCCDDEEFF
AABBCCDDEEFF
GGHHIIJJKKLL
GGHHIIJJKKLL
`;
[
    [1053, [
        0b00011011, 170, 170, 170, 170, 170, 170, 0x0,
        170, 170, 170, 170, 170, 170, 170, 170,
        170, 170, 170, 170, 170, 170, 170, 170,
        170, 170, 170, 170, 170, 170, 170, 170
    ]],
   [1088, [170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170]],
].forEach(([index, attributes]) => attributes.forEach((byte, i) => { practise[i+index] = byte; }));

writeFileSync(__dirname + '/game_type_menu_nametable_practise.bin', practise);
