const { readFileSync, writeFileSync } = require('fs');

const buffer = readFileSync(__dirname + '/game_type_menu_nametable.bin');

const lookup = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-.\'>################qweadzxc###############/##!###########()############################################################################################################################################################### ';

const chars = [...buffer].map(value => lookup[value] || '__NOWAYNOWAY');

console.log(chars.join('').match(/.{35}/g).join('\n'));

const tiles = `
W0W################################
WWW################################
W#W#qwwwwwwwwwwwwwwwwwwwwwwwwwwwwe#
W#W#aTETRIS GYM (PROTOTYPE)      d#
W#W#a                            d#
W#W#a                            d#
W#W#a                            d#
W#W#a                            d#
X0W#a                            d#
XWW#a                            d#
X#W#a                            d#
X#W#a    PLAY                    d#
X#W#a    LEVEL 29                d#
X#W#a    ALWAYS TETRIS READY     d#
X#W#a    DEBUG MODE          1   d#
X#W#a                            d#
Y0W#a                            d#
YWW#a                            d#
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
const practise = Buffer.from(buffer);
[...tiles.trim().split('\n').join('')].forEach((d, i) => {
    // TODO: patch logo
    if (d !== '#') {
        practise[i] = lookup.indexOf(d);
    }
});
writeFileSync(__dirname + '/game_type_menu_nametable_practise.bin', practise);
