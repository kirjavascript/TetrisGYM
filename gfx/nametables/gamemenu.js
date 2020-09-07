const { readFileSync, writeFileSync } = require('fs');

const buffer = readFileSync('./game_type_menu_nametable.bin');

const lookup = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-.\'>################qweadzxc###############/##!###########()############################################################################################################################################################### ';

const chars = [...buffer].map(value => lookup[value] || '__NOWAYNOWAY');

console.log(chars.join('').match(/.{35}/g).join('\n'));

const tiles = `
W0W################################
WWW################################
W#W#qwwwwwwwwwwwwwwwwwwwwwwwwwwwwe#
W#W#a                            d#
W#W#a                            d#
W#W#a          A TETRIS          d#
W#W#a        PRACTISE ROM        d#
W#W#a                            d#
X0W#a                            d#
XWW#a                            d#
X#W#a                            d#
X#W#a    NORMAL                  d#
X#W#a    LEVEL 29                d#
X#W#a    ALWAYS TETRIS READY     d#
X#W#a    T-SPINS X               d#
X#W#a    OTHER SPIN SETUPS X     d#
Y0W#a    DROUGHT MODIFIER X      d#
YWW#a    SOMETHING ELSE X        d#
Y#W#a                            d#
Y#W#a                            d#
Y#W#a                            d#
Y#W#a                            d#
Y#W#a                            d#
Y#W#a                            d#
Z0W#a                            d#
ZWW#a                            d#
Z#W#aV1                   KIRJAVAd#
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
writeFileSync('./game_type_menu_nametable_practise.bin', buffer);
