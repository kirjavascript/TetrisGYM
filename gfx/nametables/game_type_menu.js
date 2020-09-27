const { readFileSync, writeFileSync } = require('fs');

const buffer = readFileSync(__dirname + '/game_type_menu_nametable.bin');

let lookup = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-.\'>################qweadzxc###############/##!###########()############################################################################################################################################################### ';

lookup = [...lookup].map((d, i) => d === '#' ? String.fromCharCode(9472 + i) : d).join``

const chars = [...buffer].map(value => lookup[value] || '__NOWAYNOWAY');

console.log(chars.join('').match(/.{35}/g).join('\n'));

const tiles = `
W0W################################
WWW####qwwwwwwwwwwwwwwwwwwwwwwe####
W#W#qwwaTETRIS GYM (PROTOTYPE)dwwe#
W#W#a  zxxxxxxxxxxxxxxxxxxxxxxc  d#
W#W#a                            d#
W#W#a                            d#
W#W#a                            d#
W#W#a                            d#
X0W#a                            d#
XWW#a                            d#
X#W#a                            d#
X#W#a   PLAY                     d#
X#W#a   LEVEL 29                 d#
X#W#a   T-SPINS                  d#
X#W#a   SETUPS                   d#
X#W#a   FLOOR                    d#
Y0W#a   TAP                      d#
YWW#a   DROUGHT                  d#
Y#W#a   DEBUG MODE               d#
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
Z◀W▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
Z◠W▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
`;
const practise = Buffer.from(buffer);
[...tiles.trim().split('\n').join('')].forEach((d, i) => {
    // TODO: patch logo
    if (d !== '#') {
        practise[i] = lookup.indexOf(d);
    }
});
writeFileSync(__dirname + '/game_type_menu_nametable_practise.bin', practise);
