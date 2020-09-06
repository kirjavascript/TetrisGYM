const { readFileSync, writeFileSync } = require('fs');

const buffer = readFileSync('./game_type_menu_nametable_clean.bin');

const lookup = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-.\'>qweadzxc############################################################################################################################################################################################################### ';
console.log(lookup.length)
// [...buffer].forEach(d => console.log(d))

// TODO: conditionally insert clean

const chars = [...buffer].map(value => lookup[value] || '#');

console.log(chars.join('').match(/.{35}/g).join('\n'));
const tiles = `
W0W################################
WWW################################
W#W#qwwwwwwwwwwwwwwwwwwwwwwwwwwwwe#
W#W#a                            d#
W#W#a                            d#
W#W#a      THE PRACTISE ROM      d#
W#W#a                            d#
W#W#a                            d#
X0W#a                            d#
XWW#a                            d#
X#W#a                            d#
X#W#a    NORMAL                  d#
X#W#a    T-SPINS                 d#
X#W#a    OTHER SPIN SETUPS       d#
X#W#a    LEVEL 29 TRAINER        d#
X#W#a    ALWAYS TETRIS READY     d#
Y0W#a    DROUGHT MODIFIER        d#
YWW#a    SOMETHING ELSE          d#
Y#W#a                            d#
Y#W#a                            d#
Y#W#a                            d#
Y#W#a                            d#
Y#W#a                            d#
Y#W#a                            d#
Z0W#a                            d#
ZWW#a                            d#
Z#W#a                     KIRJAVAd#
Z#W#zxxxxxxxxxxxxxxxxxxxxxxxxxxxxc#
Z#W################################
Z#W################################
Z#W#AAA################PAA#Y000####
Z#W###000#####000#####000##AAAAAAAA
`;
[...tiles.trim().split('\n').join('')].forEach((d, i) => {
    if (d !== '#') {
        buffer[i] = lookup.indexOf(d);
    }
});
writeFileSync('./game_type_menu_nametable.bin', buffer);
